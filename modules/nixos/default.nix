# modules/nixos/default.nix — NARBS NixOS module exports
#
# Re-exports all NARBS NixOS modules for use in flake.nix

{ ... }: {
  imports = [
    # Common modules
    ./common/shell.nix
    ./common/stylix.nix
    ./common/theme.nix
    ./common/local.nix
    ./common/security.nix
    ./common/users.nix
    ./common/starship.nix
    ./common/deploy.nix
    ./common/secrets.nix
    ./common/yazi
    ./common/power.nix
    ./common/bluetooth.nix
    ./common/automount.nix
    ./common/virtualization.nix
    ./common/printing.nix
    ./common/impermanence.nix
    ./common/disko.nix
    ./common/tor.nix
    
    # System type modules
    ./workstation/desktop.nix
    ./headless/default.nix
  ];
}