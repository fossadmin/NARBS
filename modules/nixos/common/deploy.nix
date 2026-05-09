{ pkgs, ... }:

let
  narbs-deploy = pkgs.writeShellScriptBin "narbs-deploy" ''
    # Determine the hostname
    HOST=$(hostname)
    # Get pool name
    POOL=$(zfs list -H -o name / | cut -d/ -f1)
    # Define a timestamped snapshot name
    SNAPSHOT_NAME="$POOL/local/root@pre-rebuild-$(date +%Y-%m-%d-%H%M)"

    echo "🛡️ Creating ZFS snapshot: $SNAPSHOT_NAME"
    sudo zfs snapshot -r $SNAPSHOT_NAME

    echo "🚀 Starting NixOS rebuild for host: $HOST"
    if sudo narbs-rebuild; then
      echo "✅ NARBS deployment successful!"
    else
      echo "❌ Deployment failed! You can roll back to the snapshot using:"
      echo "   zfs rollback -r $SNAPSHOT_NAME"
      exit 1
    fi
  '';
in
{
  home.packages = [ narbs-deploy ];
}
