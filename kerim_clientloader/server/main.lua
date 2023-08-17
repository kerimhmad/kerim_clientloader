if GetCurrentResourceName() ~= "kerim_clientloader" then
    print("^1(!) You do not have permission to rename the script!^0")
elseif GetCurrentResourceName() == "kerim_clientloader" then
    local current_version = GetResourceMetadata(GetCurrentResourceName(), "version")

    print(string.format("^2(!) ^0Script ^3v%s ^0successfully loaded.", current_version))

    PerformHttpRequest("https://raw.githubusercontent.com/kerimhmad/kerim_clientloader/main/version.txt", function(error, newest_version, headers)
        if newest_version ~= nil then
            if newest_version:gsub("%s+", "") ~= current_version:gsub("%s+", "") then
                print(string.format("^3(!) ^0You are using an outdated version. ^1%s ^0> ^2%s^0", current_version:gsub("%s+", ""), newest_version:gsub("%s+", "")))
            end
        end
    end)
end