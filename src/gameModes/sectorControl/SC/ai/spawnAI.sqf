SC_fnc_spawnAi = {
    params ["_unit"];
    _side = side (group _unit);

    if !(_side in SC_var_sides) exitWith {};

    _rank = _unit getVariable "SC_var_rank";
    [_unit] join grpNull;
    _unit setVariable ["SC_var_name", ([_unit] call SC_fnc_getName), true];
    _unit setSkill (_unit getVariable "SC_var_aiSkill");

    _otherGroupUnits = (([_unit] call SC_fnc_getGroupUnits) - [_unit]) select {
        (alive _x) &&
        {!(_x getVariable ["ais_unconscious", false])} &&
        {(getPosWorld _x) inArea "SC_Var_playZone"} &&
        {
            !(surfaceIsWater (getPosWorld _x)) ||
            {
                _parX = objectParent _x;
                !(isNull _parX) && {((fullCrew [_parX, "", true]) findIf {isNull (_x select 0)}) != -1}
            }
        }
    };
    _otherGroupUnitsPriorityPos = _otherGroupUnits findIf {
        _parGroupMate = objectParent _x;
        (!(isNull _parGroupMate) && {(locked _parGroupMate) <= 1} && {((fullCrew [_parGroupMate, "", true]) findIf {(isNull (_x select 0)) && {(_x select 1) in ["commander", "gunner", "turret"]}}) != -1})
    };
    _spawnPos = [];
    _groupSpawn = false;
    _spawnMarker = "";
    _baseMarker = "SC_var_" + (toLower (str _side)) + "Respawn";
    _zoneParachuteJump = false;

    if (!(_otherGroupUnits isEqualTo []) && {(_otherGroupUnitsPriorityPos != -1) || {(random 1) < (0.3 * ((count _otherGroupUnits) / 3))}}) then {
        _groupSpawn = true;
        _grpUnit = if (_otherGroupUnitsPriorityPos != -1) then {_otherGroupUnits select _otherGroupUnitsPriorityPos} else {selectRandom _otherGroupUnits};
        _spawnPos = getPosATL _grpUnit;

        if (isPlayer _unit) exitWith {};

        _hdl = [_unit, _grpUnit] spawn SC_fnc_groupSpawn;
        waitUntil {scriptDone _hdl};
    } else {
        if (random 1 < 0.12) exitWith {
            _zoneParachuteJump = true;
        };

        _possibleMarkers = [_baseMarker] + ((SC_var_sectors select {(missionNamespace getVariable ("SC_var_owner" + _x)) == _side}) apply {"SC_var_sector" + _x});
        
        _spawnMarker = if SC_var_hugeMap then {
            if ((random 1) < 0.1) then {
                _baseMarker
            } else {
                ([
                    _possibleMarkers, [],
                    {_pos = getMarkerPos _x; selectMin (((SC_var_sectors select {(missionNamespace getVariable ("SC_var_owner" + _x)) != _side}) apply {"SC_var_sector" + _x}) apply {(getMarkerPos _x) distance2D _pos})}, "ASCEND"
                ] call BIS_fnc_sortBy) select (round (random [0, 0.5, ((count _possibleMarkers) - 1)]))
            }
        } else {
            selectRandom _possibleMarkers
        };

        _spawnPos = getMarkerPos _spawnMarker;

        _type = switch _side do {
            case west: {"B_Soldier_F"};
            case east: {"O_Soldier_F"};
            case independent: {"I_Soldier_F"};
        };

        _semaphoreVar = "SC_var_unitSpawnSemaphore" + (toLower (str _side));

        if (isNil _semaphoreVar) exitWith {};

        waitUntil {
            [_semaphoreVar] call {
                params ["_semaphoreVar"];

                if !(missionNameSpace getVariable _semaphoreVar) then {
                    missionNameSpace setVariable [_semaphoreVar, true];
                    true
                } else {
                    false
                }
            }
        };

        _safeSpawnPos = [];
        _isBaseSpawn = "Respawn" in _spawnMarker;
        _radius = 5;

        waitUntil {
            _safeSpawnPos = [_spawnPos, _radius] call BIS_fnc_randomPosTrigger;
            _radius = _radius * 1.05;

            _isBaseSpawn || {
                _safePosAsl = _safeSpawnPos;
                _safePosAsl set [2, 0];
                _safePosAsl = AGLToASL _safePosAsl;
                _safePosAsl set [2, ((_safePosAsl select 2) + 0.5)];

                (([objNull, "VIEW"] checkVisibility [_safePosAsl, (_safePosAsl vectorAdd [0, 0, 100])]) != 0)
            }
        };

        _spawnPos = _safeSpawnPos;

        if (isPlayer _unit) exitWith {
            missionNameSpace setVariable [_semaphoreVar, false];
        };

        _unit setPos _safeSpawnPos;

        missionNameSpace setVariable [_semaphoreVar, false];
    };

    _unit hideObjectGlobal false;
    _unit setVariable ["SC_var_posAtServerTime", [(getPosWorld _unit), serverTime]];
    _unit enableSimulationGlobal true;
    _unit addPlayerScores [0, 0, 0, 0, 0];

    [_unit, false] call ADG_fnc_allowDamage;

    _perks = [];

    _possiblePerks = ([
        ["EXPR", 1],
        ["STAM", 5],
        ["MRKS", 7],
        ["MGNR", 10],
        ["LNCR", 15],
        ["ARMR", 18],
        ["GRND", 20],
        ["SUPR", 25]
    ] select {(_x select 1) <= _rank}) apply {_x select 0};

    if ((_rank >= 7) && {_rank <= 50} && {(random 1) < (((1 / 80) * ((_rank ^ 0.825) - 40)) + 0.5)}) then {
        _perks = ["MRKS"];
        _possiblePerks = _possiblePerks - ["MRKS", "MGNR", "GRND"];
    } else {
        _exclusivePerks = ["MGNR", "GRND"] arrayIntersect _possiblePerks;

        if (_rank > 50) then {
            _exclusivePerks pushBack "MRKS";
        };

        if ((count _exclusivePerks) > 1) then {
            _possiblePerks = _possiblePerks - (_exclusivePerks - [selectRandom _exclusivePerks]);
        };
    };

    if ((random 1) < 0.5) then {
        _perks pushBack "MEDC";
    };

    _perks append ((_possiblePerks call BIS_fnc_arrayShuffle) select [0, (count ((SC_var_rankForPerkId select [1, 5]) select {_x <= _rank})) - (count _perks)]);
    _isMarksman = "MRKS" in _perks;

    _isMedic = "MEDC" in _perks;
    ([_side, _perks, _rank, true] call SC_fnc_getItemsUniqueAndGrouped) params ["_items", "_mags", "_groupedWeapons", "_groupedOptics", "_groupedSuppressors"];
    _unit setUnitLoadout [[],[],[],[],[],[],"","",[],["","","","","",""]];

    if (isPlayer _unit) exitWith {};

    _preferredUniformRank = 1 max (round (_rank * (random 1)));
    _bestUniformYet = "";
    _bestDeviationYet = 999;
    {
        _deviation = abs ((_x select 1) - _preferredUniformRank);
        
        if (_deviation < _bestDeviationYet) then {
            _bestUniformYet = _x;
            _bestDeviationYet = _deviation;
        };
    } forEach (_items select {
        if _isMarksman then {((_x select 0) find "hillie") != -1} else {
            (((_x select 0) select [0, 2]) == "U_") && {((_x select 0) find "Wetsuit") == -1} && {((_x select 0) find "Viper") == -1}
        }
    });
    _unit forceAddUniform (_bestUniformYet select 0);

    _preferredVestRank = 1 max (round (_rank * (random 1)));
    _bestVestYet = "";
    _bestDeviationYet = 999;
    {
        _deviation = abs ((_x select 1) - _preferredVestRank);

        if (_deviation < _bestDeviationYet) then {
            _bestVestYet = _x;
            _bestDeviationYet = _deviation;
        };
    } forEach (_items select {(((_x select 0) find "vest" != -1) || {((_x select 0) select [0, 2]) == "V_"}) && {((_x select 0) find "Rebreather") == -1}});
    _unit addVest (_bestVestYet select 0);

    _preferredBagRank = 1 max (round (_rank * (random 1)));
    _bestBagYet = "";
    _bestDeviationYet = 999;
    {
        _deviation = abs ((_x select 1) - _preferredBagRank);

        if (_deviation < _bestDeviationYet) then {
            _bestBagYet = _x;
            _bestDeviationYet = _deviation;
        };
    } forEach (_items select {((([_x select 0] call BIS_fnc_itemType) select 1) == "Backpack") && {!("_Bergen_" in (_x select 0))}});
    _unit addBackpackGlobal (_bestBagYet select 0);

    _preferredHelmetRank = 1 max (round (_rank * (random 1)));
    _bestHelmetYet = "";
    _bestDeviationYet = 999;
    {
        _deviation = abs ((_x select 1) - _preferredHelmetRank);

        if (_deviation < _bestDeviationYet) then {
            _bestHelmetYet = _x;
            _bestDeviationYet = _deviation;
        };
    } forEach (_items select {((((_x select 0) select [0, 2]) == "H_") || {(_x select 0) find "helmet" != -1}) && {(((_x select 0) find "Viper") == -1) && {((_x select 0) find "H_PilotHelmetFighter_") == -1}}});
    _unit addHeadgear (_bestHelmetYet select 0);

    if _isMedic then {
        _unit addItem "Medikit";
    } else {
        for "_i" from 1 to (selectRandom [4, 5]) do {
            _unit addItem "FirstAidKit";
        };
    };

    if (isPlayer _unit) exitWith {};
    
    _unit linkItem "ItemMap";
    _unit linkItem "ItemWatch";
    _unit linkItem "ItemCompass";
    _unit addWeaponGlobal (["Binocular", "Rangefinder"] select ("MRKS" in _perks));
    _unit linkItem ((switch _side do {
        case west: {"B"};
        case east: {"O"};
        case independent: {"I"};
    }) + "_UavTerminal");

    for "_i" from 1 to (round (random [1,2,4])) do {
        _unit addItem (selectRandom ["HandGrenade", "MiniGrenade"]);
    };

    for "_i" from 1 to (round (random [1,1.5,3])) do {
        _unit addItem "SmokeShell";
    };

    if !DW_var_skipNight then {
        _newNvg = (selectRandom (_items select {((_x select 0) find "NVGoggles") != -1})) select 0;
        _unit addItem _newNvg;
        _unit assignItem _newNvg;
    };

    _tertWeps = (_groupedWeapons apply {_x select 0}) select {((((_x select 0) call BIS_fnc_itemType) select 1) find "Launcher") != -1};
    if !(_tertWeps isEqualTo []) then {
        _newTertiaryWep = selectRandom _tertWeps;
        _newTertiaryWep = (selectRandom (_groupedWeapons select (_groupedWeapons findIf {_newTertiaryWep in _x}))) select 0;
        _possibleMags = _mags arrayIntersect (getArray (configFile >> "CfgWeapons" >> _newTertiaryWep >> "magazines"));
        for "_i" from 0 to 3 do {
            _unit addMagazineGlobal (selectRandom _possibleMags);
        };
        _unit addWeaponGlobal _newTertiaryWep;
    };

    _primWeps = (_groupedWeapons apply {_x select 0}) select {_type = ((_x select 0) call BIS_fnc_itemType) select 1; (((_x select 0) != "arifle_SDAR_F") && {_type != "Handgun"} && {(_type find "Launcher") == -1})};
    _newPrimWep = selectRandom _primWeps;
    _newPrimWep = (selectRandom (_groupedWeapons select (_groupedWeapons findIf {_newPrimWep in _x}))) select 0;
    _possibleMags = _mags arrayIntersect (getArray (configFile >> "CfgWeapons" >> _newPrimWep >> "magazines"));
    for "_i" from 1 to 9 do {
        _unit addMagazineGlobal (selectRandom _possibleMags);
    };
    _muzzles = getArray (configFile >> "CfgWeapons" >> _newPrimWep >> "muzzles");
    if !(_muzzles isEqualTo ["this"]) then {
        _secondaryMuzzle = (_muzzles - ["this"]) select 0;
        _possibleMags = _mags arrayIntersect (getArray (configFile >> "CfgWeapons" >> _newPrimWep >> _secondaryMuzzle >> "magazines"));
        for "_i" from 1 to 4 do {
            _unit addMagazineGlobal (selectRandom _possibleMags);
        };
    };
    _unit addWeaponGlobal _newPrimWep;

    if (_rank >= 3) then {
        _compatibleItems = compatibleItems _newPrimWep;
        _preferredOpticRank = 3 max (round (_rank * (random 1)));
        _bestOpticYet = nil;
        _bestDeviationYet = 999;
        {
            if ((_x select 0) in _compatibleItems) then {
                _deviation = abs ((_x select 1) - _preferredOpticRank);

                if (_deviation < _bestDeviationYet) then {
                    _bestOpticYet = _x;
                    _bestDeviationYet = _deviation;
                };
            };
        } forEach (_groupedOptics apply {_x select 0});

        if !(isNil "_bestOpticYet") then {
            _newOptic = (selectRandom (_groupedOptics select (_groupedOptics findIf {_bestOpticYet in _x}))) select 0;
            _unit addPrimaryWeaponItem _newOptic;
        };
    };

    if ("SUPR" in _perks) then {
        _allSuppressors = [];
        {_allSuppressors append (_x apply {_x select 0});} forEach _groupedSuppressors;

        _possibleSuppressors = (compatibleItems [_newPrimWep, "MuzzleSlot"]) arrayIntersect _allSuppressors;

        if !(_possibleSuppressors isEqualTo []) then {
            _unit addPrimaryWeaponItem (selectRandom _possibleSuppressors);
        };
    };

    if ((random 1) < 0.5) then {
        _accs = _items select {((_x select 0) select [0, 4]) == "acc_"};
        _added = false;
        while {!(isNil "_added") && {!_added} && {!(_accs isEqualTo [])}} do {
            _acc = selectRandom _accs;
            _accs = _accs - [_acc];
            _added = _unit addPrimaryWeaponItem (_acc select 0);
        };
    };
    
    if (isPlayer _unit) exitWith {};

    _newHgunWep = selectRandom ((_groupedWeapons apply {_x select 0}) select {(((_x select 0) call BIS_fnc_itemType) select 1) == "Handgun"});
    _newHgunWep = (selectRandom (_groupedWeapons select (_groupedWeapons findIf {_newHgunWep in _x}))) select 0;
    _possibleMags = _mags arrayIntersect (getArray (configFile >> "CfgWeapons" >> _newHgunWep >> "magazines"));
    for "_i" from 0 to 2 do {
        _unit addMagazineGlobal (selectRandom _possibleMags);
    };
    _unit addWeaponGlobal _newHgunWep;

    if (isPlayer _unit) exitWith {};

    waitUntil {!(isNull _unit)};

    _unit setVariable ["SC_var_isWatched", false];
    _unit setVariable ["SC_var_movingToSector", objNull];
    _unit setVariable ["SC_var_movingToSectorInd", ""];
    _unit setVariable ["SC_var_timeRemaining", SC_var_unitDespawnTime];

    [_unit] call SC_fnc_registerEntityServer;

    _unit setUnitTrait ["UAVHacker", true];
    _unit setUnitTrait ["Medic", _isMedic];

    if _isMedic then {
        _unit setAnimSpeedCoef 1.1;
    };

    _unit enableStamina false;
    _unit enableFatigue false;
    _unit setCustomAimCoef 0.35;

    if (!_groupSpawn && {SC_var_spawnVehiclesOnSectors || {"Respawn" in _spawnMarker}} && {(SC_var_numVehiclesSides select (SC_var_sides find _side)) < SC_var_wantedVehicleAmount}) then {
        [_side] call {
            params ["_side"];

            _sideIndex = SC_var_sides find _side;
            SC_var_numVehiclesSides set [_sideIndex, (SC_var_numVehiclesSides select _sideIndex) + 1];
            publicVariable "SC_var_numVehiclesSides";
        };

        _availableVehicles = (SC_var_availableVehiclesWithoutUnarmedUavs select {(_x select 1) <= _rank}) apply {_x select 0};
        _type = _availableVehicles select (floor ((random [0.4, 0.85, 1]) * (count _availableVehicles)));
        [_unit, (if ((_spawnMarker select [0,3]) == "SC_") then {"the Base"} else {_spawnMarker select [(count _spawnMarker) - 1, 1]}), _type] spawn SC_fnc_spawnVehicle;
    };

    if (!SC_var_hugeMap || {_spawnMarker != _baseMarker}) then {
        [_unit] spawn SC_fnc_sendUnitToAnySector;
    };

    _base = "SC_var_" + (toLower (str _side)) + "Base";
    _id = _unit getVariable "SC_var_respawnPositionId";

    if !(isNil "_id") then {
        [_unit, _id] call BIS_fnc_removeRespawnPosition;
    };

    ([_unit, [100, 100, 10], "respawn"] call BIS_fnc_addRespawnPosition) params ["", "_id"];
    _unit setVariable ["SC_var_respawnPositionId", _id];

    if _zoneParachuteJump then {
        [_unit] spawn SC_fnc_zoneParachuteJump;
        _spawnPos = [0, 0, 0];
    };

    [_unit, _base, _spawnPos] spawn {
        params ["_unit", "_base", "_spawnPos"];

        sleep 4;
        if (isPlayer _unit) exitWith {};

        if (_spawnPos inArea _base) then {
            waitUntil {
                sleep 1;
                ((isPlayer _unit) || {(_unit distance _spawnPos) > 8} || {!(alive _unit)})
            };
        };

        if (isPlayer _unit) exitWith {};

        if (alive _unit) then {
            [_unit, true] call ADG_fnc_allowDamage;
        };
    };
};