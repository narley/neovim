{
  # vim-ledger — filetype detection, syntax highlighting, folding, auto-format,
  # and completion for ledger accounting files (github.com/ledger/vim-ledger).
  # nixvim also pulls in the `ledger` CLI automatically, which the plugin uses
  # for aligning amounts and account-name completion.
  plugins.ledger = {
    enable = true;

    # Options below map to `g:ledger_*`. Adjust to taste.
    settings = {
      bin = "ledger"; # use ledger-cli (not hledger): it speaks `cleared`/`--uncleared` for :Balance/:Reconcile and reads the comma-decimal journals fine. hledger stays the terminal source of truth (make check).
      decimal_sep = ","; # journals use decimal commas, so :LedgerAlign snaps to the comma (col 60)
      maxwidth = 80; # align amounts to this column
      fillstring = "  "; # string used to pad while aligning
      # detailed_first = 1;  # order completion by most-detailed account first
      # fold_blanks = 0;     # keep blank lines visible when folded
    };
  };
}
