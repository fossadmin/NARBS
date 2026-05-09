# modules/nixos/common/theme.nix — NARBS Theme module
#
# Base16 theming without Stylix - uses hardcoded colors.
# Provides Tokyo Night theme colors to wrapped programs.

{ config, lib, ... }:

let
  # Tokyo Night theme colors (base16 format)
  theme = {
    # Backgrounds
    base00 = "#1a1b26";  # bg
    base01 = "#16161e";  # dark
    base02 = "#24283b";  # selection
    base03 = "#414868";  # comments
    
    # Foregrounds
    base04 = "#787c99";  # dim
    base05 = "#c0caf5";  # fg
    base06 = "#a9b1d6";  # text
    base07 = "#cba6f7";  # light (purple accent)
    
    # Colors
    base08 = "#f7768e";  # red
    base09 = "#ff9e64";  # orange
    base0A = "#e0af68";  # yellow
    base0B = "#9ece6a";  # green
    base0C = "#7dcfff";  # cyan
    base0D = "#7aa2f7";  # blue
    base0E = "#bb9af7";  # magenta
    base0F = "#9ece6a";  # same as green
  };
in
{
  options.narbs.theme = {
    enable = lib.mkEnableOption "NARBS theme (Tokyo Night)";
  };
  
  config = lib.mkIf config.narbs.theme.enable {
    # Theme is used by hardcoding colors in wrapped programs
    # This module just provides the enable/disable toggle
  };
}
