{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    {
      packages = {
        x86_64-linux = {
          powershell = nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/powershell.nix { };
        };
      };

      nixosConfigurations.qemu = nixpkgs.lib.nixos.evalModules {
        specialArgs = {
          inherit inputs;
          lib = nixpkgs.lib;
          pkgs = import nixpkgs {
            localSystem = "x86_64-linux";
            crossSystem = {
              config = "x86_64-w64-mingw32";
              # TODO: this doesn't work because: lld: error: unknown argument: --version-script
              #useLLVM = true;
            };
            overlays = [
              (import ./overlays/windows.nix)
            ];
            config.allowUnsupportedSystem = true;
          };
        };
        modules = [
          ./modules/windows.nix
        ];
      };
    };
}
