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
  ];
}
