local Popup = {}
require("keymaps")
function Popup.show(content)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))

	vim.api.nvim_open_win(bufnr, true, {
		relative = 'editor',
		width = 80,
		height = 50,
		row = 80,
		col = 50,
		style = 'minimal',
		border = 'single'
	})
end

return Popup
