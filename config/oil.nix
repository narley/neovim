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
