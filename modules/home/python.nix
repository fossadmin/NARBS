# modules/home/python.nix — Python module (Home Manager)
#
# Python environment for user.
# Enable with: home.manager.modules.python.enable = true;

{ pkgs, ... }:

{
  # Using python3.withPackages to create a Python environment
  home.packages = with pkgs; [
    pkgs.python3
  ];
}