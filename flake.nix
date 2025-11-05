{
  description = "Keymap manager for wlroots-based Wayland compositors";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" ];
        };

        wlr-which-key = pkgs.rustPlatform.buildRustPackage {
          pname = "wlr-which-key";
          version = "1.3.0";

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          nativeBuildInputs = with pkgs; [
            pkg-config
            rustToolchain
          ];

          buildInputs = with pkgs; [
            pango
            cairo
            wayland
            wayland-protocols
            libxkbcommon
          ];

          meta = with pkgs.lib; {
            description = "Keymap manager for wlroots-based Wayland compositors";
            homepage = "https://github.com/MaxVerevkin/wlr-which-key/";
            license = licenses.gpl3Only;
            platforms = platforms.linux;
            mainProgram = "wlr-which-key";
          };
        };
      in
      {
        packages = {
          default = wlr-which-key;
          wlr-which-key = wlr-which-key;
          default-config = pkgs.writeText "config.yaml" (builtins.readFile ./config/default.yaml);
        };

        apps = {
          default = flake-utils.lib.mkApp {
            drv = wlr-which-key;
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            pkg-config
            pango
            cairo
            wayland
            wayland-protocols
            libxkbcommon
          ];
        };
      });
}
