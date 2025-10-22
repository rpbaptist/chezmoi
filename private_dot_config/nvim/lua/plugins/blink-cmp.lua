return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		build = "cargo build --release",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		event = { "InsertEnter", "CmdlineEnter" },
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
						preselect = function()
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
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					lua = {
						inherit_defaults = true,
						"lazydev",
					},
				},
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
						score_offset = 100,
					},
				},
			},
			cmdline = {
				enabled = true,
				keymap = {
					["<Tab>"] = { "show", "accept" },
					preset = "inherit",
				},
				completion = {
					list = { selection = { preselect = false } },
					menu = {
						auto_show = function()
							return vim.fn.getcmdtype() == ":"
						end,
					},
					ghost_text = { enabled = true },
				},
			},
			keymap = {
				preset = "super-tab",
				["<Esc"] = { "hide", "fallback" },
				["<Tab>"] = {
					"snippet_forward",
					function()
						return require("sidekick").nes_jump_or_apply()
					end,
					"fallback",
				},
			},
		},
		config = function(_, opts)
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
