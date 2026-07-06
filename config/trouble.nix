{
  # trouble — a clean, navigable list of diagnostics (also quickfix, LSP
  # references, etc.). Handy for stepping through all the type/lint errors in a
  # file or across the project.
  plugins.trouble.enable = true;

  keymaps = [
    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<cr>";
      options.desc = "Diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xX";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
      options.desc = "Buffer diagnostics (Trouble)";
    }
  ];
}
