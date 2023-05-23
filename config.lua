Config = {}

Config.Enable = true -- musí být zaplý pokud bude hodnota false script nepojede

Config.CircleZones = {
    Field = {coords = vector3(2808.7437, 4765.9019, 46.9180), name = 'Coke', radius = 100.0, model = 'prop_barrel_02b', item = 'water', amount = 1},
	Field1 = {coords = vector3(2863.2053, 4623.1938, 48.8185), name = 'Coke', radius = 100.0, model = 'prop_rad_waste_barrel_01', item = 'bread', amount = 2},
    Field2 = {coords = vector3(2266.1746, 5611.5454, 54.8872), name = 'Coke', radius = 100.0, model = 'prop_rad_waste_barrel_01', item = 'weapon_pistol', amount = 3}
}

Config.ProcessZones = {
    Coke = {coords = vector3(317.0858, 345.8761, 105.2013), name = 'Coke', radius = 10.0, removeItem = 'bread', removeAmmount = 1, giveItem = 'water', giveAmount = 10},
    Meth = {coords = vector3(2808.7437, 4765.9019, 46.9180), name = 'Meth', radius = 10.0, removeItem = 'bread', removeAmmount = 1, giveItem = 'water', giveAmount = 10},
    Weed = {coords = vector3(2808.7437, 4765.9019, 46.9180), name = 'Weed', radius = 10.0, removeItem = 'bread', removeAmmount = 1, giveItem = 'water', giveAmount = 10}
}


Config.Delays = {
    PickUp = 5000, -- délka je v milisekundách
    Processing = 5000
}
