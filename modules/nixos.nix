{ ftNixpaletteLib, builtinThemesDir, defaultWallpaper }:

{ config, lib, pkgs, ... }:

let
  cfg = config."ft-nixpalette";

  allThemes    = ftNixpaletteLib.loadAllThemes {
    builtinRoot = builtinThemesDir;
    userRoot    = cfg.userThemeDir;
  };

  resolvedTheme = ftNixpaletteLib.resolve allThemes cfg.theme;

  stylixCfg = import ./stylix.nix {
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
      ids        = lib.unique ([ cfg.theme ] ++ cfg.preloadThemes);
      resolveOne = id:
        let r = ftNixpaletteLib.resolve allThemes id;
        in { themeId = id; polarity = r.polarity; base16 = r.base16; meta = r.meta or {}; };
    in
    builtins.toJSON (builtins.listToAttrs
      (map (id: { name = id; value = resolveOne id; }) ids));

in
{
  options."ft-nixpalette" = {

    enable = lib.mkEnableOption "ft-nixpalette theme management";

    # ── Theme selection ────────────────────────────────────────────────────────

    theme = lib.mkOption {
      type    = lib.types.str;
      default = "builtin:base/catppuccin-mocha";
      example = "builtin:base/nord";
      description = ''
        Namespaced theme identifier.
        Format: "<namespace>:<category>/<name>"
        Built-in examples: "builtin:base/catppuccin-mocha", "builtin:base/nord"
        User theme example: "user:derived/my-theme"
      '';
    };

    userThemeDir = lib.mkOption {
      type    = lib.types.nullOr lib.types.path;
      default = null;
      example = lib.literalExpression "./assets/themes";
      description = ''
        Path to a directory containing your own themes.
        Expected layout: base/<name>/theme.nix and/or derived/<name>/theme.nix.
        Set to null to use built-in themes only.
      '';
    };

    # ── Wallpaper ──────────────────────────────────────────────────────────────

    defaultWallpaper = lib.mkOption {
      type    = lib.types.nullOr lib.types.path;
      default = defaultWallpaper;
      example = lib.literalExpression "./wallpaper.png";
      description = ''
        Fallback wallpaper for themes that do not ship their own image.
        When null, a solid-color PNG is generated from the theme's base00.
        Defaults to wallpaper.{png,jpg,jpeg} at the flake root if present.
      '';
    };

    # ── Stylix ─────────────────────────────────────────────────────────────────

    stylixOverrides = lib.mkOption {
      type    = lib.types.attrs;
      default = {};
      example = lib.literalExpression ''{ cursor.size = 32; }'';
      description = ''
        Stylix options merged on top of theme-provided values.
        Theme values use mkDefault, so plain assignments here win.
        Use lib.mkForce to override values set by Stylix itself.
      '';
    };

    stylix = lib.mkOption {
      type        = lib.types.attrs;
      readOnly    = true;
      default     = stylixCfg;
      description = ''
        The fully-resolved Stylix configuration for the active theme.
        ft-nixpalette applies this automatically; expose it here so you can
        reference or merge it in your own config:

          stylix = config.ft-nixpalette.stylix;
      '';
    };

    # ── Theme switching ────────────────────────────────────────────────────────

    specialisations = lib.mkOption {
      type    = lib.types.attrsOf lib.types.str;
      default = {};
      example = lib.literalExpression ''
        {
          dark  = "builtin:base/catppuccin-mocha";
          light = "builtin:base/nord";
        }
      '';
      description = ''
        Pre-built alternative themes as NixOS specialisations.
        Switch without a rebuild:
          sudo /run/current-system/specialisation/<name>/bin/switch-to-configuration switch
      '';
    };

    preloadThemes = lib.mkOption {
      type    = lib.types.listOf lib.types.str;
      default = [];
      example = lib.literalExpression ''[ "builtin:base/nord" "builtin:base/dracula" ]'';
      description = ''
        Additional theme IDs to resolve and bake into /etc/ft-nixpalette/themes.json.
        The active theme is always included. Use this to feed a live theme switcher
        with pre-resolved palettes so it can switch at runtime without a rebuild.
      '';
    };

  };

  config = lib.mkIf cfg.enable {

    stylix = stylixCfg;

    environment.etc."ft-nixpalette/colors.json".text = colorsJson;
    environment.etc."ft-nixpalette/themes.json".text  = themesJson;

    specialisation = lib.mapAttrs
      (_: themeId: {
        configuration = {
          "ft-nixpalette".theme          = lib.mkForce themeId;
          "ft-nixpalette".specialisations = lib.mkForce {};
        };
      })
      cfg.specialisations;

  };
}
