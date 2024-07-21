{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, self, ... }@inputs:
    {
      packages = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
        "i686-linux"
      ] (
        system:
        let
          inherit (nixpkgs) lib;
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.writeShellScriptBin "affinity" ''echo Hello world!'';
        }
      );

      nixosModules.affinity = { pkgs, ... }: {
        imports = [ ./default.nix ];
      };

  };
}

