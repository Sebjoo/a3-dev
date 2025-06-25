SC_var_sides = [west, east, independent];
publicVariable "SC_var_sides";
SC_var_GroundWeaponHolders = [];

SC_var_rf_active = isClass (configFile >> "CfgWeapons" >> "SMG_01_black_RF");
SC_var_lxws_active = isClass (configFile >> "CfgWeapons" >> "arifle_Velko_lxWS");
SC_var_ef_active = isClass (configFile >> "CfgWeapons" >> "ef_hgun_P07_coy");

SC_var_rankForPerkId = [nil, 1, 6, 18, 35, 67, 100];
publicVariable "SC_var_rankForPerkId";

_vars = [];

_vars pushBack ["SC_var_vehicles", []];
_vars pushBack ["SC_var_numVehicles", 0];
_vars pushBack ["SC_var_numVehiclesSides", [0, 0, 0]];
_vars pushBack ["SC_var_lastDrop", 0];

{
    {_vars pushBack _x;} forEach [
        [("SC_var_units" + (str _x)), []],
        [("SC_var_numUnits" + (str _x)), 0],
        [("SC_var_uavAiUnits" + (str _x)), []],
        [("SC_var_numUavAiUnits" + (str _x)), 0]
    ];
} forEach [west, east, independent, civilian, sideEmpty, sideLogic, sideAmbientLife, sideUnknown];

{
    _side = _x;

    _vars pushBack ["SC_var_" + (str _side) + "Tickets", 0];
    _vars pushBack ["SC_var_last" + (str _side) + "Drop", 0];
    _vars pushBack ["SC_var_planeSpawnSemaphore" + (str _side), false];
    _vars pushBack ["SC_var_vehicleSpawnSemaphore" + (str _side), false];
    _vars pushBack ["SC_var_unitSpawnSemaphore" + (str _side), false];
} forEach SC_var_sides;

{
    _sector = _x;

    _vars pushBack ["SC_var_flag" + _sector, 0];
    _vars pushBack ["SC_var_holder" + _sector, civilian];
    _vars pushBack ["SC_var_owner" + _sector, civilian];
    _vars pushBack ["SC_var_lastOwner" + _sector, civilian];
    _vars pushBack ["SC_var_lastDowningSide" + _sector, civilian];
    _vars pushBack ["SC_var_" + _sector + "RespawnPos", []];
} forEach SC_var_sectors;

{
    missionNamespace setVariable (_x + [true]);
} forEach _vars;

{
    _sectorInd = _x;
    _flag3d = missionNameSpace getVariable ("SC_var_flag" + _sectorInd + "3d");
    _flag3d setVariable ["SC_var_sectorInd", _sectorInd];
} forEach SC_var_sectors;

SC_var_watchedUnits = [];
SC_var_playerDataArr = [];

SC_var_gameModeLoopScript = scriptNull;
SC_var_playZoneLoopScript = scriptNull;
SC_var_aiLoopScript = scriptNull;
SC_var_suspendAiLoopScript = scriptNull;
SC_var_groupLoopScript = scriptNull;

MM_var_restrictUnitIcons = true;
publicVariable "MM_var_restrictUnitIcons";

_playZoneSize = getMarkerSize "SC_var_playZone";
_centerPos = getArray (configfile >> "CfgWorlds" >> worldname >> "centerPosition");

SC_var_maxZoneSize = selectMax _playZoneSize;
publicVariable "SC_var_maxZoneSize";

TDI_var_ShowGroupIcons = true;
publicVariable "TDI_var_ShowGroupIcons";

SC_var_mapArea = (_playZoneSize select 0) * (_playZoneSize select 1);
if ((markerShape "SC_var_playZone") == "RECTANGLE") then {
    SC_var_mapArea = 4 * SC_var_mapArea;
} else {
    SC_var_mapArea = pi * SC_var_mapArea;
};
publicVariable "SC_var_mapArea";

SC_var_mapScaleFactor = sqrt ((_centerPos select 0) * (_centerPos select 1)) * 10 ^ -3;
publicVariable "SC_var_mapScaleFactor";

SC_var_mapZoomFactor = switch worldName do {
    case "Malden": {1.3};
    case "Altis": {0.5};
    case "Stratis": {2};
    default {1};
};
publicVariable "SC_var_mapZoomFactor";

{
    _sector = _x;
    _nearestSectorDistance = selectMin ((SC_var_sectors - [_sector]) apply {(getMarkerPos ("SC_var_sector" + _sector)) distance2D (getMarkerPos ("SC_var_sector" + _x))});
    missionNamespace setVariable [("SC_var_nearestSectorDistance" + _sector), _nearestSectorDistance];
} forEach SC_var_sectors;

SC_var_parachuteJumpHeight = 15 * (sqrt (sqrt SC_var_mapArea));
publicVariable "SC_var_parachuteJumpHeight";

SC_var_mapSize = switch (true) do {
    case (SC_var_mapArea < 700000): {"Small"};
    case (SC_var_mapArea < 2000000): {"Medium"};
    case (SC_var_mapArea < 15000000): {"Large"};
    default {"Huge"};
};
SC_var_hugeMap = SC_var_mapSize == "Huge";
publicVariable "SC_var_hugeMap";

SC_var_ticketGainFactor = 0.02 max (800 / (SC_var_mapArea ^ 0.66));
SC_var_wantedUnitAmount = ([30, 50] select SC_var_hugeMap) min (round (0.052 * (SC_var_mapArea ^ 0.4)));

SC_var_playZoneMiddle = [0, 0, 0];
{
    SC_var_playZoneMiddle = SC_var_playZoneMiddle vectorAdd (getMarkerPos ("SC_var_sector" + _x));
} forEach SC_var_sectors;
SC_var_playZoneMiddle = SC_var_playZoneMiddle vectorMultiply (1 / (count SC_var_sectors));
publicVariable "SC_var_playZoneMiddle";

SC_var_vehicleDamageFactor = 0.1 * (("vehicleDamage" call BIS_fnc_getParamValue) + 1);
publicVariable "SC_var_vehicleDamageFactor";

_oldGameVersion = profileNamespace getVariable ["SC_var_gameVersion", []];

if !(_oldGameVersion isEqualTo productVersion) then {
    SC_var_launcherAmmos = createHashMap;
    publicVariable "SC_var_launcherAmmos";

    [] spawn {
        _isAmmoValid = {
            params ["_ammo"];

            _return = false;
            _ammoCfg = configFile >> "CfgAmmo" >> _ammo;

            if (
                (
                    ((getNumber (_ammoCfg >> "caliber")) > 12.7) ||
                    {(getNumber (_ammoCfg >> "explosive")) > 0} ||
                    {
                        (["penetrator", "apfsds", "heat", "he_mp", "at", "scalpel", "titan", "vorona", "mraaws", "nlaw", "rpg", "agm", "firefist", "missile", "rocket", "tratnyr"] findIf {((toLower _ammo) find _x) != -1}) != -1
                    }
                ) &&
                {(["water", "smoke", "flare", "leaflet", "laser", "signal", "strobe", "dummy", "fake", "_pellet_", "_sg_", "12g"] findIf {((toLower _ammo) find _x) != -1}) == -1}
            ) then {
                _return = true;
            };

            _return
        };

        {
            _weapon = _x;
            _muzzles = getArray (_weapon >> "muzzles");

            {
                _mags = getArray (_weapon >> "magazines");
                {
                    _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                    if (_ammo != "" && {[_ammo] call _isAmmoValid}) then {
                        SC_var_launcherAmmos set [_ammo, true];
                    };
                } forEach _mags;
            } forEach _muzzles;
        } forEach configProperties [configFile >> "CfgWeapons", "isClass _x", true];

        {
            _vehCfg = _x;
            _turrets = [configName _vehCfg] call BIS_fnc_getTurrets;

            {
                _turret = _x;
                _mags = getArray (_turret >> "magazines");

                {
                    _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                    
                    if (_ammo != "" && {[_ammo] call _isAmmoValid}) then {
                        SC_var_launcherAmmos set [_ammo, true];
                    };
                } forEach _mags;
            } forEach _turrets;
        } forEach configProperties [configFile >> "CfgVehicles", "isClass _x", true];
        
        publicVariable "SC_var_launcherAmmos";

        {
            _subAmmo = configName _x;

            {
                _parentAmmo = configName _x;
                _sub = getText (_x >> "submunitionAmmo");

                if (_sub == _subAmmo) then {
                    {
                        _mag = configName _x;

                        if (getText (_x >> "ammo") == _parentAmmo) then {
                            {
                                _vehCfg = _x;
                                _turrets = [configName _vehCfg] call BIS_fnc_getTurrets;

                                {
                                    _turretCfg = _x;
                                    _mags = getArray (_turretCfg >> "magazines");

                                    if (_mag in _mags) then {
                                        SC_var_launcherAmmos set [_subAmmo, true, true];
                                    };
                                } forEach _turrets;
                            } forEach configProperties [configFile >> "CfgVehicles", "isClass _x", true];

                            {
                                _weap = _x;

                                if ((getNumber (_weap >> "type")) == 4) then {
                                    _mags = getArray (_weap >> "magazines");

                                    if (_mag in _mags && {[_parentAmmo] call _isAmmoValid}) then {
                                        SC_var_launcherAmmos set [_subAmmo, true, true];
                                    };
                                };
                            } forEach configProperties [configFile >> "CfgWeapons", "isClass _x", true];
                        };
                    } forEach configProperties [configFile >> "CfgMagazines", "isClass _x", true];
                };
            } forEach configProperties [configFile >> "CfgAmmo", "isClass _x", true];
        } forEach configProperties [configFile >> "CfgAmmo", "isClass _x", true];

        publicVariable "SC_var_launcherAmmos";
        profileNamespace setVariable ["SC_var_launcherAmmos", SC_var_launcherAmmos];
        profileNamespace setVariable ["SC_var_gameVersion", productVersion];
        saveProfileNamespace;
    };
} else {
    SC_var_launcherAmmos = profileNamespace getVariable "SC_var_launcherAmmos";
    publicVariable "SC_var_launcherAmmos";
};

SC_var_maxDistanceToUseableGroundVehicle = switch SC_var_mapSize do {
    case "Small": {10};
    case "Medium": {30};
    case "Large": {50};
    case "Huge": {300};
};

SC_var_maxDistanceToUseableHelicopter = switch SC_var_mapSize do {
    case "Small": {10};
    case "Medium": {30};
    case "Large": {50};
    case "Huge": {500};
};

SC_var_minDistanceFromTargetSectorForUnitToUseVehicle = switch SC_var_mapSize do {
    case "Small": {50};
    case "Medium": {70};
    case "Large": {120};
    case "Huge": {200};
};

SC_var_sectorCaptureRate = switch SC_var_mapSize do {
    case "Small": {6};
    case "Medium": {5};
    case "Large": {4};
    case "Huge": {2};
};

SC_var_unitDespawnTime = switch SC_var_mapSize do {
    case "Small": {30};
    case "Medium": {45};
    case "Large": {60};
    case "Huge": {480};
};

SC_var_vehicleDespawnTime = switch SC_var_mapSize do {
    case "Small": {90};
    case "Medium": {120};
    case "Large": {240};
    case "Huge": {960};
};

SC_var_minDistanceFromVehicleToDespawn = switch SC_var_mapSize do {
    case "Small": {5};
    case "Medium": {8};
    case "Large": {12};
    case "Huge": {30};
};

SC_var_minDistanceFromUnitToDespawn = switch SC_var_mapSize do {
    case "Small": {3};
    case "Medium": {4.5};
    case "Large": {6};
    case "Huge": {20};
};

SC_var_timeToDeleteNotMovingVehicle = switch SC_var_mapSize do {
    case "Small": {60};
    case "Medium": {90};
    case "Large": {120};
    case "Huge": {360};
};

SC_var_airDropDurationMins = switch SC_var_mapSize do {
    case "Small": {2};
    case "Medium": {5};
    case "Large": {10};
    case "Huge": {15};
};

SC_var_maxVehicleRank = switch SC_var_mapSize do {
    case "Small": {27};
    case "Medium": {55};
    case "Large": {75};
    case "Huge": {1000};
};

SC_var_maxVehicleMass = switch SC_var_mapSize do {
    case "Small": {4000};
    case "Medium": {14000};
    default {999999};
};

SC_var_sideDropStep = switch SC_var_mapSize do {
    case "Small": {25};
    case "Medium": {15};
    case "Large": {10};
    case "Huge": {7};
};

SC_var_dropStep = switch SC_var_mapSize do {
    case "Small": {20};
    case "Medium": {10};
    case "Large": {5};
    case "Huge": {4};
};

DW_var_timeBetweenWeatherChangesMultiplierSunny = switch SC_var_mapSize do {
    case "Small": {1};
    case "Medium": {1.5};
    case "Large": {2};
    case "Huge": {2};
};

DW_var_timeBetweenWeatherChangesMultiplierStormy = switch SC_var_mapSize do {
    case "Small": {0.1};
    case "Medium": {0.15};
    case "Large": {0.2};
    case "Huge": {0.2};
};

SC_var_wantedVehicleAmount = if (SC_var_mapSize == "Huge") then {
    1 max (round (SC_var_wantedUnitAmount / 5))
} else {
    1 max (round (SC_var_wantedUnitAmount / 6))
};
SC_var_maximumVehicleAmount = (SC_var_wantedVehicleAmount + 1) max (round (1.5 * SC_var_wantedVehicleAmount));
publicVariable "SC_var_maximumVehicleAmount";

SC_var_sectorCapturedMessages = "sectorCapturedMessages" call BIS_fnc_getParamValue;
SC_var_spawnVehiclesOnSectors = switch ((getArray (missionConfigFile >> "params" >> "spawnVehiclesOnSectors" >> "texts")) select ("spawnVehiclesOnSectors" call BIS_fnc_getParamValue)) do {
    case "Disabled": {false};
    case "Enabled": {true};
    default {SC_var_hugeMap};
};

_timeMultiplierDay = call compile ((getArray (missionConfigFile >> "params" >> "timeMultiplierDay" >> "texts")) select ("timeMultiplierDay" call BIS_fnc_getParamValue));
_timeMultiplierNight = call compile ((getArray (missionConfigFile >> "params" >> "timeMultiplierNight" >> "texts")) select ("timeMultiplierNight" call BIS_fnc_getParamValue));
DW_var_changeTimeMultiplierDay = _timeMultiplierDay;
DW_var_staticTimeMultiplierDay = _timeMultiplierDay;
DW_var_changeTimeMultiplierNight = _timeMultiplierNight;
DW_var_staticTimeMultiplierNight = _timeMultiplierNight;
DW_var_skipNight = "Enabled" == ((getArray (missionConfigFile >> "params" >> "skipNight" >> "texts")) select ("skipNight" call BIS_fnc_getParamValue));
publicVariable "DW_var_skipNight";

switch ((getArray (missionConfigFile >> "params" >> "weather" >> "texts")) select ("weather" call BIS_fnc_getParamValue)) do {
    case "Dynamic": {};
    case "Dynamic Foggy": {
        DW_var_minFogSunny = 0.1;
        DW_var_maxFogSunny = 0.2;
        DW_var_minFogStormy = 0.2;
        DW_var_maxFogStormy = 0.5;
    };
    case "Sun": {
        DW_var_maxOvercast = 0.35;
    };
    case "Clouds": {
        DW_var_minOvercast = 0.6;
        DW_var_maxOvercast = 0.7;
    };
    case "Storm": {
        DW_var_minRain = 0.5;
        DW_var_maxRain = 1.0;
        DW_var_minOvercast = 0.7;
        DW_var_minWindStormy = 0.6;
        DW_var_maxWindStormy = 1.0;
    };
};

DW_var_date = [2035, 07, 01] + (
    switch ((getArray (missionConfigFile >> "params" >> "startTime" >> "texts")) select ("startTime" call BIS_fnc_getParamValue)) do {
        case "Morning": {[[6, 00], [8, 00]] select (worldName == "Tanoa")};
        case "Noon": {[12, 00]};
        case "Evening": {[18, 00]};
        case "Night": {[1, 00]};
    }
);

SC_var_availableVehicles = ((getArray (missionConfigFile >> "vehicles")) call SC_fnc_filterConfigArr) select {
    _x params ["_type", "_rank"];
    
    (_rank <= SC_var_maxVehicleRank) &&
    {SC_var_hugeMap || {!((_type isKindOf "Plane_Base_F") || {_type isKindOf "Plane"})}} &&
    {
        _vehicle = _type createVehicleLocal [0, 0, 100];
        _mass = getMass _vehicle;
        deleteVehicle _vehicle;

        (_mass <= SC_var_maxVehicleMass)
    }
};
publicVariable "SC_var_availableVehicles";

SC_var_availableVehiclesWithoutUnarmedUavs = SC_var_availableVehicles select {
    _x params ["_veh"];

    !(_veh isKindOf "UAV") ||
    {(getarray (configfile >> "CfgVehicles" >> (_x select 0) >> "weapons")) findIf {!(("Horn" in _x) || {"Laser" in _x})} != -1}
};

_sidesNvGoggless = [];
_ranks = [];

{
    _side = _x;
    _NvGoggless = [];

    {
        if ((((_x select 0) call BIS_fnc_itemType) select 1) == "NvGoggles") then {
            _NvGoggless pushBack _x;
            _ranks pushBackUnique (_x select 1);
        };
    } forEach (((getarray (missionConfigFile >> ((str _side) + "General"))) + (getarray (missionConfigFile >> ((str _side) + "Marksman")))) call SC_fnc_filterConfigArr);

    _sidesNvGoggless pushBack _NvGoggless;
} forEach SC_var_sides;

SC_var_NvGogglesByRank = _ranks apply {
    _rank = _x;
    _NvGogglessForRank = [];

    {
        _NvGogglessForRank pushBack ((((_sidesNvGoggless select _forEachIndex) select {(_x select 1) == _rank}) select 0) select 0);
    } forEach SC_var_sides;

    [_rank, _NvGogglessForRank]
};
publicVariable "SC_var_NvGogglesByRank";

_sidesUniforms = [];
_ranks = [];

{
    _side = _x;
    _uniforms = [];

    {
        if ((((_x select 0) call BIS_fnc_itemType) select 1) == "Uniform") then {
            _uniforms pushBack _x;
            _ranks pushBackUnique (_x select 1);
        };
    } forEach (((getarray (missionConfigFile >> ((str _side) + "General"))) + (getarray (missionConfigFile >> ((str _side) + "Marksman"))) + (getarray (missionConfigFile >> ((str _side) + "Armor")))) call SC_fnc_filterConfigArr);

    _sidesUniforms pushBack _uniforms;
} forEach SC_var_sides;

SC_var_UniformsByRank = _ranks apply {
    _rank = _x;
    _uniformsForRank = [];

    {
        _uniformsForRank pushBack ((((_sidesUniforms select _forEachIndex) select {(_x select 1) == _rank}) select 0) select 0);
    } forEach SC_var_sides;

    [_rank, _uniformsForRank]
};
publicVariable "SC_var_UniformsByRank";

_sidesHelmets = [];
_ranks = [];

{
    _side = _x;
    _helmets = [];

    {
        if ((((_x select 0) call BIS_fnc_itemType) select 1) == "Headgear") then {
            _helmets pushBack _x;
            _ranks pushBackUnique (_x select 1);
        };
    } forEach (((getarray (missionConfigFile >> "general")) + (getarray (missionConfigFile >> ((str _side) + "General"))) + (getarray (missionConfigFile >> ((str _side) + "Armor")))) call SC_fnc_filterConfigArr);

    _sidesHelmets pushBack _helmets;
} forEach SC_var_sides;

SC_var_helmetsByRank = _ranks apply {
    _rank = _x;
    _helmetsForRank = [];

    {
        _helmetsForRank set [_forEachIndex, ((((_sidesHelmets select _forEachIndex) select {(_x select 1) == _rank}) select 0) select 0)];
    } forEach SC_var_sides;

    [_rank, _helmetsForRank]
};
publicVariable "SC_var_helmetsByRank";

_sidesVests = [];
_ranks = [];

{
    _side = _x;
    _vests = [];

    {
        if ((((_x select 0) call BIS_fnc_itemType) select 1) == "Vest") then {
            _vests pushBack _x;
            _ranks pushBackUnique (_x select 1);
        };
    } forEach (((getarray (missionConfigFile >> ((str _side) + "General"))) + (getarray (missionConfigFile >> ((str _side) + "Armor")))) call SC_fnc_filterConfigArr);

    _sidesVests pushBack _vests;
} forEach SC_var_sides;

SC_var_vestsByRank = _ranks apply {
    _rank = _x;
    _vestsForRank = [];

    {
        _vestsForRank pushBack ((((_sidesVests select _forEachIndex) select {(_x select 1) == _rank}) select 0) select 0);
    } forEach SC_var_sides;

    [_rank, _vestsForRank]
};
publicVariable "SC_var_vestsByRank";

_sidesBackpacks = [];
_ranks = [];

{
    _side = _x;
    _backpacks = [];

    {
        if ((((_x select 0) call BIS_fnc_itemType) select 1) == "Backpack") then {
            _backpacks pushBack _x;
            _ranks pushBackUnique (_x select 1);
        };
    } forEach ((getarray (missionConfigFile >> ((str _side) + "General"))) call SC_fnc_filterConfigArr);

    _sidesBackpacks pushBack _backpacks;
} forEach SC_var_sides;

SC_var_BackpacksByRank = _ranks apply {
    _rank = _x;
    _backpacksForRank = [];

    {
        _backpacksForRank pushBack ((((_sidesBackpacks select _forEachIndex) select {(_x select 1) == _rank}) select 0) select 0);
    } forEach SC_var_sides;

    [_rank, _backpacksForRank]
};
publicVariable "SC_var_BackpacksByRank";

SC_var_worldGroups = [
    ["2035", ["Altis", "Stratis", "Malden", "Tanoa"]],
    ["Chernarus", ["cup_chernarus_A3"]]
];
publicVariable "SC_var_worldGroups";

SC_var_currentWorldGroup = (SC_var_worldGroups select (SC_var_worldGroups findIf {worldName in (_x select 1)})) select 0;
publicVariable "SC_var_currentWorldGroup";