if matches[2] == "add" then
  local itemTbl = matches[3]:split("#")
  if #itemTbl ~= 2 then
    Highlighter:echo("Please provide both the category and item separated by a #.")
    Highlighter:echo("'hl item add Enemy#Bob' to add 'Bob' to the 'Enemy' category")
    Highlighter:echo("'hl item add Quest Items#a rotting pumpkin' to add 'a rotting pumpkin' to the 'Quest Items' category")
    return
  end
  if not Highlighter.categories[itemTbl[1]] then
    Highlighter:echo("could not find category {itemTbl[1]} to add {itemTbl[2]} to")
    return
  end
  Highlighter:add(itemTbl[2], itemTbl[1])
  Highlighter:echo("Added " .. itemTbl[2] .. " to category: " .. itemTbl[1])
else
  if not Highlighter.items2category[matches[3]] then
    Highlighter:echo(f"item {matches[3]} not found to remove")
  end
  Highlighter:remove(matches[3])
  Highlighter:echo("Removed '" .. matches[3] .. "'" )
end