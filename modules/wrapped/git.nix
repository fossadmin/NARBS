# modules/wrapped/git.nix — Git configuration
#
# Git with user identity.
# Enable with: narbs.wrapped.git.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.wrapped.git;
in
{
  options.narbs.wrapped.git = {
    enable = lib.mkEnableOption "Git";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
    };
  };
}