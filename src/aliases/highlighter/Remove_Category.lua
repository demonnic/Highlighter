local category = matches[2]
if Highlighter.categories[category] then
  Highlighter:removeCategory(category)
  Highlighter:echo(f"Category {category} removed")
else
  Highlighter:echo(f"Could not find category {category} to remove")
end