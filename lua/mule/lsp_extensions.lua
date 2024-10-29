vim.api.nvim_create_autocmd({ "InsertEnter" }, {
	group = vim.api.nvim_create_augroup("NotifyClearGroup", {}),
	pattern = "*",
	callback = function()
		vim.notify.dismiss({ silent = true })
	end
})

local function string_empty(s)
	return not s or s == ''
end

local function empty_response(resp)
	return (not resp) or (#resp == 0)
end

-- Credit to ViRu-ThE-ViRuS
-- https://github.com/ViRu-ThE-ViRuS/configs/blob/f992ed40026fa387f3a8727f3bbc9c0b59154841/nvim/lua/lsp-setup/handlers.lua

-- TODO: This function is gross; make less huge
local function qf_rename()
	local parameters = vim.lsp.util.make_position_params()
	parameters.oldName = vim.fn.expand("<cword>")

	vim.ui.input({ prompt = 'Rename> ', default = parameters.oldName }, function(input)
		parameters.newName = input

		local notify_opts = {
			title = string.format('rename: %s -> %s', parameters.oldName, parameters.newName),
			timeout = 1000,
		}

		local notify = function(msg, lvl)
			if not lvl then
				lvl = 'info'
			end

			vim.notify(msg, lvl, notify_opts)
		end

		if input == nil then
			notify('aborted rename', 'warn')
			return
		end

		local method_rename = 'textDocument/rename'
		vim.lsp.buf_request_all(0, method_rename, parameters, function(responses)
			local notification, entries = '', {}
			local num_files, num_updates = 0, 0
			for client_id, response in ipairs(responses) do
				local ctx = {
					method    = method_rename,
					client_id = client_id,
				}

				vim.lsp.handlers[method_rename](
					response.error,
					response.result,
					ctx)

				if empty_response(response) then
					goto continue
				end

				for _, doc in ipairs(response.result.documentChanges) do
					local uri = doc.textDocument.uri
					local edits = doc.edits

					num_files = num_files + 1
					local bufnr = vim.uri_to_bufnr(uri)

					for _, edit in ipairs(edits) do
						local start_line = edit.range.start.line + 1
						local line = vim.api.nvim_buf_get_lines(
							bufnr,
							start_line - 1,
							start_line,
							false)[1]

						num_updates = num_updates + 1
						table.insert(entries, {
							bufnr = bufnr,
							lnum = start_line,
							col = edit.range.start.character + 1,
							text = line
						})
					end

					local short_uri = string.sub(vim.uri_to_fname(uri), #vim.fn.getcwd() + 2)
					notification = notification ..
					    string.format('made %d change(s) in %s', #edits, short_uri)
				end

				::continue::
			end

			if not string_empty(notification) then
				notify(notification, 'info')
			end
		end)
	end)
end

vim.lsp.buf.rename = qf_rename
