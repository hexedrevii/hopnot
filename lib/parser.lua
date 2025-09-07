--[[
Copyright 2025 HexedRevii

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

---@class parser
---@field options table
---@field private __values table
---@field private __flags boolean[]
---@field private __required table
---@field private __empty function
local parser = {}
parser.__index = parser

function parser:new()
  local p = {
    options = {},

    __values = {},
    __flags  = {},
    __required = {},
    __empty = nil
  }

  return setmetatable(p, parser)
end

---Set the function to be called if no value or flag is provided.
---@param callback function
function parser:setNothingProvided(callback)
  self.__empty = callback
end

---Add new option to the parser
---@param long string   Long name of the option
---@param short string? Short name of the option
---@param isRequired boolean
function parser:pushOption(long, short, isRequired)
  if isRequired then
    -- Set to false because they aren't provided yet!
    self.__required[long]  = false
    if short ~= nil then
      self.__required[short] = false
    end
  end

  self.options['--'..long] = { flag = false, required = isRequired, long = long, short = short }

  if short ~= nil then
    self.options['-'..short] = { flag = false, required = isRequired, long = long, short = short }
  end
end

---Add new flag to the parser
---@param long string   Long name of the option
---@param short string? Short name of the option
---@param isRequired boolean
function parser:pushFlag(long, short, isRequired)
  if isRequired then
    -- Set to false because they aren't provided yet!
    self.__required[long]  = false
    if short ~= nil then
      self.__required[short] = false
    end
  end

  self.options['--'..long] = { flag = true, required = isRequired, long = long, short = short }

  if short ~= nil then
    self.options['-'..short] = { flag = true, required = isRequired, long = long, short = short }
  end
end

---@param args string[] The commandline arguments, usually `arg`
function parser:parse(args)
  local value = false

  for idx, arg in ipairs(args) do
    if value then
      value = false
      goto continue
    end

    local opt = self.options[arg]
    if opt == nil then
      print("Unrecognised flag or option: " .. arg)
      goto continue
    end

    if not opt.flag then
      local val = args[idx + 1]
      if opt.short ~= nil then
        self.__values[opt.short] = val
      end

      self.__values[opt.long]  = val

      if opt.required then
        if opt.short ~= nil then
          self.__required[opt.short] = true
        end

        self.__required[opt.long]  = true
      end

      value = true
      goto continue
    end

    if opt.short ~= nil then
      self.__flags[opt.short] = true
    end

    self.__flags[opt.long]  = true

    if opt.required then
      if opt.short ~= nil then
        self.__required[opt.short] = true
      end

      self.__required[opt.long]  = true
    end

    ::continue::
  end

  -- Check if any required options aren't present
  local missing = {}
  for name, present in pairs(self.__required) do
    if not present then
      table.insert(missing, name)
    end
  end

  if #missing > 0 then
    print("Missing required options: " .. table.concat(missing, ", "))
    os.exit(1)
  end

  -- If nothing was provided
  -- Utility function
  local function __isEmptyTable(t)
    for _ in pairs(t) do
      return false
    end
    return true
  end

  if __isEmptyTable(self.__values) and __isEmptyTable(self.__flags) then
    if self.__empty then
      self.__empty()
    end
  end
end

---@param name string
function parser:getValue(name)
  return self.__values[name]
end

---@param name string
function parser:hasFlag(name)
  if self.__flags[name] then
    return true
  end

  return false
end

return parser
