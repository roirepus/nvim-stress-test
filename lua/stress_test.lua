local M = {}

function M.run_stress_test()
	local handle = io.popen("./path/to/your/cpp_program") -- Adjust this to the path of your compiled C++ program
	local result = handle:read("*a")
	handle:close()

	-- Use Neovim's popup API to show the result
	vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
		relative = 'editor',
		width = 50,
		height = 10,
		row = 10,
		col = 10,
		style = 'minimal',
		border = 'single'
	})

	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result, "\n"))
end

return M
