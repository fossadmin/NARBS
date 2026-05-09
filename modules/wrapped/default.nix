# modules/wrapped/default.nix — NARBS wrapped programs module exports
#
# Re-exports all wrapped program modules

{ ... }: {
  imports = [
    ./kitty.nix
    ./niri.nix
    ./noctalia.nix
    ./mako.nix
    ./waybar.nix
    ./lf.nix
    ./git.nix
    ./jj.nix
    ./fish.nix
  ];
}