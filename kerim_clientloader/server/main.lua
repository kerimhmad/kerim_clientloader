CreateThread(function()
    local version = GetResourceMetadata(GetCurrentResourceName(), "version")

    printGreen(string.format("Script ^3v%s ^0successfully loaded.", version))

    PerformHttpRequest("https://raw.githubusercontent.com/kerimhmad/kerim_clientloader/main/version.txt", function(error, newVersion, headers)
        version = version:gsub("%s+", "")
        newVersion = newVersion:gsub("%s+", "")

        if newVersion ~= version then
            printYellow(string.format("You are using an outdated version. ^1%s ^0> ^2%s", version, newVersion))
        end
    end)
end)