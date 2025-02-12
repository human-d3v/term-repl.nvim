local M = {}

function M.next_line()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	local total_lines = vim.api.nvim_buf_line_count(0)

	for i = current_line+1, total_lines do
    local line_content = vim.api.nvim_buf_get_lines(0, i-1, i, false)[1]
    if line_content:match('^%S') then
      vim.api.nvim_win_set_cursor(0, {i,0})
      break
    end
  end
end

function M.LastChanceReplSpawn(term_type)
  term = require('terminal')
  local answer = vim.fn.input('No terminal found. Do you want to open one? [y/n]\n')
  if answer:lower() == 'y' then
    term.OpenBufferTerminal(term_type)
    term_buf = vim.g.term_buf --set variable since it didn't get set above
  else
    print("\nAction Cancelled")
  end
end

function M.SendToRepl(opts, ...)
	-- expects an opts table {repl_type, input_type} where:
	-- repl_type: the command you would send to the terminal to spawn the repl:
	--		"node", "python3", "stata-mp"/"stata-se", "R", etc.
	-- and 
	-- input_type
	--	0: send the current line to Repl
	--  1: send the visual selection to Repl
	--	2: send the entire file up to and including the current line to Repl
	--  3: send an optional string to the Repl
	local txt = ''

	if opts.input_type == 1 then -- visual selection
		vim.cmd('normal! gv"xy') --captures vis selection
    txt = vim.fn.getreg('x')
		print('txt captured in visual selection: '.. txt)
    -- vim.api.nvim_exec2(":'>", {})
	elseif opts.input_type == 2 then -- normal mode entire file
		local ln, _ = unpack(vim.api.nvim_win_get_cursor(0))
		local ln_txts = vim.api.nvim_buf_get_lines(
			vim.api.nvim_get_current_buf(),
			0,
			ln,
			false
		)
		txt = table.concat(ln_txts, "\n")
	elseif opts.input_type == 3 then -- send text explicitly
		if ... then
			for i, v in ipairs({...}) do
				txt = txt .. v
			end
		end
	else
		txt = vim.api.nvim_get_current_line()
	end

	M.next_line()

	local term_buf = nil
	if opts.repl_type then 
		term_buf = vim.g.repl
	else
		term_buf = vim.g.term_buf
	end
	if term_buf == nil then 
    M.LastChanceReplSpawn(opts.repl_type)
  end
	
	vim.api.nvim_chan_send(
		vim.api.nvim_get_option_value('channel', {buf = term_buf}), 
		txt .. '\r'
	)
end

-- function aliases
function M.SendVisualSelection(repl_type)
	M.SendToRepl({input_type = 1, repl_type = repl_type})
end

function M.SendCurrentLine(repl_type)
	M.SendToRepl({input_type = 0, repl_type = repl_type})
end

function M.SendFileFromStartToCursor(repl_type)
	M.SendToRepl({input_type = 2, repl_type = repl_type})
end

function M.EndReplInstance(repl_type)
  M.SendToRepl({input_type = 3, repl_type = repl_type}, 'exit')
end

return M
