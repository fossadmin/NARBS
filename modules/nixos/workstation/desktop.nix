# modules/nixos/workstation/desktop.nix — Desktop module
#
# Full desktop experience with Niri, Kitty, Mako, Waybar.
# Enable with: narbs.workstation.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.workstation;
in
{
  options.narbs.workstation = {
    enable = lib.mkEnableOption "NARBS desktop environment";
    
    wm = lib.mkOption {
      type = lib.types.enum [ "niri" "hyprland" ];
      default = "niri";
      description = "Window manager/compositor";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable Nix flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Packages
    environment.systemPackages = with pkgs; [
      # Terminal
      kitty
      
      # File management
      eza
      bat
      fzf
      
      # System monitoring
      htop
      btop
      fastfetch
      
      # Media
      mpv
      imv
      zathura
      
      # Screenshot tools
      grim
      slurp
      wl-clipboard
      
      # Git
      git
      
      # Network
      curl
      wget
    ];

    # PipeWire
    services.pipewire.enable = true;
    
    # Boot
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    hardware.graphics.enable = true;
  };
}