# modules/nixos/common/starship.nix — Starship module
#
# Starship prompt configuration (works with Stylix for theming).
# Enable with: narbs.starship.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.starship;
in
{
  options.narbs.starship = {
    enable = lib.mkEnableOption "NARBS Starship prompt";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      # Stylix handles the colors, we just define the symbols
      settings = {
        add_newline = false;
        # Add a custom NixOS symbol at the start
        format = "$os$hostname$directory$git_branch$character";

        hostname = {
          ssh_only = true; # Only shows up when you are SSH'd in
          format = " on [$hostname](bold red) "; # Bright Red warning
          trim_at = ".";
          disabled = false;
        };

        os = {
          disabled = false;
          symbols.NixOS = "nixos "; # Requires a Nerd Font
        };

        character = {
          success_symbol = "[nixos](bold magenta)";
          error_symbol = "[nixos](bold red)";
        };

        directory = {
          style = "bold blue";
        };
      };
    };
  };
}