local QBCore = exports['qb-core']:GetCoreObject()
DoingDeliveries = false
local busy = false
destination = nil
hasLoaded = false
zoneid = nil
TotalBagsDelivered = 0
local BagObject = nil
local amntDone = nil
local amntDue = nil

local ped = cache.ped or PlayerPedId()

CreateThread(function()
    local blip = AddBlipForCoord(Config.StartDeliveryPed.Coords.xyz)
    SetBlipSprite (blip, 408)
    SetBlipDisplay(blip, 2)
    SetBlipScale  (blip, 0.7)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Gruppe 6 Delivery Job")
    EndTextCommandSetBlipName(blip)
    blip = AddBlipForCoord(Config.DropSpot.xyz)
    SetBlipSprite (blip, 408)
    SetBlipDisplay(blip, 2)
    SetBlipScale  (blip, 0.7)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Gruppe 6 Drop Spot")
    EndTextCommandSetBlipName(blip)
end)

local function RandomizeNumDeliveries()
    amntDone = 0
    amntDue = math.random(Config.MinRunsToDone, Config.MaxRunsToDone)
end

RandomizeNumDeliveries()

RegisterNetEvent('pengu_gruppe6delivery:StopDeliveries', function()
    DoingDeliveries = false
    if destination ~= nil then
        RemoveBlip(destination)
        destination = nil
    end
    if TotalBagsDelivered > 0 or TotalOrganized > 0 then
        if not Organizing then
            TriggerServerEvent('pengu_gruppe6delivery:RecievePaycheck', TotalBagsDelivered, TotalOrganized)
            Wait(1)
            TotalBagsDelivered = 0
            TotalOrganized = 0
        end
    end
    if Organizing == true then
        TriggerEvent('pengu_gruppe6delivery:StopOrganizing')
    end
    TriggerServerEvent('pengu_gruppe6delivery:DeleteVehicle')
end)

RegisterNetEvent('pengu_gruppe6delivery:Notify', function(title, var1, var2, var3)
    if Config.Notify == "ox" then
        lib.notify({title = title, description = var1, type = var2, duration = var3})
    elseif Config.Notify == "qb" then
        QBCore.Functions.Notify(title, var2, var3)
    else
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(title)
        EndTextCommandThefeedPostTicker(true, true)
    end
end)

CreateThread(function()
    if Config.Menu == 'ox' then
        lib.registerContext({
            id = "gruppe6jobmenustart",
            title = "Gruppe 6 Job Menu",
            options = {
                {
                    title = "Start Working",
                    description = "Clock on duty at Gruppe 6!",
                    icon = "fas fa-box",
                    serverEvent = "pengu_gruppe6delivery:ToggleIsOnDuty",
                }
            }
        })
        lib.registerContext({
            id = "gruppe6jobmenustopstart",
            title = "Gruppe 6 Job Menu",
            options = {
                {
                    title = "Stop Working",
                    description = "Clock off duty at Gruppe 6!",
                    icon = "fas fa-box",
                    serverEvent = "pengu_gruppe6delivery:ToggleIsOnDuty",
                },
                {
                    title = "Start Delivering Bags",
                    description = "Start retrieving bags of cash.",
                    icon = "fas fa-box",
                    serverEvent = "pengu_gruppe6delivery:SpawnVehicle",
                }
            }
        })
        lib.registerContext({
            id = "gruppe6jobmenustopstop",
            title = "Gruppe 6 Job Menu",
            options = {
                {
                    title = "Stop Working",
                    description = "Clock off duty at Gruppe 6!",
                    icon = "fas fa-box",
                    serverEvent = "pengu_gruppe6delivery:ToggleIsOnDuty",
                },
                {
                    title = "Stop Delivering Bags",
                    description = "Stop retrieving bags of cash.",
                    icon = "fas fa-box",
                    event = "pengu_gruppe6delivery:StopDeliveries",
                }
            }
        })

    end
    local model = Config.StartDeliveryPed.Model
    local loc = Config.StartDeliveryPed.Coords
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    local ent = CreatePed(0, model, loc, false, false)
    FreezeEntityPosition(ent, true)
    SetBlockingOfNonTemporaryEvents(ent, true)
    SetEntityInvincible(ent, true)
    SetEntityCanBeDamaged(ent, false)
    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetEntity(ent, {
            options = {
            {
                num = 1,
                type = "client",
                event = "pengu_gruppe6delivery:OpenGruppe6JobMenu",
                icon = 'fas fa-bars',
                label = 'Access Gruppe 6 Job Menu',
                
            }
            },
            distance = 3,
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(ent, {
            label = "Access Gruppe 6 Job Menu",
            icon = "fas fa-bars",
            distance = 3,
            event = "pengu_gruppe6delivery:OpenGruppe6JobMenu",
            serverEvent = false,
        })
    elseif Config.Target == 'interact' then
        exports.interact:AddLocalEntityInteraction({
            entity = ent,
            name = 'Gruppe6JobMenu', -- optional
            id = 'Gruppe6JobMenu', -- needed for removing interactions
            distance = Config.InterctView, -- optional
            interactDst = Config.InterctDist, -- optional
            offset = vec3(0.0, 0.0, 0.0), -- optional
            options = {
                {
                    label = "Access Gruppe 6 Job Menu",
                    event = "pengu_gruppe6delivery:OpenGruppe6JobMenu",
                },
            }
        })
    end


end)



RegisterNetEvent('pengu_gruppe6delivery:OpenGruppe6JobMenu', function(data)
    if Config.Menu == 'qb' then
        QBCore.Functions.TriggerCallback('pengu_gruppe6delivery:GetIsOnDuty', function(cb)
            local menu = {}
            local duty = cb
            menu[#menu+1] = {
                header = "Gruppe 6 Job Menu",
                isMenuHeader = true
            }
            if not duty then
                menu[#menu+1] = {
                    header = "Start Working",
                    txt = "Start Delivering High-Value Packages!",
                    icon = "fas fa-box",
                    params = {
                        event = "pengu_gruppe6delivery:ToggleIsOnDuty",
                        isServer = true
                    }
                }
            else
                menu[#menu+1] = {
                    header = "Stop Working",
                    txt = "Stop Delivering High-Value Packages!",
                    icon = "fas fa-box",
                    params = {
                        event = "pengu_gruppe6delivery:ToggleIsOnDuty",
                        isServer = true,
                    }
                }
                if DoingDeliveries then
                    menu[#menu+1] = {
                        header = "Stop Delivering Bags",
                        txt = "Stop retrieving bags of cash.",
                        icon = "fas fa-box",
                        params = {
                            event = "pengu_gruppe6delivery:StopDeliveries",
                        }
                    }
                else
                    menu[#menu+1] = {
                        header = "Start Delivering Bags",
                        txt = "Start retrieving bags of cash.",
                        icon = "fas fa-box",
                        params = {
                            event = "pengu_gruppe6delivery:SpawnVehicle",
                            isServer = true,
                        }
                    }
                end
            end
            exports['qb-menu']:openMenu(menu)
        end)
    elseif Config.Menu == 'ox'then
        lib.callback("pengu_gruppe6delivery:GetIsOnDuty", false, function(duty)
            if not duty then
                lib.showContext('gruppe6jobmenustart')
            else
                if DoingDeliveries then
                    lib.showContext('gruppe6jobmenustopstop')
                else
                    lib.showContext('gruppe6jobmenustopstart')
                end
            end
        end)
    end
end)

RegisterNetEvent('pengu_gruppe6delivery:RequestModel', function(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
end)

RegisterNetEvent('pengu_gruppe6delivery:StartFirstJob', function(args)
    if Organizing then
        Organizing = false
    end
    TriggerEvent('pengu_gruppe6delivery:Notify', "Go to the vehicle with the marker above it!", "There's an orange marker above the vehicle you are going to use.", "primary", 4000)
    local vehicle = args["veh"]
    DoingDeliveries = true
    TriggerEvent("vehiclekeys:client:SetOwner", args["plate"])
    while not IsPedSittingInAnyVehicle(cache.ped or PlayerPedId()) and DoingDeliveries == true do
        DrawMarker(2, args["vec"].x, args["vec"].y, args["vec"].z+3.65, 0.0,0.0,0.0,0.0,180.0,0.0,1.0,1.0,1.0,255,165,0,70,true,false, 2, true, nil, nil, false)
        Wait(1)
    end
    if IsPedSittingInAnyVehicle(cache.ped or PlayerPedId()) then
        exports[Config.FuelResource]:SetFuel(GetVehiclePedIsIn(cache.ped or PlayerPedId()), 100)
        TriggerEvent('pengu_gruppe6delivery:RecieveDestinationOne', GetVehiclePedIsIn(cache.ped or PlayerPedId()))
    end
end)

local vehicle = nil
RegisterNetEvent('pengu_gruppe6delivery:RecieveDestinationOne', function(veh)
    vehicle = veh
    if DoingDeliveries == true then
        TriggerEvent('pengu_gruppe6delivery:Notify', "Go to the bag on your map!", "Check your map!", "primary", 4000)
        local model = 'prop_big_bag_01'
        local BagsRemaining = math.random(Config.MinBagsPerDestination,Config.MaxBagsPerDestination)
        --local initialBags = BagsRemaining
        local location = Config.BagSpawns[math.random(#Config.BagSpawns)]
        ped = cache.ped or PlayerPedId()
        local Pass = false
        destination = AddBlipForCoord(location.xyz)
        SetBlipRoute(destination, true)

        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
        RequestAnimDict('anim@amb@clubhouse@tutorial@bkr_tut_ig3@')
        while not HasAnimDictLoaded('anim@amb@clubhouse@tutorial@bkr_tut_ig3@') do
            Wait(1)
        end
        local ent = nil
        repeat
            ent = CreateObject(model, location, false, false, false)
            print('process')
        until ent
        Wait(500)
        FreezeEntityPosition(ent, true)
        SetEntityInvincible(ent, true)
        SetEntityCanBeDamaged(ent, false)
        print(BagsRemaining)
        if Config.Target == 'qb' then
            exports['qb-target']:AddTargetEntity(ent, {
                options = {
                {
                    num = 1,
                    type = "client",
                    icon = 'fas fa-bars',
                    label = 'Pick Up A Bag',
                    action = function()
                        if not busy then
                            busy = true
    
                            if Config.Progressbar == 'qb' then
                                QBCore.Functions.Progressbar('pickupgruppe6bag', 'Picking Up Bag', 2000, false, false, { -- Name | Label | Time | useWhileDead | canCancel
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {
                                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                    anim = 'machinic_loop_mechandplayer',
                                }, {}, {}, function()
                                    Pass = true
                                end, function()
                                end)
                            elseif Config.Progressbar == 'ox' then
                                if lib.progressCircle({
                                    label = "Picking Up Bag",
                                    duration = 2000,
                                    position = 'bottom',
                                    useWhileDead = false,
                                    canCancel = false,
                                    disable = {
                                        car = true,
                                    },
                                    anim = {
                                        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                        clip = 'machinic_loop_mechandplayer'
                                    },
                                }) then Pass = true end
                            end
                            busy = false
    
                            while not Pass do
                                Wait(1)
                                print('inpass')
                            end
                            Pass = false
                            print('af pass')
                            ClearPedTasksImmediately(ped)
                            --BagObject = CreateObject(model, 0, 0, 0, true, true, true)
                            TriggerServerEvent('pengu_gruppe6delivery:AddItem', Config.BagItemName)
                            --AttachEntityToEntity(BagObject, ped, GetPedBoneIndex(ped, 57005), 0.23, -0.01, -0.185, 220.0, 95.0, 70.0, true, true, false, true, 1, true)
                            BagsRemaining -= 1
                            if BagsRemaining == 0 then
                                DeleteObject(ent)
                                TriggerEvent('pengu_gruppe6delivery:Notify', "That's It!", nil, "success", 4000)
                            else
                                TriggerEvent('pengu_gruppe6delivery:Notify', BagsRemaining .. " Bags Left!", "Just a bit more to go!", "primary", 4000)
                            end
                        end
                    end
                    }
                },
                distance = 3,
            })
        elseif Config.Target == 'ox' then
            exports.ox_target:addLocalEntity(ent, {
                label = 'Pick Up A Bag',
                icon = "fas fa-bars",
                distance = 3,
                onSelect = function()
                    if not busy then
                        busy = true

                        if Config.Progressbar == 'qb' then
                            QBCore.Functions.Progressbar('pickupgruppe6bag', 'Picking Up Bag', 2000, false, false, { -- Name | Label | Time | useWhileDead | canCancel
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {
                                animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                anim = 'machinic_loop_mechandplayer',
                            }, {}, {}, function()
                                Pass = true
                            end, function()
                            end)
                        elseif Config.Progressbar == 'ox' then
                            if lib.progressCircle({
                                label = "Picking Up Bag",
                                duration = 2000,
                                position = 'bottom',
                                useWhileDead = false,
                                canCancel = false,
                                disable = {
                                    car = true,
                                },
                                anim = {
                                    dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                    clip = 'machinic_loop_mechandplayer'
                                },
                            }) then Pass = true end
                        end
                        busy = false

                        while not Pass do
                            Wait(1)
                            print('inpass')
                        end
                        Pass = false
                        print('af pass')
                        ClearPedTasksImmediately(ped)
                        --BagObject = CreateObject(model, 0, 0, 0, true, true, true)
                        TriggerServerEvent('pengu_gruppe6delivery:AddItem', Config.BagItemName)
                        --AttachEntityToEntity(BagObject, ped, GetPedBoneIndex(ped, 57005), 0.23, -0.01, -0.185, 220.0, 95.0, 70.0, true, true, false, true, 1, true)
                        BagsRemaining -= 1
                        if BagsRemaining == 0 then
                            DeleteObject(ent)
                            TriggerEvent('pengu_gruppe6delivery:Notify', "That's It!", nil, "success", 4000)
                        else
                            TriggerEvent('pengu_gruppe6delivery:Notify', BagsRemaining .. " Bags Left!", "Just a bit more to go!", "primary", 4000)
                        end
                    end
                end,
                serverEvent = false,
            })
        elseif Config.Target == 'interact' then
            exports.interact:AddModelInteraction({
                model = model,
                name = 'Gruppe6BagPickup', -- optional
                id = 'Gruppe6BagPickup', -- needed for removing interactions
                distance = Config.InterctView, -- optional
                interactDst = Config.InterctDist, -- optional
                offset = vec3(0.0, 0.0, 0.0), -- optional
                options = {
                    {
                        label = "Pick Up A Bag",
                        action = function()
                            if not busy then
                                busy = true
                                if Config.Progressbar == 'qb' then
                                    QBCore.Functions.Progressbar('pickupgruppe6bag', 'Picking Up Bag', 2000, false, false, { -- Name | Label | Time | useWhileDead | canCancel
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }, {
                                        animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                        anim = 'machinic_loop_mechandplayer',
                                    }, {}, {}, function()
                                        Pass = true
                                    end, function()
                                    end)
                                elseif Config.Progressbar == 'ox' then
                                    if lib.progressCircle({
                                        label = "Picking Up Bag",
                                        duration = 2000,
                                        position = 'bottom',
                                        useWhileDead = false,
                                        canCancel = false,
                                        disable = {
                                            car = true,
                                        },
                                        anim = {
                                            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                            clip = 'machinic_loop_mechandplayer'
                                        },
                                    }) then Pass = true end
                                end
                                busy = false
        
                                while not Pass do
                                    Wait(1)
                                    print('inpass')
                                end
                                Pass = false
                                print('af pass')
                                ClearPedTasksImmediately(ped)
                                --BagObject = CreateObject(model, 0, 0, 0, true, true, true)
                                TriggerServerEvent('pengu_gruppe6delivery:AddItem', Config.BagItemName)
                                --AttachEntityToEntity(BagObject, ped, GetPedBoneIndex(ped, 57005), 0.23, -0.01, -0.185, 220.0, 95.0, 70.0, true, true, false, true, 1, true)
                                BagsRemaining -= 1
                                if BagsRemaining == 0 then
                                    DeleteObject(ent)
                                    TriggerEvent('pengu_gruppe6delivery:Notify', "That's It!", nil, "success", 4000)
                                else
                                    TriggerEvent('pengu_gruppe6delivery:Notify', BagsRemaining .. " Bags Left!", "Just a bit more to go!", "primary", 4000)
                                end
                            end
                        end
                    },
                }
            })
        end    
        print(BagsRemaining)
        while BagsRemaining ~= 0 do
            Wait(1)
        end
        TriggerEvent('pengu_gruppe6delivery:Notify', "Wait for the next run!", "We'll notify you shortly", "primary", 4000)
        SetBlipRoute(destination, false)
        RemoveBlip(destination)
        destination = nil
        if Config.Target == 'ox' then
            exports.ox_target:removeLocalEntity({ent, veh})
        elseif Config.Target == 'interact' then
            exports.interact:RemoveModelInteraction(model, 'Gruppe6BagPickup')
        else
            exports['qb-target']:RemoveTargetEntity({ent, veh})
        end
        Wait(Config.MinWaitTime, Config.MaxWaitTime)
        amntDone += 1
        if amntDone == amntDue then
            TriggerEvent('pengu_gruppe6delivery:Notify', "Change of Plans!", "Drop this run off SAFELY!", "primary", 4000)
            destination = AddBlipForCoord(Config.DropSpot.xyz)
            SetBlipRoute(destination, true)
        else
            TriggerEvent('pengu_gruppe6delivery:RecieveDestinationOne', veh)
        end
    end
end)

CreateThread(function()
    RequestAnimDict('missfbi4prepp1')
    while not HasAnimDictLoaded('missfbi4prepp1') do
        Wait(1)
    end
    local model = 'prop_big_bag_01'
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    while not hasLoaded do
        Wait(1000)
    end
    while true do
        if QBCore.Functions.HasItem(Config.BagItemName) or QBCore.Functions.HasItem(Config.InkedItemName) then
            print(BagObject)
            if not BagObject then
                BagObject = CreateObject(model, 0, 0, 0, true, true, true)
            end
            print(IsEntityAttached(BagObject))
            if not IsEntityAttached(BagObject) then
                AttachEntityToEntity(BagObject, ped, GetPedBoneIndex(ped, 57005), 0.23, -0.01, -0.185, 220.0, 95.0, 70.0, true, true, false, true, 1, true)
            end
            if not IsEntityPlayingAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 3) then
                ClearPedTasksImmediately(ped)
                TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
            end
        else
            if BagObject then
                DeleteObject(BagObject)
                BagObject = nil
            end
        end
        Wait(1000)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    hasLoaded = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    hasLoaded = false
end)

CreateThread(function()

    if Config.Target == 'qb' then
        exports['qb-target']:AddBoxZone("dropspot", vector3(Config.DropSpot), 1.5, 2.0, {
            name = "dropspot",
            heading = 0.0,
            debugPoly = false,
            minZ = Config.DropSpot.z,
            maxZ = Config.DropSpot.z+2,
                },{
            options = {
            {
                num = 1,
                type = "client",
                icon = 'fas fa-bars',
                label = 'Put Bag Down',
                action = function()
                        if QBCore.Functions.HasItem(Config.BagItemName) then
                            busy = true
                            if Config.Progressbar == 'qb' then
                                QBCore.Functions.Progressbar('pickupgruppe6bag', 'Putting Bag Down', 2000, false, false, { -- Name | Label | Time | useWhileDead | canCancel
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {
                                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                    anim = 'machinic_loop_mechandplayer',
                                }, {}, {}, function()
                                    Pass = true
                                end, function()
                                end)
                            elseif Config.Progressbar == 'ox' then
                                if lib.progressCircle({
                                    label = "Putting Bag Down",
                                    duration = 2000,
                                    position = 'bottom',
                                    useWhileDead = false,
                                    canCancel = false,
                                    disable = {
                                        car = true,
                                    },
                                    anim = {
                                        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                        clip = 'machinic_loop_mechandplayer'
                                    },
                                }) then Pass = true end
                            end
                            if IsEntityPlayingAnim(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3) then
                                StopAnimTask(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                            end
                            busy = false
                            while not Pass do
                                Wait(1)
                            end
                            Pass = false
                            TotalBagsDelivered += 1
                            TriggerServerEvent('pengu_gruppe6delivery:RemoveItem', Config.BagItemName)
                            StopAnimTask(ped, "missfbi4prepp1", "_bag_walk_garbage_man", 1.0)
                            Wait(math.random(Config.MinWaitTime, Config.MaxWaitTime))
                            if not QBCore.Functions.HasItem(Config.BagItemName) then
                                SetBlipRoute(destination, false)
                                RemoveBlip(destination)
                                destination = nil      
                                RandomizeNumDeliveries()
                                TriggerEvent('pengu_gruppe6delivery:RecieveDestinationOne', vehicle)
                            end
                        end
                    end
                }
            },
            distance = 3,
        })
    elseif Config.Target == 'ox' then
        zoneid = exports.ox_target:addBoxZone({
            coords = Config.DropSpot,
            size = vector3(1.5,2,1),
            rotation = 0.0,
            debug = false,
            options = {
                {
                    label = "Put Bag Down",
                    icon = "fas fa-bars",
                    distance = 3,
                    onSelect = function()
                        --DO HERE
                        if QBCore.Functions.HasItem(Config.BagItemName) then
                            busy = true
                            if Config.Progressbar == 'qb' then
                                QBCore.Functions.Progressbar('pickupgruppe6bag', 'Putting Bag Down', 2000, false, false, { -- Name | Label | Time | useWhileDead | canCancel
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {
                                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                    anim = 'machinic_loop_mechandplayer',
                                }, {}, {}, function()
                                    Pass = true
                                end, function()
                                end)
                            elseif Config.Progressbar == 'ox' then
                                if lib.progressCircle({
                                    label = "Putting Bag Down",
                                    duration = 2000,
                                    position = 'bottom',
                                    useWhileDead = false,
                                    canCancel = false,
                                    disable = {
                                        car = true,
                                    },
                                    anim = {
                                        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                        clip = 'machinic_loop_mechandplayer'
                                    },
                                }) then Pass = true end
                            end
                            if IsEntityPlayingAnim(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3) then
                                StopAnimTask(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                            end
                            busy = false
                            while not Pass do
                                Wait(1)
                            end
                            Pass = false
                            TotalBagsDelivered += 1
                            TriggerServerEvent('pengu_gruppe6delivery:RemoveItem', Config.BagItemName)
                            StopAnimTask(ped, "missfbi4prepp1", "_bag_walk_garbage_man", 1.0)
                            Wait(math.random(Config.MinWaitTime, Config.MaxWaitTime))
                            if not QBCore.Functions.HasItem(Config.BagItemName) then
                                SetBlipRoute(destination, false)
                                RemoveBlip(destination)
                                destination = nil      
                                RandomizeNumDeliveries()
                                TriggerEvent('pengu_gruppe6delivery:RecieveDestinationOne', vehicle)
                            end
                        end
                    end,
                    serverEvent = false,
                }
            }
        })
    elseif Config.Target == 'interact' then
        zoneid = exports.interact:AddInteraction({
            coords = vec3(Config.DropSpot.x,Config.DropSpot.y,Config.DropSpot.z),
            distance = Config.InterctView, -- optional
            interactDst = Config.InterctDist, -- optional
            id = 'dropspot', -- needed for removing interactions
            name = 'dropspot', -- optional
            options = {
                 {
                    label = 'Put Bag Down',
                    action = function()
                        --DO HERE
                        SetBlipRoute(destination, false)
                        RemoveBlip(destination)
                        destination = nil
                        if QBCore.Functions.HasItem(Config.BagItemName) then
                            busy = true
                            if Config.Progressbar == 'qb' then
                                QBCore.Functions.Progressbar('pickupgruppe6bag', 'Putting Bag Down', 2000, false, false, { -- Name | Label | Time | useWhileDead | canCancel
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {
                                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                    anim = 'machinic_loop_mechandplayer',
                                }, {}, {}, function()
                                    Pass = true
                                end, function()
                                end)
                            elseif Config.Progressbar == 'ox' then
                                if lib.progressCircle({
                                    label = "Putting Bag Down",
                                    duration = 2000,
                                    position = 'bottom',
                                    useWhileDead = false,
                                    canCancel = false,
                                    disable = {
                                        car = true,
                                    },
                                    anim = {
                                        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                        clip = 'machinic_loop_mechandplayer'
                                    },
                                }) then Pass = true end
                            end
                            if IsEntityPlayingAnim(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3) then
                                StopAnimTask(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                            end
                            busy = false
                            while not Pass do
                                Wait(1)
                            end
                            Pass = false
                            TotalBagsDelivered += 1
                            TriggerServerEvent('pengu_gruppe6delivery:RemoveItem', Config.BagItemName)
                            StopAnimTask(ped, "missfbi4prepp1", "_bag_walk_garbage_man", 1.0)
                            Wait(math.random(Config.MinWaitTime, Config.MaxWaitTime))
                            if not QBCore.Functions.HasItem(Config.BagItemName) then
                                SetBlipRoute(destination, false)
                                RemoveBlip(destination)
                                destination = nil      
                                RandomizeNumDeliveries()
                                TriggerEvent('pengu_gruppe6delivery:RecieveDestinationOne', vehicle)
                            end
                        end
                    end,
                },
            }
        })
    end

end)
