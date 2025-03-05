local M = {}

-- repl_obj {command, {patterns (filetypes)}, keymap}
-- example: {"stata-mp", {'stata'}, '<leader><leader>mp'}


local default_opts = {
	repls = {
		{cmd = "stata-mp", pattern = {'stata'}, keymap = '<leader><leader>mp'},
		{cmd = "python3", pattern = {'python'}, keymap = '<leader><leader>py'},
		{cmd = "node", pattern = {"javascript"}, keymap = '<leader><leader>js'},
	},
	linker = true,
}

function M.setup(opts)
	local term = require('term-repl.term')
	local repl = require('term-repl.repl')
	-- merge default and passed opts
	opts = vim.tbl_deep_extend("force", default_opts, opts or {})
	local keymap_opts = {silent = true, noremap = true}
	for _, obj in ipairs(opts.repls) do
		vim.api.nvim_create_autocmd("FileType", {
			pattern = obj.pattern,
			callback = function()
				vim.schedule(function ()
					vim.keymap.set('n', obj.keymap, function() term.OpenBufferTerminal(obj.cmd) end, keymap_opts)
					vim.keymap.set({'v', 'x'}, '<Bslash>d', [[:lua require('term-repl.repl')SendVisualSelection(]] .. obj.cmd .. ")<CR>", keymap_opts)
					vim.keymap.set('n', '<Bslash>d', function() repl.SendCurrentLine(obj.cmd) end, keymap_opts)
					vim.keymap.set('n', '<Bslash>aa', function() repl.SendFileFromStartToCursor(obj.cmd) end, keymap_opts)
					vim.keymap.set('n', '<Bslash>q', function() term.VerifyCloseTerminal(obj.cmd) end, keymap_opts)
					if opts.linker == true then
						vim.keymap.set('n', '<leader>t', function() term.TerminalLinkerBuf(obj.cmd) end, keymap_opts)
					end
				end)
			end
		})
	end
end

return M
