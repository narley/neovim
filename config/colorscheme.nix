{
  # One Dark (navarasu/onedark.nvim) — the classic #282c34 One Dark palette that
  # Zed's default dark theme is based on. `style = "dark"` is the closest match
  # to Zed; other styles: "darker", "cool", "deep", "warm", "warmer", "light".
  colorschemes.onedark = {
    enable = true;
    settings = {
      style = "dark";
      transparent = false;
      term_colors = true;

      # Zed italicises comments — match that. Per-token style, each of:
      # "none" | "italic" | "bold" | "underline" (combinable with ",").
      code_style = {
        comments = "italic";
      };

      # Make floating windows (LSP hover/`K`, diagnostic floats) stand out from
      # the editor: give their body the palette's darker background (`bg_d`,
      # #21252b vs the editor's #282c34) and their border a blue tint. The `$`
      # values are onedark palette references, so they stay correct if `style`
      # changes above. Combined with `winborder = "rounded"` in options.nix.
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
