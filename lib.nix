{ lib
, runCommand
, writeShellApplication
, python3Packages
, cacert
, coreutils
, nix
, nixpkgsPath
}:

let
  # Exports:
  # - fetchHF: fixed-output fetcher for a single file from a Hugging Face model repo.
  # - prefetchHF: helper command that resolves a revision to a commit, computes the
  #   SRI sha256, seeds the local Nix store, and prints a fetchHF-ready attrset.
  #
  # fetchHF usage:
  #   let api = import ./default.nix {}; in
  #   api.fetchHF {
  #     repo = "openai-community/gpt2";
  #     file = "config.json";
  #     sha256 = "sha256-Da7XdJtPArj3YkDVREVR17CHEtq00K24I5xWuoI7t7Q=";
  #     rev = "607a30d783dfa663caf39e06633721c8d4cfcd7e";
  #   }
  #
  # prefetchHF usage:
  #   nix run -f . prefetchHF -- openai-community/gpt2 main config.json
  #
  # The helper prints a snippet like:
  #   {
  #     repo = "openai-community/gpt2";
  #     file = "config.json";
  #     sha256 = "sha256-...";
  #     rev = "<resolved-commit>";
  #   }
  #
  # That output can be pasted directly into fetchHF.
  storeNameFor = repo: file:
    lib.strings.sanitizeDerivationName "${repo}-${file}";

  hfCli = "${python3Packages.huggingface-hub}/bin/hf";

  hfDownloadScript = { revisionRef }: ''
    export LANG=C.UTF-8
    export LC_ALL=C.UTF-8
    export HOME="$tmp_root/home"
    mkdir -p "$HOME"

    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
    export HF_HOME="$tmp_root/home/.huggingface"
    export HF_HUB_CACHE="$tmp_root/cache"

    hf_cache="$HF_HUB_CACHE"

    mkdir -p "$hf_cache"

    download_hf_file() {
      downloaded_file="$(${hfCli} download \
        "$repo" \
        "$file" \
        --repo-type model \
        --revision "${revisionRef}" \
        --cache-dir "$hf_cache" | tail -n 1)"
    }

  '';

  fetchHF =
    { repo
    , file
    , sha256
    , rev ? "main"
    }:
    runCommand (storeNameFor repo file) {
      nativeBuildInputs = [ python3Packages.huggingface-hub ];

      # This fetcher produces a single file at $out, so flat hashing is correct.
      outputHashMode = "flat";
      outputHashAlgo = "sha256";
      outputHash = sha256;
    } ''
        set -euo pipefail

        repo="${repo}"
        file="${file}"
        rev="${rev}"
        tmp_root="$TMPDIR"

        ${hfDownloadScript { revisionRef = "$rev"; }}
        download_hf_file

        if [[ ! -e "$downloaded_file" ]]; then
          echo "hf did not produce expected file: $downloaded_file" >&2
          exit 1
        fi

        real_downloaded_file="$(readlink -f "$downloaded_file")"
        mv "$real_downloaded_file" "$out"
        chmod 0444 "$out"
      '';

  prefetchHF = writeShellApplication {
    name = "prefetchHF";
    runtimeInputs = [ coreutils nix python3Packages.huggingface-hub ];
    meta = {
      description = "Prefetch a single file from a Hugging Face model repo for fetchHF.";
      mainProgram = "prefetchHF";
      platforms = lib.platforms.unix;
    };
    text = ''
      set -euo pipefail

      if [[ $# -ne 3 ]]; then
        echo "usage: prefetchHF <repo> <revision> <file>" >&2
        exit 1
      fi

      repo="$1"
      requested_revision="$2"
      file="$3"

      tmp_root="$(mktemp -d)"
      trap 'rm -rf "$tmp_root"' EXIT

      ${hfDownloadScript { revisionRef = "$requested_revision"; }}
      download_hf_file >/dev/null

      if [[ ! -e "$downloaded_file" ]]; then
        echo "hf did not produce expected file: $downloaded_file" >&2
        exit 1
      fi

      real_downloaded_file="$(readlink -f "$downloaded_file")"
      resolved_revision="$(basename "$(dirname "$downloaded_file")")"

      sha256="$(nix hash file --sri --type sha256 "$real_downloaded_file")"

      store_name="$(RAW_NAME="$repo-$file" nix-instantiate --eval --strict --expr 'let lib = import ${nixpkgsPath}/lib; in lib.strings.sanitizeDerivationName (builtins.getEnv "RAW_NAME")' | tr -d '"')"

      named_file="$tmp_root/$store_name"
      mv "$real_downloaded_file" "$named_file"
      chmod 0444 "$named_file"

      store_path="$(nix-store --add-fixed sha256 "$named_file")"

      if [[ "$requested_revision" != "$resolved_revision" ]]; then
        echo "# requested revision: $requested_revision"
      fi
      echo "# store path: $store_path"
      cat <<EOF
      {
        repo = "''${repo}";
        file = "''${file}";
        sha256 = "''${sha256}";
        rev = "''${resolved_revision}";
      }
      EOF
    '';
  };
in
{
  inherit fetchHF prefetchHF;
}