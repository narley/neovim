{
  # gitsigns — git change markers in the sign column (added / changed / removed),
  # plus hunk navigation, staging, preview and line blame. Also feeds the diff
  # counts shown in the lualine statusline.
  plugins.gitsigns.enable = true;

  keymaps = [
    {
      mode = "n";
      key = "]c";
      action = "<cmd>Gitsigns next_hunk<cr>";
      options.desc = "Next git hunk";
    }
    {
      mode = "n";
      key = "[c";
      action = "<cmd>Gitsigns prev_hunk<cr>";
      options.desc = "Previous git hunk";
    }
    {
      mode = "n";
      key = "<leader>hs";
      action = "<cmd>Gitsigns stage_hunk<cr>";
      options.desc = "Stage hunk";
    }
    {
      mode = "n";
      key = "<leader>hr";
      action = "<cmd>Gitsigns reset_hunk<cr>";
      options.desc = "Reset hunk";
    }
    {
      mode = "n";
      key = "<leader>hp";
      action = "<cmd>Gitsigns preview_hunk<cr>";
      options.desc = "Preview hunk";
    }
    {
      mode = "n";
      key = "<leader>hb";
      action = "<cmd>Gitsigns blame_line<cr>";
      options.desc = "Blame line";
    }
  ];
}
