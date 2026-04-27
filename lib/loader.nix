{ lib }:

let
  discoverThemeNames = categoryDir:
    if builtins.pathExists categoryDir
    then lib.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir categoryDir))
    else [];

  loadTheme = themeDir:
    let
      themePath = themeDir + "/theme.nix";
      metaPath  = themeDir + "/meta.nix";
    in
    if builtins.pathExists themePath
    then {
      definition = import themePath;
      meta       = if builtins.pathExists metaPath then import metaPath else {};
      dir        = themeDir;
    }
    else builtins.throw
      "ft-nixpalette: theme.nix not found in ${toString themeDir}";

  loadThemesFromRoot = namespace: root:
    let
      loadCategory = category:
        let
          dir   = root + "/${category}";
          names = discoverThemeNames dir;
        in
        map (name: {
          name  = "${namespace}:${category}/${name}";
          value = loadTheme (dir + "/${name}");
        }) names;
    in
    builtins.listToAttrs ((loadCategory "base") ++ (loadCategory "derived"));

  loadAllThemes = { builtinRoot, userRoot ? null }:
    let
      builtin = loadThemesFromRoot "builtin" builtinRoot;
      user    = if userRoot != null then loadThemesFromRoot "user" userRoot else {};
    in
    builtin // user;

in
{
  inherit loadThemesFromRoot loadAllThemes;
}
