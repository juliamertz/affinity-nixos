{ pkgs, config, lib, ... }:
let
  cfg = config.affinity;
  bin = pkgs.writeShellScriptBin;

  prefix = ''WINE_PREFIX=${cfg.prefix}'';
  executables = ''${cfg.prefix}/drive_c/Program\ Files/Affinity'';
  wine = "${pkgs.affinity}/bin/affinity wine";
  
  exec = {
    photo = ''${prefix} ${wine} ${executables}/Photo\ 2/Photo.exe'';
    designer = ''${prefix} ${wine} ${executables}/Designer\ 2/Designer.exe'';
    publisher = ''${prefix} ${wine} ${executables}/Publisher\ 2/Publisher.exe'';
    run = ''${prefix} ${wine} $@'';
  };
  pkg = {
    photo = bin "affinity-photo" exec.photo;
    designer = bin "affinity-designer" exec.designer;
    publisher = bin "affinity-publisher" exec.publisher;
    run = bin "affinity-run" exec.run;
  };
  desktop = {
    photo = pkgs.makeDesktopItem {
      name="affinity-photo";
      desktopName = "Affinity Photo";
      genericName = "Image Editor";
      exec = "${pkg.photo}/bin/affinity-photo";
      terminal = false;
      categories = [ "Utility" ];
    };
    designer = pkgs.makeDesktopItem {
      name="affinity-designer";
      desktopName = "Affinity Designer";
      genericName = "Vector Graphics editor";
      exec = "${pkg.designer}/bin/affinity-designer";
      terminal = false;
      categories = [ "Utility" ];
    };
    publisher = pkgs.makeDesktopItem {
      name="affinity-publisher";
      desktopName = "Affinity Publisher";
      genericName = "";
      exec = "${pkg.publisher}/bin/affinity-publisher";
      terminal = false;
      categories = [ "Utility" ];
    };
  };
in {
  imports = [
    ./wine.nix # ElementalWarrior wine build
    ./launcher.nix # Provides pkgs.affinity
    ./setup.nix # Installation step to create wine prefix
  ];

  options.affinity = {
    prefix = lib.mkOption { 
      type = lib.types.nonEmptyStr;
      default = "";
    };
    licenseViolations = lib.mkOption { 
      type = lib.types.nonEmptyStr;
      default = "";
    };
    user = lib.mkOption { 
      type = lib.types.nonEmptyStr;
      default = "";
    };
    designer.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    photo.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    publisher.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    desktopEntries.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    env = lib.mkOption {
      type = lib.types.str;
      default = /*bash*/''
        winepath="${pkgs.wineElementalWarrior}"
        export WINEPREFIX="${cfg.prefix}"
        export PATH="$winepath/bin:$PATH"
        export LD_LIBRARY_PATH="$winepath/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        export WINEDLLOVERRIDES="winemenubuilder.exe=d"
        export WINESERVER="$winepath/bin/wineserver"
        export WINELOADER="$winepath/bin/wine"
        export WINEDLLPATH="$winepath/lib/wine"
      '';
    };
  };

  config = {
    environment.systemPackages = [ pkg.run ]
      ++ lib.optionals cfg.photo.enable [ pkg.photo desktop.photo ]
      ++ lib.optionals cfg.designer.enable [ pkg.designer desktop.designer ]
      ++ lib.optionals cfg.publisher.enable [ pkg.publisher desktop.publisher ];
  };
}

