# QwenUILib
A modern, modular, and highly performant UI Library for Roblox Executors.

## Features
- **Global Search Bar**: Instantly filter elements in any tab.
- **Modular Architecture**: Clean separation of Core and Components.
- **Executor Safe**: Automatically handles `syn.protect_gui` and `gethui`.
- **Smooth Tweens**: High-quality animations using TweenService.

## How to Build
Since executors cannot natively `require` local folders, you must bundle the `src` folder into a single `.lua` file.
We recommend using **[DarkLua](https://github.com/seaofvoices/darklua)** or **Rojo**.

### DarkLua Bundling Command:
`darklua process src/init.lua build/bundle.lua`

Then, upload `build/bundle.lua` to your GitHub repository and use `loadstring(game:HttpGet("..."))()` in your scripts.
