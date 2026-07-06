{
  # Treesitter — real syntax-aware parsing. Big upgrade over regex highlighting
  # (accurate colors for TS/TSX/etc.), and it powers the scope detection used by
  # indent-blankline and rainbow-delimiters below.
  #
  # All grammars are installed by default, so every filetype you open is
  # highlighted. To slim the closure, pin a curated list, e.g.:
  #   grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
  #     typescript tsx javascript json yaml toml nix lua bash markdown html css
  #   ];
  plugins.treesitter = {
    enable = true;
    highlight.enable = true;
    indent.enable = true;
  };
}
