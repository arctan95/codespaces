{ config, userConfig, pkgs, lib, ... }:

{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = map (name: pkgs.${name}) userConfig.nix.packages;

  home.file = userConfig.home.file;

  home.sessionVariables = userConfig.env;

  # Set zsh as default shell on activation
  home.activation.make-zsh-default-shell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # if zsh is not the current shell
      PATH="/usr/bin:/bin:$PATH"
      ZSH_PATH="/home/${builtins.getEnv "USER"}/.nix-profile/bin/zsh"
      if [[ $(getent passwd ${builtins.getEnv "USER"}) != *"$ZSH_PATH" ]]; then
        echo "Setting zsh as default shell..."
        if ! grep -q $ZSH_PATH /etc/shells; then
          echo "Adding zsh to /etc/shells"
          run echo "$ZSH_PATH" | sudo tee -a /etc/shells
        fi
        echo "Running chsh to make zsh the default shell"
        run sudo chsh -s $ZSH_PATH ${builtins.getEnv "USER"}
        echo "Zsh is now set as default shell!"
      fi
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Git
  programs.git = {
    enable = true;
    userName = userConfig.git.username;
    userEmail = userConfig.git.email;
  };

  # Fzf
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Neovim
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];
    extraLuaConfig = builtins.readFile "${builtins.getEnv "HOME"}/.codespaces/.config/nvim/init.lua";
  };

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    shellAliases = userConfig.alias;
    initContent = ''
      export PATH="$HOME/.asdf/shims:$PATH"
    '';

    oh-my-zsh = {
      enable = true;
      plugins = userConfig.omz.plugins;
      theme = userConfig.omz.theme;
    };
  };
}
