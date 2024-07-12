local M = {}

local function extract_function_code(file_path, function_name)
	local file = io.open(file_path, "r")
	if not file then
		return nil, "Could not open file: " .. file_path
	end

	local code_lines = {}
	local in_function = false
	for line in file:lines() do
		if line:match("//%s*void%s+" .. function_name) then
			in_function = true
			line = line:gsub("//", "")
		end

		if in_function then
			table.insert(code_lines, line)
			if line:match("^}") then
				in_function = false
				break
			end
		end
	end

	file:close()

	if #code_lines == 0 then
		return nil, "Function " .. function_name .. " not found or not commented out."
	end

	return table.concat(code_lines, "\n")
end

local function compile_and_run_cpp(file_path, function_code)
	local temp_cpp = "/tmp/temp_stress_test.cpp"
	local temp_exec = "/tmp/temp_stress_test"

	local file = io.open(temp_cpp, "w")
	if not file then
		return nil, "Could not create temporary file: " .. temp_cpp
	end

	file:write("#include <iostream>\n")
	file:write(function_code)
	file:write("\nint main() {\n    stress_fn();\n    return 0;\n}\n")
	file:close()

	os.execute("g++ " .. temp_cpp .. " -o " .. temp_exec)
	local handle = io.popen(temp_exec)
	local result = handle:read("*a")
	handle:close()

	return result
end

function M.run_stress_test()
	local file_path = vim.fn.input("Path to C++ file: ")
	local function_name = vim.fn.input("stress fn name: ")


	local function_code, err = extract_function_code(file_path, function_name)
	if not function_code then
		print(err)
		return
	end

	local result = compile_and_run_cpp(file_path, function_code)

	-- Use Neovim's popup API to show the result
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(result, "\n"))

	vim.api.nvim_open_win(bufnr, true, {
		relative = 'editor',
		width = 50,
		height = 10,
		row = 10,
		col = 10,
		style = 'minimal',
		border = 'single'
	})
end

return M
