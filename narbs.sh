#!/usr/bin/env bash
# NARBS Setup Script
# Generates local.nix for NixOS configuration

set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NARBS_DIR="$SCRIPT_DIR"

# Default to TUI mode
USE_TUI=1
for arg in "$@"; do
  case "$arg" in
  --cli) USE_TUI=0 ;;
  --tui | --whiptail) USE_TUI=1 ;;
  --help | -h)
    echo "Usage: $0 [--cli | --tui]"
    echo "  TUI mode is default when running in a terminal."
    exit 0
    ;;
  esac
done

# Root check
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Error: This script must be run as root.${NC}"
  echo "Please run: sudo ./narbs.sh"
  exit 1
fi

# Detect if we should use TUI
should_tui() {
  [ "$USE_TUI" -eq 0 ] && return 1
  [ ! -t 0 ] && return 1

  if ! command -v whiptail &>/dev/null; then
    if command -v nix-shell &>/dev/null; then
      echo "Installing whiptail (newt) via nix-shell..."
      export NIX_SHELL_ACTIVE=1
      exec nix-shell -p newt --command "exec '$0' '$@'"
    else
      echo "whiptail not found and nix-shell not available. Falling back to CLI mode."
      return 1
    fi
  fi
  return 0
}

# --- TUI MODE ---
run_tui() {
  local DIALOG="whiptail"

  # Change input text to black, keeping the blue background
  export NEWT_COLORS='
    entry=black,blue
  '

  # Welcome
  $DIALOG --title "NARBS Setup" \
    --msgbox "Welcome to NARBS Setup!

NARBS: Nix Atomic Reliable Build System

This script will configure NARBS for your machine.
It will ask questions and create local.nix." \
    15 60 || exit 1

  # Username
  username=$(whiptail --title "NARBS Setup" --inputbox "Enter your username (lowercase, no spaces):" 10 60 3>&1 1>&2 2>&3) || exit 1
  while true; do
    if [ -n "$username" ]; then
      if echo "$username" | grep -qE "^[a-z_][a-z0-9_-]*$"; then
        break
      else
        $DIALOG --title "Error" --msgbox "Invalid username. Must start with a lowercase letter and contain only lowercase letters, numbers, - or _" 8 50
        username=$(whiptail --title "NARBS Setup" --inputbox "Enter your username (lowercase, no spaces):" 10 60 3>&1 1>&2 2>&3) || exit 1
      fi
    else
      username=$(whiptail --title "NARBS Setup" --inputbox "Enter your username (lowercase, no spaces):" 10 60 3>&1 1>&2 2>&3) || exit 1
    fi
  done

  full_name=$(whiptail --title "NARBS Setup" --inputbox "Enter your full name (Real Name):" 10 60 3>&1 1>&2 2>&3) || exit 1
  user_email=$(whiptail --title "NARBS Setup" --inputbox "Enter your email:" 10 60 3>&1 1>&2 2>&3) || exit 1

  hostname=$(whiptail --title "NARBS Setup" --inputbox "Enter hostname for this machine:" 10 60 3>&1 1>&2 2>&3) || exit 1
  while [ -z "$hostname" ]; do
    $DIALOG --title "Error" --msgbox "Hostname cannot be empty." 8 40
    hostname=$(whiptail --title "NARBS Setup" --inputbox "Enter hostname for this machine:" 10 60 3>&1 1>&2 2>&3) || exit 1
  done

  host_type=$(whiptail --title "Select host type" --menu "Select host type:" 20 60 10 \
    "workstation" "Laptop/Desktop with GUI" \
    "server" "Headless server" \
    "router" "Router/firewall" 3>&1 1>&2 2>&3) || exit 1

  timezone=$(whiptail --title "NARBS Setup" --inputbox "Enter timezone:" 10 60 "America/Los_Angeles" 3>&1 1>&2 2>&3) || exit 1

  # Security / SOPS options
  setup_secrets=$(whiptail --title "Security" --yesno "Would you like to generate SSH and Age keys for sops-nix?" 10 60 3>&1 1>&2 2>&3 && echo "yes" || echo "no")

  if [ "$setup_secrets" = "yes" ]; then
    ssh_key_path="/persist/etc/ssh/ssh_host_ed25519_key"
    age_key_path="/persist/var/lib/sops-nix/key.txt"
  else
    ssh_key_path=""
    age_key_path=""
  fi

  # ZFS options
  if [ "$host_type" != "router" ]; then
    # HostId first
    hostid_choice=$(whiptail --title "ZFS Configuration" --menu "Choose ZFS HostId method:" 20 60 10 \
      "generate" "Auto-generate new hostId" \
      "manual" "Enter existing hostId manually" \
      "none" "No ZFS (disable)" 3>&1 1>&2 2>&3) || exit 1

    case "$hostid_choice" in
    generate)
      hostid=$(od -An -tx1 -N4 /dev/urandom 2>/dev/null | tr -d ' \n' | head -c 8)
      $DIALOG --title "Generated" --msgbox "Generated hostId: $hostid" 8 40
      [ "$host_type" = "workstation" ] && pool_name="rpool" || pool_name="zroot"
      ;;
    manual)
      hostid=$(whiptail --title "NARBS Setup" --inputbox "Enter 8-character hex hostId:" 10 60 3>&1 1>&2 2>&3) || exit 1
      [ "$host_type" = "workstation" ] && pool_name="rpool" || pool_name="zroot"
      ;;
    none)
      hostid=""
      pool_name=""
      ;;
    esac

    # Disk
    local disks=()
    if [ -d "/dev/disk/by-id" ]; then
      for dev in /dev/disk/by-id/*; do
        [[ -e "$dev" ]] || continue
        [[ "$dev" == *-part* ]] || [[ "$dev" == *wwn-* ]] || [[ "$dev" == *dm-* ]] || [[ "$dev" == *eui.* ]] || [[ "$dev" == *_1 ]] && continue

        local target=$(readlink -f "$dev")
        local name=$(basename "$target")
        [[ "$name" == loop* ]] || [[ "$name" == sr* ]] && continue

        local size=""
        command -v lsblk &>/dev/null && size=$(lsblk -dno SIZE "$target" 2>/dev/null | xargs)

        disks+=("$dev" "$name ($size)")
      done
    fi

    if [ ${#disks[@]} -eq 0 ]; then
      disks+=("/dev/sda" "SATA disk")
      disks+=("/dev/nvme0n1" "NVMe disk")
    fi

    disk_device=$(whiptail --title "Disk Device" --menu "Select installation disk:" 20 60 10 "${disks[@]}" 3>&1 1>&2 2>&3) || exit 1
  else
    pool_name=""
    hostid=""

    local disks=()
    if [ -d "/dev/disk/by-id" ]; then
      for dev in /dev/disk/by-id/*; do
        [[ -e "$dev" ]] || continue
        [[ "$dev" == *-part* ]] || [[ "$dev" == *wwn-* ]] || [[ "$dev" == *dm-* ]] || [[ "$dev" == *eui.* ]] || [[ "$dev" == *_1 ]] && continue

        local target=$(readlink -f "$dev")
        local name=$(basename "$target")
        [[ "$name" == loop* ]] || [[ "$name" == sr* ]] && continue

        local size=""
        command -v lsblk &>/dev/null && size=$(lsblk -dno SIZE "$target" 2>/dev/null | xargs)

        disks+=("$dev" "$name ($size)")
      done
    fi

    if [ ${#disks[@]} -eq 0 ]; then
      disks+=("/dev/sda" "SATA disk")
      disks+=("/dev/nvme0n1" "NVMe disk")
    fi

    disk_device=$(whiptail --title "Disk Device" --menu "Select disk:" 20 60 10 "${disks[@]}" 3>&1 1>&2 2>&3) || exit 1
  fi

  generate_local_nix "$username" "$full_name" "$user_email" "$host_type" "$hostname" "$hostid" "$disk_device" "$pool_name" "$timezone" "$ssh_key_path" "$age_key_path"

  $DIALOG --title "Installation" --yesno "Configuration saved to local.nix.

Would you like to proceed with the installation?

This will:
1. Format your disk using Disko
2. Install NixOS to /mnt
3. Set your initial password

WARNING: ALL DATA ON $disk_device WILL BE LOST!" 15 60 || exit 0

  # Installation logic
  clear
  echo -e "${YELLOW}Starting NARBS Installation...${NC}"

  # 1. Run Disko
  echo -e "\n${BLUE}Step 1: Partitioning and Formatting disk...${NC}"
  # Use zap_create_mount to ensure a clean slate
  nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode zap_create_mount --flake ".#$host_type"

  # 2. Install NixOS
  echo -e "\n${BLUE}Step 2: Installing NixOS to /mnt...${NC}"
  # Temporarily force-add local.nix to git so nix can see it without --impure
  git add -f local.nix 2>/dev/null || true

  # --no-root-passwd lets the user set it at the end of the install
  nixos-install --flake ".#$host_type" --no-root-passwd

  # Untrack local.nix after install
  git reset local.nix 2>/dev/null || true

  # 3. Post-install: Setup keys for SOPS if requested
  if [ -n "$ssh_key_path" ]; then
    echo -e "\n${BLUE}Step 3: Generating SOPS keys...${NC}"

    # Generate SSH host key (also used for SOPS)
    mkdir -p "/mnt$(dirname "$ssh_key_path")"
    ssh-keygen -t ed25519 -N "" -f "/mnt$ssh_key_path"

    # Generate Age key from SSH key using ssh-to-age
    mkdir -p "/mnt$(dirname "$age_key_path")"
    nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /mnt$ssh_key_path > /mnt$age_key_path"

    echo "Keys generated:"
    echo "  SSH: $ssh_key_path"
    echo "  Age: $age_key_path"
  fi

  echo -e "\n${GREEN}Installation Complete!${NC}"
  echo "You can now reboot into your new NARBS system."
}

# --- CLI MODE ---
run_cli() {
  # Prompt for input
  prompt() {
    local prompt="$1"
    local default="$2"
    local value

    printf "%s" "$prompt"
    [ -n "$default" ] && printf " [%s]" "$default"
    printf ": "

    read -r value </dev/tty
    [ -z "$value" ] && value="$default"
    echo "$value"
  }

  # Prompt with numbered choices
  prompt_choice() {
    local prompt="$1"
    local default="$2"
    shift 2
    local opts=("$@")
    local n=$#
    local choice

    while true; do
      echo ""
      echo "$prompt"
      local i=1
      for opt in "$@"; do
        echo "  $i) $opt"
        i=$((i + 1))
      done

      printf "Choice [%s]: " "$default"

      read -r choice </dev/tty
      choice="${choice:-$default}"
      if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $n ]; then
        i=1
        for opt in "$@"; do
          [ "$choice" = "$i" ] && {
            echo "$opt"
            return 0
          }
          i=$((i + 1))
        done
      fi
      echo "  Invalid choice (enter 1-$n)"
    done
  }

  # Generate random 8-char hex hostId
  generate_hostid() {
    od -An -tx1 -N4 /dev/urandom 2>/dev/null | tr -d ' \n' | head -c 8
  }

  # Get disks
  get_disks() {
    command -v lsblk &>/dev/null && lsblk -dndo name,size,type 2>/dev/null | grep -v 'loop\|sr0' || true
  }

  # Main
  echo ""
  echo -e "${BLUE}NARBS Setup${NC}"
  echo "Nix Atomic Reliable Build System"
  echo ""

  # Username
  while true; do
    printf "Username: "
    read -r username </dev/tty
    if [ -n "$username" ] && echo "$username" | grep -qE "^[a-z_][a-z0-9_-]*$"; then
      break
    fi
    [ -n "$username" ] && echo "  Invalid. Use lowercase letters, numbers, - or _"
  done

  full_name=$(prompt "Full Name" "")
  user_email=$(prompt "Email" "")

  # Hostname
  while true; do
    printf "Hostname: "
    read -r hostname </dev/tty
    [ -n "$hostname" ] && break
    echo "  Hostname cannot be empty"
  done

  host_type=$(prompt_choice "Select host type" 1 "workstation" "server" "router")
  timezone=$(prompt "Timezone" "America/Los_Angeles")

  # Security / SOPS options
  echo -n "Would you like to generate SSH and Age keys for sops-nix? (y/N): "
  read -r setup_secrets </dev/tty
  if [[ "$setup_secrets" =~ ^[Yy]$ ]]; then
    ssh_key_path="/persist/etc/ssh/ssh_host_ed25519_key"
    age_key_path="/persist/var/lib/sops-nix/key.txt"
  else
    ssh_key_path=""
    age_key_path=""
  fi

  # ZFS options
  if [ "$host_type" != "router" ]; then
    hostid_choice=$(prompt_choice "ZFS Configuration" 1 "Auto-generate HostId" "Enter HostId manually" "No ZFS (disable)")

    case "$hostid_choice" in
    "Enter HostId manually")
      hostid=$(prompt "Enter 8-char hex hostId" "")
      [ "$host_type" = "workstation" ] && pool_name="rpool" || pool_name="zroot"
      ;;
    "No ZFS (disable)")
      hostid=""
      pool_name=""
      ;;
    *)
      hostid=$(generate_hostid)
      echo "  Generated HostId: $hostid"
      [ "$host_type" = "workstation" ] && pool_name="rpool" || pool_name="zroot"
      ;;
    esac

    local disk_opts=()
    if [ -d "/dev/disk/by-id" ]; then
      for dev in /dev/disk/by-id/*; do
        [[ -e "$dev" ]] || continue
        [[ "$dev" == *-part* ]] || [[ "$dev" == *wwn-* ]] || [[ "$dev" == *dm-* ]] || [[ "$dev" == *eui.* ]] || [[ "$dev" == *_1 ]] && continue

        local target=$(readlink -f "$dev")
        local name=$(basename "$target")
        [[ "$name" == loop* ]] || [[ "$name" == sr* ]] && continue

        disk_opts+=("$dev")
      done
    fi
    [ ${#disk_opts[@]} -eq 0 ] && disk_opts=("/dev/sda" "/dev/nvme0n1")

    disk_device=$(prompt_choice "Select Disk Device" 1 "${disk_opts[@]}")
  else
    pool_name=""
    hostid=""

    local disk_opts=()
    if [ -d "/dev/disk/by-id" ]; then
      for dev in /dev/disk/by-id/*; do
        [[ -e "$dev" ]] || continue
        [[ "$dev" == *-part* ]] || [[ "$dev" == *wwn-* ]] || [[ "$dev" == *dm-* ]] || [[ "$dev" == *eui.* ]] || [[ "$dev" == *_1 ]] && continue

        local target=$(readlink -f "$dev")
        local name=$(basename "$target")
        [[ "$name" == loop* ]] || [[ "$name" == sr* ]] && continue

        disk_opts+=("$dev")
      done
    fi
    [ ${#disk_opts[@]} -eq 0 ] && disk_opts=("/dev/sda" "/dev/nvme0n1")

    disk_device=$(prompt_choice "Select Disk Device" 1 "${disk_opts[@]}")
  fi

  generate_local_nix "$username" "$full_name" "$user_email" "$host_type" "$hostname" "$hostid" "$disk_device" "$pool_name" "$timezone" "$ssh_key_path" "$age_key_path"

  echo -e "\n${GREEN}Configuration saved to local.nix.${NC}"
  echo -e "${RED}WARNING: The next step will format $disk_device and ERASE ALL DATA!${NC}"
  read -p "Do you want to proceed with the installation? (y/N): " confirm </dev/tty
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 0
  fi

  # Installation logic
  echo -e "\n${YELLOW}Starting NARBS Installation...${NC}"

  # 1. Run Disko
  echo -e "\n${BLUE}Step 1: Partitioning and Formatting disk...${NC}"
  # Use zap_create_mount to ensure a clean slate
  nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode zap_create_mount --flake ".#$host_type"

  # 2. Install NixOS
  echo -e "\n${BLUE}Step 2: Installing NixOS to /mnt...${NC}"
  # --no-root-passwd lets the user set it at the end of the install
  nixos-install --flake ".#$host_type" --no-root-passwd

  echo -e "\n${GREEN}Installation Complete!${NC}"
  echo "You can now reboot into your new NARBS system."
}

generate_local_nix() {
  local username="$1"
  local full_name="$2"
  local user_email="$3"
  local host_type="$4"
  local hostname="$5"
  local hostid="$6"
  local disk_device="$7"
  local pool_name="$8"
  local timezone="$9"
  local ssh_key_path="${10:-}"
  local age_key_path="${11:-}"

  local workstation_hostname="narbs-workstation"
  local workstation_hostid="aaaaaaaa"
  local workstation_disk="/dev/nvme0n1"
  local workstation_zfs="true"

  local server_hostname="narbs-server"
  local server_hostid="bbbbbbbb"
  local server_disk="/dev/sda"
  local server_zfs="true"

  local router_hostname="narbs-router"
  local router_hostid="cccccccc"
  local router_disk="/dev/sda"
  local router_zfs="false"

  case "$host_type" in
  workstation)
    workstation_hostname="$hostname"
    workstation_hostid="$hostid"
    workstation_disk="$disk_device"
    workstation_zfs=$([ -n "$hostid" ] && echo "true" || echo "false")
    ;;
  server)
    server_hostname="$hostname"
    server_hostid="$hostid"
    server_disk="$disk_device"
    server_zfs=$([ -n "$hostid" ] && echo "true" || echo "false")
    ;;
  router)
    router_hostname="$hostname"
    router_hostid="$hostid"
    router_disk="$disk_device"
    router_zfs=$([ -n "$hostid" ] && echo "true" || echo "false")
    ;;
  esac

  cat >"$NARBS_DIR/local.nix" <<EOF
# local.nix — Local configuration (NOT TRACKED BY GIT)
#
# This file is for user-specific configuration that should NOT be committed to git.
# It contains sensitive information like API keys, credentials, and machine-specific values.
#
# Generated by narbs.sh
#
# IMPORTANT: local.nix is in .gitignore - DO NOT commit it!

{
  # ============================================================
  # USER CONFIGURATION
  # ============================================================
  
  # Primary username (used for user creation, home directory, etc.)
  user = "${username}";
  
  # User's real name (for git config, etc.)
  userName = "${full_name}";
  
  # User email (for git config)
  userEmail = "${user_email}";
  
  # ============================================================
  # MACHINE-SPECIFIC CONFIGURATION
  # ============================================================
  
  # Generate unique 8-digit hex ID for each machine:
  #   python3 -c "import random; print(f'{random.randint(0, 0xffffffff):08x}')"
  
  machines = {
    workstation = {
      hostName = "${workstation_hostname}";
      hostId = "${workstation_hostid}";
      diskDevice = "${workstation_disk}";
      enableZFS = ${workstation_zfs};
    };
    
    server = {
      hostName = "${server_hostname}"; 
      hostId = "${server_hostid}";
      diskDevice = "${server_disk}";
      enableZFS = ${server_zfs};
    };
    
    router = {
      hostName = "${router_hostname}";
      hostId = "${router_hostid}";
      diskDevice = "${router_disk}";
      enableZFS = ${router_zfs};
    };
  };
  
  # Default ZFS pool name
  poolName = "${pool_name:-zroot}";
  
  # ============================================================
  # LOCALE & TIMEZONE
  # ============================================================
  
  locale = {
    timeZone = "${timezone}";
    language = "en_US.UTF-8";
  };
  
  # ============================================================
  # PRIVATE SECRETS (Optional - for advanced use)
  # ============================================================
  # These are typically managed by sops-nix or agenix
  # Uncomment and use if needed:
  #
  secrets = {
    # Path to SSH private key file
    sshKeyPath = "${ssh_key_path}";
    
    # Age key file for sops
    ageKeyPath = "${age_key_path}";
  };
}
EOF
}

# Run in appropriate mode
if should_tui; then
  run_tui
else
  run_cli
fi
