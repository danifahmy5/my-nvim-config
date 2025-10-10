-- ~/.config/nvim/lua/plugins/laravel-autocomplete.lua
return {
  -- Plugin utama Laravel helper
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local laravel = require("laravel")
      laravel.setup()

      -- Preload daftar route untuk autocomplete
      vim.defer_fn(function()
        pcall(function()
          require("laravel.routes").list()
        end)
      end, 2000)
    end,
  },

  -- Sumber autocomplete tambahan untuk asset() dan route()
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-path" },
    opts = function(_, opts)
      local cmp = require("cmp")

      -- Tambahkan sumber custom untuk laravel_routes
      local source = {}
      source.new = function()
        return setmetatable({}, { __index = source })
      end

      source.complete = function(_, request, callback)
        local ok, laravel_routes = pcall(require, "laravel.routes")
        if not ok then
          return callback()
        end

        local routes = laravel_routes.list() or {}
        local items = {}
        for _, route in ipairs(routes) do
          if route.name and route.name ~= "" then
            table.insert(items, { label = route.name })
          end
        end

        callback({ items = items, isIncomplete = false })
      end

      -- Register sumber laravel_routes ke cmp
      cmp.register_source("laravel_routes", source.new())

      -- Konfigurasi global cmp
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources or {}, {
        { name = "laravel_routes" }, -- untuk route()
        { name = "path" }, -- untuk asset()
        { name = "buffer" },
        { name = "nvim_lsp" },
      }))

      -- Custom logic agar path autocomplete di dalam asset() diarahkan ke public/
      cmp.event:on("menu_opened", function()
        local line = vim.api.nvim_get_current_line()
        if line:match("asset%('") then
          vim.b.cmp_path_cwd = vim.fn.getcwd() .. "/public"
        else
          vim.b.cmp_path_cwd = nil
        end
      end)

      return opts
    end,
  },
}
