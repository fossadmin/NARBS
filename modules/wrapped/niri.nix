# modules/wrapped/niri.nix — Niri window manager
#
# Scrollable tiling Wayland compositor with Tokyo Night theme.
# Enable with: narbs.wrapped.niri.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.wrapped.niri;
in
{
  options.narbs.wrapped.niri = {
    enable = lib.mkEnableOption "Niri window manager";
    
    terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
      description = "Default terminal for Niri";
    };
    
    fontSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 12;
      description = "UI font size";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Niri is typically started via display manager or greetd
    # The config is done via niri.settings in home-manager or /etc/niri.conf
    
    # For system-level config, we set up basic settings
    # The actual config is typically in the user's home-manager config
    
    # Niri package
    environment.systemPackages = [ pkgs.niri ];
    
    # Create system config file
    environment.etc."niri/config.toml".text = let
      tn = {
        bg = "#1a1b26";
        bg_light = "#24283b";
        fg = "#c0caf5";
        fg_dim = "#565f89";
        red = "#f7768e";
        orange = "#ff9e64";
        yellow = "#e0af68";
        green = "#9ece6a";
        cyan = "#7dcfff";
        blue = "#7aa2f7";
        purple = "#bb9af7";
      };
    in ''
      # Niri Configuration - Tokyo Night Theme
      
      [workspace]
      default-width = 1920
      default-height = 1080
      
      [input]
      # Keyboard
      [input.keyboard]
      xkb-map = "us,ru,ua"
      xkb-options = ["grp:alt_shift_toggle"]
      repeat-rate = 40
      repeat-delay = 250
      
      # Mouse
      [input.mouse]
      accel-profile = "flat"
      
      # Touchpad
      [input.touchpad]
      natural-scroll = true
      tap = true
      
      [binds]
      # Launch terminal
      "Mod+Return".spawn = "${cfg.terminal}"
      
      # Window management
      "Mod+Q".close-window = null
      "Mod+F".maximize-column = null
      "Mod+G".fullscreen-window = null
      "Mod+Shift+F".toggle-window-floating = null
      
      # Focus navigation (vim-like)
      "Mod+H".focus-column-left = null
      "Mod+L".focus-column-right = null
      "Mod+K".focus-window-up = null
      "Mod+J".focus-window-down = null
      
      # Arrow keys
      "Mod+Left".focus-column-left = null
      "Mod+Right".focus-column-right = null
      "Mod+Up".focus-window-up = null
      "Mod+Down".focus-window-down = null
      
      # Move windows
      "Mod+Shift+H".move-column-left = null
      "Mod+Shift+L".move-column-right = null
      "Mod+Shift+K".move-window-up = null
      "Mod+Shift+J".move-window-down = null
      
      # Workspaces (10 workspaces)
      "Mod+1".focus-workspace = "w0"
      "Mod+2".focus-workspace = "w1"
      "Mod+3".focus-workspace = "w2"
      "Mod+4".focus-workspace = "w3"
      "Mod+5".focus-workspace = "w4"
      "Mod+6".focus-workspace = "w5"
      "Mod+7".focus-workspace = "w6"
      "Mod+8".focus-workspace = "w7"
      "Mod+9".focus-workspace = "w8"
      "Mod+0".focus-workspace = "w9"
      
      # Move to workspaces
      "Mod+Shift+1".move-column-to-workspace = "w0"
      "Mod+Shift+2".move-column-to-workspace = "w1"
      "Mod+Shift+3".move-column-to-workspace = "w2"
      "Mod+Shift+4".move-column-to-workspace = "w3"
      "Mod+Shift+5".move-column-to-workspace = "w4"
      "Mod+Shift+6".move-column-to-workspace = "w5"
      "Mod+Shift+7".move-column-to-workspace = "w6"
      "Mod+Shift+8".move-column-to-workspace = "w7"
      "Mod+Shift+9".move-column-to-workspace = "w8"
      "Mod+Shift+0".move-column-to-workspace = "w9"
      
      # Screenshot (grim + wl-copy)
      "Mod+Shift+S".spawn-sh = "grim -g \"\$(slurp)\" - | wl-copy"
      
      # Media keys
      "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"
      "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"
      "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      
      # Resize
      "Mod+Ctrl+H".set-column-width = "-5%"
      "Mod+Ctrl+L".set-column-width = "+5%"
      "Mod+Ctrl+J".set-window-height = "-5%"
      "Mod+Ctrl+K".set-window-height = "+5%"
      
      [layout]
      gaps = 8
      
      [layout.focus-ring]
      width = 2
      active-color = "${tn.blue}"
      
      [xwayland]
      # XWayland satellite for X11 apps
      enable = true
      
      [workspace.w0]
      [workspace.w1]
      [workspace.w2]
      [workspace.w3]
      [workspace.w4]
      [workspace.w5]
      [workspace.w6]
      [workspace.w7]
      [workspace.w8]
      [workspace.w9]
    '';
  };
}
