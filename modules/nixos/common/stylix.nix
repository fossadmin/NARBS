# modules/nixos/common/stylix.nix — Stylix module (DEPRECATED)
#
# NOTE: This module is deprecated. NARBS now uses hardcoded theme colors
# in individual wrapped program modules instead of Stylix.
# 
# If you want Stylix theming, enable it in your host configuration directly.

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.stylix;
in
{
  options.narbs.stylix = {
    enable = lib.mkEnableOption "NARBS Stylix theming (DEPRECATED - use hardcoded themes instead)";
  };
  
  config = lib.mkIf cfg.enable {
    warnings = [
      "Stylix is deprecated in NARBS. Use hardcoded theme colors in wrapped programs instead."
    ];
  };
}
