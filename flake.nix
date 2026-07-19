{
  description = "FetchHF: Nix helpers for fetching and prefetching Hugging Face files";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      pkgsFor = system: import nixpkgs { inherit system; };

      apiFor = system: import ./default.nix { pkgs = pkgsFor system; };

      fetchFixtureFor = system: import ./tests/fetch.nix { pkgs = pkgsFor system; };
      fetchTinyLlamaManualFor = system: import ./tests/fetch-tinyllama-manual.nix { pkgs = pkgsFor system; };
      checksFor = system: import ./tests/default.nix { pkgs = pkgsFor system; };
    in
    {
      lib = {
        mkApi = apiFor;
      };

      legacyPackages = forAllSystems (system:
        let
          api = apiFor system;
        in
        api // {
          fetchFixture = fetchFixtureFor system;
          fetchTinyLlamaManual = fetchTinyLlamaManualFor system;
          tests = checksFor system;
        });

      packages = forAllSystems (system:
        let
          api = apiFor system;
        in
        {
          default = api.prefetchHF;
          prefetchHF = api.prefetchHF;
          fetchFixture = fetchFixtureFor system;
          fetchTinyLlamaManual = fetchTinyLlamaManualFor system;
        });

      apps = forAllSystems (system:
        let
          api = apiFor system;
        in
        {
          default = {
            type = "app";
            program = "${api.prefetchHF}/bin/prefetchHF";
          };

          prefetchHF = {
            type = "app";
            program = "${api.prefetchHF}/bin/prefetchHF";
          };
        });

      checks = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          testResults = checksFor system;
        in
        {
          default = assert testResults == [];
            pkgs.runCommand "fastdownloader-tests" { } ''
              touch "$out"
            '';
        });
    };
}