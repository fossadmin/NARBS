{ pkgs, ... }:

let
  # A Nix-native version of Luke's 'compiler' script
  compiler = pkgs.writeShellScriptBin "compiler" ''
    case "$1" in
      *.tex) pdflatex "$1" ;;
      *.md) ${pkgs.pandoc}/bin/pandoc "$1" -o "''${1%.md}.pdf" ;;
      *.c) ${pkgs.gcc}/bin/gcc "$1" -o "''${1%.c}" ;;
      *) echo "Don't know how to compile $1" ;;
    esac
  '';
in
{
  # Wayland-native dotfile management
  home = {
    packages = with pkgs; [
      yazi # Modern File Manager
      imv # Image viewer
      zathura # PDF viewer
      mpv # Video
      compiler
    ];
    # Custom Environment Variables (Replacing .bashrc / .zshrc)
    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "kitty";
      BROWSER = "qutebrowser";
    };
    stateVersion = "25.11";
  };

  programs = {
    # Kitty Config (Optimized for Yazi previews)
    kitty = {
      enable = true;
      settings = {
        background_opacity = "0.9";
        confirm_os_window_close = 0;
      };
    };

    # Yazi Config
    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_by = "mtime";
        };
      };
    };

    # Niri Keybindings (Scrollable tiling focus)
    niri.settings = {
      binds = {
        "Mod+Return".action = {
          spawn = [ "kitty" ];
        };
        "Mod+D".action = {
          spawn = [ "fuzzel" ];
        };
        "Mod+Q".action = {
          close-window = [ ];
        };
        # Scrolling the ribbon
        "Mod+WheelScrollRight".action = {
          focus-column-right = [ ];
        };
        "Mod+WheelScrollLeft".action = {
          focus-column-left = [ ];
        };
      };
    };
  };
}
