# hosts/darwin/macbook/hardware-macbook.nix - MacBook Hardware
#
# Hardware-specific configuration for MacBook.

{ config, pkgs, ... }: {
  # Boot configuration
  boot.loader = {
    # Use macOS's boot loader
    useAppleBootLoader = true;
    efi = {
      canTouchEfiVariables = true;
    };
  };
  
  # APFS configuration
  boot.apfs = {
    volumes = {
      "Macintosh HD" = {
        encrypt = false;
      };
    };
  };
  
  # Hardware - will detect automatically on real MacBook
  hardware = {
    # Enable Bluetooth
    bluetooth.enable = true;
    
    # Enable WiFi
    wifi.enable = true;
  };
  
  # Auto-upgrade
  system.autoUpgrade = {
    enable = true;
    channel = "stable";
  };
}