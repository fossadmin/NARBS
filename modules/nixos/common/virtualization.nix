# modules/nixos/virtualization.nix — Virtualization module
#
# Virtualization with QEMU/KVM and libvirt.
# Enable with: narbs.virtualization.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.virtualization;
in
{
  options.narbs.virtualization = {
    enable = lib.mkEnableOption "NARBS virtualization (QEMU/KVM, libvirt)";
  };

  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = true;
    
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      qemu
      OVMF
    ];

    virtualisation.libvirtd = {
      enable = true;
      allowedBridges = [
        "nm-bridge"
        "virbr0"
      ];
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
      };
    };

    services = {
      qemuGuest.enable = true;
      # Disable conflicting services
      dnsmasq.enable = false;
      resolved.enable = false;
    };
  };
}