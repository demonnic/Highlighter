# Highlighter

This package aims to be a game agnostic word/name highlighter. There are several different packages I've seen for this but they are all geared towards a specific game or lacked much in the way of configurability.

## Aliases

All aliases start with `hl`. Some of them get a little bit expressive, but the [API](#API) section will show you how to write your own shorter aliases. Since category names and items to be highlights both can contain spaces, I settled on using `#` as a separator for my aliases. If you need to highlight something with a `#` in it then the [API](#API) can help you out.

* `hl cat list`
  * Displays a list of the categories you have configured.
* `hl cat add <Category#options>`
  * this is the alias you use to add categories to the Highlighter.
  * category is the name of the category. Can contain spaces.
  * options is a comma separated list of options and their values.
    * `fg = "<127,0,0>", bold = true`
    * Available options
      * fg
        * the color to make the text. Can be specified as a color name ("red"), decho style ("<255,0,0>"), or hecho style ("#ff0000")
        * defaults to "red", set to false if you want fg uncolored
      * bg
        * the same as fg, but the background of the text.
        * defaults to false (uncolored)
      * bold
        * if true, highlight is bold. If false then highlight is unbolded if originally bold.
        * defaults to false
      * italics
        * if true, item will be italicized. If false it will not be
        * defaults to false
      * underline
        * if true, item will be underlined. If false it will not be
        * defaults to false
      * paused
        * if true, items in this category will not actually be highlighted, but will still be tracked
        * defaults to false
  * Examples:
    * `hl cat add enemy#fg = "red", bold = true`
    * `hl cat add quest items#italics = true`
* `hl item add <Category#Item>`
  * used to add a highlight item
  * to move an item from one category to another, simply add it to the new category
  * both category and item may contain spaces.
  * Examples
    * `hl item add enemy#Bob`
    * `hl item add quest items#a purple crystal`
* `hl item remove <item>`
  * used to remove an item from the highlighter
  * an item can only belong to one category at a time, so category needn't be specified.
* `hl cat display <category>`
  * displays the configuration and items for the given category.
* `hl cat remove <category>`
  * removes a category from the highlighter, including all of its items
  * use with caution
* `hl cat clear <category>`
  * removes all of the items from a category, but leaves the category and configuration in place.
  * use with caution
* `hl cat update <category#config>`
  * just like `hl cat add` but updates the config of an existing category
  * Does not **replace** the config, but updates any item included, so if it has a fg and you only pass in `bold = true` for the options then it will have both bold and the fg which was set
  * Examples
    * `hl cat update enemy#bold = true`
    * `hl cat update riders of the bleeding eyeball#italics = false, bg = "red", fg = "yellow"`
* `hl save`
  * saves your highlighter configs and items to disk
  * automatically done when you close the profile or uninstall the package
* `hl load`
  * loads your highlighter info from disk.
  * automatically done when you load the profile or reinstall the package.
* `hl pause <category>`
  * pauses the specific category
* `hl pause`
  * pauses all categories
* `hl unpause <category>`
  * unpauses the specific category
* `hl unpause`
  * unpauses all categories

## API

There are several functions you can make use of yourself for creating aliases or triggers that interact with the Highlighter.

* Highlighter:addCategory(name, options)
  * adds a category to the Highlighter
  * name must be a string, can contain spaces
  * options is a table of key/value options.
    * Available options
      * fg
        * the color to make the text. Can be specified as a color name ("red"), decho style ("<255,0,0>"), or hecho style ("#ff0000")
        * defaults to "red", set to false if you want fg uncolored
      * bg
        * the same as fg, but the background of the text.
        * defaults to false (uncolored)
      * bold
        * if true, highlight is bold. If false then highlight is unbolded if originally bold.
        * defaults to false
      * italics
        * if true, item will be italicized. If false it will not be
        * defaults to false
      * underline
        * if true, item will be underlined. If false it will not be
        * defaults to false
      * paused
        * if true, items in this category will not actually be highlighted, but will still be tracked
        * defaults to false
* Highlighter:add(item, category)
  * adds an item to the Highlighter under category
  * to change categories for an item, just add it using the new category.
  * item must be a string, may contain spaces
  * category must be a string and an existing Highlighter category
* Highlighter:removeCategory(name)
  * removes the named category from the Highlighter
  * use with caution
* Highlighter:pause(name)
  * pauses a specific category
* Highlighter:pauseAll()
  * pauses all categories
* Highlighter:unpause(name)
  * unpauses a specific category
* Highlighter:unpauseAll()
  * unpauses all categories
* Highlighter:remove(item)
  * removes the item from the Highlighter
  * Any given item can only be in one category, so that need not be specified
* Highlighter:clearCategory(name)
  * removes all items which belong to the named category
  * use with caution
* Highlighter:clearAll(reallyReally)
  * removes all items from the Highlighter
  * reallyReally must be true, to show you really mean it
  * use with caution
  * really really
* Highlighter:load(silent)
  * loads the configuration and items for the Highlighter from disk
  * if silent is true, then it will not echo to the main console
* Highlighter:save(silent)
  * saves the configuration and items for the Highlighter to disk
  * if silent is true, then it will not echo to the main console
* Highlighter:updateConfig(category, options)
  * options is a table of options for the highlighter.
  * options are **updated** not **replaced** so any options you do not specify in the options table will remain whatever they were before the update.
  * `Highlighter:updateConfig("enemy", {fg = false, bg = "red", italics = true})`
    * set text bg to red but fg unchanged from however it came in
    * also make it italics
    * in addition to whatever bold/underline options are already set
* Highlighter:updateConfig(category, option, value)
  * updates one specific option for category
  * `Highlighter:updateConfig("friend", "bg", "purple")` would set the bg to purple for the friend category