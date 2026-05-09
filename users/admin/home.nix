# home/admin/home.nix - Simplified NARBS Admin User
#
# Lean configuration - most moved to system-level via wrapped programs

{ pkgs, lib, ... }:

{
  imports = [
    ../scripts.nix
  ];

  home.stateVersion = "25.05";

  # ─────────────────────────────────────────────────────────────────────
  # Only user-level packages not available system-wide
  # (Most CLI tools are in wrapped programs at system level)
  # ─────────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Media (typically user-level)
    mpv
    zathura
    
    # Fonts (can also be system-level)
    nerd-fonts.jetbrains-mono
  ];

  # ─────────────────────────────────────────────────────────────────────
  # Essential session variables only
  # ─────────────────────────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";
    BROWSER = "firefox";
    # XDG for dotfile cleanliness
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };
}
