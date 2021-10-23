Highlighter = Highlighter or {
  categories = {},
  triggerIDs = {},
  mouseIDs = {},
  items = {},
  items2category = {},
  header = "<0,255,255>(<255,255,0>Highlighter<0,255,255>)<r>:"
}
local selectString, setBold, setUnderline, setItalics, deselect, resetFormat, setFgColor, setBgColor = selectString, setBold, setUnderline, setItalics, deselect, resetFormat, setFgColor, setBgColor
local savefile = getMudletHomeDir() .. "/demonhighlighter.lua"

local defaultConfig = {
  fg = "red",
  bg = false,
  paused = false,
  bold = false,
  italics = false,
  underline = false,
}

function Highlighter:addCategory(categoryName, options)
  if self.categories[categoryName] then
    debugc(f"Highlighter:addCategory(name, options): {categoryName} category already exists, will not overwrite it.")
    return
  end
  options = options or {}
  local configType = type(options)
  local nameType = type(categoryName)
  assert(nameType == "string", "Highlighter:addCategory(name, options): name as string expected, got: " .. nameType)
  assert(configType == "table", "Highlighter:addCategory(name, options): options as table expected, got: " .. configType)
  local config = table.deepcopy(options)
  setmetatable(config, defaultConfig)
  defaultConfig.__index = defaultConfig
  if config.fg then
    local test = Geyser.Color.parse(config.fg)
    assert(test, "Highlighter:addCategory(name, options): options.fg specified but unable to be parse. Try a word from showColors() like 'red', R,G,B values like '<182,0,0>', or hex color codes like '#ff0000'")
  end
  if config.bg then
    local test = Geyser.Color.parse(config.bg)
    assert(test, "Highlighter:addCategory(name, options): options.bg specified but unable to be parse. Try a word from showColors() like 'red', R,G,B values like '<182,0,0>', or hex color codes like '#ff0000'")
  end
  self.categories[categoryName] = config
  self.items[categoryName] = {}
  self:save(true)
  self:addCategoryMenu(categoryName)
end

local function getSelectedText(event, menu, window, startCol, startRow, endCol, endRow)
  -- Check whether there's an actual selection
  if startCol == endCol and startRow == endRow then return "" end
  local parsed = ""
  -- Loop through each symbol within the range
  for lineNum = startRow, endRow do
    local cStart = lineNum == startRow and startCol or 0
    moveCursor(window, cStart, lineNum)
    local cEnd = lineNum == endRow and endCol or #getCurrentLine() - 1
    selectSection(window, cStart, cEnd - cStart + 1)
    parsed = parsed .. (getSelection(window) or "")
    if lineNum ~= endRow then parsed = parsed .. "\n" end
  end
  return parsed
end

function Highlighter:removeCategoryMenu(category)
  local menuItem = "Highlight as '" .. category .. "'"
  removeMouseEvent(menuItem)
  local id = self.mouseIDs[category]
  if id then
    killAnonymousEventHandler(id)
  end
  self.mouseIDs[category] = nil
end

function Highlighter:addCategoryMenu(category)
  self:removeCategoryMenu(category)
  local menuItem = "Highlight as '" .. category .. "'"
  local mouseEventName = "demonhiglighter" .. category
  addMouseEvent(menuItem, mouseEventName)
  local handler = function(...)
    local text = getSelectedText(...)
    if text == "" then return end
    self:add(text, category)
    self:echo("Added '" .. text .. "' to highlight category: " .. category)
  end
  self.mouseIDs[category] = registerAnonymousEventHandler(mouseEventName, handler)
end

function Highlighter:addAllMenuItems()
  for category,_ in spairs(self.categories) do
    self:addCategoryMenu(category)
  end
end

function Highlighter:removeAllMenuItems()
  for category,_ in pairs(self.categories) do
    self:removeCategoryMenu(category)
  end
end

function Highlighter:add(item, categoryName)
  local config = self.categories[categoryName]
  assert(config, f"Highlighter:add(item, category): Could not find a configuration for category '{categoryName}'")
  local itemString = type(item) == "string" and item or tostring(item)
  assert(itemString, f"Highlighter:add(item, category): item is expected to be a string, or coercable to a string using tostring, got {item}")
  self:remove(itemString)
  self.items[categoryName][itemString] = true
  self.items2category[itemString] = categoryName
  self:save(true)
  self:createItemTrigger(itemString)
end

function Highlighter:removeCategory(categoryName)
  local conf = self.categories[categoryName]
  if not conf then
    debugc(f"Highlighter:removeCategory(name): could not find category with name {categoryName} to remove")
    return
  end
  self:removeTriggers(categoryName)
  self:clearCategory(categoryName)
  self.categories[categoryName] = nil
  self.items[categoryName] = nil
  self:removeCategoryMenu(categoryName)
end

function Highlighter:pause(categoryName)
  local config = self.categories[categoryName]
  assert(config, f"Highlighter:pause(categoryName): selected category does not seem to exist. Did you create {categoryName} first?")
  config.paused = true
end

function Highlighter:pauseAll()
  for _, config in pairs(self.categories) do
    config.paused = true
  end
end

function Highlighter:unpause(categoryName)
  local config = self.categories[categoryName]
  assert(config, f"Highlighter:unpause(categoryName): selected category does not seem to exist. Did you create {categoryName} first?")
  config.paused = false
end

function Highlighter:unpauseAll()
  for _, config in pairs(self.categories) do
    config.paused = false
  end
end

function Highlighter:echo(msg)
  decho(f"{self.header} {msg}\n")
end

function Highlighter:displayCategory(categoryName)
  local config = self.categories[categoryName]
  local header = self.header
  if not config then
    self:echo(f"Could not find category {categoryName} to display")
    return
  end
  local items = table.concat(table.keys(self.items[categoryName]), ", ")
  self:echo(f"Configuration and highlight items for category {categoryName}")
  self:echo(f"bold     : {config.bold and 'true' or 'false'}")
  self:echo(f"italics  : {config.italics and 'true' or 'false'}")
  self:echo(f"underline: {config.underline and 'true' or 'false'}")
  self:echo(f"paused   : {config.paused and 'true' or 'false'}")
  self:echo(f"fg       : {config.fg and config.fg or 'false'}")
  self:echo(f"bg       : {config.bg and config.bg or 'false'}")
  local fg,bg = "",""
  if config.fg then
    local r,g,b = Geyser.Color.parse(config.fg)
    fg = f"{r},{g},{b}"
  end
  if config.bg then
    local r,g,b = Geyser.Color.parse(config.bg)
    bg = f":{r},{g},{b}"
  end
  local color = ""
  if fg ~= "" or bg ~= "" then
    color = f"<{fg}{bg}>"
  end
  local msg = color .. items
  if config.bold then
    msg = f"<b>{msg}</b>"
  end
  if config.italics then
    msg = f"<i>{msg}</i>"
  end
  if config.underline then
    msg = f"<u>{msg}</u>"
  end
  self:echo(f"Items:\n  {msg}")
end

function Highlighter:remove(item)
  local itemString = type(item) == "string" and item or tostring(item)
  assert(itemString, f"Highlighter:remove(item): item must be a string or coercable into one, got: {item}")
  self:removeItemTrigger(itemString)
  local oldCat = self.items2category[itemString]
  if oldCat then
    self.items[oldCat][itemString] = nil
  end
  self.items2category[itemString] = nil
end

function Highlighter:clearCategory(categoryName)
  local items = self.items[categoryName]
  assert(items, f"Highlighter:clearCategory(name): category {name} does not exist")
  for item,_ in pairs(table.deepcopy(items)) do
    self:remove(item)
  end
end

function Highlighter:clearAll(reallyReally)
  if not reallyReally then
    debugc("Highlighter:clearAll(reallyReally): reallyReally must be true, or else we don't know you really really mean it.")
    return
  end
  local catNames = table.keys(self.categories)
  for _, name in ipairs(catNames) do
    self:clearCategory(name)
  end
end

function Highlighter:load()
  if not io.exists(savefile) then
    debugc(f"Highlighter:load(): could not load save from file {savefile} because it does not exist. If this is a fresh install, the first of these is fine.")
    return
  end
  local conf = {}
  table.load(savefile, conf)
  self.categories = conf.categories
  for _,config in pairs(self.categories) do
    setmetatable(config, defaultConfig)
    defaultConfig.__index = defaultConfig
  end
  self.items = conf.items
  self.items2category = conf.items2category
  self:createAllTriggers()
  self:echo("Configuration loaded from disk")
end

function Highlighter:save(silent)
  local config = {}
  config.categories = self.categories
  config.items = self.items
  config.items2category = self.items2category
  table.save(savefile, config)
  if silent then return end
  self:echo("Configuration saved to disk")
end

function Highlighter:updateConfig(categoryName, option, value)
  local config = self.categories[categoryName]
  assert(config, f"Highlighter:updateConfig(name, option, [value]): category {categoryName} was not found")
  local optionType = type(option)
  if optionType ~= "table" then
    local validKeys = table.keys(defaultConfig)
    assert(table.contains(validKeys, option), f"Highlighter:updateConfig(name, option, [value]): option name passed in is invalid. Valid options are ({table.concat(validKeys, ',')}), got: {option}")
    if value == nil then
      debugc(f"Highlighter:updateConfig(name, option, value): value was passed as nil, resetting {option} to its default")
    end
    config[option] = value
    return
  end
  config = table.update(config, option)
  setmetatable(config, defaultConfig)
  defaultConfig.__index = defaultConfig
  self.categories[categoryName] = config
end

function Highlighter:createItemTrigger(item)
  self:removeItemTrigger(item)
  self.triggerIDs[item] = tempTrigger(item, function() self:highlight(item) end)
end
local function _color_name(rgb)
  local least_distance = math.huge
  local cname = ""
  for name, color in pairs(color_table) do
    local color_distance = math.sqrt((color[1] - rgb[1]) ^ 2 + (color[2] - rgb[2]) ^ 2 + (color[3] - rgb[3]) ^ 2)
    if color_distance < least_distance then
      least_distance = color_distance
      cname = name
    end
  end
  return cname
end

function Highlighter:dhighlight(text)
  return self:echoFormat(text, "d")
end

function Highlighter:hhighlight(text)
  return self:echoFormat(text, "h")
end

function Highlighter:chighlight(text)
  return self:echoFormat(text, "c")
end

function Highlighter:echoFormat(text, fmt)
  local patterns = {d = _Echos.Patterns.Decimal[1], c = _Echos.Patterns.Color[1], h = _Echos.Patterns.Hex[1]}
  local exceptions = {"<i>", "</i>", "<b>", "</b>", "<u>", "</u>"}
  local resetCodes = {d = "<r>", h = "#r", c = "<reset>"}
  local parse = Geyser.Color.parse
  local pattern = patterns[fmt]
  local reset = resetCodes[fmt]
  local result = ""
  local lastColor = reset
  local split = rex.split
  for str, color, res in split(text, pattern) do
    for cat, items in pairs(self.items) do
      local config = self.categories[cat]
      if not config.paused then
        local bold = config.bold
        local italics = config.italics
        local underline = config.underline
        local hl, hlcolor, fg, bg  = false, "", "", ""
        if config.fg then
          local r,g,b = parse(config.fg)
          hl = true
          if fmt == "d" then
            fg = string.format("%d,%d,%d",r,g,b)
          elseif fmt == "h" then
            fg = string.format("%02x%02x%02x",r,g,b)
          elseif fmt == "c" then
            fg = _color_name({r,g,b})
          end
        end
        if config.bg then
          local r,g,b = parse(config.bg)
          hl = true
          if fmt == "d" then
            bg = string.format(":%d,%d,%d",r,g,b)
          elseif fmt == "h" then
            bg = string.format(",%02x%02x%02x",r,g,b)
          elseif fmt == "c" then
            bg = ":" .. _color_name({r,g,b})
          end
        end
        if hl then
          if fmt == "d" or fmt == "c" then
            hlcolor = string.format("<%s%s>", fg, bg)
          elseif fmt == "h" then
            hlcolor = string.format("#%s%s", fg, bg)
          end
        end
        for name, _ in pairs(items) do
          local pat = "%f[%a]"..name.."%f[%A]"
          if str:find(pat) then
            local transformed = name
            if hl then
              transformed = hlcolor .. transformed .. lastColor
            end
            if bold then
              if fmt == "h" then
                transformed = "#b" .. transformed .. "#/b"
              else
                transformed = "<b>" .. transformed .. "</b>"
              end
            end
            if italics then
              if fmt == "h" then
                transformed = "#i" .. transformed .. "#/i"
              else
                transformed = "<i>" .. transformed .. "</i>"
              end
            end
            if underline then
              if fmt == "h" then
                transformed = "#u" .. transformed .. "#/u"
              else
                transformed = "<u>" .. transformed .. "</u>"
              end
            end
            str = str:gsub(pat, transformed)
          end
        end
      end
    end
    result = result .. str
    if color then
      if not table.contains(exceptions, color) then
        lastColor = color
      end
      result = result .. color
    end
    if res then
      if res == "r" or res == "<reset>" then
        lastColor = reset
        result = result .. reset
      else
        if fmt == "h" then
          result = result .. "#" .. res
        else
          result = result .. "<" .. res .. ">"
        end
      end
    end
  end
  return result
end

function Highlighter:highlight(item)
  local cat = self.items2category[item]
  local conf = self.categories[cat]
  local parse = Geyser.Color.parse
  if conf.paused then
    return
  end
  local fg,bg = false,false
  if conf.fg then
    local r,g,b = parse(conf.fg)
    fg = {r,g,b}
  end
  if conf.bg then
    local r,g,b = parse(conf.bg)
    bg = {r,g,b}
  end
  -- following loop logic retained from another NDB designed for Lusternia originally, though I've adjusted the highlighting a bit

  -- c counts the appearance of the substring of the word in the line, k counts the character position
  local c, k = 1, 1
  while k > 0 do
    k = line:find(item, k)
    if k == nil then return end
    c = c + 1

    if k == line:find("%f[%a]"..item.."%f[%A]", k) then
      if selectString(item, c-1) > -1 then
        if fg then setFgColor(unpack(fg)) end
        if bg then setBgColor(unpack(bg)) end
        setBold(conf.bold)
        setUnderline(conf.underline)
        setItalics(conf.italics)
        deselect()
        resetFormat()
      else return end
    end
    k = k + 1
  end
end

function Highlighter:createTriggers(categoryName)
  local items = self.items[categoryName]
  if not items then
    debugc(f"Highlighter:createTriggers(category): Category {categoryName} does not seem to exist")
    return
  end
  for item,_ in pairs(items) do
    self:createItemTrigger(item)
  end
end

function Highlighter:createAllTriggers()
  self:removeAllTriggers()
  for category,_ in pairs(self.categories) do
    self:createTriggers(category)
  end
end

function Highlighter:removeItemTrigger(item)
  local triggerID = self.triggerIDs[item]
  if triggerID then
    killTrigger(triggerID)
    self.triggerIDs[item] = nil
  end
end

function Highlighter:removeTriggers(categoryName)
  local items = self.items[categoryName]
  assert(items, f"Highlighter:removeTriggers(category): unable to find category {categoryName} to remove the triggers for it")
  for item, _ in pairs(items) do
    self:removeItemTrigger(item)
  end
end

function Highlighter:removeAllTriggers()
  for _,triggerID in pairs(self.triggerIDs) do
    killTrigger(triggerID)
  end
  self.triggerIDs = {}
end

function Highlighter:killEvents()
  if Highlighter.eventIDs then
    for _,id in pairs(Highlighter.eventIDs) do
      killAnonymousEventHandler(id)
    end
  end
  Highlighter.eventIDs = {}
end

Highlighter.eventIDs = Highlighter.eventIDs or {}
local function loadFunc(event, name)
  if event == "sysLoadEvent" or name == "@PKGNAME@" then
    Highlighter:load()
    Highlighter:addAllMenuItems()
  end
  if name == "@PKGNAME@" then
    Highlighter:echo("Highlighter installed, happy highlighting!")
  end
end

local function saveFunc(event, name)
  if event == "sysExitEvent" then
    Highlighter:save()
  elseif name == "@PKGNAME@" then
    Highlighter:save()
    Highlighter:removeAllTriggers()
    Highlighter:removeAllMenuItems()
    Highlighter:killEvents()
    Highlighter:echo("Highlighter uninstalled, but your configs are safe in case you change your mind")
    Highlighter = nil
  end
end

Highlighter:killEvents()
Highlighter.eventIDs[#Highlighter.eventIDs+1] = registerAnonymousEventHandler("sysLoadEvent", loadFunc)
Highlighter.eventIDs[#Highlighter.eventIDs+1] = registerAnonymousEventHandler("sysInstallPackage", loadFunc)
Highlighter.eventIDs[#Highlighter.eventIDs+1] = registerAnonymousEventHandler("sysInstallModule", loadFunc)
Highlighter.eventIDs[#Highlighter.eventIDs+1] = registerAnonymousEventHandler("sysExitEvent", saveFunc)
Highlighter.eventIDs[#Highlighter.eventIDs+1] = registerAnonymousEventHandler("sysUninstallPackage", saveFunc)
Highlighter.eventIDs[#Highlighter.eventIDs+1] = registerAnonymousEventHandler("sysUninstallModule", saveFunc)