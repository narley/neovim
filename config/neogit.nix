{
  # Neogit — a Magit clone (à la Spacemacs). Opens a status buffer where you
  # stage/unstage (s / u), discard (x), and drive everything else through
  # single-key popups: `c` commit, `p` push, `F` pull, `b` branch, `r` rebase,
  # `Z` stash, `l` log. It auto-detects and uses the plugins already enabled
  # here — telescope (pickers), gitsigns (hunk staging) and diffview (diffs +
  # 3-way merge-conflict resolution).
  plugins.neogit = {
    enable = true;
    settings = {
      # Syntax-highlight the code inside diff hunks (per the file's language) via
      # treesitter, instead of showing them as plain +/- text. Off by default in
      # Neogit; works here because all treesitter grammars are installed.
      treesitter_diff_highlight = true;

      # Neogit hides line numbers in its buffers by default. Turn them back on to
      # match the editor's hybrid numbering (options.nix: number + relativenumber)
      # — handy for `V`-selecting a range of diff lines.
      disable_line_numbers = false;
      disable_relative_line_numbers = false;
    };
  };

  # diffview.nvim — the diff / merge-conflict UI Neogit opens when you view a
  # change. Also usable standalone via :DiffviewOpen.
  plugins.diffview.enable = true;

  # <Space>gs opens the status buffer — the single entry point; everything else
  # is driven from inside it with the popup keys above.
  keymaps = [
    {
      mode = "n";
      key = "<leader>gs";
      action = "<cmd>Neogit<cr>";
      options.desc = "Git status (Neogit)";
    }
  ];
}
