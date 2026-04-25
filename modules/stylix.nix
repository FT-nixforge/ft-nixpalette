# Translates a resolved ft-nixpalette theme into Stylix option values.
# All theme-provided values use mkDefault so users can override them
# either through stylixOverrides or by setting stylix.* directly.
{ lib, pkgs, resolvedTheme, stylixOverrides, wallpaper }:

let
  fonts          = resolvedTheme.fonts;
  cursorTheme    = resolvedTheme.cursor;
  opacityTheme   = resolvedTheme.opacity;
  themeOverrides = resolvedTheme.overrides or {};
  hasWallpaper   = resolvedTheme ? wallpaper && resolvedTheme.wallpaper != null;

  # Generate a solid-color wallpaper from the theme's background color.
  # Last-resort fallback when neither the theme nor the user provides a wallpaper.
  fallbackWallpaper = pkgs.runCommand "ft-nixpalette-wallpaper.png" {
    nativeBuildInputs = [ pkgs.imagemagick ];
  } ''
    magick -size 3840x2160 xc:'#${resolvedTheme.base16.base00}' png:$out
  '';

  # Wallpaper priority:
  #   1. Theme-specific wallpaper (theme.wallpaper != null)
  #   2. "ft-nixpalette".defaultWallpaper (user override or flake root wallpaper image)
  #   3. Auto-generated solid-color PNG from base00
  activeWallpaper =
    if hasWallpaper          then resolvedTheme.wallpaper
    else if wallpaper != null then wallpaper
    else                           fallbackWallpaper;

  # Resolve a package from a string reference.
  # Supports dot-separated paths (e.g. "nerd-fonts.jetbrains-mono") as well as
  # top-level attribute names (e.g. "inter").
  resolvePkg = subject: packageRef:
    let
      segments = lib.splitString "." packageRef;
      resolved = lib.attrByPath segments null pkgs;
    in
    if resolved != null then
      resolved
    else
      builtins.throw
        ("ft-nixpalette: Package '${packageRef}' (for ${subject}) not found in nixpkgs. "
        + "Check the package name in your theme definition.");

  # Extract cursor-related overrides so we can merge them correctly.
  # When the theme does not define a cursor, we still want stylixOverrides
  # to be able to set one without causing Stylix-internal null issues.
  cursorOverride = stylixOverrides.cursor or {};
  hasCursorOverride = cursorOverride != {};

  # Extract font-related overrides.
  fontsOverride = stylixOverrides.fonts or {};
  hasFontsOverride = fontsOverride != {};

  # Extract opacity-related overrides.
  opacityOverride = stylixOverrides.opacity or {};
  hasOpacityOverride = opacityOverride != {};

  # Everything in stylixOverrides that is NOT fonts, cursor, or opacity.
  # These are passed through as-is (plain values take precedence).
  otherOverrides = lib.filterAttrs
    (n: _: n != "fonts" && n != "cursor" && n != "opacity")
    stylixOverrides;

in
lib.mkMerge [
  {
    enable       = true;
    base16Scheme = lib.mkDefault resolvedTheme.base16;
    polarity     = lib.mkDefault resolvedTheme.polarity;
    image        = lib.mkDefault activeWallpaper;
  }

  # Theme-provided fonts (always present via themes/default.nix)
  {
    fonts = {
      serif = {
        name    = lib.mkDefault fonts.serif.name;
        package = lib.mkDefault (resolvePkg "fonts.serif" fonts.serif.package);
      };
      sansSerif = {
        name    = lib.mkDefault fonts.sansSerif.name;
        package = lib.mkDefault (resolvePkg "fonts.sansSerif" fonts.sansSerif.package);
      };
      monospace = {
        name    = lib.mkDefault fonts.monospace.name;
        package = lib.mkDefault (resolvePkg "fonts.monospace" fonts.monospace.package);
      };
      emoji = {
        name    = lib.mkDefault fonts.emoji.name;
        package = lib.mkDefault (resolvePkg "fonts.emoji" fonts.emoji.package);
      };
      sizes = {
        applications = lib.mkDefault fonts.sizes.applications;
        desktop      = lib.mkDefault fonts.sizes.desktop;
        popups       = lib.mkDefault fonts.sizes.popups;
        terminal     = lib.mkDefault fonts.sizes.terminal;
      };
    };
  }

  # Theme-provided cursor (always present via themes/default.nix)
  {
    cursor = {
      name    = lib.mkDefault cursorTheme.name;
      package = lib.mkDefault (resolvePkg "cursor" cursorTheme.package);
      size    = lib.mkDefault cursorTheme.size;
    };
  }

  # Theme-provided opacity (always present via themes/default.nix)
  {
    opacity = {
      applications = lib.mkDefault opacityTheme.applications;
      desktop      = lib.mkDefault opacityTheme.desktop;
      popups       = lib.mkDefault opacityTheme.popups;
      terminal     = lib.mkDefault opacityTheme.terminal;
    };
  }

  # Theme overrides (plain values — highest theme priority)
  themeOverrides

  # stylixOverrides for fonts (plain values — override theme)
  (lib.mkIf hasFontsOverride {
    fonts = lib.mapAttrs
      (role: value: {
        name    = lib.mkDefault value.name or (throw "stylixOverrides.fonts.${role}.name is required");
        package = lib.mkDefault (
          if value ? package then
            (if lib.isString value.package then resolvePkg "fonts.${role}" value.package else value.package)
          else
            (throw "stylixOverrides.fonts.${role}.package is required")
        );
      } // lib.optionalAttrs (value ? sizes) {
        sizes = lib.mapAttrs (_: v: lib.mkDefault v) value.sizes;
      })
      fontsOverride;
  })

  # stylixOverrides for cursor (plain values — override theme)
  # We always emit this block when stylixOverrides.cursor is set,
  # regardless of whether the theme defines a cursor.
  (lib.mkIf hasCursorOverride {
    cursor = lib.mkMerge [
      (lib.optionalAttrs (builtins.hasAttr "name" cursorOverride) {
        name = cursorOverride.name;
      })
      (lib.optionalAttrs (builtins.hasAttr "package" cursorOverride) {
        package =
          if lib.isString cursorOverride.package
          then resolvePkg "cursor" cursorOverride.package
          else cursorOverride.package;
      })
      (lib.optionalAttrs (builtins.hasAttr "size" cursorOverride) {
        size = cursorOverride.size;
      })
    ];
  })

  # stylixOverrides for opacity (plain values — override theme)
  (lib.mkIf hasOpacityOverride {
    opacity = lib.mapAttrs (_: value: value) opacityOverride;
  })

  # Any other stylixOverrides (passed through as-is)
  otherOverrides
]
