# Clientloader by Keriyem (discord.gg/gQeKYvDTQt)


what your fxmanifest.lua & resources.lua should look like:

# fxmanifest.lua
shared_script "@kerim_clientloader/resources.lua"
shared_script "@kerim_clientloader/shared/clientloader.lua"

lua54 "yes"

client_scripts {
    --"config.lua",
    --"client.lua",
}

# resources.lua
Resources = {
    ["testscript"] = { -- Resource Name
        "config.lua",
        "client.lua",
    },
}