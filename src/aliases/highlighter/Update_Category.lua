local catTbl = matches[2]:split("#")
local function usage()
  Highlighter:echo("You must provide the category name and configuration, separated by #.\n")
  Highlighter:echo("The configuration options should be comma separate table values. For example\n")
  Highlighter:echo("\"hl cat update Quest Items#fg = 'red', bold = true\"\n")
  Highlighter:echo("\"hl cat update Enemy# italics = true, fg = '<127,0,0>'\"\n")
end
if #catTbl ~= 2 then
  usage()
  return
end
local name = catTbl[1]
local success, options = pcall(loadstring("return { " .. catTbl[2] .. "}"))
if success then
  Highlighter:updateConfig(name, options)
  Highlighter:echo(f"Category {name} updated!")
  Highlighter:displayCategory(name)
else
  Highlighter:echo(f"Error parsing configuration options {catTbl[2]}. Usage:\n")
  usage()
end