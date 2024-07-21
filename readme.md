# Affinity wine nix configuration

#### This flake does a few things to greatly simplify the process of installing Affinity applications on linux
- Build and install [ElementalWarrior's Wine fork](https://gitlab.winehq.org/ElementalWarrior)
- Create and set up a wine prefix if it doesn't already exist
- Provide binaries to easily launch Affinity applications: `affinity-designer`, `affinity-photo` and `affinity-publisher`
- Provide the `affinity-run` binary to run Affinity installers that install into your prefix

### Credits
- [Affinity crimes](https://github.com/lf-/affinity-crimes)
- [Wanesty](https://codeberg.org/Wanesty/affinity-wine-docs)

### Options
> example `flake.nix`
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    affinity.url = "github:juliamertz/affinity-nixos/main";
  };
}
```
> example `configuration.nix`
```nix
{ inputs, ... }:
{ 
  imports = [
    inputs.affinity.nixosModules.affinity
  ];

  affinity = {
    # If there is no prefix found at this path it will be created and set up for you.
    prefix = "/home/${user}/affinity/prefix";
    # Path to Winmd files (https://codeberg.org/Wanesty/affinity-wine-docs#setting-up-your-build-and-your-wineprefix-https-wiki-winehq-org-wine_user-27s_guide-wineprefix)
    licenseViolations = "/home/${user}/affinity/license_violations";

    photo.enable = true;
    designer.enable = true;
    publisher.enable = true;
  };
}
```

### Installing the Affinity suite
> Make sure the prefix is created before following these steps
1. Download the desired application installers: (Choose MSI/EXE(x64))
    - [Photo 2](https://store.serif.com/en-us/update/windows/photo/2/)
    - [Designer 2](https://store.serif.com/en-us/update/windows/designer/2/)
    - [Publisher 2](https://store.serif.com/en-us/update/windows/publisher/2/)
2. Open a terminal and run `affinity-run <path-to-installer>`
3. Follow the steps in the installer and you're done!

### Updating
Follow the same steps as when [installing](#installing-the-affinity-suite). 
