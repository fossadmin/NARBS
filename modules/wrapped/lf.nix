# modules/wrapped/lf.nix — Lf file manager configuration
#
# Modern CLI file manager with preview and icons.
# Enable with: narbs.wrapped.lf.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.wrapped.lf;
in
{
  options.narbs.wrapped.lf = {
    enable = lib.mkEnableOption "Lf file manager";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.lf ];
    
    environment.sessionVariables = {
      LF_ICONS = "di=📁:fi=📄:ln=🔗:so=🔗:pi=📦:bd=📦:cd=📦:cu=🔒:ex=🔯:tx=📄:do=📥:dp=📤";
    };
  };
}