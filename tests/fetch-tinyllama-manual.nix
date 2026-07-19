{
  nixpkgs ? import ../nixpkgs-pin.nix,
  pkgs ? import nixpkgs { },
}:
let
  api = import ../default.nix { inherit pkgs; };
in
api.fetchHF {
  repo = "TheBloke/Tinyllama-2-1b-miniguanaco-GGUF";
  file = "tinyllama-2-1b-miniguanaco.Q2_K.gguf";
  sha256 = "sha256-F7XYKlK3G3TOMD++F/u6ZkYtgPuLQrgGKQErWMGgtqc=";
  rev = "d1c4ea0af66f6a27786ed9dcde826d45e4d7558c";
}
