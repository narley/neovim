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
}
