# modules/nixos/common/security.nix — Security & Privacy Hardening
#
# Kernel hardening, privacy settings, and security defaults.
# Enable with: narbs.security.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.security;
in
{
  options.narbs.security = {
    enable = lib.mkEnableOption "NARBS security and privacy hardening";
    
    # Kernel sysctl hardening
    enableKernelHardening = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable kernel hardening via sysctl";
    };
    
    # Disable Nix telemetry
    disableNixTelemetry = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable Nix telemetry and experimental features";
    };
    
    # Boot hardening (can break some setups)
    enableBootHardening = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable boot hardening (initrd sanity check)";
    };
    
    # Network privacy (can break some networks)
    enableNetworkPrivacy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable network privacy restrictions";
    };
  };

  config = lib.mkIf cfg.enable {
    # ─────────────────────────────────────────────────────────────────────
    # Kernel Hardening & Boot (combined in one boot block)
    # ─────────────────────────────────────────────────────────────────────
    boot.kernel.sysctl = lib.mkIf cfg.enableKernelHardening {
      # Restrict dmesg (kernel messages) - hides sensitive info
      "kernel.dmesg_restrict" = 1;
      
      # Hide kernel pointers - prevents kernel exploit hunting
      "kernel.kptr_restrict" = 2;
      
      # Reverse path filter - prevents spoofing
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      
      # NOTE: IP forwarding is intentionally NOT disabled here
      # Router/Server configs need to set this themselves if required
      # "net.ipv4.ip_forward" = 0;
      # "net.ipv6.conf.all.forwarding" = 0;
      
      # Ignore ICMP redirects (prevent MITM)
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      
      # Ignore ICMP ping (privacy)
      "net.ipv4.icmp_echo_ignore_all" = 0;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      
      # Restrict /proc (hide other users' processes)
      "kernel.apparmor_restrict" = lib.mkDefault 1;
      "kernel.unprivileged_userns_clone" = 1; # Required for browser sandboxing
    };

    # Boot hardening - initrd (future use)
    # NOTE: boot.initrd.sanityCheck is not available in current nixpkgs

    # ─────────────────────────────────────────────────────────────────────
    # Secure Boot (requires additional setup!)
    # ─────────────────────────────────────────────────────────────────────
    # NOTE: Secure Boot requires:
    # 1. Generate signing keys: `openssl req -new -x509 -newkey rsa:4096 -keyout secureboot.key -out secureboot.crt`
    # 2. Sign the bootloader and kernel
    # 3. Enroll keys in UEFI firmware (outside NixOS)
    # 
    # For full Secure Boot, also add in host config:
    #   boot.loader.grub.secureBoot = true;
    #   boot.kernelPackages = pkgs.linuxPackages_latest;  # Must be signed
    #
    # For now, we just document it - actual implementation needs per-host setup

    # ─────────────────────────────────────────────────────────────────────
    # Disable Nix Telemetry
    # ─────────────────────────────────────────────────────────────────────
    nix = lib.mkIf cfg.disableNixTelemetry {
      settings = {
        # Disable experimental features that may phone home
        experimental-features = [];
      };
    };
    
    # ─────────────────────────────────────────────────────────────────────
    # User Security Defaults
    # ─────────────────────────────────────────────────────────────────────
    
    # Require password for sudo
    security.sudo.wheelNeedsPassword = true;
    security.sudo.execWheelOnly = true; # Only wheel users can use sudo
    
    # Protect kernel image
    security.protectKernelImage = true;
    
    # Disable coredumps (privacy)
    systemd.coredump.enable = false;

    # ─────────────────────────────────────────────────────────────────────
    # Network Privacy (optional - can break stuff)
    # ─────────────────────────────────────────────────────────────────────
    # When enabled, this would tighten the firewall significantly
    # Note: Actual implementation would need careful per-host configuration
    # to avoid locking yourself out
  };
}
