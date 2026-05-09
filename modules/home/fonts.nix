# modules/home/fonts.nix — Fonts module (Home Manager)
#
# Font configuration for user environment.
# Enable with: home.manager.modules.fonts.enable = true;

{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      pkgs.nerd-fonts.dejavu-sans-mono
      pkgs.nerd-fonts.fira-code
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.noto
    ];
  };
}