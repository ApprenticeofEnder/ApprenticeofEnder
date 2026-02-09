{
  description = "A home-manager template providing useful tools & settings for Nix-based development";

  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # TODO: Revert to "nixpkgs" once inetutils-2.7 build issue is fixed in nixos-25.11
      # inetutils-2.7 fails to build on macOS due to gnulib/clang incompatibility
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-unified.url = "github:srid/nixos-unified";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Software inputs
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixvim.url = "github:nix-community/nixvim";
    # nixvim.inputs.nixpkgs.follows = "nixpkgs";
    # nixvim.inputs.flake-parts.follows = "flake-parts";
    Terramaid.url = "github:RoseSecurity/Terramaid";
  };

  # Wired using https://nixos-unified.org/guide/autowiring
  outputs = inputs: let
    flake = inputs.nixos-unified.lib.mkFlake {
      inherit inputs;
      root = ./.;
    };
  in
    flake;
}
