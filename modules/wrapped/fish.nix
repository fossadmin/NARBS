# modules/wrapped/fish.nix — Fish shell
#
# Friendly interactive shell.
# Enable with: narbs.wrapped.fish.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.wrapped.fish;
in
{
  options.narbs.wrapped.fish = {
    enable = lib.mkEnableOption "Fish shell";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.fish pkgs.zoxide ];
  };
}