{
  # flash.nvim (folke) — avy-style motion. `require('flash').jump()` starts an
  # incremental search: type the characters you're heading for and every match
  # gets a label; press the label to teleport there. This is the equivalent of
  # Spacemacs' SPC j j (avy-goto-char-timer). Installing flash also enhances
  # f/t/;/, and labels matches during / and ? search out of the box.
  plugins.flash.enable = true;

  # <Space>jj — flash jump, in normal, visual and operator-pending modes (so it
  # doubles as a motion, e.g. d<Space>jj). Bound under the leader to keep Vim's
  # built-in `s` (substitute) intact, rather than flash's default `s`/`S`.
  keymaps = [
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "<leader>jj";
      action = "<cmd>lua require('flash').jump()<cr>";
      options.desc = "Flash jump (avy)";
    }
    # <Space>jt — flash treesitter: labels every syntax node around the cursor
    # (identifier, call, statement, function…) so you can select an entire scope
    # by jumping to its label. The label-driven cousin of expand-region.
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "<leader>jt";
      action = "<cmd>lua require('flash').treesitter()<cr>";
      options.desc = "Flash treesitter select";
    }
  ];
}
