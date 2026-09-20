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
  extraConfigLua = ''
    vim.api.nvim_create_autocmd("VimEnter", {
      desc = "On `nvim <dir>`, float a file finder over Oil",
      nested = true,
      callback = function()
        -- Single directory argument only. `vim.g.started_with_stdin` is set by
        -- persistence.nix's StdinReadPre autocmd, which fires before VimEnter.
        if vim.fn.argc(-1) ~= 1 or vim.g.started_with_stdin then
          return
        end
        local arg = vim.fn.argv(0)
        if vim.fn.isdirectory(arg) ~= 1 then
          return
        end
        local dir = vim.fn.fnamemodify(arg, ":p")
        -- Root the session at the project dir so the finder (and later grep)
        -- searches there.
        pcall(vim.cmd.cd, dir)
        -- Defer so Oil finishes building the directory buffer first; the picker
        -- then floats on top and <Esc> falls back into Oil.
        vim.schedule(function()
          require("telescope.builtin").find_files({ cwd = dir })
        end)
      end,
    })
  '';
}
