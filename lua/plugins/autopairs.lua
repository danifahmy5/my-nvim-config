-- ~/.config/nvim/lua/plugins/autopairs.lua
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    local npairs = require("nvim-autopairs")
    local Rule = require("nvim-autopairs.rule")

    npairs.setup({
      check_ts = true,
      fast_wrap = {},
    })

    -- 🧠 Custom rule untuk file Blade
    npairs.add_rules({
      Rule("{{", "}}", "blade")
        :with_pair(function()
          return false
        end)
        :replace_endpair(function()
          vim.schedule(function()
            vim.api.nvim_feedkeys("  ", "i", true)
          end)
          return "}}"
        end)
        :with_move(function(opts)
          return opts.next_char == "}"
        end)
        :use_key("{"),
    })
  end,
}
