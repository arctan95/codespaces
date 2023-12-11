{
  description = "Home Manager configuration of codespace";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        user = "codespace";
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.homeConfigurations = {
          ${user} = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;

            # Specify your home configuration modules here, for example,
            # the path to your home.nix.
            modules = [ .config/home-manager/home.nix ];

            # Optionally use extraSpecialArgs
            # to pass through arguments to home.nix
          };
        };
      }
    );
}
