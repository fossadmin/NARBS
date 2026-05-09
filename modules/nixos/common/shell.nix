# modules/nixos/common/shell.nix — Shell module
#
# Zsh and Starship configuration with Tokyo Night theming.
# Enable with: narbs.shell.enable = true;

{ config, lib, pkgs, ... }:

let
  cfg = config.narbs.shell;
in
{
  options.narbs.shell = {
    enable = lib.mkEnableOption "NARBS shell (Zsh + Starship)";
    
    editor = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "Default editor";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      
      # LARBS-style aliases
      shellAliases = {
        # Editor shortcuts
        v = "nvim";
        
        # Modern coreutils replacements
        ls = "eza --icons";
        la = "eza --all --icons";
        ll = "eza -l --icons";
        lt = "eza --tree --level=2";
        
        # File manager
        y = "yazi";
        
        # System monitoring
        top = "btop";
        
        # Navigation
        ".." = "cd ..";
        "..." = "cd ../..";
        
        # NARBS commands
        narbs-push = "sudo /etc/nixos/narbs-push";
        narbs-deploy = "sudo /etc/nixos/narbs-deploy";
      };
    };

    # Starship prompt with NixOS logo and SSH warning
    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        
        # Format: OS icon, hostname (SSH only), directory, git, character
        format = "$os$hostname$git_branch$character";
        
        # Show NixOS logo
        os = {
          disabled = false;
          symbols.NixOS = "nixos ";
        };
        
        # Show hostname in bold red when SSH'd in (safety feature)
        hostname = {
          ssh_only = true;
          format = " on [$hostname](bold red) ";
          trim_at = ".";
          disabled = false;
        };
        
        # Lambda prompt
        character = {
          success_symbol = "[nixos](bold magenta) ";
          error_symbol = "[nixos](bold red) ";
        };
        
        # Directory styling
        directory = {
          style = "bold blue";
          truncation_length = 3;
          truncate_to_repo = true;
        };
      };
    };
  };
}