# scripts.nix - Custom NARBS scripts for the admin user
{ pkgs, ... }:

let
  narbs-rebuild = pkgs.writeShellScriptBin "narbs-rebuild" ''
    ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo "$(pwd)")
    cd "$ROOT_DIR"
    if [ ! -f "local.nix" ]; then
      echo "Error: local.nix not found in $ROOT_DIR"
      exit 1
    fi
    CURRENT_HOST=$(hostname)
    HOST_TYPE=$(grep -B 5 "hostName = \"$CURRENT_HOST\";" local.nix | grep -E "^[[:space:]]+(workstation|server|router)[[:space:]]*=" | head -n 1 | tr -d ' ={[:space:]}' | cut -d= -f1)
    if [ -z "$HOST_TYPE" ]; then
      echo "Warning: Current hostname '$CURRENT_HOST' not found in local.nix machines."
      echo "Falling back to 'workstation'..."
      HOST_TYPE="workstation"
    fi
    echo "Rebuilding NARBS for machine type: $HOST_TYPE (Host: $CURRENT_HOST)"
    echo "Tracking local.nix..."
    git add -f local.nix 2>/dev/null || true
    if sudo nixos-rebuild switch --flake ".#$HOST_TYPE" "$@"; then
      echo -e "\nNARBS rebuild successful!"
    else
      echo -e "\nNARBS rebuild failed!"
      git reset local.nix 2>/dev/null || true
      exit 1
    fi
    echo "Resetting local.nix..."
    git reset local.nix 2>/dev/null || true
  '';

  narbs-deploy = pkgs.writeShellScriptBin "narbs-deploy" ''
    HOST=$(hostname)
    POOL=$(zfs list -H -o name / | cut -d/ -f1)
    SNAPSHOT_NAME="$POOL/local/root@pre-rebuild-$(date +%Y-%m-%d-%H%M)"
    echo "Creating ZFS snapshot: $SNAPSHOT_NAME"
    sudo zfs snapshot -r $SNAPSHOT_NAME
    ${narbs-rebuild}/bin/narbs-rebuild "$@"
  '';

  narbs-push = pkgs.writeShellScriptBin "narbs-push" ''
    ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo "$(pwd)")
    cd "$ROOT_DIR"
    if [ -d .git ]; then
      git add .
      git commit -m "NARBS Update: $(date +'%Y-%m-%d %H:%M:%S')"
      git push origin main
      echo "NARBS config synced to GitHub!"
    else
      echo "Error: Not a git repository."
    fi
  '';

  narbs-audit = pkgs.writeShellScriptBin "narbs-audit" ''
    echo "Starting NARBS Security Audit..."
    ${pkgs.vulnix}/bin/vulnix --system || true
    echo ""
    echo "Audit complete."
  '';

  narbs-help = pkgs.writeShellScriptBin "narbs-help" ''
    echo "  NARBS Keybindings"
    echo "  -----------------"
    echo "  Mod + Return : Open Kitty"
    echo "  Mod + D      : App Launcher (Fuzzel)"
    echo "  Mod + Q      : Close Window"
    echo "  Mod + F      : Toggle Fullscreen"
    echo "  Mod + H/J/K/L: Move Focus (vim-style)"
    echo "  Mod + Space  : Toggle Floating"
    echo "  Mod + Wheel  : Scroll Niri columns"
    echo ""
    echo "  NARBS Commands"
    echo "  --------------"
    echo "  y            : Open Yazi file manager"
    echo "  v            : Open Neovim"
    echo "  nr (rebuild) : Normal update (pure)"
    echo "  nd (deploy)  : Safe update (with ZFS snapshot)"
    echo "  np (push)    : Sync config to GitHub"
    echo "  na (audit)   : Run security audit"
  '';

  try = pkgs.writeShellScriptBin "try" ''
    if [ -z "$1" ]; then
      echo "Usage: try <package>"
      exit 1
    fi
    nix shell nixpkgs#$1 --command $1
  '';

  # Short aliases
  nr = pkgs.writeShellScriptBin "nr" "exec ${narbs-rebuild}/bin/narbs-rebuild \"$@\"";
  nd = pkgs.writeShellScriptBin "nd" "exec ${narbs-deploy}/bin/narbs-deploy \"$@\"";
  np = pkgs.writeShellScriptBin "np" "exec ${narbs-push}/bin/narbs-push \"$@\"";
  na = pkgs.writeShellScriptBin "na" "exec ${narbs-audit}/bin/narbs-audit \"$@\"";
  nh = pkgs.writeShellScriptBin "nh" "exec ${narbs-help}/bin/narbs-help \"$@\"";

in
{
  home.packages = [
    narbs-rebuild
    narbs-deploy
    narbs-push
    narbs-audit
    narbs-help
    try
    
    # Short aliases
    nr
    nd
    np
    na
    nh

    pkgs.vulnix
    pkgs.osv-scanner
  ];
}
