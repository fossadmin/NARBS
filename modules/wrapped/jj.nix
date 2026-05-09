# modules/wrapped/jj.nix — Jujutsu (JJ) VCS
#
# Git-compatible distributed VCS.
# Enable with: narbs.wrapped.jj.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.wrapped.jj;
in
{
  options.narbs.wrapped.jj = {
    enable = lib.mkEnableOption "Jujutsu VCS";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.jujutsu ];
  };
}