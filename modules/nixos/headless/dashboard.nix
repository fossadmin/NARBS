{ config, ... }:
{
  services.homepage-dashboard = {
    enable = true;
    widget.key = config.sops.secrets."dashboard/api_key".path;
    # Layout and Widgets
    settings = {
      title = "NARBS Server Node";
      background = {
        image = "https://raw.githubusercontent.com/tokyo-night/tokyo-night-vscode-theme/master/assets/wallpaper.png";
      };
    };
    services = [
      {
        "System" = [
          {
            "Stats" = {
              icon = "si-nixos";
              href = "http://localhost";
              widget = {
                type = "glances"; # Requires glances service enabled
                url = "http://localhost:61208";
              };
            };
          }
        ];
      }
      {
        "Development" = [
          {
            "GitHub" = {
              icon = "si-github";
              href = "https://github.com/yourusername/narbs";
              description = "NARBS Dotfiles";
            };
          }
        ];
      }
    ];
  };
}
