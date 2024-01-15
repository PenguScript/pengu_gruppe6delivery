local QBCore = exports['qb-core']:GetCoreObject()
local Working = {}
local Vehicles = {}
local RobbedVehicles = {}

-- Set Duty

QBCore.Functions.CreateUseableItem(Config.BagItemName, function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.GetItemByName(item.name) then
        print('opening')
    end
end)

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

lib.callback.register("pengu_gruppe6delivery:GetIsOnDuty", function(duty)
    if Working[source] then
        return true
    else
        return false
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for i,v in pairs(Vehicles) do
            DeleteEntity(v.model)
        end
    end
end)

RegisterNetEvent('pengu_gruppe6delivery:DeleteVehicle', function(data)
    local source = source or data
    if Vehicles[source] then
        DeleteEntity(Vehicles[source].model)
        Vehicles[source] = nil    
    end
end)


RegisterNetEvent('pengu_gruppe6delivery:SpawnVehicle', function()
    local vec = Config.VehicleSpawns[math.random(1, #Config.VehicleSpawns)]
    local model = Config.Vehicle
    local plate = "GRUP"..source
    local spawning = false
    while spawning do
        Wait(5000)
    end
    TriggerClientEvent('pengu_gruppe6delivery:RequestModel', source, model)
    Vehicles[source] = {}
    Vehicles[source].model = CreateVehicle(model, vec, true, true)
    Vehicles[source].bags = 0
    SetVehicleNumberPlateText(Vehicles[source].model, plate)
    TriggerClientEvent('pengu_gruppe6delivery:StartFirstJob', source, {["vec"] = vec, ["veh"] = Vehicles[source].model, ["plate"] = plate,})
end)

RegisterNetEvent('pengu_gruppe6delivery:PutBagIntoTrunk', function(plate)
    local Player = QBCore.Functions.GetPlayer(source)
    print(plate)
    if Config.Inventory == 'ox' then
        local vehicleInventoryId = 'trunk'..plate
        local vehicleInventory = exports.ox_inventory:GetInventory(vehicleInventoryId, false)
        if vehicleInventory then
            exports.ox_inventory:RemoveItem(source, Config.BagItemName, 1)
            local success, response = exports.ox_inventory:AddItem(vehicleInventory.id, Config.BagItemName, 1)
            if not success then
                return print(response)
            end
        end
        Vehicles[source].bags = Vehicles[source].bags + 1
    elseif Config.Inventory == 'qb' then
        Player.Functions.RemoveItem(Config.BagItemName, 1)
        -- BLANK FOR NOW
    end
end)

RegisterNetEvent('pengu_gruppe6delivery:RemoveItemFromTrunk', function(plate, itemName)
    local vehicleInventoryId = 'trunk'..plate
    local vehicleInventory = exports.ox_inventory:GetInventory(vehicleInventoryId, false)

    exports.ox_inventory:RemoveItem(vehicleInventory.id, itemName, 1)
end)

RegisterNetEvent('pengu_gruppe6delivery:AddItem', function(itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    if Config.Inventory == 'ox' then
        if exports.ox_inventory:CanCarryAmount(source, Config.BagItemName) then
            if exports.ox_inventory:AddItem(source, Config.BagItemName, 1) then end
        end
    elseif Config.Inventory == 'qb' then
        Player.Functions.AddItem(Config.BagItemName, 1)
    end
end)

QBCore.Functions.CreateCallback('pengu_gruppe6delivery:GetBagsFromVehicle', function(source, cb, model)
    model = NetworkGetEntityFromNetworkId(model)
    print(RobbedVehicles[model])
    if RobbedVehicles[model] then
        cb('robbed')
    end
    for i,v in pairs(Vehicles) do
        if v.model == model then
            cb(Vehicles[i])
            Vehicles[i].bags = 0
            break
        end
    end
    print('lol')
    RobbedVehicles[model] = model
    cb(false)
end)

RegisterNetEvent('pengu_gruppe6delivery:RemoveItem', function(itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    if Config.Inventory == 'ox' then
        local slot = exports.ox_inventory:GetSlotIdWithItem(source, itemName)
        if slot then
            if exports.ox_inventory:RemoveItem(source, itemName, 1, nil, slot) then end
        end
    elseif Config.Inventory == 'qb' then
        if Player.Functions.RemoveItem(itemName, 1) then end
    end
end)
    
RegisterNetEvent('pengu_gruppe6delivery:RobbedItem', function(ink, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if ink == 'uninked' then
        if Config.Inventory == 'ox' then
            if exports.ox_inventory:CanCarryAmount(source, Config.BagItemName) then
                if exports.ox_inventory:AddItem(source, Config.BagItemName, amount) then end
            end
        elseif Config.Inventory == 'qb' then
            if Player.Functions.AddItem(Config.BagItemName, amount) then end
        end
    elseif ink == 'inked' then
        if Config.Inventory == 'ox' then
            if exports.ox_inventory:CanCarryAmount(source, Config.InkedItemName) then
                if exports.ox_inventory:AddItem(source, Config.InkedItemName, amount) then end
            else 
            end
        elseif Config.Inventory == 'qb' then
            if Player.Functions.AddItem(Config.InkedItemName, amount) then end
        end

    end
end)

