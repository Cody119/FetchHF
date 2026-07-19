let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgs = lock.nodes.nixpkgs.locked;
in
fetchTree {
  type = "github";
  inherit (nixpkgs) owner;
  inherit (nixpkgs) repo;
  inherit (nixpkgs) rev;
  inherit (nixpkgs) narHash;
}
