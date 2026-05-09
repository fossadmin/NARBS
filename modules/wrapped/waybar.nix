# modules/wrapped/waybar.nix — Waybar status bar
#
# Highly customizable status bar for Wayland.
# Enable with: narbs.wrapped.waybar.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.wrapped.waybar;
in
{
  options.narbs.wrapped.waybar = {
    enable = lib.mkEnableOption "Waybar status bar";
    
    position = lib.mkOption {
      type = lib.types.enum [ "top" "bottom" ];
      default = "top";
      description = "Bar position";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Waybar config file
    environment.etc."waybar/config".text = let
      pos = if cfg.position == "top" then "top" else "bottom";
    in ''
      {
        "layer": "top",
        "position": "${pos}",
        "height": 30,
        "modules-left": ["hyprland/workspaces", "hyprland/window", "idle_inhibitor"],
        "modules-center": ["clock"],
        "modules-right": ["pulseaudio", "network", "battery", "tray"],
        
        "hyprland/workspaces": {
          "format": "{icon}",
          "format-icons": {
            "1": "一", "2": "二", "3": "三", "4": "四", "5": "五",
            "6": "六", "7": "七", "8": "八", "9": "九", "10": "十",
            "urgent": "⚠", "focused": "●", "default": "○"
          }
        },
        
        "hyprland/window": {
          "format": "{}",
          "max-length": 50
        },
        
        "idle_inhibitor": {
          "format": "{icon}",
          "format-icons": {"activated": "⏱", "deactivated": "⏱"}
        },
        
        "clock": {
          "format": "{:%H:%M}",
          "format-alt": "{:%Y-%m-%d}",
          "interval": 1
        },
        
        "pulseaudio": {
          "format": "{icon} {volume}%",
          "format-muted": "🔇",
          "format-icons": {"default": ["🔊", "🔉", "🔈"]},
          "on-click": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        },
        
        "network": {
          "format-wifi": "📶 {signalStrength}%",
          "format-ethernet": "🌐",
          "format-disconnected": "⚠"
        },
        
        "battery": {
          "format": "{icon} {capacity}%",
          "format-charging": "⚡ {capacity}%",
          "format-plugged": "⚡ {capacity}%",
          "format-icons": {"10": "🪫", "20": "🔋", "30": "🔋", "40": "🔋", "50": "🔋",
                           "60": "🔌", "70": "🔌", "80": "🔌", "90": "🔌", "100": "🔌"}
        },
        
        "tray": {
          "spacing": 10
        }
      }
    '';
    
    # Waybar style
    environment.etc."waybar/style.css".text = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        min-height: 0;
      }
      
      window#waybar {
        background: #1a1b26;
        color: #c0caf5;
      }
      
      #workspaces button {
        padding: 0 5px;
        color: #565f89;
      }
      
      #workspaces button.active {
        color: #7aa2f7;
      }
      
      #clock, #battery, #network, #pulseaudio, #tray {
        padding: 0 10px;
      }
      
      #battery.charging { color: #9ece6a; }
      #battery.warning { color: #e0af68; }
      #battery.critical { color: #f7768e; }
      #network.disconnected { color: #f7768e; }
      #pulseaudio.muted { color: #565f89; }
    '';
    
    # Waybar script
    environment.etc."waybar/launch.sh".text = ''
      #!/bin/sh
      waybar &
    '';
    
    # Waybar package
    environment.systemPackages = [ pkgs.waybar ];
  };
}
