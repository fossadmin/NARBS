# modules/nixos/bluetooth.nix — Bluetooth module
#
# Bluetooth configuration.
# Enable with: narbs.bluetooth.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.bluetooth;
in
{
  options.narbs.bluetooth = {
    enable = lib.mkEnableOption "NARBS Bluetooth support";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;
  };
}