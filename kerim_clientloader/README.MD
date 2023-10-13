# Clientloader by kerim.52

## Usage
Remeber you can't use ***.lua** or something like that in your **fxmanifest** or 
**__resource** anymore!
- Drag and Drop **kerim_clientloader** (Never Rename)
- Change **client_scripts** to **kerim_client_scripts** (fxmanifest/__resource)
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

kerim_client_scripts {
    "config.lua",
    "client.lua",
}
```

| Original | Protected | Description |
| ------------- | ------------- | ------------- |
| client_script | kerim_client_script | Can't be dumped ✅|
| client_scripts | kerim_client_scripts | Can't be dumped ✅|

(remember this script is still in **BETA** , report problems to kerim)
