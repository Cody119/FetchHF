let
  nixpkgs = fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/b7f4d1a81b8e3444be323a92b2d7e62473b78b12.tar.gz";
    sha256 = "sha256-aV1pCMBEHciJHwG/Mx3Pg6xeOd32qaPCAL8yjYS4KqM=";
  };

  pkgs = import nixpkgs { };

  api = import ../default.nix { inherit pkgs; };
  fixture = import ./fetch-fixture.nix;
  drv = import ./fetch.nix;
in
pkgs.lib.runTests {
  derivationNameIsSanitized = {
    expr = drv.name;
    expected = "openai-community-gpt2-config-json";
  };

  flatFixedOutput = {
    expr = {
      outputHashMode = drv.outputHashMode;
      outputHashAlgo = drv.outputHashAlgo;
      outputHash = drv.outputHash;
    };
    expected = {
      outputHashMode = "flat";
      outputHashAlgo = "sha256";
      outputHash = fixture.sha256;
    };
  };

  roundTripFixtureFields = {
    expr = builtins.attrNames fixture;
    expected = [ "file" "repo" "rev" "sha256" ];
  };

  roundTripFixturePinsSmallFile = {
    expr = {
      repo = fixture.repo;
      file = fixture.file;
      rev = fixture.rev;
    };
    expected = {
      repo = "openai-community/gpt2";
      file = "config.json";
      rev = "607a30d783dfa663caf39e06633721c8d4cfcd7e";
    };
  };

  prefetchHFExported = {
    expr = builtins.isAttrs api && api ? prefetchHF;
    expected = true;
  };

  prefetchHFName = {
    expr = api.prefetchHF.name;
    expected = "prefetchHF";
  };

  prefetchHFHasMainProgram = {
    expr = api.prefetchHF.meta.mainProgram;
    expected = "prefetchHF";
  };

  prefetchHFHasDescription = {
    expr = api.prefetchHF.meta.description;
    expected = "Prefetch a single file from a Hugging Face model repo for fetchHF.";
  };

  prefetchHFPlatformsIncludeHost = {
    expr = builtins.elem pkgs.stdenv.hostPlatform.system api.prefetchHF.meta.platforms;
    expected = true;
  };
}