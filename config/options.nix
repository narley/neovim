{
  # General editor settings.
  #
  # Use Space as the leader key (Neovim's default is "\"). This must be set
  # before any <leader> mappings are defined; nixvim emits globals before
  # keymaps, so plugin keymaps using <leader> resolve to Space.
  globals.mapleader = " ";
  globals.maplocalleader = " ";

  # Line numbers: relative on every line, with the current line showing its
  # absolute number (hybrid). Applied globally, so it's on for every buffer
  # without any manual `:set`. Drop `number` below for pure relative (the
  # current line would then show 0).
  opts.number = true;
  opts.relativenumber = true;

  # Winbar: a thin bar at the top of every split showing its window number
  # (followed by the file name and a modified flag). Neovim numbers windows
  # left-to-right, top-to-bottom; jump straight to one with `<count><C-w>w`
  # — e.g. `2<C-w>w` for window 2. `%{winnr()}` is evaluated per window, so
  # each split shows its own number; `%t` is the file's tail, `%m` the [+]
  # modified flag. lualine's statusline is global (globalstatus), so the
  # winbar is what carries per-split identity here.
  opts.winbar = " %{winnr()}  %t %m";
}
