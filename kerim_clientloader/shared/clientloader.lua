local Kerim = {}

Kerim.ResourceName = GetCurrentResourceName()
Kerim.MetadataString = "kerim_client_script"

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
        TriggerServerEvent(Kerim.Events.Server.requestFromServer)

        CreateThread(function()
            while true do
                Wait(0)

                if Kerim.ClientFilesLoaded then break end

                TriggerServerEvent(Kerim.Events.Server.requestFromServer)

                Wait(2500)
            end
        end)

        RegisterNetEvent(Kerim.Events.Client.sendToClient, function(clientFiles)
            if GetInvokingResource() ~= nil or Kerim.ClientFilesLoaded then return end

            for k, v in ipairs(clientFiles) do
                local fileLoaded = pcall(load(Kerim.Decrypt(v.code, v.cryptKey), v.name, "bt"))

                if not fileLoaded then
                    printRed(string.format("An error occurred while loading ^3%s^0!", v.name))
                end
            end

            TriggerEvent(Kerim.Events.Client.clientLoaded)

            Kerim.ClientFilesLoaded = true
        end)

        -- This will repair exports!
        local _exports = exports

        exports = _exports
        -- This will repair exports!
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
