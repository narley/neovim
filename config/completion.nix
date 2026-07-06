{
  # blink.cmp — fast completion engine. Pops up automatically as you type,
  # sourcing from your LSP servers (ts_ls / eslint), buffer words, file paths,
  # and snippets. On Neovim 0.11+ it wires its completion capabilities into the
  # LSP servers automatically, so no extra setup is needed there.
  plugins.blink-cmp = {
    enable = true;
    settings = {
      # Tab accepts / navigates the menu (Zed / VS Code-like). Other presets:
      # "default" (<C-y> to accept), "enter" (<CR> to accept).
      keymap.preset = "super-tab";

      completion = {
        # Show a documentation popup for the highlighted item.
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 250;
        };
      };
    };
  };
}
