# InfiniteYieldPlus

An alternative UI for [Infinite Yield](https://github.com/EdgeIY/infiniteyield),
designed specifically for **Mobile and PC**. It features command search
and a favorites system all without requiring a fork of the original IY source code.

## Features
- Responsive layout — automatically adapts between mobile/tablet and desktop modes
- 🔍 Real-time command search
- Category tabs (Movement, Combat, Teleport, Visual, Utility)
- **Run** and **Save** buttons for every command
- Favorites list persists across sessions (provided your executor supports `writefile`)

## Installation

1. Ensure **Infinite Yield** is already running.
2. Execute `dist/InfiniteYieldPlus.lua` via your executor, for example:

```luau
loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/LucidSc1pt/Roblox/main/infinite-yield-plus/dist/InfiniteYieldPlus.lua"
))()
```

# Folder Structure
```
InfiniteYieldPlus/
├── README.md                  → installation guide, screenshots, roadmap
├── src/
│   ├── init.lua
│   ├── Core/
│   │   ├── IYBridge.lua
│   │   ├── Registry.lua
│   │   └── Saved.lua
│   ├── UI/
│   │   ├── Theme.lua
│   │   ├── Layout.lua
│   │   ├── Builder.lua
│   │   ├── CommandRow.lua
│   │   └── TabBar.lua
│   └── Data/
│       └── commands.lua        → raw command data (name + description + category)
└── dist/
    └── InfiniteYieldPlus.lua   → single-file build for use with loadstring
```

# License
Open Source.
Free to use and modify whatever you want.