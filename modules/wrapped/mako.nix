# modules/wrapped/mako.nix — Mako notification daemon
#
# Lightweight Wayland notification daemon.
# Enable with: narbs.wrapped.mako.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.wrapped.mako;
in
{
  options.narbs.wrapped.mako = {
    enable = lib.mkEnableOption "Mako notification daemon";
    
    fontSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 11;
      description = "Notification font size";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Mako config file
    environment.etc."mako/config".text = ''
      # Tokyo Night Theme
      background=#1a1b26
      foreground=#c0caf5
      border=#24283b
      
      # Urgency colors
      [urgency=low]
      background=#1a1b26
      foreground=#565f89
      
      [urgency=normal]
      background=#1a1b26
      foreground=#c0caf5
      
      [urgency=critical]
      background=#f7768e
      foreground=#1a1b26
      border=#f7768e
      
      # Font
      font=JetBrainsMono Nerd Font ${toString cfg.fontSize}
      
      # Style
      border-size=1
      border-radius=8
      padding=12
      margin=10
      
      # Behavior
      default-timeout=5000
      sort=urgency
      anchor=top-right
    '';
    
    # Mako package
    environment.systemPackages = [ pkgs.mako ];
  };
}
