# InfiniteYieldPlus

UI alternatif untuk [Infinite Yield](https://github.com/EdgeIY/infiniteyield),
dirancang khusus untuk **mobile dan PC**, dengan fitur pencarian command dan
sistem simpan-favorit, tanpa perlu fork source IY.

## ✨ Fitur
- Tata letak responsif — otomatis menyesuaikan mode HP/tablet vs desktop
- 🔍 Pencarian command realtime
- Tab kategori (Movement, Combat, Teleport, Visual, Utility)
- Tombol **Run** dan **Save** di setiap command
- Daftar favorit tersimpan lintas sesi (jika executor mendukung `writefile`)

## 📦 Instalasi

1. Pastikan **Infinite Yield** sudah dijalankan lebih dulu.
2. Jalankan `dist/InfiniteYieldPlus.lua` via executor, contoh:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/<user>/InfiniteYieldPlus/main/dist/InfiniteYieldPlus.lua"))()
```

# Structure Folder
```
InfiniteYieldPlus/
├── README.md                  → cara install, screenshot, roadmap
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
│       └── commands.lua        → data mentah command (nama + desc + kategori)
└── dist/
    └── InfiniteYieldPlus.lua   → build single-file untuk loadstring
```