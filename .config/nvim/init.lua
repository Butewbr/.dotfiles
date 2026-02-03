-- 1. Bootstrap lazy.nvim (This installs the plugin manager itself)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. Setup plugins
require("lazy").setup({
  {
    "Shatur/neovim-ayu",
    lazy = false,    -- Load this immediately
    priority = 1000, -- Load this before other plugins
    config = function()
      -- You can set the variant here: 'mirage', 'dark', or 'light'
      vim.g.ayucolor = "light" 
      vim.cmd("colorscheme ayu")
    end,
  },
})

-- 3. Basic Quality of Life settings
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers (great for engineers!)
vim.opt.termguicolors = true  -- Enable 24-bit RGB colors (Required for Ayu)