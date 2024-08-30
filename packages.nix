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
        rev = "a7c9b19e1a26cf49c63a7c19189a3e2bbe2c6ac2";
        hash = "sha256-XVhz9p2kgFBoJ376vg8OaFXxcMEjAe9AK1hk0I1rb1Q=";
      };
      version = "9.13";
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

