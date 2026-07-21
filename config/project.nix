{
  # project.nvim — the projectile analog. Detects each file's project root (via
  # the attached LSP, then falling back to marker files) and sets the cwd to it,
  # so telescope's find_files/live_grep stay scoped to the project no matter
  # which file you opened. Keeps a history of visited projects, exposed through
  # telescope for quick switching (Spacemacs' `SPC p p`). Pairs with
  # persistence.nvim: switching project restores that directory's session.
  plugins.project-nvim = {
    enable = true;
    enableTelescope = true; # registers the `:Telescope projects` picker

    settings = {
      # Try the attached LSP's root first, then fall back to marker files.
      detection_methods = [ "lsp" "pattern" ];

      # Root markers for the pattern fallback: git repos, Nix flakes, node
      # packages, make-based projects, other VCS.
      patterns = [
        ".git"
        "flake.nix"
        "package.json"
        "Makefile"
        ".hg"
        ".svn"
      ];
    };
  };

  # project.nvim saves its visited-project history as a file under
  # stdpath("data") and validates that directory when it loads. Neovim doesn't
  # always create the dir first — harmless in normal use (it exists), but in the
  # headless `nix flake check` sandbox it's absent, so the plugin errors and
  # fails the check. Create it in the *Pre* hook, before the plugin's setup runs.
  extraConfigLuaPre = ''
    vim.fn.mkdir(vim.fn.stdpath("data"), "p")
  '';

  # On exit project.nvim writes its history; when no project has been visited
  # yet it emits a WARN notification ("No data available to write!"). That's
  # noise on a first-ever exit and, worse, fails the strict headless
  # `nix flake check`. Drop just that one message and pass everything else
  # through. Wrapping in the *post* hook means we wrap whatever vim.notify is in
  # effect after all plugins have set up (e.g. if fidget takes it over).
  extraConfigLua = ''
    local base_notify = vim.notify
    vim.notify = function(msg, level, opts)
      if type(msg) == "string" and msg:find("No data available to write", 1, true) then
        return
      end
      return base_notify(msg, level, opts)
    end

    -- Guard against a stack overflow in project.nvim 3.3.1 (E5108, raised from
    -- any BufEnter) when a project directory disappears while Neovim is running.
    --
    -- get_recent_projects() copies the project list, drops paths that no longer
    -- exist from that *copy*, sets removed = true, and calls write_history() —
    -- which calls get_recent_projects() again. Because the copy is discarded,
    -- M.recent_projects still holds the dead path, so the next pass removes it
    -- again, and the two recurse until the stack blows. BufEnter runs that chain
    -- via on_buf_enter, so a single deleted project poisons every buffer switch.
    --
    -- Loading is not the problem: read_history() honours `remove_missing_dirs`
    -- (true by default) and filters missing directories then. The gap is a
    -- directory removed *after* that — deleted, renamed, moved, a worktree torn
    -- down, an unmounted volume.
    --
    -- So prune the persistent lists in place before each call. With the dead
    -- entries actually gone, `removed` stays false and the recursion never
    -- starts. Same filesystem test the plugin itself applies.
    local ok, History = pcall(require, "project.util.history")
    if ok and type(History.get_recent_projects) == "function" then
      local base_get_recent = History.get_recent_projects
      History.get_recent_projects = function(...)
        for _, list in ipairs({ History.recent_projects, History.session_projects }) do
          if type(list) == "table" then
            -- Backwards: table.remove() shifts everything after the index.
            for i = #list, 1, -1 do
              -- Entries are { path, name }, or bare strings in the old format.
              local entry = list[i]
              local path = type(entry) == "table" and entry.path or entry
              local dir = type(path) == "string" and vim.uv.fs_stat(path) or nil
              if not (dir and dir.type == "directory") then
                table.remove(list, i)
              end
            end
          end
        end
        return base_get_recent(...)
      end
    end
  '';

  # <Space>fp — switch project (Spacemacs' SPC p p). Fits the <leader>f* family
  # of telescope pickers; picking a project cds into it, so find_files/live_grep
  # then target that project.
  keymaps = [
    {
      mode = "n";
      key = "<leader>fp";
      action = "<cmd>Telescope projects<cr>";
      options.desc = "Telescope: switch project";
    }
  ];
}
