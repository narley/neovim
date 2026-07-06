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
    };
  };
}
