{
  # nvim-surround — add/change/delete surrounding pairs.
  #   ys{motion}{char} — add:    ysiw"  wraps a word in quotes
  #   cs{old}{new}      — change: cs"'   turns "..." into '...'
  #   ds{char}          — delete: ds(    removes surrounding parens
  # In visual mode, `S{char}` surrounds the selection.
  plugins.nvim-surround.enable = true;
}
