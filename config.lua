Config = {}

Config.Notify = 'ox' -- 'qb' or 'ox' or 'none'
Config.Target = 'ox' -- 'qb' or 'ox' or 'interact' [https://github.com/darktrovx/interact]
Config.InterctView = 7.5 -- Only used if Config.Target == 'interact' | Does not affect 'qb' or 'ox'
Config.InteractDist = 2.5 -- Only used if Config.Target == 'interact' | Does not affect 'qb' or 'ox'
Config.Menu = 'ox' -- 'qb' or 'ox'
Config.Progressbar = 'ox' -- 'qb' or 'ox'
Config.Inventory = 'ox' -- 'qb' or 'ox'
Config.Skillcheck = 'ox' -- 'ps' or 'ox'

Config.FuelResource = 'qb_tk_gasstations'

Config.StartDeliveryPed = {
    Coords = vector4(-4.22, -659.18, 32.48, 183.34),
    Label = "Jimmy From Gruppe 6",
    Model = 'mp_s_m_armoured_01',
    Icon = 'fas fa-briefcase',
}

Config.BagItemName = 'cash_bag'
Config.InkedItemName = 'inked_cash_bag'

Config.Vehicle = 'stockade'

Config.Use3DMarker = true

Config.MinRunsToDone = 1
Config.MaxRunsToDone = 3

Config.VehicleSpawns = {
    vector4(-32.41, -670.52, 31.34, 187.86),
    vector4(-36.74, -671.4, 31.34, 186.63),
    vector4(-21.22, -670.17, 31.34, 184.74),
    vector4(-17.77, -669.95, 31.34, 185.03),
    vector4(-6.85, -668.34, 31.34, 183.4),
    vector4(-2.73, -667.9, 31.34, 187.8),
    vector4(3.22, -669.83, 31.34, 187.06),
}

Config.MinBagsPerDestination = 1 -- minimum bags per location
Config.MaxBagsPerDestination = 4 -- maximum bags per location

Config.BagSpawns = {
    --[[vector4(234.72, 209.21, 104.39, 161.51),
    vector4(929.34, 55.75, 80.1, 65.93),]]
    -- ADD MORE IN THE SAME FORMAT
    vector4(-12.45, -678.57, 32.34, 206.6)
}

Config.DropSpot = vector3(-9.58, -654.66, 32.91)



Config.MoneyType = 'bank'
Config.MoneyPerBagMin = 100
Config.MoneyPerBagMax = 300


Config.MinWaitTime = 5000
Config.MaxWaitTime = 15000



-- Organizer Job

Config.OrganizerLocations = {
    { coords = vector4(8.25, -658.0, 33.45, 335.71), width = 3, length = 1, height = 1, active = false },
    { coords = vector4(2.74, -659.47, 33.45, 93.25), width = 3, length = 1, height = 1, active = false },
}

Config.OrganizerGuyCoords = vector4(4.39, -656.41, 33.45, 165.4)

Config.OrganizerPed = {
    Coords = vector4(4.39, -656.41, 32.45, 165.4),
    Label = "Kyle From Gruppe 6",
    Model = 'mp_s_m_armoured_01',
    Icon = 'fas fa-briefcase',
}

Config.OrganizerMarker = true

Config.MoneyPerOrganizedMin = 300
Config.MoneyPerOrganizedMax = 400

Config.MinOrganizeWaitTime = 2000
Config.MaxOrganizeWaitTime = 6500



Config.RobberySettings = {
    StockadeModels = {
        'stockade'
    },
    ThermiteParticle = 'proj_flare_trail',
    ExplosionPaticle = 'exp_grd_grenade_lod',
    WaitTimeForThermite = 10000,
    ThermiteItemName = 'thermite',
    IgnitionItemName = 'lighter',
    MinBags = 2, -- ONLY NPC STOCKADES
    MaxBags = 5, -- ONLY NPC STOCKADES
}

