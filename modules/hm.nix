# Home Manager module for ft-nixpalette.
# Declares user-facing options, loads themes, resolves inheritance,
# and delegates to Stylix via modules/stylix.nix.
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
  deHmConfigs = {
    Hyprland = (import ./integrations/de/hyprland.nix deArgs).hmConfig;
    MangoWC  = (import ./integrations/de/mangowc.nix  deArgs).hmConfig;
    Niri     = (import ./integrations/de/niri.nix     deArgs).hmConfig;
    GNOME    = (import ./integrations/de/gnome.nix    deArgs).hmConfig;
    KDE      = (import ./integrations/de/kde.nix      deArgs).hmConfig;
    COSMIC   = (import ./integrations/de/cosmic.nix   deArgs).hmConfig;
  };

  stylixConfig = import ./stylix.nix {
    inherit lib pkgs resolvedTheme;
    inherit (cfg) stylixOverrides;
    wallpaper = cfg.defaultWallpaper;
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

    enable = lib.mkEnableOption "ft-nixpalette theme management (Home Manager)";

    integrations = import ./integrations/de/default.nix { inherit lib; };

    theme = lib.mkOption {
      type        = lib.types.str;
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

    preloadThemes = lib.mkOption {
      type        = lib.types.listOf lib.types.str;
      default     = [];
      description = ''
        List of additional theme IDs to resolve and bake into
        $XDG_DATA_HOME/ft-nixpalette/themes.json at build time.
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
      stylix = stylixConfig;

      xdg.dataFile."ft-nixpalette/colors.json".text = colorsJson;
      xdg.dataFile."ft-nixpalette/themes.json".text  = themesJson;
    }

    (lib.optionalAttrs (cfg.integrations.de != null)
      (deHmConfigs.${cfg.integrations.de} or {}))
  ]);
}
