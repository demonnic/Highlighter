local msg = [[
  <0,255,255>*<r> `hl cat list`
  <0,255,255>*<r> Displays a list of the categories you have configured.
<0,255,255>*<r> `hl cat add <Category#options>`
  <0,255,255>*<r> this is the alias you use to add categories to the Highlighter.
  <0,255,255>*<r> category is the name of the category. Can contain spaces.
  <0,255,255>*<r> options is a comma separated list of options and their values.
    <0,255,255>*<r> `fg = "#ff0000", bold = true`
    <0,255,255>*<r> Available options
      <0,255,255>*<r> fg]]
local cechomsg = [[        <cyan>*<reset> the color to make the text. Can be specified as a color name ("red"), decho style ("<255,0,0>"), or hecho style ("#ff0000")]]
local msg2 = [[
        <0,255,255>*<r> defaults to false (uncolored)
      <0,255,255>*<r> bg
        <0,255,255>*<r> the same as fg, but the background of the text.
        <0,255,255>*<r> defaults to false (uncolored)
      <0,255,255>*<r> bold
        <0,255,255>*<r> if true, highlight is bold. If false then highlight is unbolded if originally bold.
        <0,255,255>*<r> defaults to false
      <0,255,255>*<r> italics
        <0,255,255>*<r> if true, item will be italicized. If false it will not be
        <0,255,255>*<r> defaults to false
      <0,255,255>*<r> underline
        <0,255,255>*<r> if true, item will be underlined. If false it will not be
        <0,255,255>*<r> defaults to false
      <0,255,255>*<r> paused
        <0,255,255>*<r> if true, items in this category will not actually be highlighted, but will still be tracked
        <0,255,255>*<r> defaults to false
  <0,255,255>*<r> Examples:
    <0,255,255>*<r> `hl cat add enemy#fg = "red", bold = true`
    <0,255,255>*<r> `hl cat add quest items#italics = true`
<0,255,255>*<r> `hl item add <Category#Item>`
  <0,255,255>*<r> used to add a highlight item
  <0,255,255>*<r> to move an item from one category to another, simply add it to the new category
  <0,255,255>*<r> both category and item may contain spaces.
  <0,255,255>*<r> Examples
    <0,255,255>*<r> `hl item add enemy#Bob`
    <0,255,255>*<r> `hl item add quest items#a purple crystal`
<0,255,255>*<r> `hl item remove <item>`
  <0,255,255>*<r> used to remove an item from the highlighter
  <0,255,255>*<r> an item can only belong to one category at a time, so category needn't be specified.
<0,255,255>*<r> `hl cat display <category>`
  <0,255,255>*<r> displays the configuration and items for the given category.
<0,255,255>*<r> `hl cat remove <category>`
  <0,255,255>*<r> removes a category from the highlighter, including all of its items
  <0,255,255>*<r> use with caution
<0,255,255>*<r> `hl cat clear <category>`
  <0,255,255>*<r> removes all of the items from a category, but leaves the category and configuration in place.
  <0,255,255>*<r> use with caution
<0,255,255>*<r> `hl cat update <category#config>`
  <0,255,255>*<r> just like `hl cat add` but updates the config of an existing category
  <0,255,255>*<r> Does not <b>replace</b> the config, but updates any item included, so if it has a fg and you only pass in `bold = true` for the options then it will have both bold and the fg which was set
  <0,255,255>*<r> Examples
    <0,255,255>*<r> `hl cat update enemy#bold = true`
    <0,255,255>*<r> `hl cat update riders of the bleeding eyeball#italics = false, bg = "red", fg = "yellow"`
<0,255,255>*<r> `hl save`
  <0,255,255>*<r> saves your highlighter configs and items to disk
  <0,255,255>*<r> automatically done when you close the profile or uninstall the package
<0,255,255>*<r> `hl load`
  <0,255,255>*<r> loads your highlighter info from disk.
  <0,255,255>*<r> automatically done when you load the profile or reinstall the package.
<0,255,255>*<r> `hl pause <category>`
  <0,255,255>*<r> pauses that specific category
<0,255,255>*<r> `hl pause`
  <0,255,255>*<r> pauses all categories
<0,255,255>*<r> `hl unpause <category>`
  <0,255,255>*<r> unpauses that specific category
<0,255,255>*<r> `hl unpause`
  <0,255,255>*<r> unpauses all categories
  ]]
Highlighter:echo(f"Available aliases and their usage:\n{msg}")
cecho(cechomsg)
decho(msg2)