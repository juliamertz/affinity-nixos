{ config, pkgs, ... }:
let
  wrap = pkgs.callPackage ./wrap.nix { };
  wineUnstable =
    pkgs.wineWow64Packages.full.override (old: { wineRelease = "unstable"; });
in {
  launchWrapper = env:
    # https://github.com/lf-/affinity-crimes/blob/main/affinity.sh
    pkgs.writeShellScriptBin "run" # bash
    ''
      (return 0 2>/dev/null) && sourced=1 || sourced=0
      ${env}

      if [[ $sourced == 0 ]]; then exec "$@"; fi
    '';

  wine = wrap {
    wine = wineUnstable.overrideAttrs (old: {
      src = pkgs.fetchFromGitLab {
        domain = "gitlab.winehq.org";
        owner = "elementalwarrior";
        repo = "wine";
        rev = "c12ed1469948f764817fa17efd2299533cf3fe1c";
        hash = "sha256-eMN4SN8980yteYODN2DQIVNEJMsGQE8OIdPs/7DbvqQ=";
      };
      version = "8.14";
    });
  };

  winetricks = pkgs.winetricks.overrideAttrs (old: rec {
    src = pkgs.fetchFromGitHub {
      owner = "Winetricks";
      repo = "winetricks";
      rev = "20240105";
      hash = "sha256-YTEgb19aoM54KK8/IjrspoChzVnWAEItDlTxpfpS52w=";
    };
    version = src.rev;
  });
}

