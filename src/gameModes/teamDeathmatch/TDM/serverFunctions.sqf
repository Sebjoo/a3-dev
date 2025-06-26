DM_fnc_applyMap = {
    params ["_map", "_switchedSides"];

    ((getArray (missionConfigFile >> "MapData")) select ((getArray (missionConfigFile >> "params" >> "MapName" >> "texts") find _map) - 2)) params [
        "_coverMapPos",
        "_coverMapDir",
        "_coverMapSize",
        "_playZonePos",
        "_playZoneSize",
        "_playZoneDir",
        "_playZoneShape",
        "_respawn_westPos",
        "_respawn_eastPos",
        "_westHQPos",
        "_eastHQPos"
    ];

    call DM_fnc_cleanUp;

    DM_var_coverMap setPos _coverMapPos;
    DM_var_coverMap setVariable ["objectArea", [_coverMapSize, _coverMapSize, _coverMapDir, true, 0]];
    [DM_var_coverMap, [], true] call BIS_fnc_moduleCoverMap;

    "DM_mrk_playZone" setMarkerPos _playZonePos;
    "DM_mrk_playZone" setMarkerSize _playZoneSize;
    "DM_mrk_playZone" setMarkerDir _playZoneDir;
    "DM_mrk_playZone" setMarkerShape _playZoneShape;
    "respawn_west" setMarkerPos _respawn_westPos;
    "respawn_west" setMarkerDir ([_respawn_westPos, _playZonePos] call DM_fnc_posGetRelDir);
    "respawn_east" setMarkerPos _respawn_eastPos;
    "respawn_east" setMarkerDir ([_respawn_eastPos, _playZonePos] call DM_fnc_posGetRelDir);
    "DM_mrk_westHQ" setMarkerPos _westHQPos;
    "DM_mrk_eastHQ" setMarkerPos _eastHQPos;

    if _switchedSides then {
        call DM_fnc_switchSides;
    };

    DM_var_zoneStartSize = _playZoneSize;
    DM_var_maxZoneSize = selectMax DM_var_zoneStartSize;
    DM_var_zoneSize = (DM_var_zoneStartSize select 0) * (DM_var_zoneStartSize select 1) * ([1, pi] select (_playZoneShape == "ELLIPSE"));
    DM_var_zoneSizeFactor = ((DM_var_zoneStartSize select 0) * (DM_var_zoneStartSize select 1) / 4560) ^ 0.05;
    DM_var_zoneStartPos = _playZonePos;

    if (_playZoneShape == "ELLIPSE") then {
        DM_var_zoneSizeFactor = DM_var_zoneSizeFactor * pi
    };

    publicVariable "DM_var_maxZoneSize";

    [true] remoteExec ["DM_fnc_setToSpawn", (allPlayers select {(alive _x) && (simulationEnabled _x)})];
};

DM_fnc_EntityRespawned = {
    params ["_newEntity", "_oldEntity"];

    if ((_newEntity isKindOf "CAManBase") && {!(isPlayer _newEntity)}) then {
        [_newEntity] call DM_fnc_suspendUnit;
    };
};

DM_fnc_setTimerTo0 = {
    DM_var_timerStr = "0:00";
    publicVariable "DM_var_timerStr";
};

DM_fnc_resetPlayZone = {
    "DM_mrk_playZone" setMarkerSize DM_var_zoneStartSize;
    "DM_mrk_playZone" setMarkerPos DM_var_zoneStartPos;
};

DM_fnc_movement = {
    params ["_state"];

    DM_var_movingEnabled = _state;
    publicVariable "DM_var_movingEnabled";
};

DM_fnc_gameRunning = {
    params ["_state"];
    
    DM_var_gameRunning = _state;
    publicVariable "DM_var_gameRunning";
};

DM_fnc_setRespawnTimeTo = {
    params ["_respawnTime"];

    DM_var_respawnTime = _respawnTime;
    publicVariable "DM_var_respawnTime";
};

DM_fnc_initPlayerServer = {
    params ["_player"];

    _player setVariable ["DM_var_arsenalOpened", false, true];
};

DM_fnc_resetPlayerScores = {
    {
        _scores = getPlayerScores _x;

        if !(_scores isEqualTo []) then {
            _x addPlayerScores ((_scores select [0, 5]) apply {-_x});
        };
    } forEach playableUnits;
};

DM_fnc_showNotificationGlobal = {
    [_this, {if hasInterface then {_this call BIS_fnc_showNotification;};}] remoteExecCall ["call", 0];
};

DM_fnc_suspendUnit = {
    params ["_unit"];

    [_unit] spawn {
        params ["_unit"];

        waitUntil {
            if !(
                [_unit] call {
                    params ["_unit"];
                    
                    if (isNull _unit) exitWith {true};
                    [_unit, [0, 0, 10]] remoteExecCall ["setPos", -2];
                    _unit setPos [0, 0, 10];
                    _unit disableAI "ALL";

                    if ((_unit distance [0, 0, 0]) > 100) then {
                        false
                    } else {
                        while {simulationEnabled _unit} do {
                            _unit enableSimulationGlobal false;
                        };
                        
                        if (_unit in playableUnits) then {
                            _sideStr = str (side (group _unit));

                            if ((random 1) < 0.01) then {
                                _unit call (compile ("DM_var_suspendedUnits" + _sideStr + " = DM_var_suspendedUnits" + _sideStr + " - [objNull];"));
                            };

                            _unit call (compile ("DM_var_suspendedUnits" + _sideStr + " pushBackUnique _this;"));
                            call (compile ('DM_var_suspendedUnits' + _sideStr + ' = [DM_var_suspendedUnits' + _sideStr + ', [], {_x getVariable "DM_var_unitId"}, "ASCEND"] call BIS_fnc_sortBy;'));
                        } else {
                            [_unit] remoteExecCall ["deleteVehicle", _unit];
                        };
                        true
                    }
                }
            ) then {
                sleep 1;
                false
            } else {
                true
            }
        };
    };
};

DM_fnc_spawnSpawnSpawnGlobal = {
    params ["_relRoundNumber"];

    [
        (
            if DM_var_loadoutsRestricted then {
                [(DM_var_roundNUmber == 1), _relRoundNumber, ([_relRoundNumber] call DM_fnc_calculateItems)]
            } else {
                [false, 25, [[], [], [], []]]
            }
        ),
        {
            if hasInterface then {
                waitUntil {!(isNil "DM_fnc_spawnSpawn")};
                _this spawn DM_fnc_spawnSpawn;
            };
        }
    ] remoteExecCall ["spawn", 0];
};

DM_fnc_oneTeamDead = {
    (
        {
            _side = _x;
            ((entities [["CAManBase"], [], true, true]) findIf {(simulationEnabled _x) && {(side (group _x)) == _side}}) == -1
        } count [west, east]
    ) != 0
};

DM_fnc_getWinSide = {
    (
        [west, east] select {
            _side = _x;
            (({(simulationEnabled _x) && {(side (group _x)) == _side}} count (entities [["CAManBase"], [], true, true])) != 0)
        }
    ) select 0
};

DM_fnc_increaseSidesScore = {
    params ["_winSide"];

    _varStr = "DM_var_" + (toLower (str _winSide)) + "Points";

    missionNameSpace setVariable [_varStr, ((missionNameSpace getVariable _varStr) + 1)];
    publicVariable _varStr;
};

DM_fnc_setAllPlayersToSpawn = {
    {
        if (hasInterface && {!(isNil "player")} && {alive player}) then {
            [true] spawn DM_fnc_setToSpawn;
        };
    } remoteExecCall ["call", 0];
};

DM_fnc_spawnVehicles = {
    params ["_side", "_playerNum"];

    _pos = getMarkerPos ("DM_mrk_" + (toLower (str _side)) + "HQ");
    _vehType = DM_var_vehicleType;

    _vehAmount = switch DM_var_vehicleAmount do {
        case "One per Team": {1};
        case "One per 2 Players, but at least one": {1 max (floor (_playerNum / 2))};
        case "One per Player": {_playerNum};
    };

    _sleepTime = 3 / _vehAmount;

    for "_i" from 1 to _vehAmount do {
        _hdl = [_pos, _vehType] spawn DM_fnc_spawnVehicle;
        sleep _sleepTime;
    };
};

DM_fnc_spawnVehicle = {
    params ["_pos", "_vehType"];

    _safePos = [];
    _rad = 3;
    _startTime = time;

    waitUntil {
        waitUntil {_pos findEmptyPositionReady [0, _rad]};
        _safePos = _pos findEmptyPosition [0, _rad, _vehType];
        _rad = _rad + 0.5;

        (
            (
                !(_safePos isEqualTo []) &&
                {
                    _safePosAsl = _safePos;
                    _safePosAsl set [2, 0];
                    _safePosAsl = AGLToASL _safePosAsl;
                    _safePosAsl set [2, ((_safePosAsl select 2) + 0.5)];

                    (([objNull, "VIEW"] checkVisibility [_safePosAsl, (_safePosAsl vectorAdd [0, 0, 100])]) != 0)
                }
            ) ||
            {if ((serverTime - _startTime) > 5) then {_safePos = _pos; true} else {false}}
        )
    };

    _veh = [_vehType, _safePos] call {
        params ["_vehType", "_safePos"];

        _veh = createVehicle [_vehType, _safePos, [], 0, "NONE"];
        [_veh, false] call ADG_fnc_allowDamage;

        _veh
    };

    waitUntil {!(isNull _veh)};
    
    _veh setDir (random 360);

    clearBackpackCargoGlobal _veh;
    clearItemCargoGlobal _veh;
    clearMagazineCargoGlobal _veh;
    clearWeaponCargoGlobal _veh;

    _veh addItemCargoGlobal ["Toolkit", 1];

    [_veh] spawn {
        params ["_veh"];

        sleep 5;
        [_veh, true] call ADG_fnc_allowDamage;
    };
};

DM_fnc_zoneShrink = {
    _totalDuration = ceil (60 * DM_var_zoneSizeFactor * DM_var_zoneShrinkSpeed);
    DM_var_timerHdl = [_totalDuration] spawn DM_fnc_timer;

    _remainingDuration = _totalDuration;
    _lastPos = DM_var_zoneStartPos;
    _lastSize = DM_var_zoneStartSize;

    while {_remainingDuration > 0} do {
        _roundDuration = (1 / 48) max (DM_var_zoneShrinkRatio * _remainingDuration);
        _remainingDuration = _remainingDuration - _roundDuration;

        _targetPos = [
            "DM_mrk_playZone",
            (((markerSize "DM_mrk_playZone") apply {_x * DM_var_zoneShrinkRatio}) +
            [(markerDir "DM_mrk_playZone"),
            ((markerShape "DM_mrk_playZone") isEqualTo "Rectangle")
        ])] call BIS_fnc_randomPosTrigger;
        _targetSize = _lastSize apply {_x * (1 - DM_var_zoneShrinkRatio)};

        _diffSize = [_targetSize, (_lastSize apply {-_x})] call DM_fnc_vectorAddXd;
        _diffPos = [_targetPos, (_lastPos apply {-_x})] call DM_fnc_vectorAddXd;

        _startTime = time;

        waitUntil {
            _ratio = (time - _startTime) / _roundDuration;
            "DM_mrk_playZone" setMarkerSize ([_lastSize, (_diffSize apply {_x * _ratio})] call DM_fnc_vectorAddXd);
            "DM_mrk_playZone" setMarkerPos ([_lastPos, (_diffPos apply {_x * _ratio})] call DM_fnc_vectorAddXd);

            (_ratio >= 1)
        };

        _lastPos = _targetPos;
        _lastSize = _targetSize;
    };
};

DM_fnc_getCurrentMap = {
    _roundIndex = (DM_var_roundNumber - 1) mod (2 * ((count DM_var_randomMapRotation) - 2));
    _switchedSides = (_roundIndex mod 2) != 0;
    _mapIndex = floor (_roundIndex / 2);

    [(DM_var_randomMapRotation select _mapIndex), _switchedSides]
};

DM_fnc_switchSides = {
    {
        _formatStr = _x;
        _sidesStr = "west";
        _otherSidesStr = "east";
        _sidesMarkerStr = format [_formatStr, _sidesStr];
        _otherSidesMarkerStr = format [_formatStr, _otherSidesStr];
        _posS = [_sidesMarkerStr, _otherSidesMarkerStr] apply {getMarkerPos _x};
        _dirS = [_sidesMarkerStr, _otherSidesMarkerStr] apply {markerDir _x};
        _sidesMarkerStr setMarkerPos(_posS select 1);
        _otherSidesMarkerStr setMarkerPos(_posS select 0);
        _sidesMarkerStr setMarkerDir (_dirS select 1);
        _otherSidesMarkerStr setMarkerDir (_dirS select 0);
    } forEach ["DM_mrk_%1HQ","respawn_%1"];
};

DM_fnc_posGetRelDir = {
    params ["_v1", "_v2"];

    _v1 resize 3;
    _v2 resize 3;
    _v3 = _v2 vectorAdd(_v1 vectorMultiply - 1);
    _v3 resize 2;
    _dir = (_v3 select 0) atan2 (_v3 select 1);

    if (_dir < 0) then {
        _dir = 360 + _dir;
    };

    _dir
};

DM_fnc_allPlayersReady = {
    params ["_includeArs", "_includeSides"];

    _exit = false;
    _arr = [{_this getVariable "DM_var_isLoading"}];

    if _includeArs then {
        _arr pushBack {
            _this getVariable "DM_var_arsenalOpened"
        };
    };

    _allPlayers = allPlayers;
    _allUnits = entities [["CAManBase"], [], true, false];

    if _includeSides then {
        if (({_side = _x; (({(simulationEnabled _x) && {(side (group _x)) == _side}} count _allUnits)) == 0} count [west, east]) != 0) then {
            _exit = true;
        };
    };

    if !_exit then {
        (
            {
                _player = _x;

                if ((simulationEnabled _player) && {alive _player}) then {
                    _execArr = _arr apply {_player call _x};

                    if (({isNil "_x"} count _execArr) == 0 ) then {
                        ({_x} count _execArr) != 0
                    } else {
                        false
                    }
                } else {
                    true
                }
            } count _allPlayers
        ) == 0
    } else {
        false
    }
};

DM_fnc_relativeRoundNumber = {
    params ["_roundNumber"];
    round (30 * (_roundNumber / (2 * (DM_var_minPointsToWin - 1))))
};

DM_fnc_calculateItems = {
    params ["_relRoundNumber"];

    _roundArr = [1, 2, 7, 13, 19, 25];
    _weapons = [];
    _items = [];
    _magazines = [];
    _backpacks = [];

    {
        _roundInd = str _x;
        _weapons append (getArray (missionConfigFile >> ("weaponsRound" + _roundInd)));
        _items append (getArray (missionConfigFile >> ("itemsRound" + _roundInd)));
        _magazines append (getArray (missionConfigFile >> ("magazinesRound" + _roundInd)));
        _backpacks append (getArray (missionConfigFile >> ("backpacksRound" + _roundInd)));
    } forEach (_roundArr select {_x <= _relRoundNumber});

    if !DM_var_autoHealEnabled then {
        if (_relRoundNumber >= 19) then {
            _items pushBack "Medikit";
        } else {
            _items pushBack "FirstAidKit";
        };
    };

    [_weapons, _items, _magazines, _backpacks]
};

DM_fnc_timer = {
    params ["_time"];

    for "_i" from 1 to (_time + 1) do {
        DM_var_timerStr = [-_i + _time + 1] call DM_fnc_durationToMinSec;
        publicVariable "DM_var_timerStr";
        sleep 1;
    };
};

DM_fnc_vectorAddXd = {
    params ["_v1", "_v2"];

    _v3 = [];

    for "_i" from 0 to (count _v1) do {
        _v3 pushBack ((_v1 select _i) + (_v2 select _i));
    };

    _v3
};

DM_fnc_durationToMinSec = {
    params ["_time"];

    _mins = floor (_time / 60);
    _secs = _time - (_mins * 60);
    _str = format ["%1:%2", _mins, _secs];
    _pos = _str find ":";
    _length = count _str;

    if ((_length - _pos) == 2) then {
        [(_str select [0, _pos + 1]), (_str select [(_pos + 1), (_length - _pos)])] joinString "0"
    } else {
        _str
    }
};

DM_fnc_getSidestring = {
    switch (_this select 0) do {
        case west: {"Blufor"};
        case east: {"Opfor"};
        case independent: {"Independent"};
    };
};

DM_fnc_aiWarmup = {
   waitUntil {
        _hdl = [2 * DM_var_minPointsToWin] spawn DM_fnc_balanceAi;
        waitUntil {scriptDone _hdl};
        sleep 1;
        false
    };
};

DM_fnc_getAiNameArr = {
    params ["_unit"];

    _name = [];
    _ss = (name _unit) splitString " ";
    _sss = (_ss select 0) splitString "-";

    if ((count _sss) > 1) then {
        _name = [
            (((_sss select 0) select [0,1]) + ".-" + ((_sss select 1) select [0,1]) + "."),
            ((_ss select 1) + " (AI)")
        ];
    } else {
        _name = [
            (((_ss select 0) select [0,1]) + "."),
            ((_ss select 1) + " (AI)")
        ];
    };

    ([(_name select 0) + " " + (_name select 1)] + _name)
};

DM_fnc_balanceAi = {
    params ["_relRoundNumber"];

    _sidesPlayers = [west, east] apply {_side = _x; (allPlayers select {(side (group _x)) == _side})};
    _sidesAIs = [west, east] apply {_side = _x; ((entities [["CAManBase"], [], true, false]) select {(simulationEnabled _x) && {alive _x} && {(side (group _x)) == _side} && {!(isPlayer _x)}})};

    _wantedAmount = 0;

    if (DM_var_aiMode == 0) then {
        _wantedAmount = 1 max (selectMax (_sidesPlayers apply {count _x}));
    } else {
        if (DM_var_aiMode == 1) then {
            _wantedAmount = 8 min (1 max (round (1.1 * (DM_var_zoneSize / 20000) ^ 0.93)));
        } else {
            _wantedAmount = DM_var_aiMode;
        };
    };
    
    {
        _side = _x;
        _diff = _wantedAmount - ((count (_sidesPlayers select ([0, 1] select (_side == east)))) + ({simulationEnabled _x} count (_sidesAIs select ([0, 1] select (_side == east)))));

        if (_diff > 0) then {
            for "_i" from 1 to _diff do {
                _possibleUnits = (call compile ("DM_var_suspendedUnits" + (str _side))) select {!(isNil "_x") && {!(isNull _x)}};
                if (_possibleUnits isEqualTo []) exitWith {};
                _unit = _possibleUnits select 0;
                _unit call (compile ("DM_var_suspendedUnits" + (str _side) + " deleteAt (DM_var_suspendedUnits" + (str _side) + " find _this);"));
                [_unit, _side, _relRoundNumber] spawn DM_fnc_aiPlayer;
            };
        } else {
            for "_i" from 1 to (-_diff) do {
                [selectRandom ((_sidesAIs select ([0, 1] select (_side == east))) select {!(isNull _x) && {local _x}})] call DM_fnc_suspendUnit;
            };
        };
    } forEach [west, east];
};

DM_fnc_despawnAi = {
    {
        [_x] call DM_fnc_suspendUnit;
    } forEach ((entities [["CAManBase"], [], true, false]) select {(simulationEnabled _x) && {!(isPlayer _x)} && {local _x}});
};

DM_fnc_aiPlayer = {
    params ["_unit", "_side", "_relRoundNumber"];

    if ((isNil "_unit") || {isNull _unit} || {isPlayer _unit}) exitWith {};

    _unit disableAI "ALL";
    _unit addPlayerScores [0, 0, 0, 0, 0];
    _unit setSkill (_unit getVariable "DM_var_aiSkill");

    [_unit, false] call ADG_fnc_allowDamage;

    _pos = getMarkerPos ("DM_mrk_" + (str _side) + "HQ");

    _safePos = [];
    _rad = 3;
    _startTime = serverTime;

    waitUntil {
        waitUntil {_pos findEmptyPositionReady [0, _rad]};
        _safePos = _pos findEmptyPosition [0, _rad, "B_Soldier_F"];
        _rad = _rad + 0.5;

        (
            (
                !(_safePos isEqualTo []) &&
                {
                    _safePosAsl = _safePos;
                    _safePosAsl set [2, 0];
                    _safePosAsl = AGLToASL _safePosAsl;
                    _safePosAsl set [2, ((_safePosAsl select 2) + 0.5)];

                    (([objNull, "VIEW"] checkVisibility [_safePosAsl, (_safePosAsl vectorAdd [0, 0, 100])]) != 0)
                }
            ) ||
            {if ((serverTime - _startTime) > 2) then {_safePos = _pos; true} else {false}}
        )
    };

    if ((isNil "_unit") || {isPlayer _unit}) exitWith {};

    _unit enableSimulationGlobal true;
    _unit setPos _safePos;

    ([_relRoundNumber] call DM_fnc_calculateItems) params ["_weps", "_items", "_mags", "_bags"];

    removeUniform _unit;
    removeVest _unit;
    removeBackpack _unit;
    removeHeadgear _unit;
    removeGoggles _unit;

    _unit removeItem (binocular _unit);
    _nvg = (hmd _unit);
    _unit unassignItem _nvg;
    _unit removeItem _nvg;

    _unit forceAddUniform (selectRandom (_items select {((_x find "Wetsuit") == -1) && (((_side == west) && ((_x select [0, 4]) == "U_B_")) || ((_side == east) && ((_x select [0, 4]) == "U_O_")))}));
    _unit addVest (selectRandom (_items select {((_x find "vest" != -1) || ((_x select [0, 2]) == "V_")) && ((_x find "Rebreather") == -1)}));
    _unit addBackpack (selectRandom _bags);
    _unit addHeadgear (selectRandom (_items select {(_x find "helmet" != -1) || ((_x select [0, 2]) == "H_")}));

    if ((isNil "_unit") || {isPlayer _unit}) exitWith {};

    if !DM_var_autoHealEnabled then {
        if (DM_var_roundNumber >= 19) then {
            _unit addItem "Medikit";
        } else {
            for "_i" from 1 to 4 do {
                _unit addItem "FirstAidKit";
            };
        };
    };

    _newNvg = selectRandom (_items select { (_x find "NVGoggles") != -1 });
    _unit addItem _newNvg;
    _unit assignItem _newNvg;

    removeAllWeapons _unit;
    _newPrimWep = selectRandom (_weps select {((_x call BIS_fnc_itemType) select 1) != "Handgun"});

    for "_i" from 0 to 8 do {
        _unit addMagazine (selectRandom (getArray (configFile >> "CfgWeapons" >> _newPrimWep >> "magazines")))
    };

    _unit addWeapon _newPrimWep;
    _unit addPrimaryWeaponItem (selectRandom (_items select {((_x select [0, 6]) == "optic_") || ((_x find "_o_") != -1)}));
    _hguns = _weps select {((_x call BIS_fnc_itemType) select 1) == "Handgun"};

    if ((count _hguns) != 0) then {
        _newHgunWep = selectRandom _hguns;

        for "_i" from 0 to 2 do {
            _unit addMagazine (selectRandom (getArray (configFile >> "CfgWeapons" >> _newHgunWep >> "magazines")))
        };

        _unit addWeapon _newHgunWep;
    };

    if ((isNil "_unit") || {isPlayer _unit}) exitWith {};

    waitUntil {alive _unit};

    [_unit] spawn {
        params ["_unit"];

        sleep 3;

        if !(isNull _unit) then {
            waitUntil {DM_var_movingEnabled};
            
            if !(isNull _unit) then {
                [_unit, true] call ADG_fnc_allowDamage;
            };
        };
    };
    
    waitUntil {DM_var_movingEnabled};

    (group _unit) setCombatBehaviour "COMBAT";
    _unit setCombatBehaviour "COMBAT";
    (group _unit) setCombatMode "RED";
    _unit setUnitCombatMode "RED";
    _unit enableAI "all";
    _destination = [0, 0];
    _lastOrder = 0;
    if ((isNil "_unit") || {isPlayer _unit}) exitWith {};

    waitUntil {
        if ((isNil "_unit") || {isPlayer _unit}) exitWith {true};

        if ((alive _unit) && {!(_destination inArea "DM_mrk_playZone") || {(_unit distance _destination) < 1}}) then {
            _pos = "DM_mrk_playZone" call BIS_fnc_randomPosTrigger;
            _safePos = [];
            _rad = 3;
            _startTime = serverTime;

            waitUntil {
                waitUntil {_pos findEmptyPositionReady [0, _rad]};
                _safePos = _pos findEmptyPosition [0, _rad, "B_Soldier_F"];
                _rad = _rad + 0.5;

                (
                    (
                        !(_safePos isEqualTo []) &&
                        {
                            _safePosAsl = _safePos;
                            _safePosAsl set [2, 0];
                            _safePosAsl = AGLToASL _safePosAsl;
                            _safePosAsl set [2, ((_safePosAsl select 2) + 0.5)];

                            (([objNull, "VIEW"] checkVisibility [_safePosAsl, (_safePosAsl vectorAdd [0, 0, 100])]) != 0)
                        }
                    ) ||
                    {if ((serverTime - _startTime) > 2) then {_safePos = _pos; true} else {false}}
                )
            };

            if (alive _unit) then {
                _destination = _safePos;
                _unit doMove _destination;
                _lastOrder = time;
            };
        } else {
            if (((time - _lastOrder) >= 3) && (((speed _unit) < 2) || !(_unit inArea "DM_mrk_playZone"))) then {
                _unit doMove _destination;
                _lastOrder = time;
            };
        };
        
        !(alive _unit)
    };
};

DM_fnc_spawnVehiclesForSides = {
    {
        _side = _x;
        _playerNum = ({(simulationEnabled _x) && {(side (group _x)) == _side} && {!([_x] call KF_fnc_isUavAi)}} count (entities [["CAManBase"], [], true, true]));
        [_side, _playerNum] spawn DM_fnc_spawnVehicles;
    } forEach [west, east];
};

DM_fnc_roundStartedNotification = {
    params ["_roundNumber"];

    _newEquipmentUnlocked = if (!DM_var_loadoutsRestricted || (_roundNumber == 1)) then {false} else {
        _relRoundNumber = [_roundNumber] call DM_fnc_relativeRoundNumber;
        _oldRelRoundNumber = [_roundNumber - 1] call DM_fnc_relativeRoundNumber;

        ({_x >= _relRoundNumber} count [2, 7, 13, 19, 25]) > ({_x >= _oldRelRoundNumber} count [2, 7, 13, 19, 25])
    };

    ["teamDeathmatch", [["Round starts in 30 seconds", (if _newEquipmentUnlocked then {"New equipment unlocked"} else {""})] joinString ". "]] call DM_fnc_showNotificationGlobal;
};

DM_fnc_assignVehiclesToAiUnits ={
    {
        _veh = _x;
        {
            _unit = _x;

            if ((simulationEnabled _x) && {!(isPlayer _unit)}) then {
                (group _unit) addVehicle _veh;
            };
        } forEach (entities [["CAManBase"], [], true, false]);
    } forEach vehicles;
};

DM_fnc_cleanUp = {
    {{deleteVehicle _x;} forEach _x;} forEach (
        (
            [
                "GroundWeaponHolder",
                "WeaponHolderSimulated",
                "#slop",
                "#mark",
                "#crateronvehicle",
                "#crater",
                "#track",
                "#objectdestructed",
                "#explosion"
            ] apply {allMissionObjects _x}
        ) +
        [vehicles]
    );

    {
        if !((_x isKindOf "CAManBase") && {_x in playableUnits}) then {
            deleteVehicle _x;
        };
    } forEach allDead;

    {
        _x setDamage 0;
        _num = getNumber(configFile >> "CfgVehicles" >> (typeOf _x) >> "numberofdoors");

        if (_num > 0) then {
            for "_i" from 1 to _num do {
                _x animateSource[(format ["Door_%1_sound_source", _i]), 0];
            };
        };
    } forEach (
        (
            [[(getMarkerPos "DM_mrk_playZone"), [], (1.5 * (selectMax (getMarkerSize "DM_mrk_playZone")))]] apply {
                (nearestObjects(_x + [true])) +
                (nearestTerrainObjects(_x + [false, true]))
            }
        ) select 0
    );
};