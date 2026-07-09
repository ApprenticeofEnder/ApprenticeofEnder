-- local esc = vim.api.nvim_replace_termcodes("<ESC>", true, true, true)
-- local enter = vim.api.nvim_replace_termcodes("<CR>", true, true, true)
--
-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	pattern = { "*" },
-- 	callback = function()
-- 		vim.fn.setreg("s", ":!keep-sorted " .. vim.api.nvim_buf_get_name(0) .. enter)
-- 	end,
-- })

function Open_file_in_modal(file)
	Snacks.win({
		file = file,
		width = 0.6,
		height = 0.6,
		wo = {
			spell = false,
			wrap = true,
			signcolumn = "yes",
			statuscolumn = " ",
			conceallevel = 3,
		},
	})
end

local nvim_data = vim.fn.expand("$HOME/.local/state/nvim")

vim.keymap.set({ "n" }, "<leader>ln", function()
	Open_file_in_modal(require("vim.lsp.log").get_filename())
end, { desc = "Open Neovim logs" })

vim.keymap.set({ "n" }, "<leader>lf", function()
	Open_file_in_modal(string.format("%s/conform.log", nvim_data))
end, { desc = "Open Conform logs" })

vim.keymap.set({ "n" }, "<leader>ll", function()
	Open_file_in_modal(string.format("%s/lsp.log", nvim_data))
end, { desc = "Open LSP logs" })
