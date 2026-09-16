{
  # git-worktree.nvim — switch between git worktrees from inside Neovim. Unlike
  # lazygit's worktree view (which only moves lazygit's own directory), switching
  # here changes Neovim's cwd into the chosen worktree (and clears the jumplist),
  # so nvim actually "moves into" it. Driven through a Telescope picker, matching
  # the rest of the <Space>g git group.
  #
  # nixpkgs ships v2 of the plugin (git-worktree.nvim 2.x). Its defaults are
  # already what we want — change_directory_command = "cd", clearjumps_on_change,
  # and update_on_change_command = "e ." to reopen the tree — so we don't set
  # `settings` here. (The nixvim module's settings options are still v1-shaped,
  # e.g. `clear_jumps_on_change`, which v2 renamed to `clearjumps_on_change`, so
  # setting them would silently no-op rather than help.)
  plugins.git-worktree = {
    enable = true;

    # Register the `git_worktree` Telescope extension (needs plugins.telescope,
    # enabled in telescope.nix). This is what the keymaps below drive.
    enableTelescope = true;
  };

  # <Space>gw — Telescope list of worktrees. <Enter> switches (nvim's cwd
  #   follows). In the picker: <M-c> create · <M-d> delete · <C-f> toggle force
  #   on the next delete.
  # <Space>gW — create a new worktree straight away (pick/type a branch, then a
  #   path, optionally tracking an upstream).
  #
  # The picker subcommand for the list is `git_worktree` (singular) in v2 — the
  # v1 name was `git_worktrees`.
  keymaps = [
    {
      mode = "n";
      key = "<leader>gw";
      action = "<cmd>Telescope git_worktree git_worktree<cr>";
      options.desc = "Git worktrees (switch)";
    }
    {
      mode = "n";
      key = "<leader>gW";
      action = "<cmd>Telescope git_worktree create_git_worktree<cr>";
      options.desc = "Create git worktree";
    }
  ];
}
