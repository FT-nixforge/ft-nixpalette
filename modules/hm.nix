# Home Manager module for nixpalette.
# Declares user-facing options, loads themes, resolves inheritance,
# and delegates to Stylix via modules/stylix.nix.
{ nixpaletteLib, builtinThemesDir }:

{ config, lib, pkgs, ... }:

let
  cfg = config.nixpalette;

  allThemes = nixpaletteLib.loadAllThemes {
    builtinRoot = builtinThemesDir;
    userRoot    = cfg.userThemeDir;
  };

  resolvedTheme = nixpaletteLib.resolve allThemes cfg.theme;

  stylixConfig = import ./stylix.nix {
    inherit lib pkgs resolvedTheme;
    inherit (cfg) stylixOverrides;
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
        let r = nixpaletteLib.resolve allThemes themeId;
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
  options.nixpalette = {

    enable = lib.mkEnableOption "nixpalette theme management (Home Manager)";

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

    preloadThemes = lib.mkOption {
      type        = lib.types.listOf lib.types.str;
      default     = [];
      description = ''
        List of additional theme IDs to resolve and bake into
        $XDG_DATA_HOME/nixpalette/themes.json at build time.
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

  config = lib.mkIf cfg.enable {
    stylix = stylixConfig;

    xdg.dataFile."nixpalette/colors.json".text = colorsJson;
    xdg.dataFile."nixpalette/themes.json".text  = themesJson;
  };
}
