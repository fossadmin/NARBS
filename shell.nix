# shell.nix - NARBS Development Shell
#
# Use: `nix develop` to enter the development environment.

{ pkgs }:

pkgs.mkShell {
  packages = with pkgs; [
    # Git tools
    git
    git-crypt
    
    # Nix tools
    nil
    nixfmt-rfc-style
    deadnix
    statix
    nix-tree
    
    # Text editors
    neovim
    helix
    
    # Shells
    zsh
    fish
    
    # Utils
    tree
    lf
    bottom
    eza
    bat
    fzf
    ripgrep
    fd
    jq
    yq-go
    xh
    httpie
    
    # Build/Deploy
    deploy-rs
    
    # Secrets
    sops
    
    # Documentation
    pandoc
    markdownlint-cli
  ];
  
  shellType = "zsh";
  
  shellHook = ''
    export EDITOR=nvim
    export VISUAL=nvim
    alias ll='eza -la --icons'
    alias la='eza -a --icons'
    alias lt='eza --tree --level=2'
  '';
}