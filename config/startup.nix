{
  # Startup behaviour for `nvim <dir>` (e.g. `nvim .`). Oil takes over directory
  # buffers, but Oil can't fuzzy-search by filename — so on that launch we float
  # a Telescope find_files picker *over* the Oil buffer: type to open a file, or
  # press <Esc> to drop into Oil and browse/rename/create. Nothing is lost; Oil
  # is still underneath and `-` still opens it anywhere.
  #
  # Only this launch shape is touched. Bare `nvim` (argc 0) still resumes the
  # last session (see persistence.nix), and `nvim file` still just opens the
  # file. Piping in via stdin (`… | nvim`) is left alone.
  #
  # Two subtleties this took a few tries to get right:
  #   1. Oil loads the directory buffer asynchronously and grabs focus when it
  #      finishes — after VimEnter. So we open the finder on Oil's own
  #      `User OilEnter` event (fired post-render) rather than racing it.
  #   2. We decide whether this is a `nvim <dir>` launch *at config-load time*,
  #      before persistence.nvim restores a session on VimEnter. A restored
  #      session re-adds its buffers to the arglist (mksession writes
  #      `$argadd oil://…/`), so reading argc/argv at OilEnter time would make the
  #      first `-` in a resumed session look exactly like `nvim <dir>` and wrongly
  #      pop the finder. Capturing the launch intent up front avoids that — the
  #      listener is only armed for a genuine directory launch.
  extraConfigLua = ''
    if vim.fn.argc(-1) == 1
      and vim.fn.isdirectory(vim.fn.argv(0)) == 1
      and not vim.g.started_with_stdin
    then
      vim.api.nvim_create_autocmd("User", {
        pattern = "OilEnter",
        once = true,
        desc = "On `nvim <dir>`, float a file finder over Oil",
        callback = function(args)
          -- The just-entered Oil buffer's real directory (nil for remote adapters).
          local dir = require("oil").get_current_dir(args.data and args.data.buf)
          if not dir then
            return
          end
          -- Root the session there so the finder (and later grep) searches it.
          pcall(vim.cmd.cd, dir)
          vim.schedule(function()
            require("telescope.builtin").find_files({ cwd = dir })
          end)
        end,
      })
    end
  '';
}
