---
order: -10
---

# Getting Started

Pick your desired operating system and follow the below instructions.

## NixOS

:::tip
For a more automated way to install NixOS, see [nixos-anywhere](https://github.com/numtide/nixos-anywhere).
:::

1. [Install NixOS w/ Flakes enabled](https://nixos.asia/en/nixos-tutorial)
1. Convert your `flake.nix` to using `nixos-flake` using the [[templates|NixOS only template]] as reference.

## non-NixOS Linux

1. [Install Nix](https://nixos.asia/en/install)
1. Use the [[templates|HOME only template]]

## macOS

1. [Install Nix](https://nixos.asia/en/install)
1. [Install nix-darwin](https://github.com/LnL7/nix-darwin)
1. Use the [[templates|macOS only template]][^both]

[^both]: Alternatively, use the "Both platforms" [[templates|template]] if you are sharing your configuration with the other platform as well.
