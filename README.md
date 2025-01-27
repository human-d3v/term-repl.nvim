# Plugin for Neovim to use a terminal as a REPL

This is a flexible repl plugin that creates a linker channel between a specific
terminal and Neovim.

This can be used to create a REPL for anything from
[stata](https://github.com/human-d3v/stata-nvim) to python, nodejs, etc.

To load with the lazy.nvim plugin manager, add the following to your lazy.lua file:
```lua
{"human-d3v/term-repl.nvim", opts = {}}
```

This loads the default configuration of the plugin.

You can also specify the types of repls that you want to load, like so:
```lua
-- the repl object looks like this:
-- { 
--      cmd = "command to spawn repl", 
--      pattern = {"table with pattern to match"}, -- e.g. {'python'}
--      keymap = "keymap to launch repl", -- '<leader>repl'
-- }

{"human-d3v/term-repl.nvim", opts = {
    repls = {
        {cmd = "python3", {"python"}, "<leader>py"}
    }, 
    linker = false -- floating linker buffer
}
```

The current keymaps are:
| Keymap | Description |
| ------ | ----------- |
| \<leader\>\<leader\>py | launch python repl |
| \<leader\>\<leader\>mp | launch stata repl |
| \<leader\>\<leader\>js | launch nodejs repl |
| backslash + d | Send visual selection or current line (in normal mode) to repl |
| backslash + aa | Send the file from the first line to cursor to repl |
| bakslash + q | Quit the repl |


