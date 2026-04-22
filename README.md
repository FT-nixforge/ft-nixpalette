# ft-nixpalette

A reusable NixOS theme framework built on top of [Stylix](https://github.com/danth/stylix). ft-nixpalette provides folder-based theme definitions, a parent-child inheritance model, and a clean separation between built-in and user-defined themes.

## Highlights

- 12 built-in base themes + 4 derived themes (Catppuccin, Nord, Dracula, Gruvbox, and more)
- Parent-child theme inheritance with deep merge
- NixOS Specialisations for near-instant theme switching
- Color JSON export for live switcher integration
- Stylix integration — no manual Stylix config needed
- DE integration layer — Hyprland, MangoWC, Niri, GNOME, KDE, COSMIC

## Quick Install

### Using the flake

```nix
inputs.nixpalette.url = "github:FT-nixforge/ft-nixpalette";
```

```nix
imports = [ ft-nixpalette.nixosModules.default ];
ft-nixpalette = {
  enable = true;
  theme  = "builtin:base/catppuccin-mocha";
};
```

### Versioning

ft-nixpalette uses **Git tags** for versioning. You can pin to a specific version or follow a release channel:

| URL | Behaviour |
|-----|-----------|
| `github:FT-nixforge/ft-nixpalette/v1.0.1` | Fixed version — never changes |
| `github:FT-nixforge/ft-nixpalette/stable` | Rolling — latest stable release |
| `github:FT-nixforge/ft-nixpalette/unstable` | Rolling — latest unstable release |
| `github:FT-nixforge/ft-nixpalette/main` | Bleeding edge — latest commit |

The `stable` / `unstable` tags are updated automatically when a release matching that status is published. They are **not** overwritten by releases with a different status — so `stable` always points to the last explicitly stable release.

```nix
# Pin to a specific version (reproducible)
inputs.nixpalette.url = "github:FT-nixforge/ft-nixpalette/v1.0.1";

# Or follow the stable channel
inputs.nixpalette.url = "github:FT-nixforge/ft-nixpalette/stable";
```

## Desktop Environment Integration

Setting `integrations.de` generates a color variable file from the active palette for the chosen desktop environment. The DE must already be installed; this only writes config files.

### Supported DEs

| Value | Desktop Environment |
|-------|---------------------|
| `"Hyprland"` | Hyprland |
| `"MangoWC"` | MangoWC |
| `"Niri"` | Niri |
| `"GNOME"` | GNOME |
| `"KDE"` | KDE Plasma |
| `"COSMIC"` | COSMIC |

### Example

```nix
ft-nixpalette = {
  enable = true;
  theme  = "builtin:base/catppuccin-mocha";
  integrations.de = "Hyprland";
};
```

**Generated file:**

| Context | Path |
|---|---|
| NixOS | `/etc/ft-nixpalette/hyprland/colors.conf` |
| Home Manager | `~/.config/hypr/ft-nixpalette-colors.conf` |

Source it in `hyprland.conf` to use `$ft_base0D` etc. anywhere:

```conf
source = ~/.config/hypr/ft-nixpalette-colors.conf

# example usage
col.active_border   = $ft_base0D $ft_base0E 45deg
col.inactive_border = $ft_base03
```

Theming for Waybar, Rofi, hyprlock, and other DE tools is intentionally left to
those tools' own configuration — ft-nixpalette exposes the palette via the color
variables file and the JSON files (`colors.json`, `themes.json`) for them to consume.

## Documentation

Full documentation, options reference, theme guide, and examples:  
**[ft-nixforge.github.io/community/ft-nixpalette](https://ft-nixforge.github.io/community/ft-nixpalette)**

## License

MIT
