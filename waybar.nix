programs.waybar = {
  enable = true;
  settings = {
    mainBar = {
      layer = "top";
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "custom/weather" "battery" "network" ];

      "custom/weather" = {
        # Using a shell script just like Luke!
        exec = "curl -s 'wttr.in?format=1'";
        interval = 3600;
      };
    };
  };
};

