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

  # Trim leading/trailing blank lines from LSP floating previews (hover/`K`,
  # signature help). Language servers — ts_ls especially — pad hover markdown
  # with empty lines, which leaves a band of background between the text and
  # the rounded `winborder`, making the border look detached. Stripping the
  # outer blanks lets the border sit flush against the content. This wraps the
  # single function every float preview goes through, so it applies everywhere.
  extraConfigLua = ''
    local orig = vim.lsp.util.open_floating_preview
    vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
      if type(contents) == "table" then
        while #contents > 0 and contents[1]:match("^%s*$") do
          table.remove(contents, 1)
        end
        while #contents > 0 and contents[#contents]:match("^%s*$") do
          table.remove(contents)
        end
      end
      return orig(contents, syntax, opts, ...)
    end
  '';

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

  # Format-on-save = ESLint fix-all.
  #
  # This repo runs Prettier THROUGH ESLint (each eslint.config.mjs ends with
  # `eslint-plugin-prettier/recommended`), so there is no standalone Prettier
  # step. Running ESLint's `applyAllFixes` on save applies Prettier formatting
  # AND the autofixable lint rules (simple-import-sort, unused-imports) in one
  # pass — matching `npm run lint`. A separate Prettier formatter would be
  # redundant and could fight these rules, so we deliberately don't add one.
  #
  # The ESLint LSP registers as a formatter (base config sets `format = true`),
  # and its formatting runs `eslint --fix`, i.e. the full autofix pass: Prettier
  # formatting AND the other fixable rules (simple-import-sort, unused-imports).
  # `vim.lsp.buf.format({ async = false })` is genuinely synchronous — the edit
  # lands before the write. (`LspEslintFixAll` applies its edit on a deferred
  # tick, so it races the write and is unreliable here.) The `filter` restricts
  # this to ESLint, and if ESLint isn't attached to the buffer, nothing happens.
  autoCmd = [
    {
      event = [ "BufWritePre" ];
      pattern = [
        "*.ts"
        "*.tsx"
        "*.js"
        "*.jsx"
        "*.mjs"
        "*.cjs"
        "*.json"
        "*.yml"
        "*.yaml"
      ];
      desc = "ESLint fix (Prettier + import sort + lint autofixes) before save";
      callback = lib.nixvim.mkRaw ''
        function(args)
          vim.lsp.buf.format({
            bufnr = args.buf,
            async = false,
            filter = function(client) return client.name == "eslint" end,
          })
        end
      '';
    }
  ];

  # To use vtsls instead (Effect plugin + the project's own TypeScript), replace
  # the `ts_ls.enable` line above with:
  #
  #   vtsls = {
  #     enable = true;
  #     config.settings.vtsls.autoUseWorkspaceTsdk = true;
  #   };
}
