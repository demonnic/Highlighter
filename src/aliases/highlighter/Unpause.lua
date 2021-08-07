if matches[2] then
  if matches[2]:starts(" ") then
    matches[2] = matches[2]:sub(2,-1)
  end
  if Highlighter.categories[matches[2]] then
    Highlighter:unpause(matches[2])
    Highlighter:echo(f"category {matches[2]} unpaused")
  else
    Highlighter:echo(f"Could not find category {matches[2]} to unpause.")
  end
  return
end
Highlighter:unpauseAll()
Highlighter:echo("All categories unpaused")