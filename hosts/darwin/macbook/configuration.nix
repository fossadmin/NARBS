# hosts/darwin/macbook/configuration.nix - NARBS macOS Configuration
#
# A macOS configuration using nix-darwin with Home Manager.

{ pkgs, lib, modulesPath, ... }: {
  imports = [
    ../../modules/nixos/common/shell.nix
    ./hardware-macbook.nix
  ];

  # Enable NARBS modules
  narbs.shell.enable = true;

  # System
  system.defaults = {
    # Dock configuration
    dock = {
      autohide = true;
      magnification = true;
      showrecent = false;
    };
    
    # Trackpad
    trackpad = {
      trackpadAcceleration = 0.5;
      trackpadCornerSecondaryClick = 2;
    };
  };
  
  # Fonts
  fonts.fontDir = "${pkgs.fira-code}/share/fonts/opentype";
  
  # Environment
  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";
  };

  # Launchd services
  services = {
    # Yabai window management
    yabai = {
      enable = true;
      config = {
        window_opacity = true;
        window_opacity_duration = 0.2;
      };
    };
  };
  
  # Programs
  programs = {
    # Zsh as default shell (shell module handles zsh + starship)
    # Also enables home-manager
  };

  # State version
  system.stateVersion = 5;
}