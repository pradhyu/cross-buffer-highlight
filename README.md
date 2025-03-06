# Cross-Buffer-Highlight Plugin for Neovim

This plugin automatically highlights all instances of a word across all visible buffers when your cursor is positioned over a word. It's useful for quickly seeing all occurrences of a variable, function, or any other term within your visible editor windows.

## Features

- Highlights the same word across all visible buffers
- Debounced highlighting to avoid performance issues during rapid cursor movement
- Configurable highlight style, update time, and word length limits
- Excluded filetypes to avoid highlighting in certain buffers
- Toggle command to enable/disable highlighting

## Installation

The plugin supports hot-loading, which means you can install and use it without restarting Neovim.

### Using Packer

```lua
use {
  'pradhyu/cross-buffer-highlight',
  config = function()
    require('cross-buffer-highlight').setup()
  end
}
```

### Using Lazy.nvim

```lua
{
  'pradhyu/cross-buffer-highlight',
  config = function()
    require('cross-buffer-highlight').setup()
  end
}
```

### Manual Installation

1. Create the directory structure in your Neovim config:

```
mkdir -p ~/.config/nvim/lua/cross-buffer-highlight
```

2. Save the plugin file as `~/.config/nvim/lua/cross-buffer-highlight/init.lua`

3. Add the following to your `init.lua`:

```lua
require('cross-buffer-highlight').setup()
```

## Configuration

The plugin works with default settings, but you can customize it by passing a configuration table:

```lua
require('cross-buffer-highlight').setup({
  highlight_group = 'CrossBufferHighlight',  -- Name of the highlight group to use
  update_time = 250,                   -- Delay in ms before updating highlights
  min_word_length = 2,                 -- Minimum word length to highlight
  max_word_length = 50,                -- Maximum word length to highlight
  excluded_filetypes = {               -- Filetypes to exclude from highlighting
    'qf', 'help', 'NvimTree', 'TelescopePrompt'
  },
})
```

## Commands

- `:CrossBufferHighlightToggle` - Toggle highlighting on/off for the current buffer

## Functions

You can also control the plugin programmatically:

```lua
-- Clear all highlights
require('cross-buffer-highlight').clear()

-- Reload the plugin without restarting Neovim
require('cross-buffer-highlight').reload()
```

## Hot-Loading Without Restart

You can load or reload the plugin during a Neovim session without restarting:

### First-time Loading

```lua
-- From the Neovim command line
:lua require('cross-buffer-highlight').setup()
```

### After Making Changes to the Plugin Code

```lua
-- From the Neovim command line
:lua package.loaded['cross-buffer-highlight'] = nil
:lua require('cross-buffer-highlight').setup()

-- Or use the built-in reload function
:lua require('cross-buffer-highlight').reload()
```

## Customizing Highlights

The plugin creates a highlight group called `CrossBufferHighlight` by default. You can customize this in your colorscheme:

```lua
vim.api.nvim_set_hl(0, 'CrossBufferHighlight', {
  bg = '#404040',
  fg = '#ffffff',
  bold = true,
})
```

## License

MIT
