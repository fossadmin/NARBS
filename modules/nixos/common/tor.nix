# modules/nixos/tor.nix — Tor/Anonymity module
#
# Tor Browser and Tor service.
# Enable with: narbs.tor.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.tor;
in
{
  options.narbs.tor = {
    enable = lib.mkEnableOption "NARBS Tor anonymization";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tor-browser
    ];

    services.tor = {
      enable = true;
      torsocks.enable = true;
      client.enable = true;
    };
  };
}