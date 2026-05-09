# modules/nixos/automount.nix — Auto-mount module
#
# Automatic mounting of removable media (USB, etc.).
# Enable with: narbs.automount.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.automount;
in
{
  options.narbs.automount = {
    enable = lib.mkEnableOption "NARBS automatic mounting of removable media";
  };

  config = lib.mkIf cfg.enable {
    services.devmon.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    
    environment.systemPackages = [ pkgs.udiskie ];
  };
}