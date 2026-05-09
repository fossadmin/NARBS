# modules/headless/default.nix — Headless services module
#
# Services for headless machines (servers, routers).
# Includes ZFS, Homepage dashboard, Uptime Kuma, Glances.
# Enable with: narbs.headless.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.headless;
in
{
  options.narbs.headless = {
    enable = lib.mkEnableOption "NARBS headless services";
    
    enableZFS = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable ZFS support";
    };
    
    enableHomepage = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Homepage dashboard";
    };
    
    enableUptimeKuma = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Uptime Kuma monitoring";
    };
    
    enableGlances = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Glances system monitor";
    };
    
    hostname = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Host hostname (null = don't set, use host config)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Hostname - only set if explicitly configured (not null)
    networking.hostName = lib.mkIf (cfg.hostname != null) (lib.mkDefault cfg.hostname);
    networking.useDHCP = lib.mkDefault true;

    # Conditionally enable ZFS
    boot.supportedFilesystems = lib.mkIf cfg.enableZFS [ "zfs" ];
    boot.zfs.devNodes = lib.mkIf cfg.enableZFS "/dev/disk/by-path";

    # Homepage Dashboard
    services.homepage-dashboard = lib.mkIf cfg.enableHomepage {
      enable = true;
      settings = {
        title = "NARBS Headless";
        background.image = "https://raw.githubusercontent.com/tokyo-night/tokyo-night-vscode-theme/master/assets/wallpaper.png";
      };
      services = [
        {
          "System" = [
            {
              "Stats" = {
                icon = "si-prometheus";
                widget.type = "glances";
              };
            }
          ];
        }
        {
          "Monitoring" = [
            {
              "Uptime Kuma" = {
                icon = "si-prometheus";
                href = "http://localhost:3001";
              };
            }
          ];
        }
        {
          "Services" = [
            {
              "SSH" = {
                icon = "si-openssh";
                href = "ssh://${config.narbs.local.user or "admin"}@localhost";
              };
            }
          ];
        }
      ];
    };

    # Uptime Kuma
    services.uptime-kuma = lib.mkIf cfg.enableUptimeKuma {
      enable = true;
      settings = {
        PORT = "3001";
        HOST = "0.0.0.0";
      };
    };

    # Glances
    services.glances = lib.mkIf cfg.enableGlances {
      enable = true;
      port = 61208;
    };

    # SSH hardening
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
    };

    # Firewall
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 3000 3001 61208 ];
    };

    # Minimal packages
    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      htop
      tmux
      vim
      eza
      bat
    ];

    # Boot
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # ZFS auto-scrub
    services.zfs.autoScrub.enable = true;
  };
}