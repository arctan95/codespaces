{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, home-manager, systems, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
      userConfig = builtins.fromTOML (builtins.readFile "${builtins.getEnv "HOME"}/.codespaces/config.toml");
      specialArgs = {
        inherit userConfig;
      };
    in
    {
      packages = eachSystem (system: {
        homeConfigurations = {
          "${builtins.getEnv "USER"}" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${system};
            # Specify your home configuration modules here, for example,
            # the path to your home.nix.
            modules = [ .config/home-manager/home.nix ];

            # Optionally use extraSpecialArgs
            # to pass through arguments to home.nix
            extraSpecialArgs = specialArgs;
          };
        };
      });
    };
}
