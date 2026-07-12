{
  # --- Currently trying: Kanagawa (rebelot/kanagawa.nvim) ---
  # Inspired by Hokusai's "The Great Wave" — muted, warm-dark palette. Ships
  # three variants: "wave" (default, dark blue-grey), "dragon" (darker/greyer),
  # "lotus" (light). Lua theme with full Treesitter support.
  #
  # To go back to One Dark: set kanagawa.enable = false and flip the onedark
  # block below back to enable = true.
  colorschemes.kanagawa = {
    enable = true;
    settings = {
      theme = "wave";
    };
  };

  # --- Previous theme: One Dark (navarasu/onedark.nvim), disabled ---
  # Kept here so switching back is a one-line change. The highlights below use
  # onedark palette refs ($bg_d/$blue) and only apply when this block is enabled.
  colorschemes.onedark = {
    enable = false;
    settings = {
      style = "dark";
      transparent = false;
      term_colors = true;

      code_style = {
        comments = "italic";
      };

      highlights = {
        NormalFloat = {
          bg = "$bg_d";
        };
        FloatBorder = {
          fg = "$blue";
          bg = "$bg_d";
        };
      };
    };
  };
}
