local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
	experimental = {
		ghost_text = true,
	},
	formatting = {
		format = lspkind.cmp_format({
			with_text = true,
		}),
	},

	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},

	mapping = {
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.close(),
		["<C-y>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
	},

	sources = {
		{ name = "nvim_lsp" },
		{ name = "nvim_lsp_signature_help" },
		{ name = "luasnip" },
	},

	documentation = {
		border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
	},
})
