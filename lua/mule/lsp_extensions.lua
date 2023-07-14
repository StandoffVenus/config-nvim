local notify = require('notify')

vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    group = vim.api.nvim_create_augroup("NotifyClearGroup", {}),
    pattern = "*",
    callback = function()
	    notify.dismiss({ silent = true })
    end
})

-- Credit to ViRu-ThE-ViRuS
-- https://github.com/ViRu-ThE-ViRuS/configs/blob/f992ed40026fa387f3a8727f3bbc9c0b59154841/nvim/lua/lsp-setup/handlers.lua

-- TODO: This function is gross; make less huge
local function qf_rename()
	local parameters = vim.lsp.util.make_position_params()
	parameters.oldName = vim.fn.expand("<cword>")

	vim.ui.input({ prompt = 'Rename> ', default = parameters.oldName }, function(input)
		parameters.newName = input
		if input == nil then
			notify('[lsp] aborted rename', 'warn', { render = 'minimal' })
			return
		end

		vim.lsp.buf_request_all(0, "textDocument/rename", parameters, function(responses)
			local notification, entries = '', {}
			local num_files, num_updates = 0, 0
			for client_id, response in ipairs(responses) do
				if response.error then
					notify(response.error.message, 'error', {
					    title = 'failed to rename',
					    timeout = 10000
					})

					return
				end

				local method_rename = 'textDocument/rename'
				local ctx = {
				    method    = method_rename,
				    client_id = client_id,
				}

				vim.lsp.handlers[method_rename](
				    response.err,
				    response.result,
				    ctx)

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
			end

			notify(notification, 'info', {
			    title = string.format('[lsp] rename: %s -> %s', parameters.oldName, parameters.newName),
			    timeout = 750
			})

			if num_files > 1 then require("utils").qf_populate(entries, "r") end
		end)
	end)
end

vim.lsp.buf.rename = qf_rename
