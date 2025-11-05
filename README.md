# wlr-which-key

**wlr-which-key** is a keymap manager for wlroots-based Wayland compositors, inspired by vim's which-key plugin. It provides a hierarchical menu system for launching commands and scripts via keyboard shortcuts. The official repo is https://github.com/MaxVerevkin/wlr-which-key

## Usage

```bash
# Run with bundled config
nix run .#wlr-which-key -- "$(nix build .#default-config --print-out-paths)"

# Run with system config
wlr-which-key [config_name]

# Navigate to submenu
wlr-which-key --initial-keys "p s"
```


## Development

### Development Environment

```bash
# Enter development shell
nix develop

# Build manually
cargo build --release

# Run tests
cargo test
```

### Hyprland

Add to Hyprland configuration:

```conf
# Using flake
bind = $mainMod, SPACE, exec, nix run "/path/to/whichkey" -- "$(nix build "/path/to/whichkey#default-config" --print-out-paths)"

# Using installed binary
bind = $mainMod, SPACE, exec, wlr-which-key
```

