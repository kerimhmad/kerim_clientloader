# Clientloader by Kerim

## Usage
Remeber you can't use ***.lua** & **@resource** or something like that in your **fxmanifest** or 
**__resource** anymore!
- Drag and Drop **kerim_clientloader** (Never Rename)
- Change **client_scripts** to **kerim_clientloader** (fxmanifest/__resource)
- Reboot your FiveM Server


**fxmanifest.lua** (Before)
```LUA
client_scripts {
    "config.lua", 
    "client.lua",
}
```

**fxmanifest.lua** (After)
```LUA
shared_script "@kerim_clientloader/shared/clientloader.lua"

lua54 "yes"

kerim_clientloader {
    "config.lua",
    "client.lua",
}
```

(remember this script is still in **BETA**, report problems to Kerim)
