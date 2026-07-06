{
  # lualine — statusline themed to match the active colorscheme (One Dark).
  #
  # `theme = "auto"` derives the palette from the current colorscheme, so the bar
  # tracks One Dark automatically (and follows along if you change the theme).
  # The default sections already show what you asked for:
  #   mode | branch · diff · diagnostics | filename | filetype | progress | location
  plugins.lualine = {
    enable = true;
    settings = {
      options = {
        theme = "auto";
        globalstatus = true; # one statusline for the whole window (not per-split)
      };
    };
  };
}
