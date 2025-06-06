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

local kinds = {
	Array = " ",
	Boolean = "󰨙 ",
	Class = " ",
	Codeium = "󰘦 ",
	Color = " ",
	Control = " ",
	Collapsed = " ",
	Constant = "󰏿 ",
	Constructor = " ",
	Copilot = " ",
	Enum = " ",
	EnumMember = " ",
	Event = " ",
	Field = " ",
	File = " ",
	Folder = " ",
	Function = "󰊕 ",
	Interface = " ",
	Key = " ",
	Keyword = " ",
	Method = "󰊕 ",
	Module = " ",
	Namespace = "󰦮 ",
	Null = " ",
	Number = "󰎠 ",
	Object = " ",
	Operator = " ",
	Package = " ",
	Property = " ",
	Reference = " ",
	Snippet = "󱄽 ",
	String = " ",
	Struct = "󰆼 ",
	Supermaven = " ",
	TabNine = "󰏚 ",
	Text = " ",
	TypeParameter = " ",
	Unit = " ",
	Value = " ",
	Variable = "󰀫 ",
}
local completion_kinds = vim.lsp.protocol.CompletionItemKind
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
		local function map(mapping, fn, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set("n", mapping, fn, opts)
		end

		map("gd", function()
			Snacks.picker.lsp_definitions()
		end, { desc = "Goto Definition" })
		map("gr", function()
			Snacks.picker.lsp_references()
		end, { desc = "References", nowait = true })
		map("gI", function()
			Snacks.picker.lsp_implementations()
		end, { desc = "Goto Implementation" })
		map("gy", function()
			Snacks.picker.lsp_type_definitions()
		end, { desc = "Goto T[y]pe Definition" })
		map("<leader>ss", function()
			Snacks.picker.lsp_symbols()
		end, { desc = "LSP Symbols" })
		map("<leader>sS", function()
			Snacks.picker.lsp_workspace_symbols()
		end, { desc = "LSP Workspace Symbols" })
		map("<leader>cp", function()
			local params = vim.lsp.util.make_position_params()
			vim.lsp.buf_request(0, "workspace/executeCommand", {
				command = "manipulatePipes:serverid",
				arguments = { "toPipe", params.textDocument.uri, params.position.line, params.position.character },
			}, params.handler)
		end, { desc = "To Pipe" })
		map("<leader>cP", function()
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
		if client.supports_method("textDocument/documentSymbol") then
			require("nvim-navic").attach(client, bufnr)
		end
	end,
})

vim.lsp.enable({
	"elixirls",
	"lua_ls",
	"marksman",
	"bashls",
  "ts_ls"
})
