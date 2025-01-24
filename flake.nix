{
  description = "Flake for search.nüschtos.de";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        darwin.follows = "nix-darwin";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
    authentik = {
      # TODO: switch back to nix-community
      # https://github.com/nix-community/authentik-nix/pull/39
      # url = "github:nix-community/authentik-nix";
      url = "github:MarcelCoding/authentik-nix/fix-doc";
      inputs = {
        flake-compat.follows = "";
        flake-parts.follows = "flake-parts";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    crowdsec = {
      url = "https://codeberg.org/kampka/nix-flake-crowdsec/archive/main.zip";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ifstate = {
      url = "git+https://codeberg.org/m4rc3l/ifstate.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        flake-compat.follows = "";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "";
        rust-overlay.follows = "rust-overlay";
      };
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
        rust-overlay.follows = "rust-overlay";
      };
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-modules = {
      url = "github:NuschtOS/nixos-modules";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs = {
        flake-compat.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        flake-parts.follows = "flake-parts";
        home-manager.follows = "home-manager";
        nix-darwin.follows = "nix-darwin";
        nixpkgs.follows = "nixpkgs";
        nuschtosSearch.follows = "search";
        # https://github.com/nix-community/nixvim/blob/main/flake.nix#L12-L34
        devshell.follows = "";
        flake-compat.follows = "";
        git-hooks.follows = "";
        treefmt-nix.follows = "";
      };
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    search = {
      url = "github:NuschtOS/search";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    simple-nixos-mailserver = {
      url = "git+https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git";
      inputs = {
        flake-compat.follows = "";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-24_11.follows = "nixpkgs";
      };
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tsnsrv = {
      url = "github:boinkor-net/tsnsrv";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { agenix, authentik, crowdsec, disko, flake-utils, home-manager, ifstate, impermanence, lanzaboote, microvm, nix-darwin, nixos-apple-silicon, nixos-hardware, nixos-modules, nixos-wsl, nixpkgs, nixvim, search, simple-nixos-mailserver, sops-nix, tsnsrv, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = (import nixpkgs) {
            inherit system;
          };
          inherit (pkgs) lib;
        in
        {
          packages = {
            default = search.packages.${system}.mkMultiSearch {
              scopes = [
                # agenix
                {
                  modules = [ agenix.nixosModules.default ];
                  name = "agenix";
                  urlPrefix = "https://github.com/ryantm/agenix/blob/main/";
                }
                # authentik
                {
                  modules = [
                    authentik.nixosModules.default
                    { _module.args = { inherit pkgs; }; }
                  ];
                  name = "authentik-nix";
                  urlPrefix = "https://github.com/nix-community/authentik-nix/blob/main/";
                }
                # crowdsec
                {
                  modules = [
                    crowdsec.nixosModules.crowdsec
                    crowdsec.nixosModules.crowdsec-firewall-bouncer
                    { _module.args = { inherit pkgs; }; }
                  ];
                  name = "crowdsec";
                  urlPrefix = "https://codeberg.org/kampka/nix-flake-crowdsec/src/branch/main/";
                }
                # disko
                {
                  modules = [ disko.nixosModules.default ];
                  name = "disko";
                  specialArgs.modulesPath = nixpkgs + "/nixos/modules";
                  urlPrefix = "https://github.com/nix-community/disko/blob/master/";
                }
                # home-manager
                {
                  optionsJSON = home-manager.packages.${system}.docs-html.passthru.home-manager-options.nixos + /share/doc/nixos/options.json;
                  name = "Home Manager NixOS";
                  urlPrefix = "https://github.com/nix-community/home-manager/tree/master/";
                }
                {
                  optionsJSON = home-manager.packages.${system}.docs-json + /share/doc/home-manager/options.json;
                  optionsPrefix = "home-manager.users.<name>";
                  name = "Home Manager";
                  urlPrefix = "https://github.com/nix-community/home-manager/tree/master/";
                }
                # ifstate.nix
                {
                  modules = [ ifstate.nixosModules.default ];
                  name = "IfState.nix";
                  urlPrefix = "https://codeberg.org/m4rc3l/ifstate.nix/src/branch/main/";
                }
                # impermanence
                {
                  modules = [ impermanence.nixosModules.default ];
                  name = "impermanence";
                  urlPrefix = "https://github.com/nix-community/impermanence/blob/master/";
                }
                # lanzaboote
                {
                  modules = [
                    lanzaboote.nixosModules.lanzaboote
                    lanzaboote.nixosModules.uki
                    { _module.args = { inherit pkgs; }; }
                  ];
                  name = "Lanzaboote";
                  urlPrefix = "https://github.com/nix-community/lanzaboote/blob/master/";
                }
                # microvm.nix
                {
                  modules = [
                    microvm.nixosModules.host
                    microvm.nixosModules.microvm
                    { _module.args = { inherit pkgs; }; }
                  ];
                  name = "MicroVM.nix";
                  urlPrefix = "https://github.com/astro/microvm.nix/blob/main/";
                }
                # nix-darwin
                {
                  optionsJSON = nix-darwin.packages.${system}.optionsJSON + /share/doc/darwin/options.json;
                  name = "nix-darwin";
                  urlPrefix = "https://github.com/LnL7/nix-darwin/tree/master/";
                }
                # NixOS/nixpkgs
                {
                  optionsJSON = (import "${nixpkgs}/nixos/release.nix" { }).options + /share/doc/nixos/options.json;
                  name = "NixOS";
                  urlPrefix = "https://github.com/NixOS/nixpkgs/tree/master/";
                }
                # nixos-apple-silicon
                {
                  modules = [ nixos-apple-silicon.nixosModules.default ];
                  name = "NixOS Apple Silicon";
                  urlPrefix = "https://github.com/tpwrules/nixos-apple-silicon/blob/main/";
                }
                # nixos-hardware
                {
                  modules = [
                    { _module.args = { inherit pkgs; }; }
                  ] ++ lib.filter (x: (builtins.tryEval (x)).success) (lib.attrValues nixos-hardware.nixosModules);
                  name = "nixos-hardware";
                  specialArgs.modulesPath = pkgs.path + "/nixos/modules";
                  urlPrefix = "https://github.com/NixOS/nixos-hardware/blob/master/";
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
                  name = "NixOS Modules";
                  urlPrefix = "https://github.com/NuschtOS/nixos-modules/tree/main/";
                }
                # NixOS-WSL
                {
                  modules = [
                    nixos-wsl.nixosModules.default
                    { _module.args = { inherit pkgs; }; }
                  ];
                  name = "Nixos-WSL";
                  urlPrefix = "https://github.com/nix-community/NixOS-WSL/blob/main/";
                }
                # nixvim
                {
                  optionsJSON = nixvim.packages.${system}.options-json + /share/doc/nixos/options.json;
                  optionsPrefix = "programs.nixvim";
                  name = "NixVim";
                  urlPrefix = "https://github.com/nix-community/nixvim/tree/main/";
                }
                # simple-nixos-mailserver
                {
                  modules = [
                    simple-nixos-mailserver.nixosModules.default
                    # based on https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/blob/290a995de5c3d3f08468fa548f0d55ab2efc7b6b/flake.nix#L61-73
                    {
                      mailserver = {
                        fqdn = "mx.example.com";
                        domains = [ "example.com" ];
                        dmarcReporting = {
                          organizationName = "Example Corp";
                          domain = "example.com";
                        };
                      };
                    }
                  ];
                  name = "simple-nixos-mailserver";
                  urlPrefix = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/blob/master/";
                }
                # sops-nix
                {
                  modules = [ sops-nix.nixosModules.default ];
                  name = "sops-nix";
                  urlPrefix = "https://github.com/Mic92/sops-nix/blob/master/";
                }
                # tsnsrv
                {
                  modules = [
                    tsnsrv.nixosModules.default
                    { _module.args = { inherit pkgs; }; }
                  ];
                  name = "tsnsrv";
                  urlPrefix = "https://github.com/boinkor-net/tsnsrv/blob/main/";
                }
              ];
            };
          };
        });
}
