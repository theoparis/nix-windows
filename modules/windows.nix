{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  install-wim = pkgs.callPackage ../packages/install-wim.nix { };
in
{
  options = {
    system.toplevel.build = lib.mkOption {
      type = lib.types.attrs;
      default = null;
      description = ''
        The build definition for the toplevel system.
      '';
    };
  };

  config = {
    system.toplevel.build = install-wim;
  };
}
