{ pkgs, ... }:
{
  # tabout.nvim — press <Tab> to jump out past the next closing bracket/quote
  # (e.g. foo(bar|) -> foo(bar)|), <S-Tab> to jump back. Complements
  # nvim-autopairs; uses treesitter (enabled in treesitter.nix).
  #
  # nixvim has no module for tabout, so it's added as a raw plugin.
  extraPlugins = [ pkgs.vimPlugins.tabout-nvim ];

  # Set tabout up BEFORE blink.cmp wires its keymap, so blink's "super-tab"
  # <Tab> treats tabout as the fallback it runs when the completion menu is
  # closed: menu open -> accept completion, otherwise -> jump out of the next
  # bracket/quote, otherwise -> a literal tab. `completion = false` because
  # blink already owns Tab while the menu is visible.
  extraConfigLuaPre = ''
    require("tabout").setup({
      tabkey = "<Tab>",
      backwards_tabkey = "<S-Tab>",
      act_as_tab = true,
      enable_backwards = true,
      completion = false,
      ignore_beginning = true,
      tabouts = {
        { open = "'", close = "'" },
        { open = '"', close = '"' },
        { open = "`", close = "`" },
        { open = "(", close = ")" },
        { open = "[", close = "]" },
        { open = "{", close = "}" },
      },
    })
  '';
}
