ExecuteCommand(("set tags \"kerim_clientloader, %s\""):format(GetConvar("tags", "no tags"))) -- do not remove, it is for statistics

AddEventHandler("onServerResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    local version = GetResourceMetadata(GetCurrentResourceName(), "version")

    printGreen(("Script ^3v%s ^0successfully loaded."):format(version))

    PerformHttpRequest("https://raw.githubusercontent.com/kerimhmad/kerim_clientloader/main/version.txt", function(error, newVersion, headers)
        version = version:gsub("%s+", "")
        newVersion = newVersion:gsub("%s+", "")

        if newVersion ~= version then
            printYellow(("You are using an outdated version. ^1%s ^0> ^2%s"):format(version, newVersion))
        end
    end)
end)
