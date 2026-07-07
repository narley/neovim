{
  # project.nvim — the projectile analog. Detects each file's project root (via
  # the attached LSP, then falling back to marker files) and sets the cwd to it,
  # so telescope's find_files/live_grep stay scoped to the project no matter
  # which file you opened. Keeps a history of visited projects, exposed through
  # telescope for quick switching (Spacemacs' `SPC p p`). Pairs with
  # persistence.nvim: switching project restores that directory's session.
  plugins.project-nvim = {
    enable = true;
    enableTelescope = true; # registers the `:Telescope projects` picker

    settings = {
      # Try the attached LSP's root first, then fall back to marker files.
      detection_methods = [ "lsp" "pattern" ];

      # Root markers for the pattern fallback: git repos, Nix flakes, node
      # packages, make-based projects, other VCS.
      patterns = [
        ".git"
        "flake.nix"
        "package.json"
        "Makefile"
        ".hg"
        ".svn"
      ];
    };
  };

  # project.nvim saves its visited-project history as a file under
  # stdpath("data") and validates that directory when it loads. Neovim doesn't
  # always create the dir first — harmless in normal use (it exists), but in the
  # headless `nix flake check` sandbox it's absent, so the plugin errors and
  # fails the check. Create it in the *Pre* hook, before the plugin's setup runs.
  extraConfigLuaPre = ''
    vim.fn.mkdir(vim.fn.stdpath("data"), "p")
  '';

  # On exit project.nvim writes its history; when no project has been visited
  # yet it emits a WARN notification ("No data available to write!"). That's
  # noise on a first-ever exit and, worse, fails the strict headless
  # `nix flake check`. Drop just that one message and pass everything else
  # through. Wrapping in the *post* hook means we wrap whatever vim.notify is in
  # effect after all plugins have set up (e.g. if fidget takes it over).
  extraConfigLua = ''
    local base_notify = vim.notify
    vim.notify = function(msg, level, opts)
      if type(msg) == "string" and msg:find("No data available to write", 1, true) then
        return
      end
      return base_notify(msg, level, opts)
    end
  '';

  # <Space>fp — switch project (Spacemacs' SPC p p). Fits the <leader>f* family
  # of telescope pickers; picking a project cds into it, so find_files/live_grep
  # then target that project.
  keymaps = [
    {
      mode = "n";
      key = "<leader>fp";
      action = "<cmd>Telescope projects<cr>";
      options.desc = "Telescope: switch project";
    }
  ];
}
