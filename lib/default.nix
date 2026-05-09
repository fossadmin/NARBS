# lib/default.nix — NARBS library re-exports
#
# Re-exports mkHost and related utilities for use in flake.nix

{ inputs, ... }:

{
  # Import mkHost with inputs bound
  mkHost = import ./mkHost.nix { inherit inputs; };
  
  # Common imports for convenience
  lib = inputs.nixpkgs.lib;
}