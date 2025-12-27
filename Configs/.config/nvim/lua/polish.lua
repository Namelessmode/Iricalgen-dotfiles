

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
--
vim.opt.termguicolors = true
vim.cmd.colorscheme("default")
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes"

-- Full transparency fix
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "BufWinEnter", "WinEnter" }, {
  pattern = "*",
  callback = function()
    local groups = {
      "Normal",
      "NormalNC",
      "NormalFloat",
      "FloatBorder",
      "NonText",
      "EndOfBuffer",
      "SignColumn",
      "MsgArea",
      "TelescopeNormal",
      "TelescopeBorder",
      "StatusLine",
      "StatusLineNC",
      "TabLine",
      "TabLineFill",
      "TabLineSel",
      "WinBar",
      "WinBarNC",
      "CursorLine",
      "VertSplit",
      "FoldColumn",
    }

    for _, group in ipairs(groups) do
      vim.cmd("hi " .. group .. " guibg=none ctermbg=none")
    end
  end,
})
