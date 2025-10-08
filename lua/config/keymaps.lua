-- ~/.config/nvim/lua/config/keymaps.lua
-- Custom keymaps tambahan untuk LazyVim

-- ambil util LazyVim (kalau tersedia)
local map = vim.keymap.set

-- ===============================
-- 📁 FILE MANAGEMENT
-- ===============================

-- Tutup semua buffer (seperti VSCode: Ctrl + K, W)
map("n", "<C-k>w", ":%bd<CR>", { desc = "Close all buffers" })
