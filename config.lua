Config = {}

Config.Notify = 'ox' -- 'qb' or 'ox' or 'none'
Config.Target = 'ox' -- 'qb' or 'ox'
Config.Menu = 'ox' -- 'qb' or 'ox'
Config.Progressbar = 'ox' -- 'qb' or 'ox'

Config.StartDeliveryPed = {
    Coords = vector4(-4.22, -659.18, 32.48, 183.34),
    Label = "Jimmy From Gruppe 6",
    Model = 'mp_s_m_armoured_01',
    Icon = 'fas fa-briefcase',
}

Config.Vehicle = 'stockade'

Config.Use3DMarker = true

Config.VehicleSpawns = {
    vector4(-32.41, -670.52, 31.34, 187.86),
    vector4(-36.74, -671.4, 31.34, 186.63),
    vector4(-21.22, -670.17, 31.34, 184.74),
    vector4(-17.77, -669.95, 31.34, 185.03),
    vector4(-6.85, -668.34, 31.34, 183.4),
    vector4(-2.73, -667.9, 31.34, 187.8),
    vector4(3.22, -669.83, 31.34, 187.06),
}
Config.MinBagsPerDestination, Config.MaxBagsPerDestination = 1,4
Config.BagSpawns = {
    vector4(234.72, 209.21, 104.39, 161.51),
    vector4(929.34, 55.75, 80.1, 65.93),
    -- ADD MORE IN THE SAME FORMAT
}

Config.DropSpot = vector3(-9.58, -654.66, 32.91)



Config.MoneyType = 'bank'
Config.MoneyPerBagMin,Config.MoneyPerBagMax = 100,300


Config.MinWaitTime, Config.MaxWaitTime = 5000, 15000
