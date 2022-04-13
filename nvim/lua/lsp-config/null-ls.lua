local null_ls = require("null-ls")

local formatting = null_ls.builtins.formatting

local sources = {
	formatting.prettier,
	formatting.stylua,
}

null_ls.setup({
	sources = sources,

	-- on_attach = function(client)
	-- 	if client.resolved_capabilities.document_formatting then
	-- 		-- format on save
	-- 		vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
	-- 	end
	-- end,
})
