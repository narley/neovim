{ pkgs, ... }:
let
  # lazygit's own theme (YAML). The default selectedLineBgColor is a solid bright
  # blue that swamps the red/green diff text and makes selected hunks unreadable.
  # These One Dark colors use a subtle grey selection instead, so removed (red)
  # and added (green) lines stay legible when highlighted.
  lazygitConfig = pkgs.writeText "lazygit-config.yml" ''
    gui:
      theme:
        activeBorderColor:
          - "#61afef"
          - bold
        inactiveBorderColor:
          - "#5c6370"
        selectedLineBgColor:
          - "#3e4451"
        optionsTextColor:
          - "#61afef"
        cherryPickedCommitBgColor:
          - "#3e4451"
        cherryPickedCommitFgColor:
          - "#61afef"
        unstagedChangesColor:
          - "#e06c75"
        defaultFgColor:
          - "#abb2bf"
  '';
in
{
  # lazygit — the standalone terminal git TUI, opened in a floating window from
  # inside Neovim via lazygit.nvim. Complements Neogit (<Space>gs): Neogit is the
  # native-buffer Magit clone; lazygit is the full-featured external TUI (great
  # for interactive rebase, cherry-pick, reflog, custom commands).
  #
  # Enabling plugins.lazygit also installs the `lazygit` binary into the wrapped
  # Neovim's PATH, so nothing extra is needed on the host system.
  plugins.lazygit.enable = true;

  # Launch lazygit with the One Dark theme above instead of its default (whose
  # bright-blue selection background is unreadable over diff colours).
  extraConfigLua = ''
    vim.g.lazygit_use_custom_config_file_path = 1
    vim.g.lazygit_config_file_path = "${lazygitConfig}"
  '';

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
