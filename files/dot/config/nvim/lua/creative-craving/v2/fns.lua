--- exports
local M = {}

function M.get_floating_win_specs(win, min_width, min_height)
    win = win or 0
    min_width = min_width or 0
    min_height = min_height or 0

    local avail = {
        x = -2 + vim.fn.winwidth(win),
        y = -2 + vim.fn.winheight(win),
    }
    local size = {
        x = math.max(avail.x, min_width),
        y = math.max(avail.y, min_height),
    }
    local pos = {
        x = 1 + 0.5 * (avail.x - size.x),
        y = 1 + 0.5 * (avail.y - size.y),
    }

    return {
        width = size.x,
        height = size.y,
        col = pos.x,
        row = pos.y,
    }
end

local function secs_to_human(secs)
  local min_t = 60
  local hr_t = 60*min_t
  local day_t = 24*hr_t

  local days = math.floor(secs / day_t)
  secs = secs % day_t
  local hours = math.floor(secs / hr_t)
  secs = secs % hr_t
  local mins = math.floor(secs / min_t)

  local fmt_spec = {}
  local hr_min_combined = hours > 0 and mins > 0
  if hr_min_combined then
    fmt_spec = {
      {days, "%d days"},
      {hours, string.format("%%d:%d", mins)},
    }
  else
    fmt_spec = {
      {days, "%d days"},
      {hours, "%d hours"},
      {mins, "%d mins"},
    }
  end

  local fmt = {}

  for _,f in pairs(fmt_spec) do
    if f[1] == nil or f[1] <= 0 then
    else
      table.insert(fmt, string.format(f[2], f[1]))
    end
  end

  local fmt_str = table.concat(fmt, " ")
  return fmt_str
end

local function uptime()
  local f = io.open("/proc/uptime", "r")
  if not f then return "uptime:not found" end

  local content = f:read("*l")
  f:close()

  local floats = {}
  for c in content:gmatch("%S+") do
    table.insert(floats, tonumber(c or "-1"))
  end

  local _uptime = floats[1] or -1
  local idle_time = floats[2] or -1

  if _uptime < 0 then
    return string.format("uptime:%s,%s", _uptime, idle_time)
  end

  local fmt = string.format("uptime:%s", secs_to_human(_uptime))
  if idle_time < 0 then
    return fmt
  end

  return string.format("%s idle:%s", fmt, secs_to_human(idle_time))
end

function M.is_headless()
    return 0 == #vim.api.nvim_list_uis()
end

function M.motd()
  return string.format("%s", uptime())
end

return M
