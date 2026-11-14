-- Data/commands.lua
-- Format: { name = "cmd", desc = "deskripsi", cat = "kategori" }
-- cat membantu untuk filter tab kategori nanti

return {
    -- Movement
    { name = "fly",        desc = "Aktifkan mode terbang",                 cat = "Movement" },
    { name = "unfly",      desc = "Matikan mode terbang",                  cat = "Movement" },
    { name = "noclip",     desc = "Tembus objek",                          cat = "Movement" },
    { name = "speed",      desc = "Atur kecepatan. Contoh: speed 100",     cat = "Movement" },
    { name = "jump",       desc = "Atur tinggi lompat. Contoh: jump 100",  cat = "Movement" },
    { name = "hipheight",  desc = "Atur HipHeight karakter",               cat = "Movement" },
    { name = "infjump",    desc = "Lompat tanpa batas",                    cat = "Movement" },
    { name = "nojumpcooldown", desc = "Hilangkan cooldown lompat",         cat = "Movement" },

    -- Combat
    { name = "god",        desc = "Mode kebal (server-side mungkin tidak berlaku)", cat = "Combat" },
    { name = "heal",       desc = "Isi penuh HP karakter",                 cat = "Combat" },
    { name = "kill",       desc = "Bunuh pemain. Contoh: kill all",        cat = "Combat" },
    { name = "loopkill",   desc = "Loop kill target",                      cat = "Combat" },
    { name = "freeze",     desc = "Bekukan pemain. Contoh: freeze all",    cat = "Combat" },
    { name = "thaw",       desc = "Cairkan pemain yang dibekukan",         cat = "Combat" },

    -- Teleport
    { name = "goto",       desc = "Teleport ke pemain. Contoh: goto Bob",  cat = "Teleport" },
    { name = "bring",      desc = "Tarik pemain ke kamu. Contoh: bring all", cat = "Teleport" },
    { name = "tp",         desc = "Alias goto",                            cat = "Teleport" },
    { name = "loopbring",  desc = "Loop tarik pemain",                     cat = "Teleport" },

    -- Visual
    { name = "esp",        desc = "Lihat posisi pemain lewat tembok",      cat = "Visual" },
    { name = "fog",        desc = "Atur kabut. Contoh: fog 100",           cat = "Visual" },
    { name = "skybox",     desc = "Ganti skybox",                          cat = "Visual" },
    { name = "day",        desc = "Atur ke siang",                         cat = "Visual" },
    { name = "night",      desc = "Atur ke malam",                         cat = "Visual" },

    -- Utility
    { name = "rejoin",     desc = "Keluar dan masuk server yang sama",     cat = "Utility" },
    { name = "serverhop",  desc = "Pindah ke server lain",                 cat = "Utility" },
    { name = "antiafk",    desc = "Cegah kick karena AFK",                 cat = "Utility" },
    { name = "btools",     desc = "Beri Building Tools",                   cat = "Utility" },
    { name = "help",       desc = "Tampilkan bantuan IY",                  cat = "Utility" },
    { name = "cmds",       desc = "List semua command IY asli",            cat = "Utility" },
}