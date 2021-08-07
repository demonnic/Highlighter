local category = matches[2]
if Highlighter.categories[category] then
  Highlighter:displayCategory(category)
else
  Highlighter:echo(f"Could not find category {category} to display")
end