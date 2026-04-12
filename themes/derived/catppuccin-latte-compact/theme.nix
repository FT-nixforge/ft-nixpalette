# Catppuccin Latte Compact — Latte with smaller fonts and Iosevka for terminals.
{
  parent = "builtin:base/catppuccin-latte";

  fonts = {
    monospace = {
      name    = "Iosevka";
      package = "iosevka";
    };
    sizes = {
      applications = 11;
      desktop      = 10;
      popups       = 9;
      terminal     = 12;
    };
  };
}
