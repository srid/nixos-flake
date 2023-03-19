# nixos-flake

A [flake-parts](https://flake.parts/) module to unify [NixOS](https://nixos.org/manual/nixos/stable/) + [nix-darwin](https://github.com/LnL7/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager) configuration in a single flake, while providing a consistent interface (and enabling common modules) for both Linux and macOS.


## Usage

We provide three templates, depending on your needs:

|Template | Command | Description |
| -- | -------- | ----------- |
| Both platforms | `nix flake init -t github:srid/nixos-flake` | NixOS, nix-darwin, home-manager configuration combined, with common modules |
| NixOS only | `nix flake init -t github:srid/nixos-flake#linux` | NixOS configuration only, with home-manager |
| macOS only | `nix flake init -t github:srid/nixos-flake#macos` | nix-darwin configuration only, with home-manager |

After initializing the template, open the generated `flake.nix` and change the user (from "john") as well as hostname (from "example1") to match that of your environment. Then run `nix run .#activate` to activate the configuration.

## Module outputs

Importing this flake-parts module will autowire the following flake outputs:

| Name                         | Description                                    |
| ---------------------------- | ---------------------------------------------- |
| `nixos-flake.lib`             | Functions `mkLinuxSystem` and `mkDarwinSystem` |
| `nixosModules.home-manager`  | Home-manager setup module for NixOS            |
| `darwinModules.home-manager` | Home-manager setup module for Darwin           |
| `packages.update`            | Flake app to update key flake inputs            |
| `packages.activate`          | Flake app to build & activate the system       |

In addition, all of your NixOS/nix-darwin/home-manager modules implicitly receive the following `specialArgs`:

- `flake@{self, inputs, config}` (`config` is from flake-parts')
- `rosettaPkgs` (if on darwin)

The module API maybe be heavily refactored over the coming days/weeks. [All feedback welcome](https://github.com/srid/nixos-flake/issues/new).

## Examples

- https://github.com/srid/nixos-config (using `#both` template)
- https://github.com/hkmangla/nixos (using `#linux` template)
