# flake.nix - NARBS: Nix Atomic Reliable Build System
#
# A modular, declarative NixOS configuration system for MSPs.
# Supports: NixOS (workstation/server/router), macOS (darwin), Android (nix-on-droid)

{
  description = "NARBS: Nix Atomic Reliable Build System";

  inputs = {
    ############### Official NixOS and HM Package Sources ###############
    
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # macOS support
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Nix-on-Droid (Android)
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    
    #################### Utilities ####################
    
    # Impermanence (stateless /tmp)
    impermanence.url = "github:nix-community/impermanence";
    
    # Disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Secrets management
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    agenix.url = "github:ryantm/agenix";
    
    # Neovim Framework
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Pre-commit hooks
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Remote deployment
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hardware detection
    hardware.url = "github:nixos/nixos-hardware";
    
    # Nix-index for command discovery
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Noctalia Shell (desktop shell for Wayland)
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, nix-darwin, nix-on-droid, home-manager, home-manager-unstable, impermanence, disko, sops-nix, agenix, nvf, pre-commit-hooks, deploy-rs, hardware, nix-index-database, noctalia, ... }@inputs: 
  
  let
    # Import mkHost
    mkHost = import ./lib/mkHost.nix { inherit inputs; };
    
    # Load local.nix for user configuration
    # Note: We prioritize git-tracked files, but this allows referencing
    # the gitignored local.nix if it exists on disk.
    localConfig = 
      let localNixPath = ./local.nix;
      in if builtins.pathExists localNixPath
         then import localNixPath
         else {
           user = "admin";
           userName = "User";
           userEmail = "user@localhost";
           machines = {
             workstation = {};
             server = {};
             router = {};
           };
           locale = {
             timeZone = "America/New_York";
             language = "en_US.UTF-8";
           };
         };
  in {
    
    # Re-export for access in configurations
    inherit inputs;
    
    # NixOS Configurations - using mkHost pattern
    nixosConfigurations = {
      # Workstation: GUI (Laptop/Desktop)
      workstation = mkHost {
        system = "x86_64-linux";
        hostDir = ./hosts/workstation;
        type = "workstation";
        stateVersion = "25.05";
        localConfig = localConfig;
      };

      # Server: Headless with ZFS
      server = mkHost {
        system = "x86_64-linux";
        hostDir = ./hosts/server;
        type = "server";
        stateVersion = "25.05";
        localConfig = localConfig;
      };

      # Router: Simple firewall/routing
      router = mkHost {
        system = "x86_64-linux";
        hostDir = ./hosts/router;
        type = "router";
        stateVersion = "25.05";
        localConfig = localConfig;
      };
    };
    
    # Darwin Configurations (macOS)
    darwinConfigurations = {
      # MacBook or Mac mini
      macbook = nix-darwin.lib.darwinSystem {
        modules = [
          ./hosts/darwin/macbook/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${localConfig.user or "admin"}" = import (./users + "/${localConfig.user or "admin"}/home.nix");
            };
          }
        ];
      };
    };
    
    # Nix-on-Droid Configurations (Android)
    nixOnDroidConfigurations = {
      android-phone = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        modules = [
          ./hosts/android/phone/configuration.nix
        ];
        home-manager-path = home-manager.outPath;
        extraSpecialArgs.inputs = inputs;
      };
    };
    
    # NixOS Modules - NARBS modules
    nixosModules.default = import ./modules/nixos/default.nix;
    
    # Dev shell - use `nix develop` to enter
    devShells.x86_64-linux.default = import ./shell.nix { 
      pkgs = nixpkgs.legacyPackages.x86_64-linux; 
    };
    
    # Checks for `nix flake check`
    checks = { };
  };
}