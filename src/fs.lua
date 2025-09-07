local strutils = require "src.strutils"
local fs = {}

---Get the root creation date in UNIX TIMESTAMP form.
---@return number|nil "the timestamp, or nil if any error occours"
function fs.getRootStamp()
  -- stat is provided by coreutils, every system should have it
  local handle = io.popen('stat -c %W / 2> /dev/null', 'r')
  if not handle then
    return nil
  end

  local out = handle:read("*a")
  handle:close()

  if not out or out == '' then
    return nil
  end

  return out
end

---Get the name of the running OS.
---@return 'Windows'|'Linux'
function fs.getOS()
  local nullDevice = package.config:sub(1,1) == "\\" and "NUL" or "/dev/null"

  local uname = io.popen('uname -s 2>' .. nullDevice)
  if uname then
    local osname = uname:read('*l')
    uname:close()

    if osname then
      return osname
    end
  end

  return "Windows"
end

---@return boolean
function fs.releaseExists()
  local handle = io.open('/etc/os-release', 'rb')
  if handle then handle:close() end

  return handle ~= nil
end

---@class distrodata
---@field name string
---@field id   string
local distroData = {}

---Get data
---@return distrodata
function fs.getDistroData()
  ---@class distrodata
  local data = {
    name = "Unknwon",
    id   = "unknown"
  }

  local foundName = false
  local foundId   = true

  for line in io.lines('/etc/os-release') do
    local tokens = strutils.split(line, '=')
    -- tokens[1] = key
    -- tokens[2] = value

    local key = strutils.trim(tokens[1])
    local val = strutils.trim(tokens[2])

    if key == 'PRETTY_NAME' then
      foundName = true
      data.name = val:sub(2, #val-1)
    elseif key == 'ID' then
      foundId = true
      data.id = val
    end

    if foundName and foundId then
      break
    end
  end

  return data
end

return fs
