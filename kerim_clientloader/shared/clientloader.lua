local Kerim = {}

Kerim.ResourceName = GetCurrentResourceName()
Kerim.MetadataString = "kerim_client_script"

Kerim.ClientFilesLoaded = false

Kerim.Events = {
    Server = string.format("%s:requestFromServer", Kerim.ResourceName),
    Client = string.format("%s:sendToClient", Kerim.ResourceName),

    Loaded = string.format("%s:clientLoaded", Kerim.ResourceName)
}

Kerim.Encrypt = function(value, cryptKey)
    local output = {}

    for i=1, #value do
        local subString = string.sub(value, i, i)

        table.insert(output, string.byte(tostring(subString)) * cryptKey)
    end

    return output
end

Kerim.Decrypt = function(value, cryptKey)
    local output = ""

    for i=1, #value do
        local item = value[i]

        output = output .. string.char(math.floor(item / cryptKey))
    end

    return output
end

if GetNumResourceMetadata(Kerim.ResourceName, Kerim.MetadataString) > 0 then
    if IsDuplicityVersion() then
        Kerim.LoadedPlayers = {}
        Kerim.LoadedClientFiles = {}

        RegisterNetEvent(Kerim.Events.Server, function()
            while not Kerim.ClientFilesLoaded do Wait(1000) end

            if Kerim.LoadedPlayers[source] == nil then
                Kerim.LoadedPlayers[source] = false
            end

            if not Kerim.LoadedPlayers[source] then
                Kerim.LoadedPlayers[source] = true

                TriggerClientEvent(Kerim.Events.Client, source, Kerim.LoadedClientFiles)
                --< You can ignore that! (just note for me) TriggerLatentClientEvent(Kerim.Events.Client, source, 120*1000 Kerim.LoadedClientFiles) >--
            end
        end)

        CreateThread(function()
            for i=0, #tostring(GetNumResourceMetadata(Kerim.ResourceName, Kerim.MetadataString)) do
                local fileName = GetResourceMetadata(Kerim.ResourceName, Kerim.MetadataString, i)

                if fileName ~= nil then
                    local clientFile = (LoadResourceFile(Kerim.ResourceName, fileName) or nil)

                    local cryptKey = math.random(0xdeadbea7)

                    if clientFile ~= nil then
                        printGreen(string.format("Added ^3%s ^0file to table.", fileName))

                        table.insert(Kerim.LoadedClientFiles, { name = fileName, code = Kerim.Encrypt(clientFile, cryptKey), cryptKey = cryptKey })
                    elseif clientFile == nil then
                        printRed(string.format("An error ^1(1) ^0occurred while loading ^3%s^0!", fileName))
                    else
                        printRed(string.format("An error ^1(2) ^0occurred while loading ^3%s^0!", fileName))
                    end
                end
            end

            Kerim.ClientFilesLoaded = true
        end)
    elseif not IsDuplicityVersion() then
        TriggerServerEvent(Kerim.Events.Server)

        CreateThread(function()
            while true do
                Wait(0)

                if Kerim.ClientFilesLoaded then break end

                if not Kerim.ClientFilesLoaded then
                    TriggerServerEvent(Kerim.Events.Server)
                end

                Wait(5000)
            end
        end)

        RegisterNetEvent(Kerim.Events.Client, function(clientFiles)
            for k, v in ipairs(clientFiles) do
                local fileLoaded = pcall(load(Kerim.Decrypt(v.code, v.cryptKey), v.name, "bt"))

                if not fileLoaded then
                    printRed(string.format("An error occurred while loading ^3%s^0!", v.name))
                end
            end

            TriggerEvent(Kerim.Events.Loaded)

            Kerim.ClientFilesLoaded = true
        end)
    end
end

function printYellow(message)
    print(string.format("^3(!) ^0%s^0", message))
end

function printGreen(message)
    print(string.format("^2(!) ^0%s^0", message))
end

function printRed(message)
    print(string.format("^1(!) ^0%s^0", message))
end
