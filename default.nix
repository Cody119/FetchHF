{
  nixpkgs ? import ./nixpkgs-pin.nix,
  pkgs ? import nixpkgs { },
}:

import ./lib.nix {
  inherit (pkgs)
    lib
    runCommand
    writeShellApplication
    python3Packages
    cacert
    coreutils
    nix
    ;
  nixpkgsPath = pkgs.path;
}
