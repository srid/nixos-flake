{
  outputs = inputs: {
    flakeModule = ./flake-module.nix;
    templates =
      let
        tmplPath = path: builtins.path { inherit path; filter = path: _: baseNameOf path != "test.sh"; };
      in
      rec {
        default = both;
        both = {
          description = "nixos-flake template for both Linux and macOS in same flake";
          path = tmplPath ./examples/both;
        };
        linux = {
          description = "nixos-flake template for NixOS configuration.nix";
          path = tmplPath ./examples/linux;
        };
      };
  };
}
