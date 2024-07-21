{ pkgs, config, ... }:
let 
  cfg = config.affinity;
  # https://github.com/lf-/affinity-crimes/blob/main/setup.sh
  script = /* bash */ ''
    #!/usr/bin/env bash
    set -eu
    ${cfg.env}
        
    # this crime is required to make wineboot not try to install mono itself
    WINEDLLOVERRIDES="mscoree=" wineboot --init
    $winepath/bin/wine msiexec /i "$winepath/share/wine/mono/wine-mono-8.1.0-x86.msi"
    ${pkgs.winetricks}/bin/winetricks -q dotnet48 corefonts vcrun2015
    $winepath/bin/wine winecfg -v win11
  '';

  binary = (pkgs.writeShellScriptBin "setup" script);
in {
  system.activationScripts.affinityCrimes = /*sh*/''
      license_violations=${cfg.licenseViolations}/WinMetadata
      prefix=${cfg.prefix}
      winmd_path=$prefix/drive_c/windows/system32/WinMetadata

      # Check if prefix exists, otherwise we create a new one
      if [ ! -e $prefix ]; then
        ${binary}/bin/setup}
      fi

      if [ -e $license_violations ]; then 
        if [ ! -e $winmd_path ]; then 
          ln -s $license_violations $winmd_path
          echo Symlinked winmd files to wine prefix
        fi
      else
        echo WARNING ! Path ${cfg.licenseViolations} not found.
        echo you will need winmd files from a windows install if you wish to use a Affinity version newer than the 1.10.3
        echo they are located in C:/windows/system32/WinMetadata and need to go in ${cfg.licenseViolations}
      fi
      '';
}
