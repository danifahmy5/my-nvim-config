return {
  "L3MON4D3/LuaSnip",
  opts = {
    history = true,
    delete_check_events = "TextChanged",
  },
  config = function(_, opts)
    local luasnip = require("luasnip")
    luasnip.config.set_config(opts)
    require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
  end,
}
