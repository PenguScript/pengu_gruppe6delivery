local QBCore = exports['qb-core']:GetCoreObject()
DoingDeliveries = false
local busy = false
destination = nil
zoneid = nil
TotalBagsDelivered = 0

CreateThread(function()
    local blip = AddBlipForCoord(-10.36249, -655.6579, 32.451221)
    SetBlipSprite (blip, 408)
    SetBlipDisplay(blip, 2)
    SetBlipScale  (blip, 0.7)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Gruppe 6 Delivery Job")
    EndTextCommandSetBlipName(blip)
end)


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
    exports[Config.FuelResource]:SetFuel(vehicle, 100)
    while not IsPedSittingInAnyVehicle(cache.ped or PlayerPedId()) and DoingDeliveries == true do
        DrawMarker(2, args["vec"].x, args["vec"].y, args["vec"].z+3.65, 0.0,0.0,0.0,0.0,180.0,0.0,1.0,1.0,1.0,255,165,0,70,true,false, 2, true, nil, nil, false)
        Wait(1)
    end
    if IsPedSittingInAnyVehicle(cache.ped or PlayerPedId()) then
        TriggerEvent('pengu_gruppe6delivery:RecieveDestinationOne', GetVehiclePedIsIn(cache.ped or PlayerPedId()))
    end
end)


RegisterNetEvent('pengu_gruppe6delivery:RecieveDestinationOne', function(veh)
    if DoingDeliveries == true then
        TriggerEvent('pengu_gruppe6delivery:Notify', "Go to the bag on your map!", "Check your map!", "primary", 4000)
        local model = 'prop_big_bag_01'
        local BagsRemaining = math.random(Config.MinBagsPerDestination,Config.MaxBagsPerDestination)
        local initialBags = BagsRemaining
        local BagActive = false
        local location = Config.BagSpawns[math.random(1, #Config.BagSpawns)]
        local BagObject = nil
        local ped = cache.ped or PlayerPedId()
        local Pass = false
        destination = AddBlipForCoord(location.xyz)
        SetBlipRoute(destination, true)

        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
        RequestAnimDict('missfbi4prepp1')
        while not HasAnimDictLoaded('missfbi4prepp1') do
            Wait(1)
        end
        RequestAnimDict('anim@amb@clubhouse@tutorial@bkr_tut_ig3@')
        while not HasAnimDictLoaded('anim@amb@clubhouse@tutorial@bkr_tut_ig3@') do
            Wait(1)
        end

        local ent = CreateObject(model, location, false, false, false)
        FreezeEntityPosition(ent, true)
        SetEntityInvincible(ent, true)
        SetEntityCanBeDamaged(ent, false)
        if Config.Target == 'qb' then
            exports['qb-target']:AddTargetEntity(veh, {
                options = {
                {
                    num = 1,
                    type = "client",
                    icon = 'fas fa-bars',
                    label = 'Put Bag Down',
                    action = function()
                        if BagActive then
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
                            BagsRemaining = BagsRemaining - 1
                            BagActive = false
                            DeleteObject(BagObject)
                            BagObject = nil
                            StopAnimTask(ped, "missfbi4prepp1", "_bag_walk_garbage_man", 1.0)
                            end
                        end
                    }
                },
                distance = 3,
            })

            exports['qb-target']:AddTargetEntity(ent, {
                options = {
                {
                    num = 1,
                    type = "client",
                    icon = 'fas fa-bars',
                    label = 'Pick Up A Bag',
                    action = function()
                        if not BagActive then
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
                            if IsEntityPlayingAnim(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3) then
                                StopAnimTask(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                            end
                            busy = false

                            while not Pass do
                                Wait(1)
                            end
                            Pass = false
                            BagActive = true
                            TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
                            BagObject = CreateObject(model, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(BagObject, ped, GetPedBoneIndex(ped, 57005), 0.23, -0.01, -0.185, 220.0, 95.0, 70.0, true, true, false, true, 1, true)
                            local hypothetical = BagsRemaining
                            if hypothetical - 1 == 0 then
                                DeleteObject(ent)
                                TriggerEvent('pengu_gruppe6delivery:Notify', "That's It!", "You're all set to go after you put this in the truck!", "success", 4000)
                            else
                                TriggerEvent('pengu_gruppe6delivery:Notify', hypothetical - 1 .. " Bags Left!", "Just a bit more to go!", "primary", 4000)
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
                    if not BagActive then
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
                        if IsEntityPlayingAnim(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3) then
                            StopAnimTask(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                        end
                        busy = false

                        while not Pass do
                            Wait(1)
                        end
                        Pass = false
                        BagActive = true
                        TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
                        BagObject = CreateObject(model, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(BagObject, ped, GetPedBoneIndex(ped, 57005), 0.23, -0.01, -0.185, 220.0, 95.0, 70.0, true, true, false, true, 1, true)
                        local hypothetical = BagsRemaining
                        if hypothetical - 1 == 0 then
                            DeleteObject(ent)
                            TriggerEvent('pengu_gruppe6delivery:Notify', "That's It!", "You're all set to go after you put this in the truck!", "success", 4000)
                        else
                            TriggerEvent('pengu_gruppe6delivery:Notify', hypothetical - 1 .. " Bags Left!", "Just a bit more to go!", "primary", 4000)
                        end
                    end
                end,
                serverEvent = false,
            })

            exports.ox_target:addLocalEntity(veh, {
                label = "Put Bag Down",
                icon = "fas fa-bars",
                distance = 3,
                onSelect = function()
                    if BagActive then
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
                        BagsRemaining = BagsRemaining - 1
                        BagActive = false
                        DeleteObject(BagObject)
                        BagObject = nil
                        StopAnimTask(ped, "missfbi4prepp1", "_bag_walk_garbage_man", 1.0)
                    end
                end,
                serverEvent = false,
            })
        end    

        while BagsRemaining ~= 0 do
            if not busy and BagActive and not IsEntityPlayingAnim(ped, 'missfbi4prepp1', '_bag_throw_garbage_man',3) then
                if not IsEntityPlayingAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 3) then
                    ClearPedTasksImmediately(ped)
                    TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
                end
                Wait(1000)
            end
            Wait(1)
        end
        TriggerEvent('pengu_gruppe6delivery:Notify', "Good job!", "Now, drop this off safely!", "primary", 4000)
        SetBlipRoute(destination, false)
        RemoveBlip(destination)
        destination = nil
        if Config.Target == 'ox' then
            exports.ox_target:removeLocalEntity({ent, veh})
        else
            exports['qb-target']:RemoveTargetEntity({ent, veh})
        end


        TriggerEvent('pengu_gruppe6delivery:SecondHalf', initialBags, veh)
    end
end)


RegisterNetEvent('pengu_gruppe6delivery:SecondHalf', function(BagsInVehicle, veh)
    local BagsInVehicle = BagsInVehicle
    local ped = PlayerPedId()
    local veh = veh
    local model = 'prop_big_bag_01'


    destination = AddBlipForCoord(Config.DropSpot)
    SetBlipRoute(destination, true)

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
                    if BagActive then
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
                        BagsInVehicle = BagsInVehicle - 1
                        TotalBagsDelivered = TotalBagsDelivered + 1
                        BagActive = false
                        DeleteObject(BagObject)
                        BagObject = nil
                        StopAnimTask(ped, "missfbi4prepp1", "_bag_walk_garbage_man", 1.0)
                        end
                    end
                }
            },
            distance = 3,
        })

        exports['qb-target']:AddTargetEntity(veh, {
            options = {
            {
                num = 1,
                type = "client",
                icon = 'fas fa-bars',
                label = 'Pick Up A Bag',
                action = function()
                    if not BagActive then
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
                        if IsEntityPlayingAnim(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3) then
                            StopAnimTask(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                        end
                        busy = false

                        while not Pass do
                            Wait(1)
                        end
                        Pass = false
                        BagActive = true
                        TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
                        BagObject = CreateObject(model, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(BagObject, ped, GetPedBoneIndex(ped, 57005), 0.23, -0.01, -0.185, 220.0, 95.0, 70.0, true, true, false, true, 1, true)
                        local hypothetical = BagsInVehicle
                        if hypothetical - 1 == 0 then
                            TriggerEvent('pengu_gruppe6delivery:Notify', "That's It!", "You're all set to go after you put this bag in the boxes!", "success", 4000)
                        else
                            TriggerEvent('pengu_gruppe6delivery:Notify', hypothetical - 1 .. " Bags Left!", "Just a bit more to go!", "primary", 4000)
                        end
                    end
                end
                
            }
            },
            distance = 3,
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(veh, {
            label = 'Pick Up A Bag',
            icon = "fas fa-bars",
            distance = 3,
            onSelect = function()
                if not BagActive then
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
                    if IsEntityPlayingAnim(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3) then
                        StopAnimTask(cache.ped or PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                    end
                    busy = false

                    while not Pass do
                        Wait(1)
                    end
                    Pass = false
                    BagActive = true
                    TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
                    BagObject = CreateObject(model, 0, 0, 0, true, true, true)
                    AttachEntityToEntity(BagObject, ped, GetPedBoneIndex(ped, 57005), 0.23, -0.01, -0.185, 220.0, 95.0, 70.0, true, true, false, true, 1, true)
                    local hypothetical = BagsInVehicle
                    if hypothetical - 1 == 0 then
                        TriggerEvent('pengu_gruppe6delivery:Notify', "That's It!", "You're all set to go after you put this in the truck!", "success", 4000)
                    else
                        TriggerEvent('pengu_gruppe6delivery:Notify', hypothetical - 1 .. " Bags Left!", "Just a bit more to go!", "primary", 4000)
                    end
                end
            end,
            serverEvent = false,
        })

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
                        if BagActive then
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
                            BagsInVehicle = BagsInVehicle - 1
                            TotalBagsDelivered = TotalBagsDelivered + 1
                            BagActive = false
                            DeleteObject(BagObject)
                            BagObject = nil
                            StopAnimTask(ped, "missfbi4prepp1", "_bag_walk_garbage_man", 1.0)
                        end
                    end,
                    serverEvent = false,
                }
            }
        })
    end    

    while BagsInVehicle ~= 0 do
        if not busy and BagActive and not IsEntityPlayingAnim(ped, 'missfbi4prepp1', '_bag_throw_garbage_man',3) then
            if not IsEntityPlayingAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 3) then
                ClearPedTasksImmediately(ped)
                TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
            end
            Wait(1000)
        end
        Wait(1)
    end

    if Config.Target == 'ox' then
        exports.ox_target:removeLocalEntity(veh)
        exports.ox_target:removeZone(zoneid)
    else
        exports['qb-target']:RemoveZone("dropspot")
        exports['qb-target']:RemoveTargetEntity(veh)
    end
    SetBlipRoute(destination, false)
    RemoveBlip(destination)
    destination = nil
    Wait(math.random(Config.MinWaitTime, Config.MaxWaitTime))

    TriggerEvent('pengu_gruppe6delivery:RecieveDestinationOne', veh)
end)
