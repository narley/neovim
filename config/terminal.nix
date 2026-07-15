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
  # Warp-style — then focuses the terminal so you can type your prompt.
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

    vim.keymap.set("x", "<leader>cs", function()
      local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
      local job, win = terminal_job()
      if not job then
        vim.notify("No terminal found — open one with <Space>' first.", vim.log.levels.WARN)
        return
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
      local text = table.concat(lines, "\r")
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
    end, { desc = "Send selection to terminal (Claude Code)" })

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
