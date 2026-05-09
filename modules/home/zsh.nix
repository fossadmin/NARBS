# modules/home/zsh.nix — Zsh module (Home Manager)
#
# Zsh configuration with Oh My Zsh.
# Enable with: home.manager.modules.zsh.enable = true;

{ pkgs, lib, ... }:

let
  cfg = lib.mkIf (lib.hasAttr "modules" config.home-manager)
    (config.home-manager.modules.zsh or {});
in
{
  # Define option for enabling
  options.home-manager.modules.zsh = {
    enable = lib.mkEnableOption "NARBS Zsh (Oh My Zsh)";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      shellAliases = {
        ".." = "cd ..";
        nv = "nvim";
        ls = "eza --icons";
        la = "eza -a --icons";
        y = "yazi";
        top = "btm";
        dots = "cd ~/.dots";

        # system maintenance
        update = "sudo nix flake update --flake ~/.dots/";
        upgrade = "sudo nixos-rebuild switch --flake ~/.dots/#nix-node";
        cleanup = "sudo nix-collect-garbage -d && nix-collect-garbage -d && sudo nix store gc && nix store gc";
        narbs-update = "sudo nixos-rebuild switch --flake . --update";
        narbs-clean = "sudo nix-collect-garbage -d && nix-store --optimize";
        try = "nix shell nixpkgs#$1";
        pydev = "nix shell nixpkgs#python3 nixpkgs#python3Packages.pip";
        nodev = "nix shell nixpkgs#nodejs nixpkgs#yarn";
      };
      autosuggestions.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = "jonathan";
        plugins = [
          "git"
          "git ssh-agent"
          "git-auto-fetch"
          "sudo"
          "systemadmin"
          "vi-mode"
          "eza"
          "rsync"
          "systemd"
          "zsh-interactive-cd"
        ];
      };
      shellInit = ''
        prompt_context(){
          prompt_segment blue default "nixos "
        }

        function yy() {
        	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        	yazi "$@" --cwd-file="$tmp"
        	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        		cd -- "$cwd"
        	fi
        	rm -f -- "$tmp"
        }

        eval "$(direnv hook zsh)"
      '';
    };

    environment.shells = [ pkgs.zsh ];
    users.defaultUserShell = pkgs.zsh;
    environment.binsh = "${pkgs.zsh}/bin/zsh";
  };
}