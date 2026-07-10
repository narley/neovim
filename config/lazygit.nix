{
  # lazygit — the standalone terminal git TUI, opened in a floating window from
  # inside Neovim via lazygit.nvim. Complements Neogit (<Space>gs): Neogit is the
  # native-buffer Magit clone; lazygit is the full-featured external TUI (great
  # for interactive rebase, cherry-pick, reflog, custom commands).
  #
  # Enabling plugins.lazygit also installs the `lazygit` binary into the wrapped
  # Neovim's PATH, so nothing extra is needed on the host system.
  plugins.lazygit.enable = true;

  # <Space>gg opens lazygit in a floating window; q closes it and returns to nvim.
  keymaps = [
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>LazyGit<cr>";
      options.desc = "Git TUI (lazygit)";
    }
  ];
}
