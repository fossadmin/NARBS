# server.nix - NARBS Headless Server Configuration
#
# ZFS with Disko, Homepage dashboard, Uptime Kuma, SSH hardening,
# and systemd maintenance timers.

{ pkgs, lib, ... }: {
  imports = [
    ./stylix.nix
    ./shell.nix
    ./users.nix
  ];

  # Enable Nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ─────────────────────────────────────────────────────────────────────
  # Boot Configuration
  # ─────────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-path";
   
  # NOTE: networking.hostId is set via host configuration from local.nix

  # ─────────────────────────────────────────────────────────────────────
  # Disko: Declarative Disk Partitioning
  # ─────────────────────────────────────────────────────────────────────
  # Import disko config from host directory
  imports = [
    ./disko.nix
  ];

  # ─────────────────────────────────────────────────────────────────────
  # Headless Server Packages
  # ─────────────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Essential CLI tools
    git
    curl
    wget
    htop
    tmux
    vim
    eza
    bat
    
    # Network tools
    iproute
    iputils
    openssh
  ];

  # ─────────────────────────────────────────────────────────────────────
  # SSH Hardening (for remote admin)
  # ─────────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      # Disable password authentication (use keys only)
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };

  # ─────────────────────────────────────────────────────────────────────
  # Homepage Dashboard
  # ─────────────────────────────────────────────────────────────────────
  services.homepage-dashboard = {
    enable = true;
    settings = {
      title = "NARBS Server";
      background = {
        image = "https://raw.githubusercontent.com/tokyo-night/tokyo-night-vscode-theme/master/assets/wallpaper.png";
      };
    };
    services = [
      {
        "System" = [
          {
            "Stats" = {
              icon = "si-nixos";
              href = "http://localhost:61208";
              widget = {
                type = "glances";
                url = "http://localhost:61208";
              };
            }
          }
        ];
      }
      {
        "Monitoring" = [
          {
            "Uptime Kuma" = {
              icon = "si-prometheus";
              href = "http://localhost:3001";
            }
          }
        ];
      }
      {
        "Services" = [
          {
            "SSH" = {
              icon = "si-openssh";
              href = "ssh://${config.narbs.local.user or "admin"}@localhost";
            }
          }
        ];
      }
    ];
  };

  # ─────────────────────────────────────────────────────────────────────
  # Uptime Kuma Monitoring
  # ─────────────────────────────────────────────────────────────────────
  services.uptime-kuma = {
    enable = true;
    settings = {
      PORT = "3001";
      HOST = "0.0.0.0";
    };
  };

  # ─────────────────────────────────────────────────────────────────────
  # Glances System Monitor
  # ─────────────────────────────────────────────────────────────────────
  services.glances = {
    enable = true;
    port = 61208;
  };

  # ─────────────────────────────────────────────────────────────────────
  # Firewall
  # ─────────────────────────────────────────────────────────────────────
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22    # SSH
      80    # HTTP
      443   # HTTPS
      3000  # Homepage
      3001  # Uptime Kuma
      61208 # Glances
    ];
  };

  # ─────────────────────────────────────────────────────────────────────
  # ZFS Auto-Snapshots and Scrubbing
  # ─────────────────────────────────────────────────────────────────────
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub = {
    enable = true;
    day = "Sun";
    time = "00:00";
  };

  # Weekly ZFS scrub timer
  systemd.services.zfs-scrub = {
    description = "Weekly ZFS Pool Scrub";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.zfs}/bin/zpool scrub zroot";
    };
  };

  systemd.timers.zfs-scrub = {
    description = "Run ZFS scrub every Sunday at midnight";
    timerConfig = {
      OnCalendar = "Sun *-*-* 00:00:00";
      Persistent = true;
      Unit = "zfs-scrub.service";
    };
    wantedBy = [ "timers.target" ];
  };

  # ─────────────────────────────────────────────────────────────────────
  # Stylix for TTY theming
  # ─────────────────────────────────────────────────────────────────────
  stylix.targets.console.enable = true;

  # ─────────────────────────────────────────────────────────────────────
  # State Version
  # ─────────────────────────────────────────────────────────────────────
  system.stateVersion = "25.05";
}