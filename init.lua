-- cross-buffer-highlight.lua
-- Plugin for highlighting the same word across all visible buffers

local M = {}

-- Namespace for our highlights
local ns_id = vim.api.nvim_create_namespace("cross_buffer_highlight")

-- Configuration with defaults
M.config = {
  highlight_group = "CrossBufferHighlight",
  update_time = 250,
  min_word_length = 2,
  max_word_length = 50,
  excluded_filetypes = { "qf", "help", "NvimTree", "TelescopePrompt" },
}

local debounce_timer = nil

-- Set up highlight group if it doesn't exist
local function ensure_highlight_group()
  local hl_exists = pcall(vim.api.nvim_get_hl_by_name, M.config.highlight_group, true)
  if not hl_exists then
    vim.api.nvim_set_hl(0, M.config.highlight_group, {
      bg = "#404040",
      fg = "#ffffff",
      bold = true,
    })
  end
end

-- Clear all highlights
local function clear_highlights()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    end
  end
end

-- Check if buffer should be excluded
local function should_exclude_buffer(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  for _, excluded_ft in ipairs(M.config.excluded_filetypes) do
    if ft == excluded_ft then
      return true
    end
  end
  return false
end

-- Get all visible buffers
local function get_visible_buffers()
  local buffers = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and not should_exclude_buffer(buf) then
      table.insert(buffers, buf)
    end
  end
  return buffers
end

-- Get word under cursor
local function get_word_under_cursor()
  local word = vim.fn.expand("<cword>")
  local word_len = #word

  if word_len < M.config.min_word_length or word_len > M.config.max_word_length then
    return nil
  end

  return word
end

-- Highlight all instances of a word in visible buffers
local function highlight_word(word)
  if not word or word == "" then
    return
  end

  clear_highlights()

  local visible_buffers = get_visible_buffers()

  for _, buf in ipairs(visible_buffers) do
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    for line_idx, line in ipairs(lines) do
      local start_idx = 1
      while true do
        local word_start, word_end = line:find("%f[%w_]" .. word .. "%f[^%w_]", start_idx)
        if not word_start then
          break
        end

        vim.api.nvim_buf_add_highlight(buf, ns_id, M.config.highlight_group, line_idx - 1, word_start - 1, word_end)

        start_idx = word_end + 1
      end
    end
  end
end

-- Update highlights based on current cursor position
local function update_highlights()
  local word = get_word_under_cursor()

  if word then
    highlight_word(word)
  else
    clear_highlights()
  end
end

-- Debounced update function to avoid excessive updates
local function debounced_update()
  if debounce_timer then
    vim.loop.timer_stop(debounce_timer)
    debounce_timer = nil
  end

  debounce_timer = vim.defer_fn(function()
    update_highlights()
    debounce_timer = nil
  end, M.config.update_time)
end

-- Setup the plugin
function M.setup(opts)
  -- Merge user config with defaults
  if opts then
    M.config = vim.tbl_deep_extend("force", M.config, opts)
  end

  ensure_highlight_group()

  -- Set up autocommands for cursor movement
  local augroup = vim.api.nvim_create_augroup("CrossBufferHighlight", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = augroup,
    callback = debounced_update,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = augroup,
    callback = update_highlights,
  })

  -- Command to manually toggle highlighting
  vim.api.nvim_create_user_command("CrossBufferHighlightToggle", function()
    if vim.b.cross_buffer_highlight_enabled == nil then
      vim.b.cross_buffer_highlight_enabled = false
    end

    vim.b.cross_buffer_highlight_enabled = not vim.b.cross_buffer_highlight_enabled

    if vim.b.cross_buffer_highlight_enabled then
      update_highlights()
      print("Cross-buffer highlighting enabled")
    else
      clear_highlights()
      print("Cross-buffer highlighting disabled")
    end
  end, {})

  -- Enable highlighting by default
  vim.b.cross_buffer_highlight_enabled = true
end

-- Expose clear function
function M.clear()
  clear_highlights()
end

return M
