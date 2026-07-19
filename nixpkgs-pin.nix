let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgs = lock.nodes.nixpkgs.locked;
in
fetchTree {
  type = "github";
  owner = nixpkgs.owner;
  repo = nixpkgs.repo;
  rev = nixpkgs.rev;
  narHash = nixpkgs.narHash;
}