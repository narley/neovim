{ pkgs, ... }:
{
  # --- Currently trying: One Dark Vaporwave (olimorris/onedarkpro.nvim) ---
  # onedarkpro.nvim registers several colorschemes (onedark, onelight,
  # onedark_vivid, onedark_dark, vaporwave). "vaporwave" is the neon
  # pink/purple/cyan One Dark variant. It's the Lua theme, so Treesitter
  # (@capture) groups are defined and code stays richly highlighted.
  #
  # Applied manually (setup + colorscheme) rather than via the colorschemes.*
  # module so there's no ambiguity about which registered theme is active.
  #
  # To go back to One Dark: remove the extraPlugins/extraConfigLua below and flip
  # the onedark block back to enable = true.
  extraPlugins = [ pkgs.vimPlugins.onedarkpro-nvim ];
  extraConfigLua = ''
    require("onedarkpro").setup({})
    vim.cmd.colorscheme("vaporwave")
  '';

  # --- Previous theme: One Dark (navarasu/onedark.nvim), disabled ---
  # Kept here so switching back is a one-line change. The highlights below use
  # onedark palette refs ($bg_d/$blue) and only apply when this block is enabled.
  colorschemes.onedark = {
    enable = false;
    settings = {
      style = "dark";
      transparent = false;
      term_colors = true;

      code_style = {
        comments = "italic";
      };

      highlights = {
        NormalFloat = {
          bg = "$bg_d";
        };
        FloatBorder = {
          fg = "$blue";
          bg = "$bg_d";
        };
      };
    };
  };
}
