{
  # render-markdown.nvim — lean in-buffer markdown rendering (headings, code-block
  # backgrounds, bullet icons, checkboxes, tables, callouts) driven by Treesitter,
  # so it fits the rest of this config. Kept behind a toggle: files open as raw
  # markdown and <Space>m flips the rendered view on/off.
  plugins.render-markdown = {
    enable = true;
    settings = {
      # Don't render automatically on open — start raw, toggle with <Space>m.
      enabled = false;
      # De-render the line the cursor is on so you can edit markup in place while
      # the rest of the buffer stays pretty.
      anti_conceal.enabled = true;

      # Stop the plugin from breaking LSP hover (`K`), which showed a literal
      # "```typescript" line instead of a highlighted signature.
      #
      # On setup render-markdown calls `disable_pattern()` on the *shared*
      # markdown highlights query, switching off the two `conceal_lines`
      # patterns that hide ```lang fences (its `patterns.markdown.disable`
      # default, ids 17 and 18). It does that so it can draw its own code
      # blocks — but the query object is global, so every markdown-rendered
      # buffer loses fence concealment too, LSP floats included. That is why
      # this happened even with `enabled = false` above, and why disabling the
      # plugin per-buffer or per-buftype cannot fix it.
      #
      # Leaving the patterns in place hands fence concealment back to Neovim.
      patterns.markdown.disable = false;
    };
  };

  # <Space>m toggles render-markdown for the current buffer.
  keymaps = [
    {
      mode = "n";
      key = "<leader>m";
      action = "<cmd>RenderMarkdown toggle<cr>";
      options.desc = "Toggle markdown render";
    }
  ];
}
