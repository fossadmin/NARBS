# modules/wrapped/noctalia.nix — Noctalia Shell
#
# Sleek and minimal desktop shell for Wayland.
# Enable with: narbs.wrapped.noctalia.enable = true;

{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.narbs.wrapped.noctalia;
in
{
  options.narbs.wrapped.noctalia = {
    enable = lib.mkEnableOption "Noctalia Shell (desktop shell for Wayland)";
    
    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Auto-start Noctalia on login";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Install noctalia-shell package
    environment.systemPackages = [ pkgs.noctalia-shell ];
    
    # Create Noctalia config directory
    environment.etc."noctalia/config.json".text = ''
      {
        "version": 1,
        "general": {
          "avatarImage": "",
          "boxRadiusRatio": 1,
          "enableShadows": true,
          "forceBlackScreenCorners": false,
          "iRadiusRatio": 1,
          "language": "",
          "lockOnSuspend": true,
          "radiusRatio": 1,
          "scaleRatio": 1,
          "screenRadiusRatio": 1,
          "showHibernateOnLockScreen": false,
          "showScreenCorners": false,
          "showSessionButtonsOnLockScreen": true
        },
        "bar": {
          "capsuleOpacity": 1,
          "density": "comfortable",
          "exclusive": true,
          "floating": false,
          "marginHorizontal": 0.25,
          "marginVertical": 0.25,
          "monitors": [],
          "outerCorners": true,
          "position": "left",
          "showCapsule": false,
          "showOutline": false,
          "transparent": false,
          "widgets": {
            "center": [],
            "left": [
              {
                "id": "Workspace",
                "showApplications": false,
                "showLabelsOnlyWhenOccupied": true
              }
            ],
            "right": [
              {
                "id": "NotificationHistory",
                "showUnreadBadge": true
              },
              {
                "id": "Battery",
                "displayMode": "alwaysShow",
                "warningThreshold": 20
              },
              {
                "id": "Clock",
                "formatHorizontal": "HH:mm ddd, MMM dd"
              },
              {
                "id": "Tray"
              }
            ]
          }
        },
        "notifications": {
          "enabled": true,
          "location": "top_right"
        },
        "dock": {
          "enabled": false
        },
        "launcher": {
          "enabled": true,
          "position": "center"
        }
      }
    '';
    
    # Create autostart entry if enabled
    environment.etc."noctalia/autostart.sh".text = ''
      #!/bin/sh
      noctalia-shell &
    '';
  };
}
