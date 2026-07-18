{
  # A terminal you toggle open as a vertical split pinned to the far right,
  # sharing the width equally with the windows already open — unlike `:term`,
  # which replaces the current window. <Space>' opens it in normal ("view")
  # mode, so you can scroll the output straight away; press `i` (or `a`) to
  # start typing. <Space>' again hides the split, and once more brings the SAME
  # shell back (the buffer is kept alive, so your session survives a hide).
  # Mirrors Spacemacs' `SPC '`.
  #
  # Leave terminal-insert mode with `jf` (mapped in keymaps.nix), then <Space>'
  # hides the split, or <Space>wd closes it.
  #
  # <Space>cs in visual mode sends the selected lines into whatever is running
  # in the terminal — e.g. paste a block straight into Claude Code's input box,
  # Warp-style — then focuses the terminal so you can type your prompt. The
  # block is headed with `/abs/path.ts:23-30` so the receiver knows what it's
  # looking at without being told.
  extraConfigLua = ''
    local term = { buf = nil, win = nil }

    local function toggle_term()
      -- Already visible? Hide it (toggle off) but keep the buffer alive.
      if term.win and vim.api.nvim_win_is_valid(term.win) then
        vim.api.nvim_win_hide(term.win)
        term.win = nil
        return
      end

      -- Open a vertical split forced to the far right. Deliberately no explicit
      -- resize: 'equalalways' (on by default) hands every window an equal share,
      -- so this is 1/2 beside a lone buffer and re-divides to 1/3, 1/4, … as
      -- more open. A hard `vertical resize` here would pin it at half forever.
      vim.cmd("botright vsplit")
      term.win = vim.api.nvim_get_current_win()

      -- Reuse the previous terminal buffer if it's still around; else spawn one.
      if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
        vim.api.nvim_win_set_buf(term.win, term.buf)
      else
        vim.cmd("terminal")
        term.buf = vim.api.nvim_get_current_buf()
      end

      -- Stay in terminal-normal ("view") mode — the split opens ready to scroll
      -- the output; press `i` to start typing. `:terminal` can leave us in
      -- insert on a fresh spawn, so drop back to normal explicitly.
      vim.cmd("stopinsert")
    end

    vim.keymap.set("n", "<leader>'", toggle_term, { desc = "Toggle terminal (right, equal share)" })

    -- ── Send a visual selection into the terminal (Warp-style) ──────────────
    -- Find the job channel of a terminal buffer, preferring one that's visible
    -- in a split (the shell you have open next to your code); returns the job id
    -- and, when on screen, its window so we can focus it afterwards.
    local function terminal_job()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" then
          return vim.b[buf].terminal_job_id, win
        end
      end
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "terminal" then
          return vim.b[buf].terminal_job_id, nil
        end
      end
    end

    -- In Neogit's status buffer `%:p` is the status buffer itself — you get
    -- `…/NeogitStatus:193-199`, naming a file that doesn't exist and lines that
    -- mean nothing outside the status view. Ask Neogit which file the hunk under
    -- the cursor came from, and translate the selected status rows into rows in
    -- that file.
    --
    -- Neogit exposes no public API for this, so every step is behind pcall: if
    -- any of it moves, the caller falls back to the plain buffer path rather
    -- than erroring in the middle of a send.
    --
    -- Returns: path, first_row, last_row — any of the rows may be nil when the
    -- selection reaches outside a hunk (a section header, a blank line).
    local function neogit_location(first, last)
      if not vim.bo.filetype:match("^NeogitStatus") then return end

      local ok_s, status = pcall(require, "neogit.buffers.status")
      local ok_j, jump = pcall(require, "neogit.lib.jump")
      if not (ok_s and ok_j) then return end

      local ok_i, inst = pcall(status.instance)
      if not ok_i or not inst or not inst.buffer then return end

      local ok_it, item = pcall(function() return inst.buffer.ui:get_item_under_cursor() end)
      if not ok_it or not item or not item.absolute_path then return end

      -- `disk_from` is where the hunk starts in the file on disk; adjust_row
      -- walks the hunk from there skipping "-" lines, which exist in the diff
      -- but not in the file. This is the same translation Neogit's own
      -- open-file action uses, so the row matches where it would jump you.
      local diff = rawget(item, "diff")
      local function row_for(line)
        if not diff then return end
        for _, hunk in ipairs(diff.hunks) do
          if line >= hunk.first and line <= hunk.last then
            return jump.adjust_row(hunk.disk_from, line - hunk.first, hunk.lines, "-")
          end
        end
      end

      return item.absolute_path, row_for(first), row_for(last)
    end

    vim.keymap.set("x", "<leader>cs", function()
      local vpos, cpos = vim.fn.getpos("v"), vim.fn.getpos(".")
      local lines = vim.fn.getregion(vpos, cpos, { type = vim.fn.mode() })
      local job, win = terminal_job()
      if not job then
        vim.notify("No terminal found — open one with <Space>' first.", vim.log.levels.WARN)
        return
      end

      -- Head the block with `path:first-last` (or `path:n` for a single line) so
      -- the receiver knows where the code came from and can open or edit it.
      -- A selection can be made bottom-up, in which case the cursor is *above*
      -- the anchor — sort the two ends rather than trusting their order.
      local first = math.min(vpos[2], cpos[2])
      local last = math.max(vpos[2], cpos[2])

      -- An unsaved buffer has no path; say so explicitly instead of emitting a
      -- bare `:23-30` with nothing in front of it.
      local path = vim.fn.expand("%:p")
      if path == "" then path = "[No Name]" end

      -- In Neogit, swap in the real file and its rows (see neogit_location).
      local ng_path, ng_first, ng_last = neogit_location(first, last)
      if ng_path then
        path, first, last = ng_path, ng_first, ng_last
      end

      -- No rows means we know the file but not where in it — better to name the
      -- file alone than to attach line numbers that point at the wrong place.
      local header = path
      if first then
        if last and last < first then first, last = last, first end
        header = path .. ":" .. ((last and last ~= first) and (first .. "-" .. last) or tostring(first))
      end

      -- Paste the raw selection into the terminal. Newlines go out as CR — what
      -- pressing Enter sends. Claude Code detects the block as a paste on its
      -- own, so it lands as one chunk without submitting per line.
      --
      -- Flip `bracketed` to true to wrap the block in bracketed-paste markers
      -- instead. That's the "proper" no-submit signal, but only works if the
      -- program consumes the markers; Claude Code renders them as literal
      -- `[200~…[201~` text if it doesn't — which is why it's off by default.
      local bracketed = false
      local text = header .. "\r" .. table.concat(lines, "\r")
      if bracketed then
        local ESC = "\27"
        text = ESC .. "[200~" .. text .. ESC .. "[201~"
      end
      vim.fn.chansend(job, text)

      -- Leave visual mode, then (if the terminal is on screen) hop into it in
      -- insert mode so you can type your prompt right away.
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      if win then
        vim.schedule(function()
          vim.api.nvim_set_current_win(win)
          vim.cmd("startinsert")
        end)
      end
    end, { desc = "Send selection + path:lines to terminal (Claude Code)" })

    -- Terminal windows read better without line numbers, the cursorline or the
    -- sign column — strip those for any :terminal buffer. The winbar is left on
    -- so the terminal still shows its window number (jump to it with <Space>N).
    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.cursorline = false
        vim.opt_local.signcolumn = "no"
      end,
    })
  '';
}
