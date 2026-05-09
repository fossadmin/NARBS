# modules/nixos/common/users.nix — Users module
#
# User management for Admin and Guest.
# Enable with: narbs.users.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.users;
in
{
  options.narbs.users = {
    enable = lib.mkEnableOption "NARBS user management";
    
    adminName = lib.mkOption {
      type = lib.types.str;
      default = "admin";
      description = "Admin username";
    };
    
    adminShell = lib.mkOption {
      type = lib.types.enum [ "bash" "zsh" "fish" "nushell" ];
      default = "zsh";
      description = "Admin login shell";
    };
  };

  config = lib.mkIf cfg.enable {
    # Set the adminName option to match the local configuration
    narbs.users.adminName = lib.mkDefault (config.narbs.local.user or "admin");

    users = {
      users = {
        # Admin: Full NARBS experience
        ${cfg.adminName} = {
          isNormalUser = true;
          description = "NARBS Administrator";
          extraGroups = [ "wheel" "networkmanager" "video" "docker" "users" "libvirtd" "kvm" ];
          shell = pkgs.${cfg.adminShell};
        };

        # Guest: Minimalist, no sudo
        guest = {
          isNormalUser = true;
          description = "Guest User";
          shell = pkgs.bash;
          extraGroups = [ "users" ];
        };
      };
      
      # Default to no password for root in VM/testing
      # In production, use sops-nix for root password
      mutableUsers = true;
    };
  };
}