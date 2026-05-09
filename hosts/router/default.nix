# hosts/router/default.nix — NARBS Router Configuration
#
# Uses mkHost pattern for simplicity.
# Hardware config is in ./hardware.nix

{ inputs, lib, localConfig }:

let
  mkHost = import ../../lib/mkHost.nix { inherit inputs; };
in

mkHost {
  system = "x86_64-linux";
  hostDir = ./.;  # This host's directory
  type = "router";
  stateVersion = "25.05";
  localConfig = localConfig;
}