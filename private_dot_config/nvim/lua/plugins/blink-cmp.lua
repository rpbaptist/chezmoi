return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		build = "cargo build --release",
		opts_extend = {
			"sources.completion.enabled_providers",
			"sources.compat",
			"sources.default",
		},
		dependencies = {
			"rafamadriz/friendly-snippets",
			"milanglacier/minuet-ai.nvim",
			-- "giuxtaposition/blink-cmp-copilot",
			{
				"saghen/blink.compat",
				optional = true, -- make optional so it's only enabled if any extras need it
				opts = {},
				version = "*",
			},
		},
		event = "InsertEnter",
		opts = {
			fuzzy = { implementation = "prefer_rust_with_warning" },
			snippets = {
				preset = "luasnip",
			},
			appearance = {
				-- sets the fallback highlight groups to nvim-cmp's highlight groups
				-- useful for when your theme doesn't support blink.cmp
				-- will be removed in a future release, assuming themes add support
				use_nvim_cmp_as_default = false,
				-- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},
			completion = {
				trigger = {
					prefetch_on_insert = true,
				},
				keyword = {
					range = "full",
				},
				list = {
					selection = {
						preselect = function(_ctx)
							return not require("blink.cmp").snippet_active({ direction = 1 })
						end,
					},
				},
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				menu = {
					draw = {
						treesitter = { "lsp" },
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				ghost_text = {
					enabled = true,
				},
			},
			sources = {
				-- adding any nvim-cmp sources here will enable them
				-- with blink.compat
				default = { "lsp", "path", "snippets", "buffer", "copilot", "lazydev" },
				-- default = { "lsp", "path", "snippets", "buffer", "lazydev", "minuet" },
				providers = {
					copilot = {
						name = "copilot",
						module = "blink-cmp-copilot",
						kind = "Copilot",
						score_offset = 100,
						async = true,
					},
					-- minuet = {
					-- 	name = "minuet",
					-- 	module = "minuet.blink",
					-- 	async = true,
					--       kind = "Claude",
					-- 	timeout_ms = 2000,
					-- 	score_offset = 100,
					-- },
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
						score_offset = 100,
					},
				},
			},
			cmdline = {
				enabled = false,
			},
			keymap = {
				preset = "super-tab",
				["<Esc"] = { "hide", "fallback" },
			},
		},
		config = function(_, opts)
			-- setup compat sources
			local enabled = opts.sources.default
			for _, source in ipairs(opts.sources.compat or {}) do
				opts.sources.providers[source] = vim.tbl_deep_extend(
					"force",
					{ name = source, module = "blink.compat.source" },
					opts.sources.providers[source] or {}
				)
				if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
					table.insert(enabled, source)
				end
			end

			-- Unset custom prop to pass blink.cmp validation
			opts.sources.compat = nil

			-- check if we need to override symbol kinds
			for _, provider in pairs(opts.sources.providers or {}) do
				if provider.kind then
					local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
					local kind_idx = #CompletionItemKind + 1

					CompletionItemKind[kind_idx] = provider.kind
					CompletionItemKind[provider.kind] = kind_idx

					local transform_items = provider.transform_items
					provider.transform_items = function(ctx, items)
						items = transform_items and transform_items(ctx, items) or items
						for _, item in ipairs(items) do
							item.kind = kind_idx or item.kind
							item.kind_icon = vim.g.custom_icons.kinds[item.kind_name] or item.kind_icon or nil
						end
						return items
					end

					-- Unset custom prop to pass blink.cmp validation
					provider.kind = nil
				end
			end

			require("blink.cmp").setup(opts)
		end,
	},
}
