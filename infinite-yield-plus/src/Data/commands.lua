return {
    -- Movement
    { name = "fly", desc = "Aktifkan mode terbang", cat = "Movement",
      args = { { key = "speed", placeholder = "default", default = "" } } },
    { name = "unfly", desc = "Matikan mode terbang", cat = "Movement" },
    { name = "noclip", desc = "Tembus objek", cat = "Movement" },
    { name = "speed", desc = "Atur kecepatan", cat = "Movement",
      args = { { key = "value", placeholder = "16", default = "16" } } },
    { name = "jump", desc = "Atur tinggi lompat", cat = "Movement",
      args = { { key = "power", placeholder = "50", default = "50" } } },
    { name = "hipheight", desc = "Atur HipHeight", cat = "Movement",
      args = { { key = "value", placeholder = "0", default = "0" } } },
    { name = "infjump", desc = "Lompat tanpa batas", cat = "Movement" },

    -- Combat
    { name = "god", desc = "Mode kebal", cat = "Combat" },
    { name = "heal", desc = "Isi penuh HP", cat = "Combat" },
    { name = "kill", desc = "Bunuh pemain", cat = "Combat",
      args = { { key = "player", placeholder = "all", default = "all" } } },
    { name = "loopkill", desc = "Loop kill target", cat = "Combat",
      args = { { key = "player", placeholder = "all", default = "all" } } },
    { name = "freeze", desc = "Bekukan pemain", cat = "Combat",
      args = { { key = "player", placeholder = "all", default = "all" } } },
    { name = "thaw", desc = "Cairkan pemain", cat = "Combat",
      args = { { key = "player", placeholder = "all", default = "all" } } },

    -- Teleport
    { name = "goto", desc = "Teleport ke pemain", cat = "Teleport",
      args = { { key = "player", placeholder = "username" } } },
    { name = "bring", desc = "Tarik pemain ke kamu", cat = "Teleport",
      args = { { key = "player", placeholder = "all", default = "all" } } },
    { name = "tp", desc = "Alias goto", cat = "Teleport",
      args = { { key = "player", placeholder = "username" } } },
    { name = "loopbring", desc = "Loop tarik pemain", cat = "Teleport",
      args = { { key = "player", placeholder = "username" } } },
    { name = "tppos", desc = "Teleport ke koordinat", cat = "Teleport",
      args = {
        { key = "x", placeholder = "0", default = "0" },
        { key = "y", placeholder = "0", default = "0" },
        { key = "z", placeholder = "0", default = "0" },
      } },

    -- Visual
    { name = "esp", desc = "Lihat posisi pemain", cat = "Visual" },
    { name = "fog", desc = "Atur kabut", cat = "Visual",
      args = { { key = "value", placeholder = "100", default = "100" } } },
    { name = "brightness", desc = "Atur brightness", cat = "Visual",
      args = { { key = "value", placeholder = "2", default = "2" } } },
    { name = "day", desc = "Atur ke siang", cat = "Visual" },
    { name = "night", desc = "Atur ke malam", cat = "Visual" },

    -- Utility
    { name = "rejoin", desc = "Keluar dan masuk server sama", cat = "Utility" },
    { name = "serverhop", desc = "Pindah ke server lain", cat = "Utility" },
    { name = "antiafk", desc = "Cegah kick karena AFK", cat = "Utility" },
    { name = "btools", desc = "Beri Building Tools", cat = "Utility" },
    { name = "notify", desc = "Kirim notifikasi", cat = "Utility",
      args = { { key = "text", placeholder = "Pesan..." } } },
    { name = "chat", desc = "Kirim chat", cat = "Utility",
      args = { { key = "text", placeholder = "Pesan..." } } },
    { name = "help", desc = "Tampilkan bantuan IY", cat = "Utility" },
    { name = "cmds", desc = "List semua command IY", cat = "Utility" },
}