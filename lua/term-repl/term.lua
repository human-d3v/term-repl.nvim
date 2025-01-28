local M = {}

function M.OpenBufferTerminal(term_type)
  -- set global variable for code_buf
  vim.g.code_buf = vim.api.nvim_get_current_buf()
  -- open term buf and move cursor there
  vim.api.nvim_exec2('belowright split | term', {output = true})
  local bufnr = vim.api.nvim_get_current_buf()
  --set global var  repl
  if term_type ~= nil then
    vim.g.repl = bufnr
  else
    vim.g.term_buf = bufnr
  end
	
	-- spawn terminal using commnad
	vim.api.nvim_chan_send(
		vim.api.nvim_get_option_value('channel', {buf=bufnr}),
		term_type .. "\r"
	)

	--move cursor to end of repl
	vim.api.nvim_win_set_cursor(0, {vim.api.nvim_buf_line_count(bufnr),0})
	--move cursor back to code_buf
	vim.cmd('wincmd p')
end

function M.CloseTerminal(term_type)
	if term_type ~= nil then 
		if vim.g.repl ~= nil then
			vim.api.nvim_buf_delete(vim.g.repl, {force=true})
		end
	else
		print("No repl found")
	end
end

function M.VerifyCloseTerminal(term_type)
	local a = vim.fn.input("Are you sure you want to close the terminal? [y/n]")
	if a:lower() == 'y' then
		M.CloseTerminal(term_type)
	else
		print('\nAction Cancelled')
	end
end

function M.TerminalLinkerBuf(term_type)
	local term = nil -- linked term or repl
	if term_type == nil then
		if vim.g.term_buf == nil then
			print("No terminal found")
			return
		else
			term = vim.g.term_buf
		end
	else
		term = vim.g.repl
	end
	-- get new buf
	local bufnr = vim.api.nvim_create_buf(false,true)
	
	-- get width of current window
	local window_width = vim.api.nvim_win_get_width(0)
	-- calculate new width of buf
	local float_width = math.ceil(window_width * 0.4)
	-- calculate starting position
	local win = vim.api.nvim_get_current_win()
	local cursor = vim.api.nvim_win_get_cursor(win)
	local row = cursor[1] + 1
	local col = cursor[2] + 1
	--set opts
	local opts = {
		relative = 'editor',
		width = float_width,
		height = 1,
		col = col,
		row = row,
		style = 'minimal',
    border = {
      {"╭", "FloatBorder"},
      {"─", "FloatBorder"},
      {"╮", "FloatBorder"},
      {"│", "FloatBorder"},
      {"╯", "FloatBorder"},
      {"─", "FloatBorder"},
      {"╰", "FloatBorder"},
			{"│", "FloatBorder"}
    },
	}
	vim.cmd("highlight FloatBorder guifg=white")
	-- create floating window
	local floating_win = vim.api.nvim_open_win(bufnr, true, opts)
		vim.api.nvim_command('startinsert')
		vim.api.nvim_win_set_buf(floating_win, term) -- link floating win to repl 
		
	-- exit insert mode on carriage return
	vim.api.nvim_buf_set_keymap(term, "t", "<CR>",
		[[<CR><C-\><C-n><Esc>]], {noremap=true, silent=true})
	-- set exit command to close floating buf	
	vim.api.nvim_buf_set_keymap(term, 'n', '<C-c>',
		[[<C-\><C-n>:q!<CR>]], {noremap=true, silent=true})
end

return M
