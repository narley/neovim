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
  # Subtleties this took a few iterations to nail down:
  #   1. Whether this is a `nvim <dir>` launch is decided at config-load time,
  #      before persistence.nvim restores a session on VimEnter. A restored
  #      session re-adds its buffers to the arglist (mksession writes
  #      `$argadd oil://…/`), so checking argc/argv later would make the first
  #      `-` in a resumed session look like a directory launch and wrongly pop
  #      the finder. Capturing up front avoids that.
  #   2. At load time the sole arg may be a plain dir ("." ) or already Oil's
  #      `oil://…` URL, so we accept either.
  #   3. Oil loads the directory buffer asynchronously and grabs focus after
  #      VimEnter, so we open the finder on Oil's own `User OilEnter` event
  #      (fired post-render) rather than racing it. `once = true` scopes it to
  #      the startup render.
  extraConfigLua = ''
    local a0 = vim.fn.argv(0)
    local launched_with_dir = vim.fn.argc(-1) == 1
      and (vim.fn.isdirectory(a0) == 1 or a0:match("^oil://") ~= nil)
      and not vim.g.started_with_stdin

    if launched_with_dir then
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
