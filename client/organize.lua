local QBCore = exports['qb-core']:GetCoreObject()
Organizing = false
TotalOrganized = 0
Failed = false

CreateThread(function()
    if Config.Menu == 'ox' then
        lib.registerContext({
            id = "gruppe6organizemenustart",
            title = "Gruppe 6 Organizer Job Menu",
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
            id = "gruppe6organizemenustopstart",
            title = "Gruppe 6 Organizer Job Menu",
            options = {
                {
                    title = "Stop Working",
                    description = "Clock off duty at Gruppe 6!",
                    icon = "fas fa-box",
                    serverEvent = "pengu_gruppe6delivery:ToggleIsOnDuty",
                },
                {
                    title = "Start Organizing Safe Deposit Boxes",
                    description = "Make them look neat!",
                    icon = "fas fa-box",
                    event = "pengu_gruppe6delivery:StartOrganizing",
                }
            }
        })
        lib.registerContext({
            id = "gruppe6organizemenustopstop",
            title = "Gruppe 6 Organizer Job Menu",
            options = {
                {
                    title = "Stop Working",
                    description = "Clock off duty at Gruppe 6!",
                    icon = "fas fa-box",
                    serverEvent = "pengu_gruppe6delivery:ToggleIsOnDuty",
                },
                {
                    title = "Stop Organizing Safe Deposit Boxes",
                    description = "Let them collect dust.",
                    icon = "fas fa-box",
                    event = "pengu_gruppe6delivery:StopOrganizing",
                }
            }
        })

    end

    local model = Config.OrganizerPed.Model
    local loc = Config.OrganizerPed.Coords
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    local OrganizationPed = CreatePed(0, model, loc, false, false)
    FreezeEntityPosition(OrganizationPed, true)
    SetBlockingOfNonTemporaryEvents(OrganizationPed, true)
    SetEntityInvincible(OrganizationPed, true)
    SetEntityCanBeDamaged(OrganizationPed, false)
    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetEntity(OrganizationPed, {
            options = {
            {
                num = 1,
                type = "client",
                event = "pengu_gruppe6delivery:OpenGruppe6OrganizerJobMenu",
                icon = 'fas fa-bars',
                label = 'Access Gruppe 6 Job Menu',
                
            }
            },
            distance = 3,
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(OrganizationPed, {
            label = "Access Gruppe 6 Job Menu",
            icon = "fas fa-bars",
            distance = 3,
            event = "pengu_gruppe6delivery:OpenGruppe6OrganizerJobMenu",
            serverEvent = false,
        })
    end


    for i,v in pairs(Config.OrganizerLocations) do
        if Config.Target == 'qb' then
            exports['qb-target']:AddBoxZone("organizerlocation_"..i, v.coords.xyz, v.length, v.width, {
                name = "organizerlocation_"..i,
                heading = v.coords.w,
                minZ = v.coords.z,
                maxZ = v.coords.z+v.height,
            }, {
                options = {
                    {
                        num = 1,
                        type = "client",
                        event = "pengu_gruppe6delivery:OrganizeSafeDepositBoxes",
                        icon = 'fas fa-box-archive',
                        label = 'Organize Safe Deposit Boxes',
                        args = i,
                        
                    }
                },
                distance = 3,
            })
        elseif Config.Target == 'ox' then
            exports.ox_target:addBoxZone({
                coords = v.coords.xyz,
                size = vector3(v.width,v.length,v.height),
                rotation = v.coords.w,
                debug = false,
                options = {
                    {
                        label = "Organize Safe Deposit Boxes",
                        icon = "fas fa-box-archive",
                        distance = 3,
                        event = "pengu_gruppe6delivery:OrganizeSafeDepositBoxes",
                        args = i, 
                    }
                },
            })
        end
        Wait(1)
    end
end)

RegisterNetEvent('pengu_gruppe6delivery:OpenGruppe6OrganizerJobMenu', function(data)
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
                    txt = "Clock on duty at Gruppe 6!",
                    icon = "fas fa-box",
                    params = {
                        event = "pengu_gruppe6delivery:ToggleIsOnDuty",
                        isServer = true
                    }
                }
            else
                menu[#menu+1] = {
                    header = "Stop Working",
                    txt = "Clock off duty at Gruppe 6!",
                    icon = "fas fa-box",
                    params = {
                        event = "pengu_gruppe6delivery:ToggleIsOnDuty",
                        isServer = true,
                    }
                }
                if Organizing then
                    menu[#menu+1] = {
                        header = "Stop Organizing Safe Deposit Boxes",
                        txt = "Let them collect dust.",
                        icon = "fas fa-box",
                        params = {
                            event = "pengu_gruppe6delivery:StopOrganizing",
                        }
                    }
                else
                    menu[#menu+1] = {
                        header = "Start Organizing Safe Deposit Boxes",
                        txt = "Make them look neat!",
                        icon = "fas fa-box",
                        params = {
                            event = "pengu_gruppe6delivery:StartOrganizing",
                        }
                    }
                end
            end
            exports['qb-menu']:openMenu(menu)
        end)
    elseif Config.Menu == 'ox'then
        lib.callback("pengu_gruppe6delivery:GetIsOnDuty", false, function(duty)
            if not duty then
                lib.showContext('gruppe6organizemenustart')
            else
                if Organizing then
                    lib.showContext('gruppe6organizemenustopstop')
                else
                    lib.showContext('gruppe6organizemenustopstart')
                end
            end
        end)
    end
end)


RegisterNetEvent('pengu_gruppe6delivery:OrganizeSafeDepositBoxes', function(data)
    --EDIT SKILLCHECKS BELOW   
    if not Organizing and Config.OrganizerLocations[data.args].active then
        Config.OrganizerLocations[data.args].active = false
    end
    if Config.OrganizerLocations[data.args].active then
        RequestAnimDict('anim@amb@clubhouse@tutorial@bkr_tut_ig3@')
        while not HasAnimDictLoaded('anim@amb@clubhouse@tutorial@bkr_tut_ig3@') do
            Wait(1)
        end

        TaskPlayAnim(cache.ped or GetPlayerPed(-1), 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
        if lib.skillCheck({"easy", "easy", "easy"}, {"e"}) then
            TriggerEvent('pengu_gruppe6delivery:Notify', "You Organized the Safe Deposit Box", nil, 'success', 3000)

        else
            TriggerEvent('pengu_gruppe6delivery:Notify', "You Made a Mess Instead...", nil, 'error', 3000)
            Failed = true
        end
        StopAnimTask(cache.ped or GetPlayerPed(-1), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
        Config.OrganizerLocations[data.args].active = false
    end
end)

RegisterNetEvent('pengu_gruppe6delivery:StartOrganizing', function()
    if DoingDeliveries then
        DoingDeliveries = false
        if destination ~= nil then
            RemoveBlip(destination)
            destination = nil
        end          
        TriggerServerEvent('pengu_gruppe6delivery:DeleteVehicle')

    end
    if not Organizing then
        Organizing = true
    end
    local DepositNum = math.random(1, #Config.OrganizerLocations)
    local Description = nil
    if Organizing == true then
        if Config.OrganizerMarker then
            Description = "There's a marker where you need to go"
        end
        TriggerEvent('pengu_gruppe6delivery:Notify', "Head to Safe Deposit #"..DepositNum, Description, 'primary', 3000)
        Config.OrganizerLocations[DepositNum].active = true
        while Config.OrganizerLocations[DepositNum].active == Organizing do
            DrawMarker(2, Config.OrganizerLocations[DepositNum].coords.xyz, 0.0,0.0,0.0,0.0,180.0,0.0,0.5,0.5,0.5,255,165,0,70,true,false, 2, true, nil, nil, false)
            Wait(1)
        end
        if Failed then
            Failed = false
            Wait(math.random(Config.MinOrganizeWaitTime, Config.MaxOrganizeWaitTime))
            TriggerEvent('pengu_gruppe6delivery:StartOrganizing')    
            return
        end
        if not Organizing then return end
        TotalOrganized = TotalOrganized + 1
        Wait(math.random(Config.MinOrganizeWaitTime, Config.MaxOrganizeWaitTime))
        if Organizing then
            TriggerEvent('pengu_gruppe6delivery:StartOrganizing')
        end
    end
end)

RegisterNetEvent('pengu_gruppe6delivery:StopOrganizing', function()
    Organizing = false
    if TotalBagsDelivered > 0 or TotalOrganized > 0 then
        TriggerServerEvent('pengu_gruppe6delivery:RecievePaycheck', TotalBagsDelivered, TotalOrganized)
        Wait(1)
        TotalBagsDelivered = 0
        TotalOrganized = 0
    end
end)