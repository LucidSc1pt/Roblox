# Ether Internal Executor

This is **not** an real executor, because it depends on your executor performance.

## Load Script
```luau
loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/LucidSc1pt/Roblox/main/ether-executor/loader.lua"
))()
```

## Features
- Script Search: Search script to API provider like [ScriptBlox](https://scriptblox.com), [HaxHell](https://haxhell.com), [Roblox Scripts](https://robloxscripts.com), and [RS Script](https://rscripts.net). Will add more provider soon.
- Code Editor: You can write code in here and execute it, has tabs editor, works well for mobile.
- Script Hub: You can add your script to save it locally on your executor workspace.
- Save the script source in your local executor workspace.

> Important: Your executor must have **writefile and readfile** function or the saving function will not work.

 ## Folder Structure
 ```
 ether-executor/
 ├── loader.lua
 └── src/
     ├── core/
     │ ├── init.lua (EtherLibrary, Settings, Config)
     │ ├── services.lua (game:GetService, TweenService, etc)
     │ ├── ui_helper.lua (Create, protect_gui, MakeDraggable)
     │ ├── highlighter.lua (highlighter syntax)
     │ ├── image_cache.lua (resolve image)
     │ ├── hub_api.lua (Class AdvancedHub)
     │ └── finalize.lua (build ui)
     ├── tabs/
     │ ├── editor.lua (TabReuse + Code Tab)
     │ ├── search.lua (Search UI & Logic)
     │ ├── saved.lua (Saved UI & Logic)
     │ ├── info.lua (Info Tab)
     │ └── settings.lua (Settings Tab)
     └── features/
         ├── clock.lua (Header Clock)
         └── toggle.lua (Floating Toggle Button)
 ```

Vibecoded project with DeepSeek.

# License
Open Source.
Free to use and modify whatever you want.