# NARBS: Nix Atomic Reliable Build System

A modular, declarative NixOS configuration system. Designed for security-conscious professionals and MSP operations. 
Lean, privacy-focused, and 100% reproducible.

## 🚀 The NARBS Stack

| Component | Choice | Why? |
| :--- | :--- | :--- |
| **Installer** | `narbs.sh` | Integrated TUI setup from Minimal ISO |
| **Compositor** | Niri | Scrollable tiling workflow |
| **Terminal** | Kitty | GPU accelerated, high performance |
| **Shell** | Fish / Zsh | User-friendly with robust NARBS aliases |
| **Theming** | Tokyo Night | Integrated via wrapped programs |
| **Filesystem** | ZFS + Disko | Atomic snapshots, "Erase Your Darlings" root |
| **Persistence** | Impermanence | Stateless root with specific data preservation |
| **Secrets** | SOPS-nix | Encrypted secrets management |

## 🏗️ Architecture

```text
NARBS/
├── flake.nix              # Project entry point
├── narbs.sh               # TUI Installation wizard
├── local.nix              # YOUR private config (Gitignored!)
├── lib/
│   └── mkHost.nix         # Intelligent host builder
├── hosts/
│   ├── workstation/       # GUI Laptop/Desktop
│   ├── server/            # Headless ZFS server
│   └── router/            # Security-hardened router
├── modules/
│   └── nixos/common/      # Hardening, ZFS, Impermanence logic
└── users/                 # Dynamic user environments
```

## ⚡ Quick Start (New Install)

NARBS is designed to be installed directly from the **NixOS Minimal ISO**:

1. Boot the ISO and get internet access.
2. Clone the repo and run the installer:
   ```bash
   git clone https://github.com/yourusername/narbs
   cd narbs
   sudo ./narbs.sh
   ```
3. Follow the TUI wizard to configure your user, hostname, ZFS, and SOPS keys.
4. The script will automatically wipe your disk, set up ZFS, and install NARBS.

## 🔧 Post-Install Management

NARBS includes custom aliases for fast, machine-aware management:

- `nr` (**narbs-rebuild**): Pure rebuild of your system using your `local.nix`.
- `nd` (**narbs-deploy**): Safe rebuild with an automatic ZFS snapshot for rollback.
- `np` (**narbs-push**): Cleanly sync your config to GitHub (omitting private data).
- `na` (**narbs-audit**): Run a security vulnerability scan.
- `nh` (**narbs-help**): Show all NARBS keybindings and commands.

## 🛡️ Security & Privacy

- **Stateless Root**: Implements "Erase Your Darlings"—root is wiped on every boot.
- **Kernel Hardening**: Includes `dmesg_restrict`, `kptr_restrict`, and `rp_filter`.
- **Privacy Defaults**: Nix telemetry and coredumps are disabled by default.
- **Encrypted Secrets**: Built-in support for `sops-nix` with automated Age key generation.
- **Sandboxing**: Hardened kernel supports unprivileged user namespaces for browser sandboxing.

## 🎨 Philosophy

1. **Atomic**: Upgrades and rollbacks are instantaneous and safe via ZFS.
2. **Reliable**: No "dotfile drift"—your entire system state is in the Nix store.
3. **User-Driven**: All hardware and identity data is isolated in `local.nix`.
4. **Machine-Aware**: Use the same repo for your Workstation, Server, and Router.

## 📜 Credits

- **Luke Smith**: Inspired by the original LARBS philosophy.
- **Graham Christensen**: "Erase Your Darlings" ZFS pattern.
- **Vimjoyer**: Wrapped program patterns and Tokyo Night aesthetics.
