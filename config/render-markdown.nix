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
