{ lib, ... }:
{
  # persistence.nvim (folke) — save a session per working directory and restore
  # it, so reopening nvim in a project brings back the buffers, window layout,
  # folds and cwd you left. Sessions are written under stdpath("state")/sessions
  # automatically on exit (the plugin's own VimLeavePre autocmd); nothing to
  # save by hand.
  plugins.persistence.enable = true;

  # What a session captures. `skiprtp` keeps sessions small; `localoptions`
  # preserves per-window settings (e.g. filetype) so restored buffers look
  # right immediately. Deliberately NOT `folds`: with treesitter folding
  # (foldmethod=expr, set in options.nix) folds are recomputed from the code,
  # and saving them makes mksession write `setlocal foldmethod=manual`, which on
  # restore overrides the global expr and breaks `zc` (E490).
  opts.sessionoptions = "buffers,curdir,globals,skiprtp,tabpages,winpos,winsize,localoptions";

  autoCmd = [
    {
      # Remember if nvim was started by piping into it (`… | nvim`), so we don't
      # clobber that with a restored session below.
      event = [ "StdinReadPre" ];
      callback = lib.nixvim.mkRaw ''
        function() vim.g.started_with_stdin = true end
      '';
    }
    {
      # Auto-restore: when nvim is launched with NO file arguments (just `nvim`
      # in a project dir) and not from stdin, load that directory's session.
      # Opening a specific file (`nvim foo.ts`) skips restore so you land on that
      # file. `nested` lets restored buffers fire their FileType/syntax autocmds.
      event = [ "VimEnter" ];
      desc = "Restore the directory's session when nvim opens with no args";
      nested = true;
      callback = lib.nixvim.mkRaw ''
        function()
          if vim.fn.argc(-1) == 0 and not vim.g.started_with_stdin then
            require("persistence").load()
          end
        end
      '';
    }
  ];

  # Manual session controls (leader = Space).
  keymaps = [
    {
      mode = "n";
      key = "<leader>qs";
      action = "<cmd>lua require('persistence').load()<cr>";
      options.desc = "Restore session (this dir)";
    }
    {
      mode = "n";
      key = "<leader>ql";
      action = "<cmd>lua require('persistence').load({ last = true })<cr>";
      options.desc = "Restore last session";
    }
    {
      mode = "n";
      key = "<leader>qd";
      action = "<cmd>lua require('persistence').stop()<cr>";
      options.desc = "Don't save the current session";
    }
  ];
}
