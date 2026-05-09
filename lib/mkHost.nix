# lib/mkHost.nix — Core host builder for NARBS
#
# Signature: mkHost { system, hostDir, type, stateVersion, localConfig }
#   system        — e.g. "x86_64-linux"
#   hostDir      — path to host dir (contains hardware.nix)
#   type         — "workstation" | "server" | "router"
#   stateVersion — NixOS/HM state version string (e.g. "25.05")
#   localConfig  — user configuration from local.nix
#
# NARBS is a "dumb engine" — zero user data lives here.
# All user-specific data comes from local.nix in the NARBS root.

{ inputs }:

{
  system,
  hostDir,
  type,
  stateVersion,
  localConfig,
}:

let
  # Common specialArgs passed to all modules
  specialArgs = {
    inherit inputs stateVersion localConfig;
    hostCfg = hostCfg;
  };
   
  # Get host config from local.nix or use fallback
  hostCfg = 
    let 
      cfg = if localConfig != null then localConfig.machines.${type} or null else null;
    in 
    if cfg != null && cfg != {} then cfg else {
      hostName = type;
      hostId = "00000000";
      enableZFS = false;
    };

  # Type-specific modules
  typeModules = {
    workstation = [
      ../modules/nixos/workstation/desktop.nix
      ../modules/nixos/common/bluetooth.nix
      ../modules/nixos/common/automount.nix
      ../modules/nixos/common/disko-workstation.nix
      ../modules/wrapped/kitty.nix
      ../modules/wrapped/niri.nix
      ../modules/wrapped/noctalia.nix
      ../modules/wrapped/mako.nix
      ../modules/wrapped/waybar.nix
      ../modules/wrapped/lf.nix
      ../modules/wrapped/git.nix
      ../modules/wrapped/fish.nix
    ];

    server = [
      ../modules/nixos/headless/default.nix
      ../modules/nixos/common/disko-server.nix
    ];

    router = [
      ../modules/nixos/headless/default.nix
      ../modules/nixos/common/disko-router.nix
    ];
  };

  # Common modules shared by all host types
  commonModules = [
    ../modules/nixos/common/local.nix
    ../modules/nixos/common/theme.nix
    ../modules/nixos/common/shell.nix
    ../modules/nixos/common/users.nix
    ../modules/nixos/common/security.nix
    ../modules/nixos/common/impermanence.nix
    ../modules/nixos/common/power.nix
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
    (hostDir + "/hardware.nix")
    ({ ... }: { system.stateVersion = stateVersion; })
  ];

  # Dynamically determine the primary username
  primaryUser = localConfig.user or "admin";

  # Type-specific configurations
  typeConfig = {
    workstation = {
      narbs = {
        local.enable = true;
        workstation.enable = true;
        theme.enable = true;
        security.enable = true;
        shell.enable = true;
        users.enable = true;
        power.enable = true;
        bluetooth.enable = true;
        automount.enable = true;
        impermanence.enable = true;
        wrapped.kitty.enable = true;
        wrapped.niri.enable = true;
        wrapped.noctalia.enable = false;
        wrapped.mako.enable = true;
        wrapped.waybar.enable = false;
        wrapped.lf.enable = true;
        wrapped.git.enable = true;
        wrapped.fish.enable = true;
      };
      networking.networkmanager.enable = true;
      
      # Configure Home Manager for workstation
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = specialArgs;
        users = {
          "${primaryUser}" = import (../users + "/${primaryUser}/home.nix");
          guest = import ../users/guest/home.nix;
        };
      };
    };

    server = {
      narbs = {
        local.enable = true;
        headless.enable = true;
        security.enable = true;
        shell.enable = true;
        users.enable = true;
        impermanence.enable = true;
      };
    };

    router = {
      narbs = {
        local.enable = true;
        headless.enable = true;
        security.enable = true;
        shell.enable = true;
        users.enable = true;
      };
      networking.useDHCP = true;
      networking.firewall.enable = true;
      networking.firewall.allowPing = true;
      networking.firewall.allowedTCPPorts = [ 22 80 443 ];
      services.openssh.enable = true;
      services.openssh.settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 0;
      };
    };
  };

  typeCfg = typeConfig.${type} or {};

  # ZFS config: only set hostId if ZFS is enabled with valid hostId
  zfsEnabled = hostCfg.enableZFS or false;
  hostId_val = hostCfg.hostId or "";
  validHostId = hostId_val != "" && builtins.stringLength hostId_val == 8;
  finalHostId = if zfsEnabled && validHostId then hostId_val else "00000000";
  
  # Build modules list
  modules = commonModules ++ (typeModules.${type} or []) ++ [
    typeCfg
    ({ lib, ... }: {
      # Pass the localConfig through to the narbs.local module
      narbs.local.localConfig = localConfig;

      # Set hostId - when ZFS disabled, use placeholder to satisfy module
      networking.hostId = lib.mkForce finalHostId;
      networking.hostName = hostCfg.hostName;
    })
  ];
in

inputs.nixpkgs.lib.nixosSystem {
  inherit system specialArgs;
  modules = modules;
}
