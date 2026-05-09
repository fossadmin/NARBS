# hosts/server/hardware.nix — Server hardware configuration
{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [
    "nvme"
    "ahci"
    "usb_storage"
    "sd_mod"
    "virtio_scsi"
  ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-path";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault true;
    enableRedistributableFirmware = lib.mkDefault true;
  };

  virtualisation.docker.enable = true;
}