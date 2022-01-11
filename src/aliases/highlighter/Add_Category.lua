local catTbl = matches[2]:split("#")

local function usage()
  Highlighter:echo("You must provide the category name and configuration, separated by #.")
  Highlighter:echo("The configuration options should be comma separate table values. For example")
  Highlighter:echo("\"hl cat add Quest Items#fg = 'red', bold = true\"")
  Highlighter:echo("\"hl cat add Enemy# italics = true, fg = '<127,0,0>'\"")
end
if #catTbl ~= 2 then
  usage()
  return
end
local name = catTbl[1]
local success, options = pcall(loadstring("return { " .. catTbl[2] .. "}"))
if success then
  Highlighter:addCategory(name, options)
  Highlighter:echo("Added category {catTbl[1]}. Configuration table used displayed below")
  display(options)
else
  Highlighter:echo(f"Error parsing configuration options {catTbl[2]}. Usage:")
  usage()
end