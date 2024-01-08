local QBCore = exports['qb-core']:GetCoreObject()
local Working = {}
local Vehicles = {}

-- Set Duty

RegisterNetEvent('pengu_gruppe6delivery:RecievePaycheck', function(TotalBags, TotalOrganized)
    local Player = QBCore.Functions.GetPlayer(source)
    local Amount = 0
    for i=1, TotalBags do
        Amount = Amount + math.random(Config.MoneyPerBagMin,Config.MoneyPerBagMax)
    end
    for i=1, TotalOrganized do
        Amount = Amount + math.random(Config.MoneyPerOrganizedMin,Config.MoneyPerOrganizedMax)
    end
    Player.Functions.AddMoney(Config.MoneyType, Amount, "Gruppe 6 Deliveries")
    TriggerClientEvent('pengu_gruppe6delivery:Notify', source, "You've recieved $"..Amount.." from Gruppe 6!", nil, "primary", 4000)
end)


RegisterNetEvent('pengu_gruppe6delivery:ToggleIsOnDuty', function()
    if Working[source] then
        Working[source] = false
        if Vehicles[source] then
            TriggerEvent('pengu_gruppe6delivery:DeleteVehicle', source)
        end
        TriggerClientEvent('pengu_gruppe6delivery:StopDeliveries', source)
        Working[source] = nil
    else
        Working[source] = true
    end
end)

RegisterNetEvent('pengu_gruppe6delivery:StartFirstDelivery', function()
    TriggerEvent('pengu_gruppe6delivery:SpawnVehicle', source)
end)


-- Callbacks

QBCore.Functions.CreateCallback('pengu_gruppe6delivery:GetIsOnDuty', function(source, cb)
    if Working[source] then
        cb(true)
    else
        cb(false)
    end
end)

if Config.Target == 'ox' then
lib.callback.register("pengu_gruppe6delivery:GetIsOnDuty", function(duty)
    if Working[source] then
        return true
    else
        return false
    end
end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for i,v in pairs(Vehicles) do
            DeleteEntity(v)
        end
    end
end)

RegisterNetEvent('pengu_gruppe6delivery:DeleteVehicle', function(data)
    local source = source or data
    if Vehicles[source] then
        DeleteEntity(Vehicles[source])
        Vehicles[source] = nil    
    end
end)


RegisterNetEvent('pengu_gruppe6delivery:SpawnVehicle', function()
    local vec = Config.VehicleSpawns[math.random(1, #Config.VehicleSpawns)]
    local model = Config.Vehicle
    local plate = "GRUP"..source
    TriggerClientEvent('pengu_gruppe6delivery:RequestModel', source, model)
    Vehicles[source] = CreateVehicle(model, vec, true, false)
    SetVehicleNumberPlateText(Vehicles[source], plate)
    TriggerClientEvent('pengu_gruppe6delivery:StartFirstJob', source, {["vec"] = vec, ["veh"] = Vehicles[source], ["plate"] = plate,})

end)