# modules/nixos/power.nix — Power management module
#
# Laptop power management (thermald, TLP, auto-cpufreq).
# Enable with: narbs.power.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.power;
in
{
  options.narbs.power = {
    enable = lib.mkEnableOption "NARBS power management";
    
    enableTLP = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable TLP power management";
    };
    
    enableAutoCpuFreq = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable auto-cpufreq";
    };
  };

  config = lib.mkIf cfg.enable {
    # Allows for managing hibernate and suspend states
    powerManagement.enable = true;
    
    # Proactively prevents overheating on Intel CPUs
    services.thermald.enable = true;
    
    # TLP (disabled by default)
    # services.tlp = lib.mkIf cfg.enableTLP {
    #   enable = true;
    #   settings = {
    #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
    #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    #   };
    # };
    
    # auto-cpufreq (disabled by default)
    # services.auto-cpufreq = lib.mkIf cfg.enableAutoCpuFreq {
    #   enable = true;
    # };
  };
}