# modules/default.nix — NARBS module exports
#
# Re-exports NixOS modules (in nixos/), Home Manager modules (in home/),
# and wrapped programs (in wrapped/)

{ ... }: {
  imports = [
    ./nixos
    ./home
    ./wrapped
  ];
}