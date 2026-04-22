# NixOS module for ft-nixpalette.
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
  deNixosConfigs = {
    Hyprland = (import ./integrations/de/hyprland.nix deArgs).nixosConfig;
    MangoWC  = (import ./integrations/de/mangowc.nix  deArgs).nixosConfig;
    Niri     = (import ./integrations/de/niri.nix     deArgs).nixosConfig;
    GNOME    = (import ./integrations/de/gnome.nix    deArgs).nixosConfig;
    KDE      = (import ./integrations/de/kde.nix      deArgs).nixosConfig;
    COSMIC   = (import ./integrations/de/cosmic.nix   deArgs).nixosConfig;
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

  # Resolve every theme listed in preloadThemes and serialise the full set to
  # a single JSON object keyed by theme ID.  A live-switcher can read this file
  # and apply any pre-resolved palette at runtime without a Nix rebuild.
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

    enable = lib.mkEnableOption "ft-nixpalette theme management";

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

    specialisations = lib.mkOption {
      type        = lib.types.attrsOf lib.types.str;
      default     = {};
      description = ''
        Pre-build alternative theme configurations as NixOS specialisations.
        Each key is a specialisation name and each value is a namespaced theme ID.
        Switch between pre-built themes instantly without a network build:
          sudo /run/current-system/specialisation/<name>/bin/switch-to-configuration switch
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
        /etc/ft-nixpalette/themes.json at build time.
        The active theme is always included automatically.
        A live theme switcher can read this file and apply any of the
        preloaded palettes at runtime without a NixOS rebuild.
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

      environment.etc."ft-nixpalette/colors.json".text = colorsJson;
      environment.etc."ft-nixpalette/themes.json".text  = themesJson;

      specialisation = lib.mapAttrs (_name: themeId: {
        configuration = {
          "ft-nixpalette".theme          = lib.mkForce themeId;
          "ft-nixpalette".specialisations = lib.mkForce {};
        };
      }) cfg.specialisations;
    }

    (lib.optionalAttrs (cfg.integrations.de != null)
      (deNixosConfigs.${cfg.integrations.de} or {}))
  ]);
}
