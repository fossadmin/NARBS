# modules/home/locale.nix — Locale module (Home Manager)
#
# Locale and timezone configuration.
# Enable with: home.manager.modules.locale.enable = true;

{ ... }:

{
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
}