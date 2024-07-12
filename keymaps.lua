require("popup")
vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Esc>', '<Cmd>q<CR>', { noremap = true, silent = true })

vim.api.nvim_create_autocmd('BufLeave', {
	buffer = bufnr,
	callback = function()
		vim.api.nvim_win_close(win_id, true)
	end
})
