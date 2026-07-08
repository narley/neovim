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
      # Auto-restore the MOST RECENT session (load { last = true }) when nvim is
      # launched with NO file arguments and not from stdin — i.e. "continue where
      # I stopped". We deliberately do NOT key off the launch directory here:
      # project.nvim changes the cwd to the file's project root, so a session
      # gets saved under (say) packages/api while nvim is launched from the repo
      # root, and a cwd-keyed load() would find nothing. Loading the last session
      # sidesteps that entirely; the session's own `cd` line restores the right
      # directory. Opening a specific file (`nvim foo.ts`) skips restore.
      # `nested` lets restored buffers fire their FileType/syntax autocmds.
      event = [ "VimEnter" ];
      desc = "Resume the most recent session when nvim opens with no args";
      nested = true;
      callback = lib.nixvim.mkRaw ''
        function()
          if vim.fn.argc(-1) == 0 and not vim.g.started_with_stdin then
            require("persistence").load({ last = true })
          end
        end
      '';
    }
  ];

  # Manual session controls (leader = Space). Grouped under <Space>S for
  # "Session" — a more literal prefix than LazyVim's <Space>q ("quit") group.
  keymaps = [
    {
      mode = "n";
      key = "<leader>Ss";
      action = "<cmd>lua require('persistence').load()<cr>";
      options.desc = "Restore session (this dir)";
    }
    {
      mode = "n";
      key = "<leader>Sl";
      action = "<cmd>lua require('persistence').load({ last = true })<cr>";
      options.desc = "Restore last session";
    }
    {
      mode = "n";
      key = "<leader>Sd";
      action = "<cmd>lua require('persistence').stop()<cr>";
      options.desc = "Don't save the current session";
    }
  ];

  # <Space>Sf — a Telescope picker over every saved session, to jump between
  # projects. persistence.nvim keeps one session file per directory under
  # stdpath("state")/sessions (named with path separators replaced by "%"); we
  # list them newest-first, show each project directory, and on select save the
  # current session first (so this project's layout isn't lost) then chdir +
  # load the chosen one — the same switch persistence's own :select does, but
  # rendered in Telescope instead of the plain vim.ui.select prompt.
  extraConfigLua = ''
    vim.keymap.set("n", "<leader>Sf", function()
      local persistence = require("persistence")
      local sessions = persistence.list()
      if vim.tbl_isempty(sessions) then
        vim.notify("No saved sessions yet.", vim.log.levels.INFO)
        return
      end

      -- Decode each session file into the project directory it represents,
      -- de-duplicating (a dir may have several branch sessions). Mirrors the
      -- decode in persistence's own select().
      local dir = require("persistence.config").options.dir
      local items, seen = {}, {}
      for _, session in ipairs(sessions) do
        local name = session:sub(#dir + 1, -5) -- strip the sessions dir and ".vim"
        local project = vim.split(name, "%%", { plain = true })[1]:gsub("%%", "/")
        if not seen[project] then
          seen[project] = true
          items[#items + 1] = { session = session, dir = project }
        end
      end

      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      pickers.new({}, {
        prompt_title = "Sessions",
        previewer = false,
        finder = finders.new_table({
          results = items,
          entry_maker = function(item)
            local display = vim.fn.fnamemodify(item.dir, ":p:~")
            return { value = item, display = display, ordinal = display }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(bufnr)
          actions.select_default:replace(function()
            local entry = action_state.get_selected_entry()
            actions.close(bufnr)
            if not entry then return end
            persistence.save() -- keep the current project's layout
            if not pcall(vim.fn.chdir, entry.value.dir) then
              vim.notify("Directory no longer exists: " .. entry.value.dir, vim.log.levels.WARN)
              return
            end
            persistence.load() -- restore the chosen session for the new cwd
          end)
          return true
        end,
      }):find()
    end, { desc = "Switch session (Telescope)" })
  '';
}
