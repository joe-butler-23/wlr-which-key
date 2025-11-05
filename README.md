# wlr-which-key

Fork of https://github.com/MaxVerevkin/wlr-which-key for personal use.

## Personal Setup

**Development folder:** `/home/joebutler/development/whichkey`
**Config file:** `config/default.yaml`
**Sync method:** Syncthing across all machines

## NixOS Integration

### flake.nix input
```nix
# Local development input
whichkey.url = "git+file:///home/joebutler/development/whichkey";
```

### Home Manager configuration
```nix
# modules/home/dotfiles/whichkey.nix
{ pkgs, whichkey, ... }: {
  home.packages = [
    whichkey.packages.x86_64-linux.wlr-which-key
  ];

  xdg.configFile."wlr-which-key/config.yaml".text = ''
    # Your configuration here
    font: JetBrainsMono Nerd Font 11
    background: "#282828d0"
    color: "#ffffff"
    border: "#ffffff"
    # ... rest of config
  '';
}
```

### Hyprland binding
```conf
# modules/home/dotfiles/hyprland.nix
bind = $mainMod, SPACE, exec, wlr-which-key
```

## Multi-Machine Setup

1. Ensure Syncthing syncs `/home/joebutler/development/whichkey`
2. Copy nix-config changes to each machine in the normal way
3. Run `sudo nixos-rebuild switch` on each machine

## Machine Setup Checklist

- [ ] Syncthing syncing development folder
- [ ] nix-config has whichkey input
- [ ] whichkey.nix module exists in dotfiles
- [ ] dotfiles/default.nix imports whichkey module
- [ ] hyprland.nix has Super+Space binding
- [ ] Run `nixos-rebuild switch`
- [ ] Test Super+Space keybinding

## Guide: Installing Local Packages with Flakes

This guide demonstrates how to install a local Rust project as a Nix package using flakes.

### 1. Create the Project Flake

In your project directory (`/home/joebutler/development/whichkey`):

```nix
# flake.nix
{
  description = "wlr-which-key - A Wayland which-key menu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, rust-overlay, crane, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import rust-overlay) ];
      };

      craneLib = crane.lib.${system};
      rustToolchain = pkgs.rust-bin.stable.latest.default;

      src = craneLib.cleanCargoSource ./.;

      commonArgs = {
        inherit src;
        strictDeps = true;
        cargoArtifacts = craneLib.buildDepsOnly commonArgs;
        nativeBuildInputs = with pkgs; [ pkg-config ];
        buildInputs = with pkgs; [
          pango
          cairo
          gdk-pixbuf
          gtk3
        ];
      };

      package = craneLib.buildPackage (commonArgs // {
        pname = "wlr-which-key";
        version = "0.1.0";
      });
    in {
      packages.${system}.default = package;
      packages.${system}.wlr-which-key = package;
    };
}
```

### 2. Add to System Configuration

Add the local flake as an input to your main nix-config:

```nix
# flake.nix (in your nix-config)
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = { /* ... */ };
    
    # Local development flake
    whichkey.url = "git+file:///home/joebutler/development/whichkey";
  };

  outputs = { nixpkgs, home-manager, whichkey, ... }: {
    # Pass whichkey to home-manager
    home-manager.users.joebutler = import ./home.nix {
      inherit (nixpkgs) lib;
      inherit whichkey;
    };
  };
}
```

### 3. Create Home Manager Module

Create a dedicated module for the package:

```nix
# modules/home/dotfiles/whichkey.nix
{ pkgs, whichkey, ... }: {
  home.packages = [
    whichkey.packages.x86_64-linux.wlr-which-key
  ];

  # Optional: Manage configuration files
  xdg.configFile."wlr-which-key/config.yaml".text = ''
    # Your configuration here
  '';
}
```

### 4. Import the Module

Add the module to your dotfiles imports:

```nix
# modules/home/dotfiles/default.nix
{
  imports = [
    ./espanso.nix
    ./foot.nix
    ./hyprland.nix
    ./whichkey.nix  # Add this line
    # ... other modules
  ];
}
```

### 5. Rebuild and Test

```bash
# Rebuild the system
sudo nixos-rebuild switch

# Test the package
which wlr-which-key
# Should show: /home/joebutler/.nix-profile/bin/wlr-which-key
```

### Key Benefits

- **Reproducible**: Same package across all machines
- **Declarative**: Configuration managed in Nix
- **Isolated**: No conflicts with system packages
- **Updatable**: Changes automatically propagate on rebuild

### Common Issues

- **"access to absolute path forbidden"**: Use `xdg.configFile.text` instead of absolute paths
- **"does not provide attribute"**: Ensure the flake outputs the correct package name
- **Missing dependencies**: Add required libraries to `buildInputs`
