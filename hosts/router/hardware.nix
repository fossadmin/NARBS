# hosts/router/hardware.nix — Router hardware configuration
{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [
    "ahci"
    "usb_storage"
    "sd_mod"
  ];

  hardware = {
    enableRedistributableFirmware = lib.mkDefault true;
  };
}