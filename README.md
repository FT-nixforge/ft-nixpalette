# nixpalette

A reusable NixOS theme framework built on top of [Stylix](https://github.com/danth/stylix). nixpalette provides folder-based theme definitions, a parent-child inheritance model, and a clean separation between built-in and user-defined themes.

## File Tree

```
nixpalette/
├── flake.nix                              # Flake entry point
├── lib/
│   ├── default.nix                        # Re-exports all lib functions
│   ├── loader.nix                         # Theme discovery and loading
│   └── resolver.nix                       # Inheritance resolution + deep merge
├── modules/
│   ├── nixos.nix                          # NixOS module (options + wiring)
│   ├── hm.nix                            # Home Manager module (options + wiring)
│   └── stylix.nix                         # Resolved theme → Stylix config
├── themes/
│   ├── base/
│   │   ├── catppuccin-mocha/
│   │   │   ├── theme.nix                  # Full dark theme definition
│   │   │   └── meta.nix                   # Author, description, tags
│   │   └── nord/
│   │       ├── theme.nix                  # Full dark theme definition
│   │       └── meta.nix
│   └── derived/
│       └── catppuccin-mocha-compact/
│           ├── theme.nix                  # Inherits catppuccin-mocha
│           └── meta.nix
├── examples/
│   └── assets/themes/derived/my-theme/
│       └── theme.nix                      # Example user-defined derived theme
└── README.md
```

## Quick Start

### 1. Add nixpalette to your flake inputs

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpalette = {
      url = "github:FTMahringer/nixpalette";
      # nixpalette brings Stylix as its own input — no need to add it separately
    };
  };

  outputs = { nixpkgs, nixpalette, ... }: {
    nixosConfigurations.myHost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixpalette.nixosModules.default
        {
          nixpalette = {
            enable = true;
            theme = "builtin:base/catppuccin-mocha";
          };
        }
      ];
    };
  };
}
```

### 2. For Home Manager

```nix
homeConfigurations.myUser = home-manager.lib.homeManagerConfiguration {
  # ...
  modules = [
    nixpalette.homeManagerModules.default
    {
      nixpalette = {
        enable = true;
        theme = "builtin:base/nord";
      };
    }
  ];
};
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `nixpalette.enable` | `bool` | `false` | Enable nixpalette theme management |
| `nixpalette.theme` | `str` | — | Namespaced theme ID (e.g. `"builtin:base/catppuccin-mocha"`) |
| `nixpalette.userThemeDir` | `null or path` | `null` | Path to user theme directory |
| `nixpalette.stylixOverrides` | `attrs` | `{}` | Extra Stylix options merged on top of the theme |
| `nixpalette.specialisations` | `attrsOf str` | `{}` | Pre-build theme variants as NixOS specialisations (NixOS only) |
| `nixpalette.preloadThemes` | `listOf str` | `[]` | Extra themes to resolve and bake into `themes.json` at build time |

## Theme Identifiers

Themes use namespaced identifiers to prevent ambiguity:

| ID Format | Meaning |
|-----------|---------|
| `builtin:base/<name>` | Base theme shipped with nixpalette |
| `builtin:derived/<name>` | Derived theme shipped with nixpalette |
| `user:base/<name>` | User-defined standalone theme |
| `user:derived/<name>` | User-defined theme inheriting from another |

## Creating Your Own Themes

### Directory structure

Your theme directory (set via `nixpalette.userThemeDir`) must follow this layout:

```
assets/themes/           # ← nixpalette.userThemeDir = ./assets/themes;
├── base/
│   └── my-base-theme/
│       ├── theme.nix    # Required
│       ├── meta.nix     # Optional
│       └── wallpaper.png
└── derived/
    └── my-derived-theme/
        └── theme.nix    # Required (must declare parent)
```

### Base theme format (`theme.nix`)

```nix
{
  polarity = "dark"; # or "light"

  base16 = {
    base00 = "1e1e2e"; # Default Background
    base01 = "181825"; # Lighter Background
    base02 = "313244"; # Selection Background
    base03 = "45475a"; # Comments
    base04 = "585b70"; # Dark Foreground
    base05 = "cdd6f4"; # Default Foreground
    base06 = "f5e0dc"; # Light Foreground
    base07 = "b4befe"; # Light Background
    base08 = "f38ba8"; # Variables
    base09 = "fab387"; # Constants
    base0A = "f9e2af"; # Classes
    base0B = "a6e3a1"; # Strings
    base0C = "94e2d5"; # RegEx, Escape chars
    base0D = "89b4fa"; # Functions
    base0E = "cba6f7"; # Keywords
    base0F = "f2cdcd"; # Deprecated
  };

  fonts = {
    serif     = { name = "Noto Serif";      package = "noto-fonts"; };
    sansSerif = { name = "Inter";           package = "inter"; };
    monospace = { name = "JetBrains Mono";  package = "jetbrains-mono"; };
    emoji     = { name = "Noto Color Emoji"; package = "noto-fonts-color-emoji"; };
    sizes = {
      applications = 12;
      desktop      = 11;
      popups       = 10;
      terminal     = 13;
    };
  };

  wallpaper = ./wallpaper.png; # or null
  overrides = {};              # reserved for future per-app overrides
}
```

When `wallpaper` is `null`, nixpalette automatically generates a solid-color wallpaper from the theme's background color (`base00`). To ship a custom wallpaper, place the image file in the theme directory and reference it with a relative path.

Font `package` values are nixpkgs attribute paths. Use top-level names like `"inter"` or dot-separated paths for nested packages like `"nerd-fonts.jetbrains-mono"`.

### Derived theme format (`theme.nix`)

Derived themes declare a `parent` and override only what they need:

```nix
{
  parent = "builtin:base/catppuccin-mocha";

  # Only the fields you specify are overridden; everything else is inherited.
  base16 = {
    base0D = "7aa2f7"; # Custom blue
  };

  fonts.sizes.terminal = 14;
}
```

### Pointing to your theme directory

```nix
{
  nixpalette = {
    enable = true;
    theme = "user:derived/my-theme";
    userThemeDir = ./assets/themes;
  };
}
```

## Inheritance Rules

1. Derived themes declare exactly **one** `parent` using a namespaced ID
2. Parent fields are **deep-merged** with child fields; child wins on collision
3. Allowed inheritance paths:
   - `builtin:derived/*` → `builtin:base/*` (standard)
   - `user:base/*` → nothing (standalone)
   - `user:derived/*` → `builtin:base/*` (primary use case)
   - `user:derived/*` → `user:base/*` (standard)
   - `user:derived/*` → `builtin:derived/*` (advanced — chains inheritance)
4. **Circular inheritance** is a hard error, detected and reported clearly
5. Unknown parent IDs fail immediately with a list of available themes

## Overriding Stylix Settings

There are two ways to override what the theme provides:

### Via `stylixOverrides`

```nix
nixpalette = {
  enable = true;
  theme = "builtin:base/catppuccin-mocha";
  stylixOverrides = {
    cursor.size = 32;
    opacity.terminal = 0.95;
  };
};
```

### Via direct `stylix.*` options

Since nixpalette sets Stylix values with `mkDefault` priority, you can override any setting directly:

```nix
nixpalette.enable = true;
nixpalette.theme = "builtin:base/catppuccin-mocha";

# Direct override — takes precedence over theme values
stylix.fonts.monospace = {
  name = "Hack";
  package = pkgs.hack-font;
};
```

## Built-in Themes

### Base themes

| ID | Polarity | Description |
|----|----------|-------------|
| `builtin:base/catppuccin-mocha` | dark | Warm dark theme with pastel accents |
| `builtin:base/catppuccin-latte` | light | Warm, creamy light theme with pastel accents |
| `builtin:base/nord` | dark | Arctic, north-bluish palette |
| `builtin:base/dracula` | dark | Vivid purple and pink accents on deep grey |
| `builtin:base/gruvbox-dark` | dark | Retro groove with warm earthy tones |
| `builtin:base/gruvbox-light` | light | Warm parchment-toned light variant of Gruvbox |
| `builtin:base/solarized-dark` | dark | Precision dark theme with unique chroma relationships |
| `builtin:base/solarized-light` | light | Precision light theme with warm parchment tones |
| `builtin:base/tokyo-night` | dark | Clean dark theme inspired by Tokyo city lights |
| `builtin:base/one-dark` | dark | Atom's iconic dark theme with cool blue-grey tones |
| `builtin:base/rose-pine` | dark | Soothingly dark with dusty rose and warm neutrals |
| `builtin:base/everforest-dark` | dark | Comfortable, nature-inspired green-based palette |

### Derived themes

| ID | Parent | Description |
|----|--------|-------------|
| `builtin:derived/catppuccin-mocha-compact` | catppuccin-mocha | Smaller fonts and Iosevka mono |
| `builtin:derived/catppuccin-latte-compact` | catppuccin-latte | Smaller fonts and Iosevka mono |
| `builtin:derived/rose-pine-nerd` | rose-pine | Nerd Font patched JetBrains Mono |
| `builtin:derived/gruvbox-dark-nerd` | gruvbox-dark | Nerd Font patched Hack |

## Fast Theme Switching with Specialisations

nixpalette supports NixOS [specialisations](https://nixos.wiki/wiki/Specialisation) to pre-build multiple theme configurations into a single system closure. This enables near-instant theme switching — no network fetch or Nix build required.

### Setup

```nix
nixpalette = {
  enable = true;
  theme = "builtin:base/catppuccin-mocha";  # default theme
  specialisations = {
    nord    = "builtin:base/nord";
    compact = "builtin:derived/catppuccin-mocha-compact";
  };
};
```

### Switching

```bash
# Switch to the pre-built "nord" theme
sudo /run/current-system/specialisation/nord/bin/switch-to-configuration switch

# Switch back to the default
sudo /run/current-system/bin/switch-to-configuration switch
```

Each specialisation is a full NixOS configuration with a different `nixpalette.theme`. All specialisations share the same Nix store, so common packages are not duplicated.

> **Note:** Specialisations are a NixOS-only feature. They are not available in Home Manager.

## Colors Export

nixpalette generates two JSON files at build time:

- **`colors.json`** — the active theme's resolved palette
  - NixOS: `/etc/nixpalette/colors.json`
  - Home Manager: `$XDG_DATA_HOME/nixpalette/colors.json`

- **`themes.json`** — every preloaded theme's resolved palette, keyed by theme ID
  - NixOS: `/etc/nixpalette/themes.json`
  - Home Manager: `$XDG_DATA_HOME/nixpalette/themes.json`

The active theme is always included in `themes.json`. Add more themes via `preloadThemes`:

```nix
nixpalette = {
  enable = true;
  theme  = "builtin:base/catppuccin-mocha";
  preloadThemes = [
    "builtin:base/nord"
    "builtin:base/dracula"
    "builtin:base/tokyo-night"
  ];
};
```

This bakes the full base16 palette of every listed theme into the system closure at rebuild time. A live switcher can then apply any of them at runtime — no network fetch, no Nix build:

```bash
# Read the current accent color
jq -r '.base16.base0D' /etc/nixpalette/colors.json

# List all preloaded theme IDs
jq -r 'keys[]' /etc/nixpalette/themes.json

# Get the full palette for a specific preloaded theme
jq '.["builtin:base/nord"].base16' /etc/nixpalette/themes.json
```

The `themes.json` structure per entry:

```json
{
  "builtin:base/nord": {
    "themeId":  "builtin:base/nord",
    "polarity": "dark",
    "base16":   { "base00": "2e3440", ... },
    "meta":     { "author": "Arctic Ice Studio", "tags": ["dark", "nord"] }
  }
}
```

## Future Theme Switcher Integration

nixpalette is designed to support a future theme switcher:

- **Discovery:** Themes are discovered by scanning `base/` and `derived/` directories under both the builtin and user roots. A switcher CLI can call `nixpaletteLib.loadAllThemes` to enumerate all available themes with their metadata.
- **Selection:** The active theme is a plain string option (`nixpalette.theme`). A switcher only needs to write the new theme ID and trigger a NixOS rebuild (or switch to a pre-built specialisation).
- **Preview:** Each theme can include a `preview` field in `meta.nix` pointing to a screenshot, enabling visual browsing before selection.

## Known Limitations

- **Rebuild required for new themes** — applying a theme not in `preloadThemes` requires a NixOS rebuild. Add frequently-used themes to `preloadThemes` so a future live switcher can apply them at runtime. Use [specialisations](#fast-theme-switching-with-specialisations) for near-instant full-system switching.
- **Single parent** — each derived theme can inherit from exactly one parent; multiple inheritance is not supported
- **Evaluation-time resolution** — theme loading uses `builtins.readDir` at Nix evaluation time; the theme directory must exist and be accessible during `nix eval`
