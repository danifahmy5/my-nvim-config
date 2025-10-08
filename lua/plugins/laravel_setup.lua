-- Laravel-first setup untuk LazyVim
return {
  -- Import extras yang relevan
  { import = "lazyvim.plugins.extras.lang.php" },
  { import = "lazyvim.plugins.extras.lang.tailwind" },
  { import = "lazyvim.plugins.extras.formatting.prettier" },
  { import = "lazyvim.plugins.extras.test.core" }, -- neotest
  { import = "lazyvim.plugins.extras.dap.core" }, -- nvim-dap

  -- Plugin util Laravel (VERSI BARU, tanpa laravel.telescope)
  {
    "adalessa/laravel.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- "nvim-neotest/nvim-nio", -- opsional; biasanya sudah ditarik otomatis
    },
    opts = {
      lsp_server = "intelephense", -- atau "phpactor"
      -- pilih backend picker (telescope/snacks/fzf-lua/ui-select)
      features = { pickers = { provider = "telescope" } },
    },
    config = function(_, opts)
      local ok_laravel, Laravel = pcall(require, "laravel")
      if not ok_laravel then
        return
      end
      Laravel.setup(opts)

      -- Helper: goto “aman” (Laravel -> LSP -> gf)
      local function laravel_goto_safe()
        -- 1) Coba mode Laravel "gf" (kalau kursor di resource Laravel)
        local on_resource = false
        local ok_app, app = pcall(function()
          return Laravel.app("gf")
        end)
        if ok_app and app and app.cursorOnResource then
          local ok_on, res = pcall(function()
            return app:cursorOnResource()
          end)
          on_resource = ok_on and res or false
        end
        if on_resource and Laravel.commands and Laravel.commands.run then
          if pcall(Laravel.commands.run, "gf") then
            return
          end
        end

        -- 2) Coba picker “related” kalau tersedia
        local ok_pick, pickers = pcall(function()
          return Laravel.pickers
        end)
        if ok_pick and pickers and pickers.related then
          if pcall(pickers.related) then
            return
          end
        end

        -- 3) Fallback: LSP definition → gf biasa
        if vim.lsp and vim.lsp.buf and vim.lsp.buf.definition then
          if pcall(vim.lsp.buf.definition) then
            return
          end
        end
        vim.cmd.normal({ args = { "gf" }, bang = false })
      end

      -- Simpan ke global utk dipakai di mapping string (Ctrl+Click)
      _G.__laravel_goto_safe = laravel_goto_safe

      -- Keymap: “gf” pintar (Laravel > LSP > gf)
      vim.keymap.set("n", "gf", laravel_goto_safe, { desc = "Laravel: goto (Laravel/LSP/gf)" })

      -- Keymap: “gl” untuk related (kalau tidak ada, fallback ke goto_safe)
      vim.keymap.set("n", "gl", function()
        local ok_pick, pickers = pcall(function()
          return Laravel.pickers
        end)
        if ok_pick and pickers and pickers.related then
          if pcall(pickers.related) then
            return
          end
        end
        laravel_goto_safe()
      end, { desc = "Laravel: related file" })

      -- Opsional: Ctrl + Click seperti VSCode
      vim.o.mouse = "a"
      vim.keymap.set(
        "n",
        "<C-LeftMouse>",
        "<LeftMouse>:lua __laravel_goto_safe()<CR>",
        { desc = "Laravel: Ctrl+Click goto", silent = true }
      )
    end,
  },

  -- Pastikan tool terpasang via Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "intelephense",
        "tailwindcss-language-server",
        "emmet-language-server",
        "prettierd", -- formatter cepat utk web assets
        "php-cs-fixer", -- alternatif formatter PHP
        "php-debug-adapter", -- DAP untuk Xdebug
        -- tambahan penting untuk ekosistem Laravel/PHP
        "blade-formatter",
        "phpcs",
        "pint",
      })
    end,
  },

  -- Treesitter: aktifkan blade + kawan-kawan
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "php",
        "blade",
        "html",
        "css",
        "javascript",
        "typescript",
        "json",
        "yaml",
        "lua",
        "bash",
        "dockerfile",
      },
    },
  },

  -- Formatter: Pint utk PHP, Blade Formatter utk .blade.php, Prettier utk web files
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        php = { "pint", "php_cs_fixer" }, -- pakai Pint jika ada, fallback ke php-cs-fixer
        blade = { "blade-formatter" },
        html = { "prettier" },
        css = { "prettier" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
      })
      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        ["blade-formatter"] = {
          command = "blade-formatter",
          args = { "--write", "$FILENAME" },
          stdin = false,
        },
        pint = {
          -- gunakan Pint lokal proyek jika ada
          command = "sh",
          args = { "-c", 'test -x "./vendor/bin/pint" && ./vendor/bin/pint -- "$FILENAME"' },
          stdin = false,
        },
        php_cs_fixer = {
          command = "php-cs-fixer",
          args = { "fix", "--using-cache=no", "$FILENAME" },
          stdin = false,
        },
      })
      return opts
    end,
  },

  -- Linting: PHPCS untuk PHP
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = { php = { "phpcs" } },
    },
  },

  -- Testing: PHPUnit & Pest via neotest
  {
    "nvim-neotest/neotest",
    dependencies = {
      "olimorris/neotest-phpunit",
      "theutz/neotest-pest",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require("neotest-phpunit")({}))
      table.insert(opts.adapters, require("neotest-pest")({}))
    end,
  },

  -- DAP: pastikan adapter PHP terinstall
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = { ensure_installed = { "php" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      -- Aktifkan intelephense (recommended)
      opts.servers.intelephense = {
        root_dir = function(fname)
          local util = require("lspconfig.util")
          -- Anggap root Laravel: composer.json / artisan / .git
          return util.root_pattern("composer.json", "artisan", ".git")(fname) or util.path.dirname(fname)
        end,
        -- (opsional) setting intelephense lain taruh di sini
      }

      -- Kalau mau tetap pakai phpactor juga, pastikan root_dir cocok
      -- atau matikan dulu supaya tidak bingung:
      -- opts.servers.phpactor = {}         -- aktifkan (pastikan phpactor terpasang)
      -- ATAU
      -- opts.servers.phpactor = false      -- nonaktifkan jika tidak dipakai
    end,
  },
}
