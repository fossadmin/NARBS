# hosts/android/phone/configuration.nix - Nix-on-Droid Configuration
#
# Android phone configuration using nix-on-droid.

{ pkgs, lib, modulesPath, ... }: {
  imports = [
    ../../modules/nixos/common/shell.nix
    ./hardware-phone.nix
  ];

  # Enable NARBS modules
  narbs.shell = {
    enable = true;
    editor = "nvim";
    terminal = "termux";
  };

  # Home Manager for user config
  home-manager.users.admin = import ../../users/admin/home.nix;
  
  # Environment variables
  environment.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "termux";
  };
  
  # Packages for Android
  environment.systemPackages = with pkgs; [
    nvim
    git
    curl
    wget
    tree
    htop
    neofetch
  ];
  
  # Services
  services = {
    # SSH server (termux-services)
    sshd = {
      enable = true;
      ports = [ 8022 ];
    };
  };
  
  # State version
  system.stateVersion = "25.05";
}