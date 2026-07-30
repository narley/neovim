{ lib, ... }:
{
  # General (non-plugin) keymaps. Plugin-specific maps live in their own files
  # (telescope.nix, oil.nix, lsp.nix).
  keymaps = [
    {
      # Type `jf` in insert mode to leave it — a fast alternative to reaching
      # for Esc. (If you ever type a literal "jf", pause briefly after "j".)
      mode = "i";
      key = "jf";
      action = "<Esc>";
      options.desc = "Exit insert mode";
    }
    {
      # Same `jf` in a :terminal — drop from terminal-insert mode to normal mode,
      # replacing the awkward built-in <C-\><C-n>. Preferred over mapping <Esc>
      # here, which would shadow the real Escape key for TUIs running inside the
      # terminal (fzf, htop, less, lazygit, …).
      mode = "t";
      key = "jf";
      action = "<C-\\><C-n>";
      options.desc = "Exit terminal mode";
    }
    {
      # <Space>fs — save the current file. Since <Space>fsa also exists, this
      # waits 'timeoutlen' for a possible "a" before firing.
      mode = "n";
      key = "<leader>fs";
      action = "<cmd>w<cr>";
      options.desc = "Save file";
    }
    {
      # <Space>fsa — write all modified buffers.
      mode = "n";
      key = "<leader>fsa";
      action = "<cmd>wa<cr>";
      options.desc = "Save all files";
    }

    # Window navigation — move the cursor between splits.
    {
      mode = "n";
      key = "<leader>wh";
      action = "<C-w>h";
      options.desc = "Go to window left";
    }
    {
      mode = "n";
      key = "<leader>wj";
      action = "<C-w>j";
      options.desc = "Go to window below";
    }
    {
      mode = "n";
      key = "<leader>wk";
      action = "<C-w>k";
      options.desc = "Go to window above";
    }
    {
      mode = "n";
      key = "<leader>wl";
      action = "<C-w>l";
      options.desc = "Go to window right";
    }

    # Splits and window close. The rightbelow/belowright modifiers force the new
    # split to the right / below regardless of 'splitright'/'splitbelow'.
    {
      mode = "n";
      key = "<leader>w/";
      action = "<cmd>rightbelow vsplit<cr>";
      options.desc = "Split window right";
    }
    {
      mode = "n";
      key = "<leader>w-";
      action = "<cmd>belowright split<cr>";
      options.desc = "Split window down";
    }
    {
      mode = "n";
      key = "<leader>wd";
      action = "<cmd>close<cr>";
      options.desc = "Close window";
    }
    {
      # <Space>w= — give every window an equal share again (Spacemacs'
      # `SPC w =`, balance-windows-area). 'equalalways' already does this when
      # windows open or close, so this is for putting things back after a
      # manual resize or a plugin that sized its own split.
      mode = "n";
      key = "<leader>w=";
      action = "<C-w>=";
      options.desc = "Balance windows";
    }

    # Move the current window to the far left / bottom / top / right.
    {
      mode = "n";
      key = "<leader>wH";
      action = "<C-w>H";
      options.desc = "Move window left";
    }
    {
      mode = "n";
      key = "<leader>wJ";
      action = "<C-w>J";
      options.desc = "Move window down";
    }
    {
      mode = "n";
      key = "<leader>wK";
      action = "<C-w>K";
      options.desc = "Move window up";
    }
    {
      mode = "n";
      key = "<leader>wL";
      action = "<C-w>L";
      options.desc = "Move window right";
    }

    # Close the current buffer, keeping the window layout.
    #
    # Plain `:bdelete` *closes every window showing the buffer* (unless it's the
    # last one), so with Neogit or any other split open next to it, deleting a
    # buffer takes the whole editing window with it and the neighbour expands to
    # fill the tab. That is rarely what you want when several buffers live in one
    # window — the bufferline tab bar implies "close this tab, show the next".
    #
    # So: point every window showing the buffer at something else first — the
    # alternate buffer (#, i.e. where you just came from), else the previous
    # listed one, else a fresh empty buffer — and only then delete it. Modified
    # buffers still refuse to close with the native E89, same as before.
    {
      mode = "n";
      key = "<leader>bd";
      action.__raw = ''
        function()
          local buf = vim.api.nvim_get_current_buf()

          -- Report a refusal (E89 on unsaved changes, E947 on a live terminal)
          -- the way :bdelete would, without Lua's E5108 wrapper and traceback.
          local function report(err)
            vim.api.nvim_echo({ { tostring(err):gsub("^.*Vim[^:]*:", ""), "ErrorMsg" } }, true, {})
          end

          if vim.bo[buf].modified then
            local ok, err = pcall(vim.cmd.bdelete)
            if not ok then
              report(err)
            end
            return
          end

          for _, win in ipairs(vim.fn.win_findbuf(buf)) do
            vim.api.nvim_win_call(win, function()
              if vim.api.nvim_win_get_buf(win) ~= buf then
                return
              end

              local alt = vim.fn.bufnr("#")
              if alt ~= -1 and alt ~= buf and vim.fn.buflisted(alt) == 1 then
                vim.api.nvim_win_set_buf(win, alt)
                return
              end

              pcall(vim.cmd, "bprevious")
              if vim.api.nvim_win_get_buf(win) == buf then
                vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
              end
            end)
          end

          if vim.api.nvim_buf_is_valid(buf) then
            local ok, err = pcall(vim.api.nvim_buf_delete, buf, {})
            if not ok then
              report(err)
            end
          end
        end
      '';
      options.desc = "Close buffer";
    }

    # Cycle buffers in the order shown in the bufferline. BufferLineCycle*
    # follows the visible tab order; plain :bnext/:bprevious go by buffer
    # number, which can differ from what you see.
    {
      mode = "n";
      key = "<leader>bn";
      action = "<cmd>BufferLineCycleNext<cr>";
      options.desc = "Next buffer";
    }
    {
      mode = "n";
      key = "<leader>bp";
      action = "<cmd>BufferLineCyclePrev<cr>";
      options.desc = "Previous buffer";
    }
  ]
  # <Space>1 … <Space>9 jump straight to the window with that number — the
  # number shown at the left of each split's winbar (winnr()). `:<N>wincmd w`
  # is the count form of <C-w>w. Windows are numbered left-to-right, top-to-
  # bottom; if fewer than N windows exist it stops at the last one.
  ++ map (n: {
    mode = "n";
    key = "<leader>${toString n}";
    action = "<cmd>${toString n}wincmd w<cr>";
    options.desc = "Go to window ${toString n}";
  }) (lib.range 1 9);
}
