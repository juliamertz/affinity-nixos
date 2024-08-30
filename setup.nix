{ pkgs, config, ... }:
let
  cfg = config.affinity;
  packages = pkgs.callPackage ./packages.nix { };
  # https://github.com/lf-/affinity-crimes/blob/main/setup.sh
in {
  system.userActivationScripts.affinityCrimes.text = # sh
    ''
      PREFIX=${cfg.prefix}
      LICENSE_VIOLATIONS=${cfg.licenseViolations}/WinMetadata
      WINMD_PATH=$PREFIX/drive_c/windows/system32/WinMetadata

      # Check if prefix exists, otherwise we create a new one
      if [ ! -e $PREFIX ]; then
        echo No prefix found at path $PREFIX
        echo creating new wine prefix
            
        mkdir -p $PREFIX
        set -eu
        ${cfg.env}

        # this crime is required to make wineboot not try to install mono itself
        WINEDLLOVERRIDES="mscoree=" wineboot --init
        $winepath/bin/wine msiexec /i "$winepath/share/wine/mono/wine-mono-8.1.0-x86.msi"
        ${packages.winetricks}/bin/winetricks -q dotnet48 corefonts vcrun2015
        $winepath/bin/wine winecfg -v win11
      fi

      if [ -e $LICENSE_VIOLATIONS ]; then 
        if [ ! -e $WINMD_PATH ]; then 
          ln -s $LICENSE_VIOLATIONS $WINMD_PATH
          echo Symlinked winmd files to wine prefix
        fi
      else
        echo WARNING ! Path ${cfg.licenseViolations} not found.
        echo you will need winmd files from a windows install if you wish to use a Affinity version newer than the 1.10.3
        echo they are located in C:/windows/system32/WinMetadata and need to go in ${cfg.licenseViolations}
      fi
    '';
}
