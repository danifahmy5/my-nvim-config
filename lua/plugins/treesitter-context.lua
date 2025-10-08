-- ~/.config/nvim/lua/plugins/treesitter-context.lua
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "BufReadPost",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    enable = true, -- aktifkan fitur
    max_lines = 3, -- maksimal 3 baris context yang ditampilkan di atas
    trim_scope = "outer", -- kurangi tampilan jika terlalu dalam
    mode = "cursor", -- berdasarkan posisi kursor
    separator = "-", -- bisa diganti "─" kalau mau garis pemisah
    zindex = 20, -- biar tampil di atas layer yang lain
  },
}
