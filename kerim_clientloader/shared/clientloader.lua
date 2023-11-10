local Kerim = {}

Kerim.ResourceName = GetCurrentResourceName()
Kerim.MetadataString = "kerim_clientloader"

Kerim.NumResourceMetadata = GetNumResourceMetadata(Kerim.ResourceName, Kerim.MetadataString)

Kerim.ClientFilesLoaded = false

Kerim.Events = {
    Server = {
        requestFromServer = string.format("%s:requestFromServer", Kerim.ResourceName)
    },
    Client = {
        sendToClient = string.format("%s:sendToClient", Kerim.ResourceName),
        clientLoaded = string.format("%s:clientLoaded", Kerim.ResourceName)
    }
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

local _exports = exports

if Kerim.NumResourceMetadata > 0 then
    if IsDuplicityVersion() then
        Kerim.LoadedPlayers = {}
        Kerim.LoadedClientFiles = {}

        RegisterNetEvent(Kerim.Events.Server.requestFromServer, function()
            while not Kerim.ClientFilesLoaded do Wait(1000) end

            if Kerim.LoadedPlayers[source] == nil then
                Kerim.LoadedPlayers[source] = false
            end

            if not Kerim.LoadedPlayers[source] then
                Kerim.LoadedPlayers[source] = true

                TriggerClientEvent(Kerim.Events.Client.sendToClient, source, Kerim.LoadedClientFiles)
            end
        end)

        CreateThread(function()
            for i=0, Kerim.NumResourceMetadata do
                local fileName = GetResourceMetadata(Kerim.ResourceName, Kerim.MetadataString, i)

                if fileName ~= nil and not alreadyInTable(Kerim.LoadedClientFiles, fileName) then
                    local clientFile = (LoadResourceFile(Kerim.ResourceName, fileName) or nil)

                    if clientFile ~= nil then
                        local cryptKey = math.random(0xdeadbea7)

                        table.insert(Kerim.LoadedClientFiles, { fileName = fileName, fileCode = Kerim.Encrypt(clientFile, cryptKey), cryptKey = cryptKey })

                        printGreen(("Added ^3%s ^0file to table."):format(fileName))
                    elseif clientFile == nil then
                        printRed(("An error ^1(1) ^0occurred while loading ^3%s^0!"):format(fileName))
                    else
                        printRed(("An error ^1(2) ^0occurred while loading ^3%s^0!"):format(fileName))
                    end
                end
            end

            Kerim.ClientFilesLoaded = true
        end)
    elseif not IsDuplicityVersion() then
        Kerim.ClientFilesLoading = false

        CreateThread(function()
            while true do
                Wait(0)

                if Kerim.ClientFilesLoaded then break end

                TriggerServerEvent(Kerim.Events.Server.requestFromServer)

                Wait(2500)
            end
        end)

        RegisterNetEvent(Kerim.Events.Client.sendToClient, function(clientFiles)
            if GetInvokingResource() ~= nil or Kerim.ClientFilesLoading or Kerim.ClientFilesLoaded then return end

            Kerim.ClientFilesLoading = true

            for k, data in ipairs(clientFiles) do
                local fileLoaded = pcall(load(Kerim.Decrypt(data.fileCode, data.cryptKey), data.fileName, "bt"))

                if not fileLoaded then
                    printRed(("An error occurred while loading ^3%s^0!"):format(data.fileName))
                end
            end

            TriggerEvent(Kerim.Events.Client.clientLoaded)

            Kerim.ClientFilesLoaded = true
            Kerim.ClientFilesLoading = false
        end)

        exports = _exports
    end
end

function alreadyInTable(table, fileName)
    for k, v in ipairs(table) do
        if v.name == fileName then
            return true
        end
    end

    return false
end

function printYellow(message)
    print(("^3(!) ^0%s^0"):format(message))
end

function printGreen(message)
    print(("^2(!) ^0%s^0"):format(message))
end

function printRed(message)
    print(("^1(!) ^0%s^0"):format(message))
end