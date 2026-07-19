let
  nixpkgs = fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/b7f4d1a81b8e3444be323a92b2d7e62473b78b12.tar.gz";
    sha256 = "sha256-aV1pCMBEHciJHwG/Mx3Pg6xeOd32qaPCAL8yjYS4KqM=";
  };

  pkgs = import nixpkgs { };

  api = import ../default.nix { inherit pkgs; };
in
api.fetchHF (import ./fetch-fixture.nix)