# hosts/workstation/hardware.nix — Workstation hardware configuration
{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-path";

  # Use open-source NVIDIA driver
  hardware.nvidia.open = true;

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault true;
    enableRedistributableFirmware = lib.mkDefault true;
  };

  # Just use Intel/AMD drivers - no NVIDIA for now
  services.xserver.videoDrivers = [ "intel" "amdgpu" ];
}