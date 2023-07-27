if GetResourceState("kerim_clientloader") == "started" then
    local self = {}
    
    local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    function self.enc(data)
        return ((data:gsub(".", function(x) 
            local r,b="",x:byte()
            for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and "1" or "0") end
            return r;
        end).."0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
            if (#x < 6) then return "" end
            local c=0
            for i=1,6 do c=c+(x:sub(i,i)=="1" and 2^(6-i) or 0) end
            return b:sub(c+1,c+1)
        end)..({ "", "==", "=" })[#data%3+1])
    end
    
    function self.dec(data)
        data = string.gsub(data, "[^"..b.."=]", "")
        return (data:gsub(".", function(x)
            if (x == "=") then return "" end
            local r,f="",(b:find(x)-1)
            for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and "1" or "0") end
            return r;
        end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
            if (#x ~= 8) then return "" end
            local c=0
            for i=1,8 do c=c+(x:sub(i,i)=="1" and 2^(8-i) or 0) end
            return string.char(c)
        end))
    end

    local resource_name = GetCurrentResourceName()
    local trigger_event = self.enc(string.format("clientloader-v1.0.5_%s", resource_name))

    if Resources[resource_name] ~= nil then
        if IsDuplicityVersion() then            
            local loaded_players = {}

            local client_files = {}

            for k, v in ipairs(Resources[resource_name]) do
                local client_file = (LoadResourceFile(resource_name, v) or nil)

                if client_file ~= nil then
                    print(string.format("^2(!) ^0Added ^3%s ^0file to table.", v))
                    
                    table.insert(client_files, { file = v, code = self.enc(client_file) })
                elseif client_file == nil then
                    print(string.format("^1(!) ^0An error occurred while loading ^3%s^0!", v))
                end
            end
    
            RegisterNetEvent(resource_name, function()
                if loaded_players[source] == nil then
                    loaded_players[source] = false
                end
    
                if not loaded_players[source] then
                    loaded_players[source] = true

                    TriggerClientEvent(trigger_event, source, client_files)
                elseif loaded_players[source] then
                    loaded_players[source] = false

                    DropPlayer(source, string.format("%s: Script Exploit detected!", resource_name))
                end
            end)
        elseif not IsDuplicityVersion() then
            Citizen.CreateThread(function()
                while not NetworkIsSessionStarted() do
                    Citizen.Wait(0)
                end

                Citizen.Wait(0)
            
                TriggerServerEvent(resource_name)
            end)
    
            RegisterNetEvent(trigger_event, function(client_files)
                local errors = {}

                local success_num = 0
                local errors_num = 0

                for k, v in ipairs(client_files) do
                    local client_loaded = pcall(load(self.dec(v.code)))

                    if client_loaded then
                        success_num = success_num +1
                    elseif not client_loaded then
                        errors_num = errors_num +1

                        table.insert(errors, v.file)
                    end
                end

                for k, v in ipairs(errors) do
                    print(string.format("^1(!) ^0An error occurred while loading ^3%s^0!", v))
                end

                if success_num > 0 then
                    print(string.format("^2(!) ^0Script loaded successfully. (%s/%s)", success_num, success_num + errors_num))
                end
            end)
        end
    end
end