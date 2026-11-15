I'm really bored, and I've got an idea to try building an internal script executor.  It's just for fun.  This script is an "AI vibecode" project with DeepSeek.

# Load Script
```luau
loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/LucidSc1pt/Roblox/main/ether-executor/loader.lua"
))()
```

 # FOLDER STRUCTURE
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


# License
Open Source.
Free to use and modify whatever you want.