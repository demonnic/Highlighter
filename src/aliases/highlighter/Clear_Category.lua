local category = matches[2]
if Highlighter.categories[category] then
  Highlighter:clearCategory(category)
  Highlighter:echo(f"Category {category} cleared")
else
  Highlighter:echo(f"Could not find category {category} to clear")
end