local lsp_installer = require("nvim-lsp-installer")

local on_attach = function(client, bufnr)
	-- Avoiding LSP formatting conflicts with null-ls and the lsp.
	client.resolved_capabilities.document_formatting = false
	client.resolved_capabilities.document_range_formatting = false

	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
end

local servers = {
	"sumneko_lua",
	"tsserver",
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

for _, name in pairs(servers) do
	local server_is_found, server = lsp_installer.get_server(name)
	if server_is_found then
		if not server:is_installed() then
			print("Installing " .. name)
			server:install()
		end
	end
end

lsp_installer.on_server_ready(function(server)
	-- Specify the default options which we'll use to setup all servers
	local default_opts = {
		on_attach = on_attach,
		capabilities = capabilities,
	}

	server:setup(default_opts)
end)
