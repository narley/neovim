{
  # Neogit — a Magit clone (à la Spacemacs). Opens a status buffer where you
  # stage/unstage (s / u), discard (x), and drive everything else through
  # single-key popups: `c` commit, `p` push, `F` pull, `b` branch, `r` rebase,
  # `Z` stash, `l` log. It auto-detects and uses the plugins already enabled
  # here — telescope (pickers), gitsigns (hunk staging) and diffview (diffs +
  # 3-way merge-conflict resolution).
  plugins.neogit = {
    enable = true;
    settings = {
      # Open the status buffer as a vertical split sharing the screen with the
      # windows already open, rather than Neogit's default `kind = "tab"` — a
      # new tab, which is why it used to fill the width. 'equalalways' (on by
      # default) then gives every window an equal share: 1/2 next to a lone
      # buffer, 1/3 once another opens, and so on.
      kind = "vsplit";

      # Syntax-highlight the code inside diff hunks (per the file's language) via
      # treesitter, instead of showing them as plain +/- text. Off by default in
      # Neogit; works here because all treesitter grammars are installed.
      treesitter_diff_highlight = true;

      # Neogit tints the diff section the cursor is in (a dark background block)
      # based on cursor position. Turn that off — plain background, no block tint.
      disable_context_highlighting = true;

      # Neogit hides line numbers in its buffers by default. Turn them back on to
      # match the editor's hybrid numbering (options.nix: number + relativenumber)
      # — handy for `V`-selecting a range of diff lines.
      disable_line_numbers = false;
      disable_relative_line_numbers = false;

      # By default Neogit rebinds the digits and j/k in the status buffer, which
      # breaks relative-number jumps like `2k`:
      #   * 1-4 are Depth1-4 (fold the tree to that depth), so `2` folds instead
      #     of starting a count;
      #   * j/k are MoveDown/MoveUp (item-wise) and ignore counts.
      # Disable those (false = fall back to native Vim) so counts + motions work
      # normally. Folding is still available via <tab>/za/zo/zc/zC/zO; section &
      # hunk jumps via {/} and <c-n>/<c-p>.
      mappings.status = {
        "1" = false;
        "2" = false;
        "3" = false;
        "4" = false;
        "j" = false;
        "k" = false;

        # <cr> defaults to "GoToFile", which *closes* Neogit and then edits the
        # file in whatever window is left — so the status buffer vanishes the
        # moment you open something. "VSplitOpen" keeps Neogit but always adds
        # a window, so browsing a handful of files leaves the tab shredded into
        # slivers.
        #
        # Neogit accepts a function here (config.lua validates status mappings
        # as string | boolean | function), so <cr> reuses a window instead:
        #   1. the window already showing that file, if any;
        #   2. otherwise the window we came from (winnr("#")), i.e. the editing
        #      window Neogit was opened from;
        #   3. otherwise any other ordinary window in the tab;
        #   4. only when none exists — Neogit alone in the tab — a vsplit.
        # Neogit stays open either way. <c-v>/<c-x>/<c-t> still force a
        # vsplit/split/tab when a new window *is* what you want.
        "<cr>".__raw = ''
          function()
            local status = require("neogit.buffers.status").instance()
            local item = status and status.buffer.ui:get_item_under_cursor()
            if not (item and item.absolute_path) then
              return
            end

            local path = item.absolute_path
            local jump = require("neogit.lib.jump")

            -- Pressing <cr> on a diff line lands on that line in the file;
            -- this mirrors Neogit's own (file-local) translate_cursor_location.
            local cursor
            if rawget(item, "diff") then
              local line = status.buffer:cursor_line()
              for _, hunk in ipairs(item.diff.hunks) do
                if line >= hunk.first and line <= hunk.last then
                  cursor = { jump.adjust_row(hunk.disk_from, line - hunk.first, hunk.lines, "-"), 0 }
                  break
                end
              end
            end

            -- An "ordinary" window: not floating, holding a real file buffer
            -- (buftype "" rules out terminals, quickfix, help, oil, …) and not
            -- one of Neogit's own (NeogitStatus, NeogitPopup, …).
            local function ordinary(win)
              if vim.api.nvim_win_get_config(win).relative ~= "" then
                return false
              end

              local buf = vim.api.nvim_win_get_buf(win)
              return vim.bo[buf].buftype == ""
                and not vim.startswith(vim.bo[buf].filetype, "Neogit")
            end

            local previous = vim.fn.win_getid(vim.fn.winnr("#"))
            local target
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              if ordinary(win) then
                if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)) == path then
                  target = win
                  break
                elseif win == previous then
                  target = win
                elseif not target then
                  target = win
                end
              end
            end

            if target then
              vim.api.nvim_set_current_win(target)
              jump.open("edit", path, cursor, "[Status - Open]")
            else
              jump.open("vsplit", path, cursor, "[Status - Open]")
            end
          end
        '';
      };
    };
  };

  # diffview.nvim — the diff / merge-conflict UI Neogit opens when you view a
  # change. Also usable standalone via :DiffviewOpen.
  plugins.diffview.enable = true;

  # <Space>gs opens the status buffer — the single entry point; everything else
  # is driven from inside it with the popup keys above.
  keymaps = [
    {
      mode = "n";
      key = "<leader>gs";
      action = "<cmd>Neogit<cr>";
      options.desc = "Git status (Neogit)";
    }
  ];
}
