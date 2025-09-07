local fs = require 'src.fs'
local logos = require 'logos'
local strutils = require 'src.strutils'
local parser   = require 'lib.parser'

---Format time
---@param time number
---@param suffix string
---@return string
local function fmt(time, suffix)
  if time <= 0 then
    return ''
  end

  return time .. ' ' .. suffix .. (time > 1 and 's ' or ' ')
end

local function c(ascii)
  return '\27[38;5;' .. ascii .. 'm'
end

local function e()
  return '\27[0m'
end

-- Setup parser
local args = parser:new()
args:pushOption('logo', 'l', false)

args:pushFlag('nologo', 'n', false)
args:pushFlag('help', 'h', false)
args:pushFlag('list-logos', 's', false)

args:parse(arg)

if args:hasFlag('help') then
  print(strutils.help)
  os.exit(0)
end

if args:hasFlag('list-logos') then
  for name,_ in pairs(logos.ascii) do
    if name ~= 'unknown' then
      print(name)
    end
  end

  os.exit(0)
end

if not fs.releaseExists() then
  print('The /etc/os-release file does not exist in your system!')
  os.exit(1)
end

local stamp = fs.getRootStamp()
if not stamp then
  print("Command 'stat' not found. (how the fuck?)")
  os.exit(1)
end

local installDate = os.date('%d/%m/%Y %T', stamp)

-- Get time difference
local difference = os.time() - stamp
local days = math.floor(difference / (24 * 3600))
local hours = math.floor((difference % (24 * 3600)) / 3600)
local minutes = math.floor((difference % 3600) / 60)

local diffstr = fmt(days, 'day') .. fmt(hours, 'hour') .. fmt(minutes, 'minute') .. 'since installation.'

-- Get ascii logo
local distroData = fs.getDistroData()

local argId = args:getValue('logo')
local id = argId or distroData.id

local ascii = logos.ascii[id] or logos.ascii['unknown']
local colour = logos.colours[id] or logos.colours['unknown']

-- Form the data string
local horizontal = string.char(0xE2, 0x94, 0x80) -- ─
local downRight  = string.char(0xE2, 0x94, 0x94) -- └
local line = downRight .. horizontal .. horizontal -- └──

local out = {
  '', '',
  'Currently on ' .. c(colour) .. distroData.name .. e(),
  line ..'Installed on ' .. c(colour) .. installDate .. e(),
  '    ' .. line .. diffstr
}

strutils.zip((args:hasFlag('nologo') and {} or ascii), out)

if args:hasFlag('nologo') then
  print('\n')
end
