if matches[2] then
  if matches[2]:starts(" ") then
    matches[2] = matches[2]:sub(2,-1)
  end
  if Highlighter.categories[matches[2]] then
    Highlighter:pause(matches[2])
    Highlighter:echo(f"Category {matches[2]} paused")
  else
    Highlighter:echo(f"Could not find category {matches[2]} to pause.")
  end
  return
end
Highlighter:pauseAll()
Highlighter:echo("All categories paused")