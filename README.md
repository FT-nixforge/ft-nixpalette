# ft-nixpalette

A NixOS theme framework built on top of [Stylix](https://github.com/danth/stylix). ft-nixpalette provides folder-based theme definitions with parent-child inheritance, and configures Stylix system-wide — including boot menus, terminals, GTK, and everything else Stylix targets.

**ft-nixpalette is system-only.** It configures Stylix at the NixOS level. Home Manager automatically inherits the theme via Stylix's own integration — no extra HM config needed.

## Highlights

- 12+ built-in themes (Catppuccin, Nord, Dracula, Gruvbox, and more)
- Parent-child theme inheritance with deep merge
- NixOS Specialisations for near-instant theme switching
- Sensible Stylix defaults (font, cursor, opacity) out of the box, fully overridable
- Exposes `config.ft-nixpalette.stylix` — the resolved Stylix config — for advanced use
- Color JSON at `/etc/ft-nixpalette/` for live switcher integration

## Quick Start

Add the input:

```nix
inputs.nixpalette.url = "github:FT-nixforge/ft-nixpalette";
```

Import the module and enable it:

```nix
imports = [ inputs.nixpalette.nixosModules.default ];

ft-nixpalette = {
  enable = true;
  theme  = "builtin:base/catppuccin-mocha";
};
```

That's it. Stylix is configured system-wide. Boot menus, terminals, GTK, and all other Stylix targets are themed automatically. Home Manager receives `config.lib.stylix.colors` without any additional setup.

---

## Options

### `ft-nixpalette.enable`

Enable ft-nixpalette. **Type:** `bool`

### `ft-nixpalette.theme`

Namespaced theme identifier. **Default:** `"builtin:base/catppuccin-mocha"`

Format: `"<namespace>:<category>/<name>"`

```nix
theme = "builtin:base/nord";
theme = "user:derived/my-theme";
```

### `ft-nixpalette.userThemeDir`

Path to your own theme directory. Expected layout: `base/<name>/theme.nix` and/or `derived/<name>/theme.nix`. **Default:** `null`

```nix
userThemeDir = ./assets/themes;
```

### `ft-nixpalette.defaultWallpaper`

Fallback wallpaper for themes that don't ship their own image. When `null`, a solid-color PNG is generated from the theme's `base00`. Defaults to `wallpaper.{png,jpg,jpeg}` at the flake root if present.

### `ft-nixpalette.stylixOverrides`

Stylix options merged on top of theme-provided values. Theme values use `mkDefault`, so plain assignments here win. **Default:** `{}`

```nix
stylixOverrides = {
  cursor.size = 32;
  fonts.monospace = {
    name    = "Iosevka";
    package = pkgs.iosevka;
  };
};
```

### `ft-nixpalette.stylix` *(read-only)*

The fully-resolved Stylix configuration for the active theme. ft-nixpalette applies this automatically, but you can also reference it yourself:

```nix
# Apply ft-nixpalette's theme directly to your own stylix config
stylix = config.ft-nixpalette.stylix;

# Or merge it with your own overrides
stylix = lib.mkMerge [
  config.ft-nixpalette.stylix
  { targets.neovim.enable = false; }
];
```

### `ft-nixpalette.specialisations`

Pre-built alternative themes as NixOS specialisations. **Default:** `{}`

```nix
specialisations = {
  dark  = "builtin:base/catppuccin-mocha";
  light = "builtin:base/nord";
};
```

Switch without a rebuild:

```bash
sudo /run/current-system/specialisation/light/bin/switch-to-configuration switch
```

### `ft-nixpalette.preloadThemes`

Additional theme IDs baked into `/etc/ft-nixpalette/themes.json` at build time. The active theme is always included. **Default:** `[]`

```nix
preloadThemes = [
  "builtin:base/nord"
  "builtin:base/dracula"
];
```

---

## Versioning

| URL | Behaviour |
|-----|-----------|
| `github:FT-nixforge/ft-nixpalette/v1.0.1` | Fixed version |
| `github:FT-nixforge/ft-nixpalette/stable` | Latest stable |
| `github:FT-nixforge/ft-nixpalette/unstable` | Latest unstable |
| `github:FT-nixforge/ft-nixpalette/main` | Bleeding edge |

---

## Documentation

**[ft-nixforge.github.io/community/ft-nixpalette](https://ft-nixforge.github.io/community/ft-nixpalette)**

## License

MIT
