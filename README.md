# wallpaper_manager.wezterm

A small WezTerm plugin that sets and rotates background images in your terminal. It scans a folder of images, can auto-rotate on a timer, and optionally exposes actions you can bind to keys.

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

## Configuration (optional)

You can tweak opacity, brightness, saturation, hue, alignment, repeat, background color, and size modes.

## Key Bindings (optional)

If you want key-based control, bind the provided actions. Example:

```lua

local wezterm = require 'wezterm'
local wallpaper = wezterm.plugin.require('https://github.com/jproberson/wallpaper_manager.wezterm')

local config = {}

local opts = {
  image_directory = wezterm.config_dir .. '/images',
  auto_rotate_interval = 300,
  rotate_mode = 'random',
}

wallpaper.enable_defaults(config, opts)

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

return config
```
