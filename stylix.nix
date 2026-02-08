{ pkgs, ... }:

{
  stylix = {
    enable = true;
    # Choose your flavor of Tokyo Night
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    # Stylix REQUIRES a wallpaper to generate certain colors
    image = ./wallpaper.png;

    # Global Font Settings (Modern-Unix style)
    fonts = {
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      size = 10;
    };

    # This will automatically theme:
    # Niri, Kitty, Yazi, Waybar, Greetd, and even your Bootloader!
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
  };
}
