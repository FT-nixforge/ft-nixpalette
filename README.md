# ft-nixpalette

A reusable NixOS theme framework built on top of [Stylix](https://github.com/danth/stylix). ft-nixpalette provides folder-based theme definitions, a parent-child inheritance model, and a clean separation between built-in and user-defined themes.

## Highlights

- 12 built-in base themes + 4 derived themes (Catppuccin, Nord, Dracula, Gruvbox, and more)
- Parent-child theme inheritance with deep merge
- **Zero-config Home-Manager integration** — set it once in NixOS, HM is auto-configured
- NixOS Specialisations for near-instant theme switching (auto-propagated to Home-Manager)
- Sensible Stylix defaults (font, cursor, opacity) out of the box, fully overridable
- Color JSON export for live switcher integration
- Stylix integration — no manual Stylix config needed
- DE integration layer — Hyprland, MangoWC, Niri, GNOME, KDE, COSMIC

## Quick Install

### Using the flake

Add the input to your flake:

```nix
inputs.nixpalette.url = "github:FT-nixforge/ft-nixpalette";
```

Import the NixOS module and enable it:

```nix
imports = [ inputs.nixpalette.nixosModules.default ];

ft-nixpalette = {
  enable = true;
  theme  = "builtin:base/catppuccin-mocha";
};
```

That's it. Home-Manager is configured automatically. Specialisations switch instantly. Stylix defaults (font, cursor, opacity) are applied out of the box.

---

## Options Reference

### `ft-nixpalette.enable`

Enable ft-nixpalette theme management. **Type:** `bool`

### `ft-nixpalette.theme`

Namespaced theme identifier. **Default:** `"builtin:base/catppuccin-mocha"`

Examples: `"builtin:base/nord"`, `"user:derived/my-theme"`

### `ft-nixpalette.userThemeDir`

Path to your own theme directory (containing `base/` and/or `derived/`). **Default:** `null`

### `ft-nixpalette.specialisations`

Map of specialisation name → theme ID. **Default:** `{}`

```nix
specialisations = {
  dark  = "builtin:base/catppuccin-mocha";
  light = "builtin:base/nord";
};
```

Switch instantly without a network build:
```bash
sudo /run/current-system/specialisation/light/bin/switch-to-configuration switch
```

### `ft-nixpalette.preloadThemes`

Additional theme IDs to bake into `/etc/ft-nixpalette/themes.json`. **Default:** `[]`

Useful for live theme switchers that need resolved palettes at runtime.

### `ft-nixpalette.stylixOverrides`

Override Stylix options. **Default:** sensible defaults for font, cursor, and opacity.

```nix
# Defaults applied automatically:
{
  fonts.monospace = {
    name    = "JetBrainsMono Nerd Font";
    package = pkgs.nerd-fonts.jetbrains-mono;
  };
  cursor = {
    package = pkgs.bibata-cursors;
    name    = "Bibata-Modern-Classic";
    size    = 24;
  };
  opacity = {
    terminal     = 0.95;
    applications = 1.0;
    desktop      = 1.0;
    popups       = 1.0;
  };
}
```

Set to `{}` to disable all defaults, or override individual values:
```nix
stylixOverrides.cursor.size = 32;
```

### `ft-nixpalette.homeManagerIntegration.enable`

Auto-configure ft-nixpalette for all Home-Manager users. **Default:** `true`

When enabled, the NixOS module propagates all settings (`theme`, `userThemeDir`, `specialisations`, `preloadThemes`, `stylixOverrides`) to every Home-Manager user automatically. Set to `false` to configure Home-Manager manually.

### `ft-nixpalette.integrations.de`

Desktop environment to generate color variables for. **Default:** `null`

Supported: `"Hyprland"`, `"MangoWC"`, `"Niri"`, `"GNOME"`, `"KDE"`, `"COSMIC"`

---

## Recommended User-Repo Pattern

Instead of configuring `ft-nixpalette` directly everywhere, wrap it in your own module:

**`modules/theming/default.nix`:**
```nix
{ config, pkgs, lib, ... }:

let
  cfg = config.ft.theming;
in
{
  options.ft.theming = {
    enable = lib.mkEnableOption "ft-nixpalette-based global theming";

    theme = lib.mkOption {
      type    = lib.types.str;
      default = "builtin:base/catppuccin-mocha";
    };

    userThemeDir = lib.mkOption {
      type    = lib.types.nullOr lib.types.path;
      default = null;
    };

    specialisations = lib.mkOption {
      type    = lib.types.attrsOf lib.types.str;
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    # Single line — everything auto-propagates to Home-Manager
    ft-nixpalette = {
      enable = true;
      inherit (cfg) theme userThemeDir specialisations;
    };

    fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  };
}
```

**`configuration.nix`:**
```nix
ft.theming = {
  enable = true;
  theme = "builtin:base/catppuccin-mocha";
  userThemeDir = ../../assets/themes;
  specialisations = {
    nord    = "builtin:base/nord";
    gruvbox = "user:base/gruvbox";
  };
};
```

**`home/features/theming.nix`:**
```nix
{ config, lib, osConfig, ... }:
{
  # ft-nixpalette HM config is auto-propagated from NixOS module.
  # Only Hyprland-specific and Stylix target overrides remain here.

  stylix.targets = {
    neovim.enable    = false;
    vim.enable       = false;
    nvf.enable       = true;
    hyprlock.enable  = false;
    hyprpaper.enable = lib.mkForce false;
  };

  gtk.gtk4.theme = null;
}
```

No manual `ft-nixpalette = { ... }` in `home.nix`. No specialisation mapping. No Stylix defaults to copy.

---

## Manual Home-Manager Setup (Advanced)

If you disable `homeManagerIntegration`, import the Home-Manager module manually:

```nix
imports = [ inputs.nixpalette.homeModules.default ];

ft-nixpalette = {
  enable = true;
  theme  = "builtin:base/catppuccin-mocha";
};
```

---

## Versioning

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

---

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

Theming for Waybar, Rofi, hyprlock, and other DE tools is intentionally left to those tools' own configuration — ft-nixpalette exposes the palette via the color variables file and the JSON files (`colors.json`, `themes.json`) for them to consume.

---

## Documentation

Full documentation, options reference, theme guide, and examples:  
**[ft-nixforge.github.io/community/ft-nixpalette](https://ft-nixforge.github.io/community/ft-nixpalette)**

## License

MIT
