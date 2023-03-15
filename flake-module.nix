{ self, inputs, config, flake-parts-lib, lib, ... }:
let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    types;
  specialArgsFor = rec {
    common = {
      flake = { inherit inputs config; };
    };
    x86_64-linux = common // {
      system = "x86_64-linux";
    };
    aarch64-darwin = common // {
      system = "aarch64-darwin";
      rosettaPkgs = import inputs.nixpkgs { system = "x86_64-darwin"; };
    };
  };
in
{
  options = {
    perSystem = mkPerSystemOption
      ({ config, self', inputs', pkgs, system, ... }: {
        options.nixos-template = lib.mkOption {
          default = { };
          type = types.submodule {
            options = {
              primary-inputs = lib.mkOption {
                type = types.listOf types.str;
                default = [ "nixpkgs" "home-manager" "darwin" "nixos-hardware" ];
                description = ''
                  List of flake inputs to update when running `nix run .#update`.
                '';
              };
            };
          };
        };
      });
  };
  config = {
    flake = {
      # Linux home-manager module
      nixosModules.home-manager = {
        imports = [
          inputs.home-manager.nixosModules.home-manager
          ({
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgsFor.x86_64-linux;
          })
        ];
      };
      # macOS home-manager module
      darwinModules.home-manager = {
        imports = [
          inputs.home-manager.darwinModules.home-manager
          ({
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgsFor.aarch64-darwin;
          })
        ];
      };
      lib = {
        mkLinuxSystem = mod: inputs.nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          # Arguments to pass to all modules.
          specialArgs = specialArgsFor.${system};
          modules = [ mod ];
        };

        mkMacosSystem = mod: inputs.nix-darwin.lib.darwinSystem rec {
          system = "aarch64-darwin";
          specialArgs = specialArgsFor.${system};
          modules = [ mod ];
        };
      };
    };

    perSystem = { system, config, pkgs, lib, ... }: {
      packages = {
        update =
          let
            inputs = config.nixos-template.primary-inputs;
          in
          pkgs.writeShellApplication {
            name = "update-main-flake-inputs";
            text = ''
              nix flake lock ${lib.foldl' (acc: x: acc + " --update-input " + x) "" inputs}
            '';
          };

        activate =
          pkgs.writeShellApplication {
            name = "activate";
            text =
              # TODO: Replace with deploy-rs or (new) nixinate
              if system == "aarch64-darwin" then
                ''
                  set -x
                  ${self.darwinConfigurations.default.system}/sw/bin/darwin-rebuild \
                    switch --flake .#default
                ''
              else
                ''
                  set -x
                  ${lib.getExe pkgs.nixos-rebuild} --use-remote-sudo switch -j auto
                '';
          };
      };
    };
  };
}
