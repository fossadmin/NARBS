# modules/wrapped/kitty.nix — Kitty terminal configuration
#
# GPU-accelerated terminal emulator with Tokyo Night theme.
# Enable with: narbs.wrapped.kitty.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.wrapped.kitty;
in
{
  options.narbs.wrapped.kitty = {
    enable = lib.mkEnableOption "Kitty terminal with Tokyo Night theme";
    
    fontSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 12;
      description = "Terminal font size";
    };
    
    fontFamily = lib.mkOption {
      type = lib.types.str;
      default = "JetBrainsMono Nerd Font";
      description = "Terminal font family";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Tokyo Night theme colors
    environment.etc."kitty/Tokyo Night.conf".text = let
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
      # Tokyo Night Theme
      
      # Background and foreground
      background ${tn.bg}
      foreground ${tn.fg}
      
      # Selection
      selection_foreground ${tn.bg}
      selection_background ${tn.blue}
      
      # Cursor
      cursor ${tn.purple}
      cursor_text_color ${tn.bg}
      
      # Dim colors
      color0 ${tn.bg}
      color8 ${tn.fg_dim}
      
      # Normal colors
      color1 ${tn.red}
      color2 ${tn.green}
      color3 ${tn.yellow}
      color4 ${tn.blue}
      color5 ${tn.purple}
      color6 ${tn.cyan}
      color7 ${tn.fg}
      
      # Bright colors
      color9 ${tn.red}
      color10 ${tn.green}
      color11 ${tn.yellow}
      color12 ${tn.blue}
      color13 ${tn.purple}
      color14 ${tn.cyan}
      color15 #ffffff
      
      # Tab bar
      active_tab_foreground ${tn.blue}
      active_tab_background ${tn.bg}
      inactive_tab_foreground ${tn.fg_dim}
      inactive_tab_background ${tn.bg_light}
      
      # Window
      window_border_color ${tn.bg}
      inactive_border_color ${tn.bg_light}
      active_border_color ${tn.blue}
    '';
    
    environment.etc."kitty/kitty.conf".text = let
      tn = {
        bg = "#1a1b26";
        fg = "#c0caf5";
      };
    in ''
      # Basic Settings
      font_size ${toString cfg.fontSize}
      font_family ${cfg.fontFamily}
      
      # Bell
      enable_audio_bell no
      
      # Cursor
      cursor_shape beam
      cursor_trail 1
      
      # Performance
      repaint_delay 10
      input_delay 3
      sync_to_terminal always
      
      # Scrollback
      scrollback_lines 10000
      
      # Window
      window_padding_width 8
      window_separator none
      
      # Shell integration
      shell_integration enabled
      allow_remote_control yes
      
      # Tab bar
      tab_bar_edge top
      tab_bar_style powerline
      tab_powerline_style slanted
      
      # Include theme
      include ./Tokyo Night.conf
      
      # Keybindings - Alt+number for tabs
      map alt+1 goto_tab 1
      map alt+2 goto_tab 2
      map alt+3 goto_tab 3
      map alt+4 goto_tab 4
      map alt+5 goto_tab 5
      map alt+6 goto_tab 6
      map alt+7 goto_tab 7
      map alt+8 goto_tab 8
      map alt+9 goto_tab 9
      map ctrl+shift+w close_tab
      map ctrl+t new_tab_with_cwd
      map ctrl+shift+t new_tab
      map ctrl+shift+left previous_tab
      map ctrl+shift+right next_tab
    '';
    
    # Kitty package
    environment.systemPackages = [ pkgs.kitty ];
  };
}
