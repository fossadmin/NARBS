{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nixos";

  # Video drivers and Niri prerequisites
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    kitty
    git
    wl-clipboard
    foot # Wayland-native lightweight terminal
    waybar # The status bar
    fuzzel # Wayland-native dmenu replacement
    grim # Screenshot tool
    slurp # Select region for screenshots
  ];

  services.getty.autologinUser = "yourusername";

  # Basic Audio (Pipewire is standard for Wayland)
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.11";
}
