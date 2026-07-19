{
  nixpkgs ? import ../nixpkgs-pin.nix,
  pkgs ? import nixpkgs { },
}:
let
  api = import ../default.nix { inherit pkgs; };
in
api.fetchHF (import ./fetch-fixture.nix)
