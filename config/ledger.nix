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

  # Ledger keys live under <Space>l, but only inside ledger buffers — the
  # :Ledger* commands and ledger# functions are buffer-local, so we bind them
  # from a FileType autocmd instead of the global keymaps list.
  extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ledger",
      callback = function(ev)
        -- Ledger files inherit Vim's defaults (shiftwidth=8, noexpandtab), which
        -- makes it easy to over-indent postings. Postings want a clean 4-space
        -- indent, so <<, >> and typed indentation all step by 4 spaces here.
        vim.bo[ev.buf].expandtab = true
        vim.bo[ev.buf].shiftwidth = 4
        vim.bo[ev.buf].softtabstop = 4

        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
        end
        -- Align every posting's amount to the decimal-comma column (maxwidth).
        map("<leader>la", "<cmd>LedgerAlignBuffer<cr>", "Align amounts (buffer)")
        -- Reports (open the ledger CLI output in a scratch buffer).
        map("<leader>lb", "<cmd>Ledger bal<cr>", "Balance report")
        map("<leader>lr", "<cmd>Ledger reg<cr>", "Register report")
        -- Echo the cleared/pending balance for the account under the cursor.
        map("<leader>lB", function()
          vim.fn["ledger#show_balance"](vim.b.ledger_main)
        end, "Balance of account under cursor")
        -- Toggle the transaction's cleared state ('  ' -> '*').
        map("<leader>lt", function()
          vim.fn["ledger#transaction_state_toggle"](vim.fn.line("."))
        end, "Toggle transaction state")
      end,
    })
  '';
}
