{ lib, pkgs, resolvedTheme, stylixOverrides, wallpaper }:

let
  fonts        = resolvedTheme.fonts;
  cursor       = resolvedTheme.cursor;
  opacity      = resolvedTheme.opacity;
  overrides    = resolvedTheme.overrides or {};
  hasWallpaper = resolvedTheme ? wallpaper && resolvedTheme.wallpaper != null;

  fallbackWallpaper = pkgs.runCommand "ft-nixpalette-wallpaper.png" {
    nativeBuildInputs = [ pkgs.imagemagick ];
  } "magick -size 3840x2160 xc:'#${resolvedTheme.base16.base00}' png:$out";

  activeWallpaper =
    if      hasWallpaper       then resolvedTheme.wallpaper
    else if wallpaper != null  then wallpaper
    else                            fallbackWallpaper;

  # Resolve "nerd-fonts.jetbrains-mono" → pkgs.nerd-fonts.jetbrains-mono
  resolvePkg = subject: ref:
    let resolved = lib.attrByPath (lib.splitString "." ref) null pkgs;
    in if resolved != null then resolved
       else builtins.throw "ft-nixpalette: package '${ref}' (for ${subject}) not found in nixpkgs";

  overridesCursor  = stylixOverrides.cursor  or {};
  overridesFonts   = stylixOverrides.fonts   or {};
  overridesOpacity = stylixOverrides.opacity or {};
  overridesOther   = lib.filterAttrs (n: _: !lib.elem n [ "fonts" "cursor" "opacity" ]) stylixOverrides;

in
lib.mkMerge [

  {
    enable       = true;
    base16Scheme = lib.mkDefault resolvedTheme.base16;
    polarity     = lib.mkDefault resolvedTheme.polarity;
    image        = lib.mkDefault activeWallpaper;
  }

  {
    fonts = {
      serif     = { name = lib.mkDefault fonts.serif.name;     package = lib.mkDefault (resolvePkg "fonts.serif"     fonts.serif.package); };
      sansSerif = { name = lib.mkDefault fonts.sansSerif.name; package = lib.mkDefault (resolvePkg "fonts.sansSerif" fonts.sansSerif.package); };
      monospace = { name = lib.mkDefault fonts.monospace.name; package = lib.mkDefault (resolvePkg "fonts.monospace" fonts.monospace.package); };
      emoji     = { name = lib.mkDefault fonts.emoji.name;     package = lib.mkDefault (resolvePkg "fonts.emoji"     fonts.emoji.package); };
      sizes = {
        applications = lib.mkDefault fonts.sizes.applications;
        desktop      = lib.mkDefault fonts.sizes.desktop;
        popups       = lib.mkDefault fonts.sizes.popups;
        terminal     = lib.mkDefault fonts.sizes.terminal;
      };
    };
  }

  {
    cursor = {
      name    = lib.mkDefault cursor.name;
      package = lib.mkDefault (resolvePkg "cursor" cursor.package);
      size    = lib.mkDefault cursor.size;
    };
  }

  {
    opacity = {
      applications = lib.mkDefault opacity.applications;
      desktop      = lib.mkDefault opacity.desktop;
      popups       = lib.mkDefault opacity.popups;
      terminal     = lib.mkDefault opacity.terminal;
    };
  }

  # Theme-level overrides (highest priority within the theme itself)
  overrides

  # stylixOverrides — fonts
  (lib.mkIf (overridesFonts != {}) {
    fonts = lib.mapAttrs (role: v: {
      name    = lib.mkDefault v.name;
      package = lib.mkDefault (
        if lib.isString v.package then resolvePkg "fonts.${role}" v.package else v.package
      );
    } // lib.optionalAttrs (v ? sizes) {
      sizes = lib.mapAttrs (_: s: lib.mkDefault s) v.sizes;
    }) overridesFonts;
  })

  # stylixOverrides — cursor
  (lib.mkIf (overridesCursor != {}) {
    cursor = lib.mkMerge [
      (lib.optionalAttrs (overridesCursor ? name)    { name    = overridesCursor.name; })
      (lib.optionalAttrs (overridesCursor ? package) { package = if lib.isString overridesCursor.package then resolvePkg "cursor" overridesCursor.package else overridesCursor.package; })
      (lib.optionalAttrs (overridesCursor ? size)    { size    = overridesCursor.size; })
    ];
  })

  # stylixOverrides — opacity
  (lib.mkIf (overridesOpacity != {}) {
    opacity = lib.mapAttrs (_: v: v) overridesOpacity;
  })

  # stylixOverrides — everything else
  overridesOther

]
