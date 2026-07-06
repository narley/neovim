{ pkgs, ... }:
{
  # telescope.nvim — fuzzy finder over files, live grep, buffers, help tags and
  # more (github.com/nvim-telescope/telescope.nvim). plenary is pulled in by the
  # nixvim module; ripgrep/fd are added below for grep and fast file finding.
  plugins.telescope = {
    enable = true;

    # Each entry becomes `<cmd>Telescope <action><cr>`, bound in normal mode.
    keymaps = {
      "<leader>ff" = {
        action = "find_files";
        options.desc = "Telescope: find files";
      };
      "<leader>fg" = {
        action = "live_grep";
        options.desc = "Telescope: live grep";
      };
      "<leader>fb" = {
        action = "buffers";
        options.desc = "Telescope: buffers";
      };
      "<leader>fh" = {
        action = "help_tags";
        options.desc = "Telescope: help tags";
      };
      "<leader>fr" = {
        action = "resume";
        options.desc = "Telescope: resume last picker";
      };
    };
  };

  # Runtime tools telescope shells out to: ripgrep for live_grep, fd for find_files.
  extraPackages = [
    pkgs.ripgrep
    pkgs.fd
  ];
}
