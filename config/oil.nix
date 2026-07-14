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
  keymaps = [
    {
      mode = "n";
      key = "-";
      action = "<cmd>Oil<cr>";
      options.desc = "Open parent directory (Oil)";
    }
  ];
}
