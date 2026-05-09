# modules/home/kanata.nix — Kanata module (Home Manager)
#
# Keyboard remapping with Kanata.
# Enable with: home.manager.modules.kanata.enable = true;

{ ... }:

{
  services.kanata = {
    enable = true;
    keyboards.main = {
      devices = [
        "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
      ];
      config = ''
        (defsrc
          caps lctl lalt ralt rmet left up down right
        )
        (deflayermap (default-layer)
          caps (tap-hold 150 150 esc lctrl)
          rmet pgup
          ralt pgdn
          lalt lmet
          lmet lalt
        )
      '';
    };
  };
}