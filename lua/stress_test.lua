local M = {}
local popup = require('popup')

local function extract_function_code(file_path, function_name)
	local file = io.open(file_path, "r")
	if not file then
		return nil, "Could not open file: " .. file_path
	end

	local code_lines = {}
	local in_function = false
	local brace_count = 0

	for line in file:lines() do
		if line:match("//%s*void%s+" .. function_name) then
			in_function = true
			line = line:gsub("//", "")
		end

		if in_function then
			line = line:gsub("^%s*//", "")
			table.insert(code_lines, line)
			for c in line:gmatch("[{}]") do
				if c == "{" then
					brace_count = brace_count + 1
				elseif c == "}" then
					brace_count = brace_count - 1
				end
			end

			if brace_count == 0 then
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

local function compile_and_run_cpp(file_path, function_code, function_name)
	local temp_cpp = "/tmp/temp_stress_test.cpp"
	local temp_exec = "/tmp/temp_stress_test"

	local file = io.open(temp_cpp, "w")
	if not file then
		return nil, "Could not create temporary file: " .. temp_cpp
	end

	file:write("#include <iostream>\n")
	file:write(function_code)
	file:write("\nint main() {\n   " .. function_name .. " ();\n    return 0;\n}\n")
	file:close()

	os.execute("g++ " .. temp_cpp .. " -o " .. temp_exec)
	local handle = io.popen(temp_exec)
	local result = handle:read("*a")
	handle:close()

	return result
end

function M.run_stress_test()
	local function_name = "stress"    --vim.fn.input("stress fn name: ")
	local file_path = "/home/charm/test.cpp" --vim.fn.input("file path: ")



	local function_code, err = extract_function_code(file_path, function_name)
	if not function_code then
		print(err)
		return
	end

	local result, temp_cpp, temp_exec = compile_and_run_cpp(file_path, function_code, function_name)

	-- Use Neovim's popup API to show the result
	popup.show(result)
	--os.remove("" .. temp_cpp)
	--os.remove("" .. temp_exec)
end

function M.show_temp_cpp()
	local temp_cpp = "/tmp/temp_stress_test.cpp"
	local file = io.open(temp_cpp, "r")
	if not file then
		print("Could not open temporary C++ file: " .. temp_cpp)
		return
	end

	local content = file:read("*a")
	file:close()
	popup.show(content)
end

return M
