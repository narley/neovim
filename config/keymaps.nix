{
  # General (non-plugin) keymaps. Plugin-specific maps live in their own files
  # (telescope.nix, oil.nix, lsp.nix).
  keymaps = [
    {
      # Type `jf` in insert mode to leave it — a fast alternative to reaching
      # for Esc. (If you ever type a literal "jf", pause briefly after "j".)
      mode = "i";
      key = "jf";
      action = "<Esc>";
      options.desc = "Exit insert mode";
    }
    {
      # <Space>fs — save the current file. Since <Space>fsa also exists, this
      # waits 'timeoutlen' for a possible "a" before firing.
      mode = "n";
      key = "<leader>fs";
      action = "<cmd>w<cr>";
      options.desc = "Save file";
    }
    {
      # <Space>fsa — write all modified buffers.
      mode = "n";
      key = "<leader>fsa";
      action = "<cmd>wa<cr>";
      options.desc = "Save all files";
    }
  ];
}
