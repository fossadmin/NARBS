# modules/nixos/common/impermanence.nix — Impermanence module
#
# Stateless NixOS using impermanence.
# Enable with: narbs.impermanence.enable = true;
# Uses local.nix for username configuration

{ config, lib, ... }:

let
  cfg = config.narbs.impermanence;

  # Get username from local.nix if available, otherwise default to "admin"
  username = config.narbs.local.user or "admin";
in
{
  options.narbs.impermanence = {
    enable = lib.mkEnableOption "NARBS impermanence (stateless /tmp)";

    persistDir = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "Persistence mount point";
    };

    includeUserDirs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include user home directories in persistence";
    };

    # Disable tmpfs /home - use when /home is already a ZFS dataset
    noTmpfsHome = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Don't create tmpfs /home (use when /home is ZFS dataset)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable impermanence
    environment.persistence.${cfg.persistDir} = {
      hideMounts = true;

      # System directories to persist
      directories = [
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/acme"
        "/var/lib/systemd/coredump"
        "/var/lib/sops-nix"
        "/var/lib/flatpak"
        "/var/lib/libvirt"
        "/var/lib/tailscale"
        "/etc/ssh"
        "/etc/wireguard"
        "/etc/NetworkManager/system-connections"
      ];

      # System files to persist
      files = [
        "/etc/machine-id"
        "/etc/adjtime"
      ];

      # User directories (from local.nix username)
      users.${username} = lib.mkIf cfg.includeUserDirs {
        directories = [
          "dl"
          "docs"
          "projects"
          "notes"
          "site"
          "sync"
          "media" # Persist entire media dir
          ".archive"
          ".machines"
          ".config"
          ".dots"
          ".hplip"
          ".librewolf"
          ".mozilla"
          ".mullvad"
          ".var"
          ".vim"
          ".zplug"
          ".cache/nix" # Cache nix evaluations
          ".local/share/direnv"
          {
            directory = ".gnupg";
            mode = "0700";
          }
          {
            directory = ".ssh";
            mode = "0700";
          }
          {
            directory = ".pki";
            mode = "0700";
          }
        ];
        files = [
          ".bash_history"
          ".gitconfig"
          ".git-credentials"
          ".zsh_histfile"
          ".zsh_history"
          ".python_history"
        ];
      };
    };

    # Mark persist filesystem as neededForBoot - required for impermanence to work
    fileSystems.${cfg.persistDir}.neededForBoot = true;

    # Use tmpfs for /home (ephemeral with impermanence)
    # Default: no tmpfs - let disko define /home as ZFS or leave user to decide
    # fileSystems."/home" = lib.mkIf (!cfg.noTmpfsHome && cfg.enable) { ... };
  };
}
