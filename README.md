# wallpaper_manager.wezterm

A WezTerm plugin that sets and rotates background images in your terminal. It scans a folder of images, can auto-rotate on a timer, and provides actions you can bind to keys.

## Install

- Using the plugin manager:
  - `local wallpaper = wezterm.plugin.require("https://github.com/jproberson/wallpaper_manager.wezterm")`
- Place images in `~/.config/wezterm/images` (default) or set another folder.

## Quick Start

Add this to your `wezterm.lua`:

```lua
local wezterm = require 'wezterm'
local wallpaper = wezterm.plugin.require('https://github.com/jproberson/wallpaper_manager.wezterm')

local config = {}

local opts = {
  image_directory = wezterm.config_dir .. '/images', -- change if you like
  auto_rotate_interval = 300,                        -- seconds; set 0 to disable
  rotate_mode = 'random',                            -- or 'sequential'
}

wallpaper.enable_defaults(config, opts)

return config
```

## Text Clarity

For good text readability with background images, these are the main settings to experiment with:

```lua
local opts = {
  opacity = 0.15,      -- lower = more subtle, higher = more visible image
  brightness = 0.8,    -- adjust image brightness (0.0 to 1.0)
  saturation = 1.0,    -- reduce if images are too colorful
}
```

Start with the defaults and adjust based on your images and preferences.

## Configuration (optional)

You can customize opacity, brightness, saturation, hue, alignment, repeat behavior, background color, and size modes.

## All Configuration Options

Here are all the available settings with their defaults:

```lua
local opts = {
  image_directory = wezterm.config_dir .. '/images',
  opacity = 0.15,
  brightness = 0.8,
  saturation = 1.0,
  hue = 1.0,
  horizontal_align = 'Center',      -- Left, Center, Right
  vertical_align = 'Middle',        -- Top, Middle, Bottom  
  attachment = 'Fixed',
  repeat_x = 'NoRepeat',
  repeat_y = 'NoRepeat',
  refresh_interval = 60,            -- seconds between directory scans
  auto_rotate_interval = 300,       -- seconds between rotations (0 = disabled)
  rotate_mode = 'random',           -- 'random' or 'sequential'
  background_color = nil,           -- optional solid color behind image (this will default to the standard wezterm color)
  available_size_modes = {'Contain', 'Cover', '75%', '100%', '125%', '150%'},
}
```

## Key Bindings (optional)

These are the actions that are currently supported feel free to change the keys:

```lua
local wm = wallpaper.actions(opts)
config.keys = {
  { key = ']', mods = 'ALT',        action = wm.select_next_image },
  { key = '[', mods = 'ALT',        action = wm.select_previous_image },
  { key = 'r', mods = 'ALT',        action = wm.select_random_image },
  { key = 'b', mods = 'ALT',        action = wm.toggle_background_display },
  { key = '=', mods = 'ALT',        action = wm.increase_image_size },
  { key = '-', mods = 'ALT',        action = wm.decrease_image_size },
  { key = '0', mods = 'ALT',        action = wm.cycle_image_size_modes },
  { key = 'R', mods = 'ALT|SHIFT',  action = wm.reload_image_directory },
}
```
