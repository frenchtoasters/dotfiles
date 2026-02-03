local progress = require("fidget.progress")

local M = {}

function M:init()
	if M.initialized then
		return
	end
	M.initialized = true

	local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", { clear = true })

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestStarted",
		group = group,
		callback = function(ev)
			local data = ev and ev.data or {}
			local id = data.id
			if not id then return end

			local handle = M:create_progress_handle(ev)
			M:store_progress_handle(id, handle)
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestFinished",
		group = group,
		callback = function(ev)
			local data = ev and ev.data or {}
			local id = data.id
			if not id then return end

			local handle = M:pop_progress_handle(id)
			if handle then
				M:report_exit_status(handle, ev)
				handle:finish()
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = { "CodeCompanionChatDone", "CodeCompanionChatStopped" },
		group = group,
		callback = function(ev)
			local data = ev and ev.data or {}
			local id = "chat_" .. (data.bufnr or vim.api.nvim_get_current_buf())

			local handle = M:pop_progress_handle(id)
			if handle then
				if ev.match == "CodeCompanionChatStopped" then
					handle.message = "󰜺 Stopped"
				else
					handle.message = "Completed"
				end
				handle:finish()
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionInlineStarted",
		group = group,
		callback = function(ev)
			local data = ev and ev.data or {}
			local id = "inline_" .. (data.bufnr or vim.api.nvim_get_current_buf())

			local handle = progress.handle.create({
				title = " Inline Assistant",
				message = "Processing...",
				lsp_client = { name = "CodeCompanion" },
			})
			M:store_progress_handle(id, handle)
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionInlineFinished",
		group = group,
		callback = function(ev)
			local data = ev and ev.data or {}
			local id = "inline_" .. (data.bufnr or vim.api.nvim_get_current_buf())

			local handle = M:pop_progress_handle(id)
			if handle then
				handle.message = "Completed"
				handle:finish()
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionToolStarted",
		group = group,
		callback = function(ev)
			local data = ev and ev.data or {}
			local tool = data.tool or {}
			local id = "tool_" .. (tool.name or "unknown")

			local handle = progress.handle.create({
				title = " Executing Tool",
				message = tool.name or "Unknown",
				lsp_client = { name = "CodeCompanion" },
			})
			M:store_progress_handle(id, handle)
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionToolFinished",
		group = group,
		callback = function(ev)
			local data = ev and ev.data or {}
			local tool = data.tool or {}
			local id = "tool_" .. (tool.name or "unknown")

			local handle = M:pop_progress_handle(id)
			if handle then
				if data.status == "error" then
					handle.message = " Error"
				else
					handle.message = "Completed"
				end
				handle:finish()
			end
		end,
	})
end

M.handles = {}

function M:store_progress_handle(id, handle)
	M.handles[id] = handle
end

function M:pop_progress_handle(id)
	local handle = M.handles[id]
	M.handles[id] = nil
	return handle
end

function M:create_progress_handle(ev)
	local data = ev and ev.data or {}

	-- strategy sometimes isn't present; fall back to interaction/type or "request"
	local strategy = data.strategy or data.interaction or data.type or "request"

	local adapter = data.adapter or {}
	local role = M:llm_role_title(adapter)

	return progress.handle.create({
		title = " Requesting assistance (" .. tostring(strategy) .. ")",
		message = "In progress...",
		lsp_client = { name = role },
	})
end

function M:llm_role_title(adapter)
	adapter = adapter or {}
	local name = adapter.formatted_name or adapter.name or "LLM"
	local model = adapter.model
	if model and model ~= "" then
		return name .. " (" .. model .. ")"
	end
	return name
end

function M:report_exit_status(handle, ev)
	local data = ev and ev.data or {}
	local status = data.status

	if status == "success" then
		handle.message = "Completed"
	elseif status == "error" then
		handle.message = " Error"
	else
		handle.message = "󰜺 Cancelled"
	end
end

return M
