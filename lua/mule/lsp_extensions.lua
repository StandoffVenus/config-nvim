vim.api.nvim_create_autocmd({ "InsertEnter" }, {
	group = vim.api.nvim_create_augroup("NotifyClearGroup", {}),
	pattern = "*",
	callback = function()
		vim.notify.dismiss({ silent = true })
	end
})

--- Guarantees to return an iterator, returning an exhausted one if `tbl` is nil.
--- @param tbl table? The table to iterate.
--- @return function
--- @return table
local function safe_pairs(tbl) return pairs(tbl or {}) end

--- Appends a variadic number of arguments to the table in the "indexed" form.
--- @param tbl table The table to append to.
--- @param ... any The elements to append.
local function append(tbl, ...)
	local len = #tbl
	for i, v in ipairs({ ... }) do
		tbl[len + i] = v
	end
end

--- Returns whether the provided string is empty (`nil` or blank)
--- @param s string The string to examine.
--- @return boolean is_empty Whether the string is empty. Will be `true` if `nil` is passed.
local function string_empty(s)
	return (not s) or (s == '')
end

--- Returns whether the provided table is empty (no elements). `nil` values evaluate to `true`.
--- @param tbl table The table to inspect emptiness of.
--- @return boolean is_empty Whether the table is empty. Will be `true` if `nil` is passed.
local function is_empty(tbl)
	-- Fast path: table is nil, ergo empty
	if not tbl then
		return true
	end

	-- Fast path: the table has at least one numbered element
	if #tbl > 0 then
		return false
	end

	-- "Slow" path: have to iterate the table once to see if
	-- it has any non-numbered elements
	local has_elements = false
	for _ in pairs(tbl) do
		has_elements = true
		break
	end

	return not has_elements
end


-- This function will prompt to rename the identifier under the cursor, submitting a rename request to the LSP
-- if a new name is provided.
--
-- The inspiration for this function comes from ViRu-ThE-ViRuS:
-- https://github.com/ViRu-ThE-ViRuS/configs/blob/f992ed40026fa387f3a8727f3bbc9c0b59154841/nvim/lua/lsp-setup/handlers.lua
vim.lsp.buf.rename = function()
	local parameters = vim.lsp.util.make_position_params()
	parameters.oldName = vim.fn.expand("<cword>")

	vim.ui.input({ prompt = 'Rename> ', default = parameters.oldName }, function(input)
		if not input then
			return
		end

		parameters.newName = input

		local notify_opts = {
			title = string.format('rename: %s -> %s', parameters.oldName, parameters.newName),
			timeout = 5000,
		}

		local notify = function(msg, lvl)
			if not lvl then
				lvl = 'info'
			end

			vim.notify(msg, lvl, notify_opts)
		end


		local method_rename = 'textDocument/rename'
		local function evaluate_response(client_id, response)
			local ctx = {
				method    = method_rename,
				client_id = client_id,
			}

			local err = response.error
			local result = response.result
			vim.lsp.handlers[method_rename](err, result, ctx)

			if is_empty(result) then
				return {}
			end

			local notifications = {}
			for file, changes in safe_pairs(result.changes) do
				local uri = vim.uri_to_fname(file)
				local num_changes = #changes
				local notif = string.format('made %d change(s) in %s', num_changes, uri)

				table.insert(notifications, notif)
			end

			return notifications
		end

		vim.lsp.buf_request_all(0, method_rename, parameters, function(responses)
			local notifications = {}
			for client_id, response in pairs(responses) do
				append(notifications, unpack(evaluate_response(client_id, response)))
			end

			local msg = table.concat(notifications, '\n')
			if not string_empty(msg) then
				notify(msg, 'info')
			end
		end)
	end)
end
