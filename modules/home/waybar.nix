# modules/home/waybar.nix — Waybar module (Home Manager)
#
# Waybar status bar configuration.
# Enable with: home.manager.modules.waybar.enable = true;

{ lib, ... }:

let
  cfg = lib.mkIf (lib.hasAttr "modules" config.home-manager)
    (config.home-manager.modules.waybar or {});
in
{
  options.home-manager.modules.waybar = {
    enable = lib.mkEnableOption "NARBS Waybar status bar";
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [ "custom/weather" "battery" "network" ];

          "custom/weather" = {
            # Using a shell script just like Luke!
            exec = "curl -s 'wttr.in?format=1'";
            interval = 3600;
          };
        };
      };
    };
  };
}