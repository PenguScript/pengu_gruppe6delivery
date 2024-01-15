local QBCore = exports['qb-core']:GetCoreObject()
local Robbing = false
CreateThread(function()
    for _,v in pairs(Config.RobberySettings.StockadeModels) do
        if Config.Target == 'qb' then
            exports['qb-target']:AddTargetModel(v, {
                options = {
                {
                    num = 1,
                    type = "client",
                    event = "pengu_gruppe6delivery:StartRobbery",
                    icon = 'fas fa-bars',
                    label = 'Break Open Trunk',
                    
                }
                },
                distance = Config.RobberySettings.RobberyDistance,
            })
        elseif Config.Target == 'ox' then
            exports.ox_target:addModel(v, {
                label = "Break Open Trunk",
                icon = "fas fa-bars",
                distance = Config.RobberySettings.RobberyDistance,
                event = "pengu_gruppe6delivery:StartRobbery",
                serverEvent = false,
            })
        end
    end
end)

RegisterNetEvent('pengu_gruppe6delivery:StartRobbery', function(args)
    local HasItems = false
    local coords = GetEntityCoords(cache.ped or PlayerPedId())
    local entity = args.entity
    local BagsToSteal = 0
    local VehicleDestroyed = false
    print(GetVehicleEngineHealth(entity))
    if not Robbing then
        if GetPedInVehicleSeat(entity, -1) and GetPedInVehicleSeat(entity, 0) == 0 then 
            if not HasAnimDictLoaded('anim_h eist@hs3f@ig13_thermal_charge@thermal_charge@male@') then  
                RequestAnimDict('anim_heist@hs3f@ig13_thermal_charge@thermal_charge@male@')
                while not HasAnimDictLoaded('anim_heist@hs3f@ig13_thermal_charge@thermal_charge@male@') do
                    Wait(1)
                end
            end
            if not HasNamedPtfxAssetLoaded('core') then
                RequestNamedPtfxAsset('core')
                while not HasNamedPtfxAssetLoaded('core') do
                    Wait(1)
                end
            end        
            if not HasModelLoaded('hei_prop_heist_thermite_flash') then
                RequestModel('hei_prop_heist_thermite_flash')
                while not HasModelLoaded('hei_prop_heist_thermite_flash') do
                    Wait(1)
                end
            end        

            UseParticleFxAssetNextCall("core")
            if Config.Inventory == 'qb' then
                if QBCore.Functions.HasItem(Config.RobberySettings.ThermiteItemName) and QBCore.Functions.HasItem(Config.RobberySettings.IgnitionItemName) then
                    HasItems = true
                end
            elseif Config.Inventory == 'ox' then
                if exports.ox_inventory:GetItemCount(Config.RobberySettings.ThermiteItemName) ~= 0 and exports.ox_inventory:GetItemCount(Config.RobberySettings.IgnitionItemName) ~= 0 then
                    HasItems = true
                end
            end
            if HasItems == true then
                Robbing = true
                QBCore.Functions.TriggerCallback('pengu_gruppe6delivery:GetBagsFromVehicle', function(result)
                    local ped = cache.ped or PlayerPedId()
                    LocalPlayer.state.invBusy = true
                    DisableAllControlActions(0)

                    if result then
                        if result == 'robbed' then
                            TriggerEvent('pengu_gruppe6delivery:Notify', "This has already been robbed!", nil, 'success', 3000)
                            LocalPlayer.state.invBusy = false
                            EnableAllControlActions(0)
        
                            return
                        end
                        BagsToSteal = result.bags

                        -- Player Stockade

                    else
                        BagsToSteal = math.random(Config.RobberySettings.MinBags,Config.RobberySettings.MaxBags)
                    end

                    
                    local pedCoords = GetOffsetFromEntityInWorldCoords(entity, -0.05,-3.5,0.85)
                    local taskCoords = GetOffsetFromEntityInWorldCoords(entity, -0.05,-4.1,0.85)
                    local pedRotation = GetEntityRotation(entity)
                    TaskGoStraightToCoord(ped, taskCoords.xyz, 1.0, 5000.0, pedRotation, 0.4)

                    local time = 0
                    while GetDistanceBetweenCoords(GetEntityCoords(ped),taskCoords, false) > 0.25 do
                        Wait(1)
                        time=time+1
                        if time == 5000.0 then
                            print('broken')
                            ClearPedTasksImmediately(ped)
                            break
                        end
                    end
                    print('lol')
                    if GetVehicleBodyHealth(entity) == 0.0 and GetVehicleEngineHealth(entity) < 0.0 then
                        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(entity), 1)
                        TriggerEvent('pengu_gruppe6delivery:Notify', "The vehicle's electronics are broken!", "You were able to open the doors easily", 'success', 3000)
                        TriggerServerEvent('pengu_gruppe6delivery:RobbedItem', 'uninked', BagsToSteal)
                        LocalPlayer.state.invBusy = false
                        EnableAllControlActions(0)
                        
                        return
                    end
                
                    if Config.Target == 'ox' then
                        exports.ox_target:disableTargeting(true)
                    elseif Config.Target == 'qb' then
                        exports['qb-target']:AllowTargeting(false)
                    end

                    RequestAnimDict("anim_heist@hs3f@ig13_thermal_charge@thermal_charge@male@")
                    while not HasAnimDictLoaded("anim_heist@hs3f@ig13_thermal_charge@thermal_charge@male@") do
                        Wait(1)
                    end
                    
                    RequestModel(GetHashKey('hei_prop_heist_thermite_flash'))
                    while not HasModelLoaded(GetHashKey('hei_prop_heist_thermite_flash')) do
                        Wait(1)
                    end
                    RequestModel(GetHashKey('hei_p_m_bag_var22_arm_s'))
                    while not HasModelLoaded(GetHashKey('hei_p_m_bag_var22_arm_s')) do
                        Wait(1)
                    end
                    --offset: x= -1.8, y= -0.17, z= 1.84, w= VehHeading
                    --vector4(-12.88, -686.59, 32.34, 128.56)
                    ClearPedTasksImmediately(ped)
                    local thermite = CreateObject(GetHashKey('hei_prop_heist_thermite_flash'), pedCoords,true,true,true)
                    local bag = CreateObject(GetHashKey('hei_p_m_bag_var22_arm_s'), pedCoords,true,true,true)
                    local intro = NetworkCreateSynchronisedScene(pedCoords.xy, pedCoords.z, pedRotation, 2, false, false, -1, 0, 1.0)
                    NetworkAddPedToSynchronisedScene(ped, intro, "anim_heist@hs3f@ig13_thermal_charge@thermal_charge@male@", "thermal_charge_male_male", 1.5, -4.0, 1, 16, 1148846080, 0) -- adding the ped to the scene
                    NetworkAddEntityToSynchronisedScene(thermite, intro, "anim_heist@hs3f@ig13_thermal_charge@thermal_charge@male@", "thermal_charge_male_hei_prop_heist_thermite", 1.0, 1.0, 1) -- adding the drill to the scene
                    NetworkAddEntityToSynchronisedScene(bag, intro, "anim_heist@hs3f@ig13_thermal_charge@thermal_charge@male@", "thermal_charge_male_p_m_bag_var22_arm_s", 1.0, 1.0, 1) -- adding the entity to the scene
                    NetworkAddSynchronisedSceneCamera(intro,"anim_heist@hs3f@ig13_thermal_charge@thermal_charge@male@",'thermal_charge_male_camera') -- adding the cam
                    NetworkStartSynchronisedScene(intro) -- starting the scene
                    SetEntityCollision(bag, false, true)

                    SetEntityCollision(thermite, false, true)


                    Wait(GetAnimDuration("anim_heist@hs3f@ig13_thermal_charge@thermal_charge@male@", "thermal_charge_male_camera") * 1000) -- waiting for the scene to finish
                    DeleteObject(bag)
                    FreezeEntityPosition(thermite, true)
                    if Config.Target == 'ox' then
                        exports.ox_target:disableTargeting(false)
                    elseif Config.Target == 'qb' then
                        exports['qb-target']:AllowTargeting(true)
                    end

                    
                    local ptfx = StartParticleFxLoopedOnEntityBone(Config.RobberySettings.ThermiteParticle, entity, -0.75, 0.0, -0.4, 65.0, 0.0, 0.0, GetEntityBoneIndexByName(entity, 'door_pside_r'), 2.0, false, false, false)
                    Wait(Config.RobberySettings.WaitTimeForThermite)
                    StopParticleFxLooped(ptfx, true)
                    NetworkStopSynchronisedScene(intro)
                    DeleteObject(thermite)

                    SetVehicleDoorOpen(entity, 3, false, false)
                    SetVehicleDoorOpen(entity, 2, false, false)
                    --exp_grd_grenade_lod
                    UseParticleFxAssetNextCall("core")
                    AddExplosion(pedCoords.xy, pedCoords.z+1.0, 0, false, true, false, 1.0)
                    


                    

                    TriggerEvent('pengu_gruppe6delivery:Notify', "Hack the ink bomb!", "Or else your stolen money will be useless!", "primary", 6000)
                    local Difficulties = {}
                    Wait(3000)

                    if Config.Skillcheck == 'ox' then
                        for i=1, BagsToSteal do
                            Difficulties[#Difficulties+1] = "easy"
                        end
                        if lib.skillCheck(Difficulties, {"e"}) then
                            TriggerEvent('pengu_gruppe6delivery:Notify', "You defused the ink bomb!", nil, 'success', 3000)
                            TriggerServerEvent('pengu_gruppe6delivery:RobbedItem', 'uninked', BagsToSteal)
    
                        else
                            TriggerEvent('pengu_gruppe6delivery:Notify', "The ink bomb blew up....", nil, 'error', 3000)
                            TriggerServerEvent('pengu_gruppe6delivery:RobbedItem', 'inked', BagsToSteal)
    
                        end
                    elseif Config.Skillcheck == 'ps' then
                        exports['ps-ui']:Circle(function(success)
                            if success then
                                TriggerEvent('pengu_gruppe6delivery:Notify', "You defused the ink bomb!", nil, 'success', 3000)
                                TriggerServerEvent('pengu_gruppe6delivery:RobbedItem', 'uninked', BagsToSteal)
                        	else
                        		TriggerEvent('pengu_gruppe6delivery:Notify', "The ink bomb blew up....", nil, 'error', 3000)
                                TriggerServerEvent('pengu_gruppe6delivery:RobbedItem', 'inked', BagsToSteal)
                        	end
                        end, BagsToSteal, 20) -- NumberOfCircles, MS

                



                    LocalPlayer.state.invBusy = false
                    EnableAllControlActions(0)



                end, VehToNet(entity))
                Robbing = false
            end
        end
    else
        TriggerEvent('pengu_gruppe6delivery:Notify', "You're already busy", nil, 'error', 3000)
    end
end)
