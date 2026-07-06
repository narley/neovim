{ lib, ... }:
{
  # Language servers for the @primary-portal/ioi TypeScript monorepo.
  #
  # - ts_ls  : TypeScript type-checking / navigation (typescript-language-server).
  # - eslint : ESLint 9 flat-config linting. Each package has its own
  #            eslint.config.mjs + node_modules and there is NO root config, so
  #            `workingDirectories.mode = "auto"` makes the server resolve the
  #            right package dir (and the local eslint) per file.
  #
  # Servers are provided by Nix (not Mason), so nothing to `npm i -g`.
  #
  # NOTE (Effect): this repo loads the `@effect/language-service` tsserver plugin
  # via tsconfig.base.json. ts_ls uses its own bundled TypeScript and won't load
  # that plugin, but plain type-checking still works. For Effect-aware diagnostics
  # and exact TS 5.8.3 parity, swap ts_ls for vtsls (see the note at the bottom).

  # nvim-lspconfig ships the base `lsp/<server>.lua` configs (cmd, filetypes,
  # root_markers, and ESLint's elaborate settings/before_init) that Neovim's
  # native LSP reads. The `lsp.servers` block below layers our overrides on top
  # and enables the servers. Without this, servers have no `cmd` and won't attach.
  plugins.lspconfig.enable = true;

  # Make diagnostics visible inline (off by default in Neovim).
  diagnostic.settings = {
    virtual_text = true;
    severity_sort = true;
    update_in_insert = false;
  };

  lsp = {
    servers = {
      ts_ls.enable = true;

      eslint = {
        enable = true;
        config.settings.workingDirectories.mode = "auto";
      };
    };

    # Buffer-local keymaps, active once a server attaches.
    keymaps = [
      {
        key = "gd";
        lspBufAction = "definition";
      }
      {
        key = "gD";
        lspBufAction = "references";
      }
      {
        key = "K";
        lspBufAction = "hover";
      }
      {
        key = "<leader>rn";
        lspBufAction = "rename";
      }
      {
        # Apply a code action — this is how you run an ESLint autofix.
        key = "<leader>ca";
        lspBufAction = "code_action";
      }
      {
        key = "<leader>e";
        action = lib.nixvim.mkRaw "function() vim.diagnostic.open_float() end";
      }
      {
        key = "[d";
        action = lib.nixvim.mkRaw "function() vim.diagnostic.jump({ count = -1, float = true }) end";
      }
      {
        key = "]d";
        action = lib.nixvim.mkRaw "function() vim.diagnostic.jump({ count = 1, float = true }) end";
      }
    ];
  };

  # To use vtsls instead (Effect plugin + the project's own TypeScript), replace
  # the `ts_ls.enable` line above with:
  #
  #   vtsls = {
  #     enable = true;
  #     config.settings.vtsls.autoUseWorkspaceTsdk = true;
  #   };
}
