# home/guest.nix - Guest user Home Manager configuration
#
# Minimalist experience - basic tools only

{ pkgs, ... }: {
  home.stateVersion = "25.05";

  # Basic packages only (most via system wrapped programs)
  home.packages = with pkgs; [
    firefox
  ];

  # Basic session variables
  home.sessionVariables = {
    EDITOR = "vim";
    TERMINAL = "kitty";
  };
}
