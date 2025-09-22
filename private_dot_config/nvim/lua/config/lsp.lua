vim.diagnostic.config({
	enabled = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
	update_in_insert = false,
	underline = true,
	severity_sort = true,
	virtual_text = {
		spacing = 4,
		source = "if_many",
		prefix = "●",
	},
})

vim.lsp.inlay_hint.enable(false)

local completion_kinds = vim.lsp.protocol.CompletionItemKind
local kinds = vim.g.custom_icons.kinds
for i, kind in ipairs(completion_kinds) do
	completion_kinds[i] = kinds[kind] and kinds[kind] .. kind or kind
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.foldingRange = {
	dynamicRegistration = true,
	lineFoldingOnly = true,
}

capabilities.textDocument.semanticTokens.multilineTokenSupport = true
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("*", {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		local function map(modes, mapping, fn, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(modes, mapping, fn, opts)
		end

		map("n", "gd", function()
			Snacks.picker.lsp_definitions()
		end, { desc = "Goto Definition" })
		map("n", "gr", function()
			Snacks.picker.lsp_references()
		end, { desc = "References", nowait = true })
		map("n", "gI", function()
			Snacks.picker.lsp_implementations()
		end, { desc = "Goto Implementation" })
		map("n", "gy", function()
			Snacks.picker.lsp_type_definitions()
		end, { desc = "Goto T[y]pe Definition" })
		map("n", "<leader>ss", function()
			Snacks.picker.lsp_symbols()
		end, { desc = "LSP Symbols" })
		map("n", "<leader>sS", function()
			Snacks.picker.lsp_workspace_symbols()
		end, { desc = "LSP Workspace Symbols" })
		map({ "n", "v" }, "<leader>cp", function()
			local params = vim.lsp.util.make_position_params()
			vim.lsp.buf_request(0, "workspace/executeCommand", {
				command = "manipulatePipes:serverid",
				arguments = { "toPipe", params.textDocument.uri, params.position.line, params.position.character },
			}, params.handler)
		end, { desc = "To Pipe" })
		map({ "n", "v" }, "<leader>cP", function()
			local params = vim.lsp.util.make_position_params()

			vim.lsp.buf_request(0, "workspace/executeCommand", {
				command = "manipulatePipes:serverid",
				arguments = { "fromPipe", params.textDocument.uri, params.position.line, params.position.character },
			}, params.handler)
		end, { desc = "From Pipe" })

		-- map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
		-- map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Documentation" })
		-- map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
		-- map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
		--
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
		end
		if client:supports_method("textDocument/documentSymbol") then
			require("nvim-navic").attach(client, bufnr)
		end
	end,
})

vim.lsp.enable({
	"elixirls",
	"lua_ls",
	"marksman",
	"bashls",
	"ts_ls",
})
