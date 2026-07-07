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

    # Close the current buffer.
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>bdelete<cr>";
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
