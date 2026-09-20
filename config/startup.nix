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
  # We trigger off Oil's own `User OilEnter` event (fired once its async render
  # finishes) rather than VimEnter, for two reasons this took a couple of tries
  # to pin down:
  #   1. Oil loads the directory buffer asynchronously; a bare VimEnter schedule
  #      races that and the picker gets closed when Oil grabs focus.
  #   2. By the time anything runs, Oil has rewritten the sole arglist entry from
  #      the directory to its own `oil://…` URL — so `isdirectory(argv(0))` is
  #      false. We detect the `oil://` arg instead and ask Oil for the real path.
  # `once = true` scopes it to the startup render; later `-` opens don't retrigger.
  extraConfigLua = ''
    vim.api.nvim_create_autocmd("User", {
      pattern = "OilEnter",
      once = true,
      desc = "On `nvim <dir>`, float a file finder over Oil",
      callback = function(args)
        -- Single directory argument only. `vim.g.started_with_stdin` is set by
        -- persistence.nix's StdinReadPre autocmd.
        if vim.fn.argc(-1) ~= 1 or vim.g.started_with_stdin then
          return
        end
        local a0 = vim.fn.argv(0)
        if not (a0:match("^oil://") or vim.fn.isdirectory(a0) == 1) then
          return
        end
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
  '';
}
