local strutils = {}

strutils.help = [[hopnot (v1.0)
Show off how long your distro has been installed!

Options:
  [LONG]  [SHORT]  [VAR]   [DESCRIPTION]
  --logo  -l       [logo]  Show a specific logo, defaults to unknown if logo is not found.

Flags:
  [LONG]       [SHORT]   [DESCRIPTION]
  --nologo     -n        Show only the data, without a logo.
  --help       -h        Display the help message
  --list-logos -s        List the name of every logo available
]]

---@param s string
---@return string
function strutils.trim(s)
  return s:match( "^%s*(.-)%s*$" )
end

---Split a string
---@param input string
---@param sep string?
---@return string[]
function strutils.split(input, sep)
  sep = sep or '%s'

  local ret = {}
  for str in string.gmatch(input, "([^"..sep.."]+)") do
    table.insert(ret, str)
  end

  return ret
end

---Print two string arrays 'zipped'
---@param one string[]
---@param two string[]
function strutils.zip(one, two)
  local max = math.max(#one, #two)
  for i=1,max do
    local first  = i > #one and '' or one[i]
    local second = i > #two and '' or two[i]

    print(first .. second)
  end
end

return strutils
