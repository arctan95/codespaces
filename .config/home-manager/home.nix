{ config, pkgs, ... }:

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
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    asdf-vm
    pass
    tldr
    tree
  ];

  home.file = {
    ".asdf/lib".source = "${pkgs.asdf-vm}/share/asdf-vm/lib";
    ".asdf/completions".source = "${pkgs.asdf-vm}/share/asdf-vm/completions";
    ".asdf/asdf.sh".source = "${pkgs.asdf-vm}/share/asdf-vm/asdf.sh";
  };

  home.sessionVariables = {
    DISABLE_MAGIC_FUNCTIONS = "true";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Git
  programs.git = {
    enable = true;
    userName = "arctan95";
    userEmail = "jaeqentan@gmail.com";
  };

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    shellAliases = {
      hm = "home-manager";
      hms = "home-manager switch --impure";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "asdf" "git" "pass" "z" ];
      theme = "bira";
    };
  };
}
