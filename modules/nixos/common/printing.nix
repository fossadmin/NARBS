# modules/nixos/printing.nix — Printing module
#
# CUPS printing and SANE scanner support.
# Enable with: narbs.printing.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.printing;
in
{
  options.narbs.printing = {
    enable = lib.mkEnableOption "NARBS printing and scanning support";
  };

  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };

    environment.systemPackages = with pkgs; [
      cups
    ];
  };
}