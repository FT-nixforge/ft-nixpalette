# Home Manager module for ft-nixpalette.
# Declares user-facing options, loads themes, resolves inheritance,
# and provides DE integrations and theme JSON files.
# NOTE: Stylix is intentionally NOT configured here — the NixOS module
# handles Stylix system-wide. This avoids duplicate definition errors.
{ ftNixpaletteLib, builtinThemesDir, defaultWallpaper }:

{ config, lib, pkgs, ... }:

let
  cfg = config."ft-nixpalette";

  allThemes = ftNixpaletteLib.loadAllThemes {
    builtinRoot = builtinThemesDir;
    userRoot    = cfg.userThemeDir;
  };

  resolvedTheme = ftNixpaletteLib.resolve allThemes cfg.theme;

  deArgs = { inherit lib resolvedTheme; };
  # Lazy thunk: each value is a function that returns the config.
  # This prevents Nix from evaluating any DE import until the mkIf condition
  # is actually checked, avoiding infinite recursion.
  deHmConfigs = {
    Hyprland = _: (import ./integrations/de/hyprland.nix deArgs).hmConfig;
    MangoWC  = _: (import ./integrations/de/mangowc.nix  deArgs).hmConfig;
    Niri     = _: (import ./integrations/de/niri.nix     deArgs).hmConfig;
    GNOME    = _: (import ./integrations/de/gnome.nix    deArgs).hmConfig;
    KDE      = _: (import ./integrations/de/kde.nix      deArgs).hmConfig;
    COSMIC   = _: (import ./integrations/de/cosmic.nix   deArgs).hmConfig;
  };

  colorsJson = builtins.toJSON {
    themeId  = cfg.theme;
    polarity = resolvedTheme.polarity;
    base16   = resolvedTheme.base16;
  };

  themesJson =
    let
      preloadIds  = lib.unique ([ cfg.theme ] ++ cfg.preloadThemes);
      resolveOne  = themeId:
        let r = ftNixpaletteLib.resolve allThemes themeId;
        in {
          themeId  = themeId;
          polarity = r.polarity;
          base16   = r.base16;
          meta     = r.meta or {};
        };
    in
    builtins.toJSON (builtins.listToAttrs
      (map (id: { name = id; value = resolveOne id; }) preloadIds));

in
{
  options."ft-nixpalette" = {

    enable = lib.mkEnableOption "ft-nixpalette theme management (Home Manager)" // {
      default = false;
    };

    integrations = import ./integrations/de/default.nix { inherit lib; };

    theme = lib.mkOption {
      type        = lib.types.str;
      default     = "builtin:base/catppuccin-mocha";
      description = ''
        Namespaced theme identifier to apply.
        Use the format "<namespace>:<category>/<name>".
        Examples: "builtin:base/catppuccin-mocha", "user:derived/my-theme".
      '';
      example = "builtin:base/catppuccin-mocha";
    };

    userThemeDir = lib.mkOption {
      type        = lib.types.nullOr lib.types.path;
      default     = null;
      description = ''
        Path to the user theme directory.
        This directory should contain base/ and/or derived/ subdirectories,
        each holding theme folders with a theme.nix inside.
        Set to null to use only built-in themes.
      '';
      example = lib.literalExpression "./assets/themes";
    };

    stylixOverrides = lib.mkOption {
      type        = lib.types.attrs;
      default     = {};
      description = ''
        Additional Stylix options merged on top of theme-provided values.
        Theme values are set with mkDefault priority, so plain values here
        take precedence. For full control, use lib.mkForce.
      '';
      example = lib.literalExpression ''{ cursor.size = 32; }'';
    };

    defaultWallpaper = lib.mkOption {
      type        = lib.types.nullOr lib.types.path;
      default     = defaultWallpaper;
      description = ''
        Wallpaper used for any theme that does not ship its own wallpaper image.
        Defaults to a flake-root wallpaper image when present, otherwise null.
        When null, a solid-color wallpaper is generated from the theme's base00.
        Set this to override the flake default with your own image.
      '';
      example = lib.literalExpression "./my-wallpaper.png";
    };

    specialisations = lib.mkOption {
      type        = lib.types.attrsOf lib.types.str;
      default     = {};
      description = ''
        Map of specialisation name → theme ID.
        Used by the NixOS module to propagate theme changes into
        Home-Manager specialisations. Normally auto-set by the NixOS module.
      '';
      example = lib.literalExpression ''
        {
          dark  = "builtin:base/catppuccin-mocha";
          light = "builtin:base/nord";
        }
      '';
    };

    preloadThemes = lib.mkOption {
      type        = lib.types.listOf lib.types.str;
      default     = [];
      description = ''
        List of additional theme IDs to resolve and bake into
        /ft-nixpalette/themes.json at build time.
        The active theme is always included automatically.
        A live theme switcher can read this file and apply any of the
        preloaded palettes at runtime without a Home Manager rebuild.
      '';
      example = lib.literalExpression ''
        [
          "builtin:base/nord"
          "builtin:base/dracula"
          "builtin:base/tokyo-night"
        ]
      '';
    };

  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # NOTE: Stylix is intentionally NOT configured here.
      # The NixOS ft-nixpalette module handles Stylix system-wide.
      # This HM module only provides: DE integration, theme files,
      # and the config.lib.stylix.colors API for user modules.

      xdg.dataFile."ft-nixpalette/colors.json".text = colorsJson;
      xdg.dataFile."ft-nixpalette/themes.json".text  = themesJson;
    }

    # DE integrations — each guarded by its own mkIf.
    # The config is fetched via a lazy thunk (function call) so the import
    # is only evaluated when the condition is true.
    (lib.mkIf (cfg.integrations.de == "Hyprland") (deHmConfigs.Hyprland null))
    (lib.mkIf (cfg.integrations.de == "MangoWC")  (deHmConfigs.MangoWC null))
    (lib.mkIf (cfg.integrations.de == "Niri")     (deHmConfigs.Niri null))
    (lib.mkIf (cfg.integrations.de == "GNOME")    (deHmConfigs.GNOME null))
    (lib.mkIf (cfg.integrations.de == "KDE")      (deHmConfigs.KDE null))
    (lib.mkIf (cfg.integrations.de == "COSMIC")   (deHmConfigs.COSMIC null))
  ]);
}
