{
  # indent-blankline — instead of the usual always-on guides at every indent
  # level, show a single solid vertical line ONLY for the block your cursor is
  # currently inside (the if / function / object "scope"). The always-on guides
  # are hidden by drawing them with a space; the scope line uses │.
  # Scope detection comes from Treesitter.
  plugins.indent-blankline = {
    enable = true;
    settings = {
      indent = {
        char = " "; # hide the always-on indent guides
      };
      scope = {
        enabled = true;
        char = "│"; # solid line, drawn only for the current scope
        show_start = false; # no horizontal underline at the top of the block
        show_end = false; # ...or the bottom
      };
    };
  };
}
