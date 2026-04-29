local esc = vim.api.nvim_replace_termcodes("<ESC>", true, true, true)
vim.fn.setreg("t", "iTesting macros!" .. esc)
