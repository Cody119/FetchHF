# FetchHF

Small Nix helpers for fetching a single file from a Hugging Face model repository and for prefetching the fixed-output hash needed to pin it.

The flake and non-flake entrypoints share the same resolved `nixpkgs` pin via `flake.lock`; `default.nix` reads that lock for its default `pkgs` import.

## Common commands

Run the prefetch helper on a small fixture:

```sh
nix run -f . prefetchHF -- openai-community/gpt2 main config.json
```

Flake equivalent:

```sh
nix run .#prefetchHF -- openai-community/gpt2 main config.json
```

Run the automated tests:

```sh
nix-build tests/default.nix
```

Flake equivalent:

```sh
nix flake check
```

Build the small automated fetch fixture directly:

```sh
nix-build tests/fetch.nix
```

Flake equivalent:

```sh
nix build .#fetchFixture
```

Run the larger manual TinyLlama smoke test:

```sh
nix-build tests/fetch-tinyllama-manual.nix
```

Flake equivalent:

```sh
nix build .#fetchTinyLlamaManual
```

## Usage example

First prefetch the file you want to pin:

```sh
nix run -f . prefetchHF -- openai-community/gpt2 main config.json
```

With flakes enabled:

```sh
nix run .#prefetchHF -- openai-community/gpt2 main config.json
```

That prints an attrset you can use with `fetchHF`:

```nix
let
  api = import ./default.nix {};
in
api.fetchHF {
  repo = "openai-community/gpt2";
  file = "config.json";
  sha256 = "sha256-Da7XdJtPArj3YkDVREVR17CHEtq00K24I5xWuoI7t7Q=";
  rev = "607a30d783dfa663caf39e06633721c8d4cfcd7e";
}
```

## Test fixtures

The automated fixture uses the small `openai-community/gpt2` `config.json` file in `tests/fetch-fixture.nix`.

The larger TinyLlama GGUF file remains available in `tests/fetch-tinyllama-manual.nix` as a manual smoke test.