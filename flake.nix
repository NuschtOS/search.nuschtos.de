{
  description = "Flake for search.nüschtos.de";

  inputs = {
    flake-compat.url = "github:nix-community/flake-compat";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    nixos-modules = {
      url = "github:NuschtOS/nixos-modules";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        search.follows = "search";
        flake-utils.follows = "flake-utils";
      };
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        flake-compat.follows = "flake-compat";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        nuschtosSearch.follows = "search";
      };
    };
    search = {
      url = "github:NuschtOS/search";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { nixpkgs, flake-utils, home-manager, nixos-apple-silicon, nixos-modules, nixvim, search, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = (import nixpkgs) {
            inherit system;
          };
        in
        {
          packages = {
            default = search.packages.${system}.mkMultiSearch {
              scopes = [
                # home-manager
                {
                  optionsJSON = home-manager.packages.${system}.docs-html.passthru.home-manager-options.nixos + /share/doc/nixos/options.json;
                  title = "Home-Manager NixOS";
                  urlPrefix = "https://github.com/nix-community/home-manager/tree/master/";
                }
                {
                  optionsJSON = home-manager.packages.${system}.docs-json + /share/doc/home-manager/options.json;
                  optionsPrefix = "home-manager.users.<name>";
                  title = "Home-Manager";
                  urlPrefix = "https://github.com/nix-community/home-manager/tree/master/";
                }
                # nixos-apple-silicon
                {
                  modules = [ nixos-apple-silicon.nixosModules.default ];
                  title = "NixOS Apple Silicon";
                  urlPrefix = "https://github.com/tpwrules/nixos-apple-silicon/blob/main/";
                }
                # nixos-modules
                {
                  modules = [
                    ({ config, lib, ... }: {
                      _module.args = {
                        libS = nixos-modules.lib { inherit config lib; };
                        inherit pkgs;
                      };
                      imports = [ (pkgs.path + "/nixos/modules/misc/extra-arguments.nix") ];
                    })
                    nixos-modules.nixosModule
                  ];
                  title = "NixOS Modules";
                  urlPrefix = "https://github.com/NuschtOS/nixos-modules/tree/main/";
                }
                # nixvim
                {
                  optionsJSON = nixvim.packages.${system}.options-json + /share/doc/nixos/options.json;
                  optionsPrefix = "programs.nixvim";
                  title = "NixVim";
                  urlPrefix = "https://github.com/nix-community/nixvim/tree/main/";
                }
              ];
            };
          };
        });
}
