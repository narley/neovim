{
  # nvim-treesitter-textobjects — syntax-aware text objects and motions built on
  # treesitter. Select/operate on whole functions, classes and parameters, and
  # jump between them. Builds on the treesitter setup in treesitter.nix.
  #
  # This is the plugin's "main" branch: setup() only configures behaviour
  # (lookahead, jumplist); the actual keymaps must be registered against its
  # API, which the extraConfigLua below does.
  plugins.treesitter-textobjects = {
    enable = true;
    settings = {
      select.lookahead = true; # jump forward to the next textobject if not on one
      move.set_jumps = true; # record movements in the jumplist
    };
  };

  # Register the text-object keymaps. Select maps work in visual/operator-pending
  # (e.g. `vaf` select function, `cif` change function body, `daa` delete arg).
  # Move maps use ]m/[m for functions and ]]/[[ for classes to avoid clashing
  # with gitsigns' ]c/[c hunk motions. Swap exchanges the parameter under the
  # cursor with its neighbour.
  extraConfigLua = ''
    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")
    local swap = require("nvim-treesitter-textobjects.swap")

    local select_maps = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
    }
    for lhs, obj in pairs(select_maps) do
      vim.keymap.set({ "x", "o" }, lhs, function()
        select.select_textobject(obj, "textobjects")
      end, { desc = "TS select " .. obj })
    end

    local function map_move(fn, maps)
      for lhs, obj in pairs(maps) do
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          fn(obj, "textobjects")
        end, { desc = "TS move " .. obj })
      end
    end
    map_move(move.goto_next_start, { ["]m"] = "@function.outer", ["]]"] = "@class.outer" })
    map_move(move.goto_next_end, { ["]M"] = "@function.outer", ["]["] = "@class.outer" })
    map_move(move.goto_previous_start, { ["[m"] = "@function.outer", ["[["] = "@class.outer" })
    map_move(move.goto_previous_end, { ["[M"] = "@function.outer", ["[]"] = "@class.outer" })

    vim.keymap.set("n", "<leader>a", function()
      swap.swap_next("@parameter.inner")
    end, { desc = "TS swap next parameter" })
    vim.keymap.set("n", "<leader>A", function()
      swap.swap_previous("@parameter.inner")
    end, { desc = "TS swap previous parameter" })
  '';
}
