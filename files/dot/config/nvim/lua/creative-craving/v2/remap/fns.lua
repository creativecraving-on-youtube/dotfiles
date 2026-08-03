--- exports
local M = {}

function M.bind_keys(bindings, bind_opts)
    bind_opts = bind_opts or {}
    local extra_opts = {}
    if bind_opts.buffer then
        extra_opts.buf = bind_opts.buffer
    end

    for _,binding in pairs(bindings) do
        local mode = binding[1]
        local lhs = binding[2]
        local rhs = binding[3]
        local opts = binding[4]
        opts = vim.tbl_extend("force", opts, extra_opts)
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

--- Move the line under the cursor to the top 1/3rd or so of the current
--- window. Pass a custom ratio to try to hit that sweet spot where it looks
--- natural.
function M.scroll_cursor_line_to_sweet_spot(ratio)
  ratio = ratio or 0.25
  local view = vim.fn.winsaveview()
  local height = vim.api.nvim_win_get_height(0)
  local offset = math.floor(height * ratio)
  local limit = vim.wo.scrolloff or 1
  view.topline = math.max(limit, view.lnum - offset)
  vim.fn.winrestview(view)
end

function M.keybindings_usage_for(bindings_spec)
  local width_avail = -2 + vim.fn.winwidth(0)
  local height_avail = -2 + vim.fn.winheight(0)

  local width = math.max(width_avail, 48)

  local formatted = M.format_keybindings_doc(bindings_spec)

  local height = math.max(height_avail, formatted.lines)

  local popup = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(popup, 0, -1, false, formatted.doc)

  local pos = {
    x = 1 + (width_avail - width)/2,
    y = 1 + (height_avail - height)/2,
  }

  local popup_win = vim.api.nvim_open_win(popup, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = pos.x,
    row = pos.y,
    style = 'minimal',
    border = 'rounded',
  })

  for _, key in pairs({ 'q', '<Esc>'}) do
    vim.keymap.set(
      'n',
      key,
      function()
        if vim.api.nvim_win_is_valid(popup_win) then
          vim.api.nvim_win_close(popup_win, true)
        end
      end,
      { buffer = popup, silent = true})
  end
end

function M.word_wrap(fmt_orig, max_length, lines_prefix, first_line_prefix)
  lines_prefix = lines_prefix or ""
  first_line_prefix = first_line_prefix or lines_prefix

  if #lines_prefix > max_length then
    lines_prefix = string.sub(lines_prefix, 1, max_length)
  end
  if #first_line_prefix > max_length then
    first_line_prefix = string.sub(first_line_prefix, 1, max_length)
  end

  local words = fmt_orig:gmatch("%S+")
  local fmts = {}
  local line_count = 0
  local word = ""
  while word ~= nil do
    line_count = line_count + 1
    local fmt_vetted = ""
    local fmt = ""
    local prefix = ""

    if line_count > 1 then
      prefix = lines_prefix
    else
      prefix = first_line_prefix
    end

    while #fmt < max_length and word ~= nil do
      fmt_vetted = fmt

      if #word + #prefix > max_length then
        if fmt_vetted ~= "" then
          table.insert(fmts, fmt_vetted)
        end

        fmt = lines_prefix .. word
        fmt = fmt:sub(1, max_length)

      elseif word ~= "" and fmt == "" then
          fmt = prefix .. word
      elseif word ~= "" then
          fmt = fmt .. " " .. word
      end
      word = words()
    end

    if #fmt < max_length then
      table.insert(fmts, fmt)
      word = ""
    else
      table.insert(fmts, fmt_vetted)
    end
  end

  return fmts
end

function M.format_keybindings_doc(bindings_spec, max_width)
  local sections = {}
  local layout_width = 0
  local rhs_width = 0
  local section_padding_sz = 2
  local tab_size = 3
  local sect_line_char = "─"
  local section_padding = string.rep(" ", section_padding_sz)

  local function bind_fmt_width(bind_data)
    return #(table.concat(bind_data, " "))
  end

  for section, bind_spec in pairs(bindings_spec) do
    if not type(section) == "string" then
      section = "Key Bindings"
    end

    layout_width = math.max(layout_width, 2*section_padding_sz + #section)
    local bindings = {}

    for _, bind in pairs(bind_spec) do
      local mode = bind[1]
      local rhs = bind[2]
      local desc = bind[4]["desc"] or "undocumented"

      local bind_data = {rhs, mode, desc}
      layout_width = math.max(layout_width, bind_fmt_width(bind_data))
      rhs_width = math.max(rhs_width, #rhs)
      table.insert(bindings, bind_data)
    end

    sections[section] = bindings
  end

  max_width = max_width or layout_width + tab_size
  layout_width = max_width
  local sect_line = string.rep(sect_line_char, layout_width)
  local doc = {}

  for section, bindings in pairs(sections) do
    if #doc > 0 then
      table.insert(doc, "")
    end

    local fmt = section_padding .. section
    if #fmt <= layout_width then
      table.insert(doc, fmt)
    else
      local fmts = M.word_wrap(fmt, layout_width, section_padding)
      for _, _fmt in pairs(fmts) do
        table.insert(doc, _fmt)
      end
    end

    table.insert(doc, sect_line)

    for _, bind_data in pairs(bindings) do
      local padding_sz = math.max(0, 3 + rhs_width)
      local padding = string.rep(" ", padding_sz)
      local prefix = bind_data[1] .. padding
      local tail = string.format(
        "[%s] %s",
        bind_data[2],
        bind_data[3]
      )
      fmt = prefix .. tail
      if #fmt <= layout_width then
        table.insert(doc, fmt)
      else
        local addl_line_padding = string.rep(" ", #prefix)
        local fmts = M.word_wrap(tail, layout_width, addl_line_padding, prefix)
        for _, _fmt in pairs(fmts) do
          table.insert(doc, _fmt)
        end
      end
    end
  end

  return {
    width = layout_width,
    lines = 2,
    doc = doc,
    structured = sections,
  }
end

--- Emulate ^] (<C-]>)
function M.tag_under_cursor()
    local word_under_cursor = vim.fn.expand("<cword>")
    vim.cmd("tag " .. word_under_cursor)
end

-- Emulate ^] (<C-]>) but open in a new tab
function M.tag_under_cursor_in_new_tab()
    local word_under_cursor = vim.fn.expand("<cword>")
    vim.cmd("tab tag " .. word_under_cursor)
end

function M.do_in_new_tab(command, expansion)
    local text = vim.fn.expand(expansion or "<cword>")
    vim.cmd("tab " .. command .. " " .. text)
end

return M
