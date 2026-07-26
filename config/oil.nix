{
  # oil.nvim — a file explorer that lets you edit your filesystem like a
  # normal buffer (github.com/stevearc/oil.nvim). Uses web-devicons (already
  # enabled) for file icons.
  plugins.oil = {
    enable = true;

    # Maps to `require("oil").setup({ ... })`.
    settings = {
      # Take over from netrw as the default file explorer (oil's default).
      default_file_explorer = true;
      view_options.show_hidden = true; # show dotfiles; set false to hide

      # Size the floating window (opened via `-`, see keymap below). Oil's
      # default max_width/max_height of 0 means "unlimited", so the float fills
      # the whole screen. Values between 0 and 1 are a fraction of the editor;
      # use absolute integers instead if you prefer fixed columns/rows.
      float = {
        max_width = 0.5; # 50% of editor width
        max_height = 0.7; # 70% of editor height
      };

      # `q` closes oil, alongside its built-in <C-c>. Oil merges user keymaps
      # into its defaults key-by-key while use_default_keymaps stays true, so
      # `-`, <CR> and the rest survive this.
      #
      # `mode = "n"` is not optional: oil hands an unset mode to vim.keymap.set
      # as "", which would also claim `q` in visual, select and operator-pending.
      keymaps."q" = {
        "__unkeyed-1" = "actions.close";
        mode = "n";
      };
    };
  };

  # oil's signature keybind: open the parent directory as an editable buffer.
  # Edit lines to rename/move/create/delete files, then `:w` to apply.
  #
  # Floating is only exposed through oil's Lua API, not the `:Oil` command —
  # `:Oil --float` doesn't work because the command parses `--float` as a
  # directory name and opens in the current window instead. `open_float()`
  # opens a centred floating window using the `float` config (oil's defaults:
  # rounded border, padding 2). `q`/<C-c> close the float; `-` inside it still
  # climbs to the parent, and `<CR>` opens the file in the previously focused
  # window.
  keymaps = [
    {
      mode = "n";
      key = "-";
      action.__raw = "function() require('oil').open_float() end";
      options.desc = "Open parent directory (Oil, float)";
    }
  ];
}
