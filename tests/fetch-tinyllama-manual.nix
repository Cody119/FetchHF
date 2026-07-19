let
  nixpkgs = fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/b7f4d1a81b8e3444be323a92b2d7e62473b78b12.tar.gz";
    sha256 = "sha256-aV1pCMBEHciJHwG/Mx3Pg6xeOd32qaPCAL8yjYS4KqM=";
  };

  pkgs = import nixpkgs { };

  api = import ../default.nix { inherit pkgs; };
in
api.fetchHF {
  repo = "TheBloke/Tinyllama-2-1b-miniguanaco-GGUF";
  file = "tinyllama-2-1b-miniguanaco.Q2_K.gguf";
  sha256 = "sha256-F7XYKlK3G3TOMD++F/u6ZkYtgPuLQrgGKQErWMGgtqc=";
  rev = "d1c4ea0af66f6a27786ed9dcde826d45e4d7558c";
}