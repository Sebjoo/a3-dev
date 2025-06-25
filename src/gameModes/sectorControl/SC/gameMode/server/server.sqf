SC_fnc_getSidestring = {
    switch (_this select 0) do {
        case west: {"Blufor"};
        case east: {"Opfor"};
        case independent: {"Independent"};
    };
};

SC_fnc_getHexColor = {
    params ["_side"];

    switch _side do {
        case west: {"#0066B3"};
        case east: {"#E60000"};
        case independent: {"#009933"};
        default {"#808080"};
    };
};

SC_fnc_distanceOfNearestObject = {
    params ["_object", "_types", "_distance"];

    _nearestObjects = nearestObjects [_object, _types, _distance, false];
    _pos = _nearestObjects findIf {(alive _x) && {!(_x isEqualTo _object)} && {!((objectParent _x) isEqualTo _object)}};

    (if (_pos == -1) then {_distance} else {(_nearestObjects select _pos) distance _object})
};

SC_fnc_HandleDisconnect = {
    params ["_unit", "_id", "_uid", "_name"];

    if ((name _unit) == _name) then {
        [_unit] spawn {
            params ["_unit"];

            waitUntil {!(isPlayer _unit)};
            [_unit] call SC_fnc_deregisterEntityServer;
            [_unit] call SC_fnc_removeFromGroup;
            _par = objectParent _unit;

            if (isNull _par) then {
                [_unit] remoteExecCall ["deleteVehicle", _unit];

                [_unit] spawn {
                    params ["_unit"];

                    while {!(isNull _unit)} do {
                        sleep 1;
                        deleteVehicle _unit;
                    };
                };
            } else {
                [_par, _unit] remoteExecCall ["deleteVehicleCrew", _par];

                [_par, _unit] spawn {
                    params ["_par", "_unit"];

                    while {!(isNull _unit)} do {
                        sleep 1;
                        _par deleteVehicleCrew _unit;
                    };
                };
            };
        };
    };
};

SC_fnc_midfeedHeal = {
    params ["_healer", "_injured", "_xp"];

    [format [
        "<t size='%1' shadow='1' shadowOffset='%2'><t color='%3'>You</t> revived <t color='%4'>%5</t> %6 XP</t>",
        (0.6 * KF_var_fontSize),
        (0.05 * KF_var_fontSize),
        (if KF_var_MidFeedYouColorYellow then {"#ffd400"} else {"#ffffff"}),
        ([_injured getVariable ["KF_var_side", sideUnknown]] call KF_fnc_GetSidesHexColor),
        (_injured getVariable ["KF_var_name", "Error: no unit"]),
        _xp
    ]] remoteExecCall ["KF_fnc_AddMidFeedLine", _healer];
};

SC_fnc_airDrop = {
    params ["_dropMarker"];

    _box = createVehicle ["box_NATO_equip_F", [0, 0, 0], [], 0, "NONE"];
    _parachute = createVehicle ["Steerable_Parachute_F", [0, 0, 0], [], 0, "NONE"];

    waitUntil {!(isNull _box) && {!(isNull _parachute)}};

    _box setVariable ["SC_var_timeRemaining", "", true];
    clearItemCargoGlobal _box;
    [_box, false] call ADG_fnc_allowDamage;

    _safePos = [];
    _rad = 3;

    waitUntil {
        _safePos = _dropMarker call BIS_fnc_randomPosTrigger;

        !(surfaceIsWater _safePos) && {
            (_dropMarker != "SC_var_playZone") ||
            {
                (
                    SC_var_hugeMap ||
                    {(random [0, 0.3, 1]) > ((_safePos distance2D (getmarkerPos "SC_var_playZone")) / SC_var_maxZoneSize)}
                ) && {
                    (["SC_var_westBase", "SC_var_eastBase", "SC_var_guerBase"] findIf {
                        (_safePos distance2D (getmarkerPos _x)) < (1.4 * (selectMax (getMarkerSize _x)))
                    }) == -1
                } && {
                    ((entities "box_NATO_equip_F") findIf {
                        !(_x isEqualTo _box) && {(_safePos distance2D _x) < (0.25 * SC_var_maxZoneSize)}
                    }) == -1
                } && {
                    (SC_var_sectors findIf {
                        (_safePos distance2D (getmarkerPos ("SC_var_sector" + _x))) <
                        (selectMax (getMarkerSize ("SC_var_sector" + _x)) max (0.3 * (missionNamespace getVariable ("SC_var_nearestSectorDistance" + _x))))
                    }) == -1
                }
            }
        } && {
            _safePosAgl = _safePos;
            _safePosAgl set [2, 0];
            _safePosAsl = AGLToASL _safePosAgl;
            _safePosAsl set [2, ((_safePosAsl select 2) + 0.5)];

            (([objNull, "VIEW"] checkVisibility [_safePosAsl, (_safePosAsl vectorAdd [0, 0, 100])]) != 0)
        }
    };

    _parachute setPos (_safePos vectorAdd [0, 0, 150]);
    _box attachTo [_parachute, [0, 0, 0]];

    [_box, _parachute, _safePos] spawn {
        params ["_box", "_parachute", "_safePos"];

        waitUntil {
            _parachute setPosASL ((_safePos select [0, 2]) + [((visiblePositionASL _parachute) select 2) - 0.05]);
            _parachute setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];

            ((visiblePosition _box select 2) < 2)
        };

        detach _box;
        waitUntil {(speed _box) == 0};
        _time = SC_var_airDropDurationMins * 60;

        waitUntil {
            _time = _time - 1;
            _box setVariable ["SC_var_timeRemaining", ([_time] call SC_fnc_secondsToMinSec), true];
            sleep 1;

            (_time <= 0)
        };

        [_box] remoteExecCall ["deleteVehicle", _box];
    };

    ([sideEmpty, [], -1, false] call SC_fnc_getItemsUniqueAndGrouped) params ["_items", "_mags", "_groupedWeapons", "_groupedOptics", "_groupedSuppressors"];

    _cargo = [];
    _worth = 0;
    
    while {_worth < 600} do {
        _itemAndRank = selectRandom _items;
        _itemAndRank params ["_item", "_rank"];

        if ((([_item] call BIS_fnc_itemType) select 0) == "Weapon") then {
            _itemAndRank = selectRandom (_groupedWeapons select (_groupedWeapons findIf {_itemAndRank in _x}));
            _itemAndRank params ["_item", "_rank"];
            _possibleMags = _mags arrayIntersect (getArray (configFile >> "CfgWeapons" >> _item >> "magazines"));

            for "_i" from 1 to (selectRandom [5, 6, 7, 8, 9]) do {
                _cargo pushBack (selectRandom _possibleMags);
            };

            _muzzles = getArray (configFile >> "CfgWeapons" >> _item >> "muzzles");

            if !(_muzzles isEqualTo ["this"]) then {
                _secondaryMuzzle = (_muzzles - ["this"]) select 0;
                _possibleMags = _mags arrayIntersect (getArray (configFile >> "CfgWeapons" >> _item >> _secondaryMuzzle >> "magazines"));
                
                for "_i" from 1 to (selectRandom [3, 4, 5, 6, 7]) do {
                    _cargo pushBack (selectRandom _possibleMags);
                };
            };
        } else {
            if ((([_item] call BIS_fnc_itemType) select 1) == "AccessorySights") then {
                _itemAndRank = selectRandom (_groupedOptics select (_groupedOptics findIf {_itemAndRank in _x}));
                _itemAndRank params ["_item", "_rank"];
            } else {
                if ((([_item] call BIS_fnc_itemType) select 1) == "AccessoryMuzzle") then {
                    _itemAndRank = selectRandom (_groupedSuppressors select (_groupedSuppressors findIf {_itemAndRank in _x}));
                    _itemAndRank params ["_item", "_rank"];
                };
            };
        };

        _cargo pushBack _item;
        _worth = _worth + _rank;
    };

    {
        _box addItemCargoGlobal [_x, 1];
    } forEach _cargo;
};

SC_fnc_UAVControl = {
    params ["_unit", "_mode", ["_altMode", ""]];
    _ret = objNull;

    _UAVControl = UAVControl _unit;
    _UAVControls = [_UAVControl select [0, 2]];

    if ((count _UAVControl) == 4) then {
        _UAVControls pushBack (_UAVControl select [2, 2]);
    };

    _pos = (_UAVControls apply {_x select 1}) find _mode;

    if (_pos != -1) then {
        _ret = (_UAVControls select _pos) select 0;
    } else {
        if (_altMode != "") then {
            _pos = (_UAVControls apply {_x select 1}) find _altMode;

            if (_pos != -1) then {
                _ret = (_UAVControls select _pos) select 0;
            };
        };
    };

    _ret
};

SC_fnc_UAVControlUnits = {
    params ["_vehicle", ["_onlyControlling", false]];

    _UAVControl = UAVControl _vehicle;
    _UAVControls = [_UAVControl select [0, 2]];

    if ((count _UAVControl) == 4) then {
        _UAVControls pushBack (_UAVControl select [2, 2]);
    };

    if _onlyControlling then {
        (_UAVControls select {(_x select 1) != ""}) apply {_x select 0}
    } else {
        (_UAVControls select {!(isNull (_x select 0))}) apply {_x select 0}
    }
};

SC_fnc_getSidesUnits = {
    params ["_side"];

    missionNamespace getVariable (["SC_var_Units", (str _side)] joinString "")
};

SC_fnc_getSidesUavAiUnits = {
    params ["_side"];

    missionNamespace getVariable (["SC_var_uavAiUnits", (str _side)] joinString "")
};

SC_fnc_registerEntityServer = {
    params ["_entity"];

    _varStr = "";
    _numVarStr = "";

    if (_entity isKindOf "CAManBase") then {
        _side = side (group _entity);
        _entity setVariable ["SC_var_side", _side];

        if ([_entity] call SC_fnc_isUavAi) then {
            _varStr = ["SC_var_uavAiUnits", (str _side)] joinString "";
            _numVarStr = ["SC_var_numUavAiUnits", (str _side)] joinString "";
        } else {
            _varStr = ["SC_var_units", (str _side)] joinString "";
            _numVarStr = ["SC_var_numUnits", (str _side)] joinString "";
        };
    } else {
        _varStr = "SC_var_vehicles";
        _numVarStr = "SC_var_numVehicles";
    };

    if ((random 1) < 0.01) then {
        call (compile ([_varStr, " = ", _varStr, " - [objNull];"] joinString ""));
    };
    
    _entity call (compile ([_varStr, " pushBackUnique _this;"] joinString ""));

    call (compile ([_numVarStr, " = count ", _varStr, ";"] joinString ""));
    publicVariable _numVarStr;
};

SC_fnc_deregisterEntityServer = {
    params ["_entity"];

    _varStr = "";
    _numVarStr = "";

    if (_entity isKindOf "CAManBase") then {
        _side = _entity getVariable ["SC_var_side", sideUnknown];
        if (_side == sideUnknown) exitWith {};
        _sideStr = str _side;

        if ([_entity] call SC_fnc_isUavAi) then {
            _varStr = ["SC_var_uavAiUnits", _sideStr] joinString "";
            _numVarStr = ["SC_var_numUavAiUnits", _sideStr] joinString "";
        } else {
            _varStr = ["SC_var_units", _sideStr] joinString "";
            _numVarStr = ["SC_var_numUnits", _sideStr] joinString "";
        };
    } else {
        _varStr = "SC_var_vehicles";
        _numVarStr = "SC_var_numVehicles";
    };

    if ((random 1) < 0.01) then {
        call (compile ([_varStr, " = ", _varStr, " - [objNull];"] joinString ""));
    };
    
    _pos = _entity call (compile ([_varStr, " find _this"] joinString ""));

    if (_pos != -1) then {
        _pos call (compile ([_varStr, " deleteAt _this;"] joinString ""));
    };

    call (compile ([_numVarStr, " = count ", _varStr, ";"] joinString ""));
    publicVariable _numVarStr;
};

SC_fnc_EntityKilled = {
    params ["_unit", "_killer", "_instigator", "_useEffects"];

    if (_unit isKindOf "CAManBase") then {
        _group = group _unit;
        
        if ((units _group) isEqualTo [_unit]) then {
            {_group leaveVehicle _x;} forEach (assignedVehicles _group);
        };

        if !(isPlayer _unit) then {
            if ([_unit] call SC_fnc_isUavAi) then {
                [_unit] call SC_fnc_deregisterEntityServer;
            };

            _sector = _unit getVariable ["SC_var_movingToSector", objNull];
        };
    } else {
        _vehicle = _unit;

        {
            _x params ["_crewUnit", "", "", "", "", "_assignedUnit"];
            
            {
                _group = group _x;

                if ((units _group) isEqualTo []) then {
                    _group leaveVehicle _vehicle;
                };
            } forEach [_crewUnit, _assignedUnit];
        } forEach (fullCrew _vehicle);
    };
};

SC_fnc_switchGroup = {
    params ["_unitToSwitch", "_unitToSwitchTo"];

    _groupToSwitchFrom = (_unitToSwitch getVariable ["SC_var_groupUnits", [_unitToSwitch]]) - [_unitToSwitch];
    _groupToSwitchTo = (_unitToSwitchTo getVariable ["SC_var_groupUnits", [_unitToSwitchTo]]) + [_unitToSwitch];
    _groupToSwitchTo = [_groupToSwitchTo, [], {name _x}, "DESCEND"] call BIS_fnc_sortBy;

    {
        _x setVariable ["SC_var_groupUnits", _groupToSwitchFrom];
    } forEach _groupToSwitchFrom;

    {
        _x setVariable ["SC_var_groupUnits", _groupToSwitchTo];
    } forEach _groupToSwitchTo;
};

SC_fnc_updateGroupAfterRespawn = {
    params ["_oldEntity", "_newEntity"];

    _group = ((_oldEntity getVariable ["SC_var_groupUnits", [_oldEntity]]) - [_oldEntity]) + [_newEntity];
    _group = [_group, [], {name _x}, "DESCEND"] call BIS_fnc_sortBy;
    _oldEntity setVariable ["SC_var_groupUnits", [_oldEntity], true];

    {
        _x setVariable ["SC_var_groupUnits", _group, true];
    } forEach _group;
};

SC_fnc_removeFromGroup = {
    params ["_unit"];

    _group = ((_unit getVariable ["SC_var_groupUnits", [_unit]]) - [_unit]);
    _unit setVariable ["SC_var_groupUnits", [_unit], true];
    
    {
        _x setVariable ["SC_var_groupUnits", _group, true];
    } forEach _group;
};

SC_fnc_EntityRespawned = {
    params ["_newEntity", "_oldEntity"];

    [_oldEntity, _newEntity] call SC_fnc_updateGroupAfterRespawn;

    if (_newEntity isKindOf "CAManBase") then {
        if (isPlayer _newEntity) then {
            _newEntity setVariable ["SC_var_timeRemaining", SC_var_unitDespawnTime];
            [_newEntity] call SC_fnc_registerEntityServer;

            _parEntity = objectParent _newEntity;

            if !(isNull _parEntity) then {
                _playerGroupMatesInVehicle = (([_newEntity] call SC_fnc_getGroupUnits) - [_newEntity]) select {(alive _x) && {isPlayer _x} && {(objectParent _x) isEqualTo _parEntity}};

                if !(_playerGroupMatesInVehicle isEqualTo []) then {
                    ["groupMateSpawned", [(_newEntity getVariable "SC_var_name"), ("in your " + ([(typeOf _newEntity)] call SC_fnc_getDisplayName))]] remoteExec ["BIS_fnc_showNotification", _playerGroupMatesInVehicle];
                };
            } else {
                _possibleMarkers = (SC_var_sectors apply {"SC_var_sector" + _x}) + ["SC_var_" + (toLower (str (side (group _newEntity)))) + "Respawn"];
                _possibleGroupUnits = (([_newEntity] call SC_fnc_getGroupUnits) - [_newEntity]) select {alive _x};

                _closestMarker = _possibleMarkers select 0;
                {
                    if ((_newEntity distance (getMarkerPos _x)) < (_newEntity distance (getMarkerPos _closestMarker))) then {
                        _closestMarker = _x;
                    };
                } forEach _possibleMarkers;

                _closestGroupUnit = _possibleGroupUnits select 0;
                {
                    if ((_newEntity distance _x) < (_newEntity distance _closestGroupUnit)) then {
                        _closestGroupUnit = _x;
                    }
                } forEach _possibleGroupUnits;

                if ((isPlayer _closestGroupUnit) && {(_newEntity distance _closestGroupUnit) < (_newEntity distance (getMarkerPos _closestMarker))}) then {
                    ["groupMateSpawned", [(_newEntity getVariable "SC_var_name"), "on your position"]] remoteExec ["BIS_fnc_showNotification", _closestGroupUnit];
                };
            };
        } else {
            [_newEntity] call SC_fnc_suspendUnit;
        };
    };
};

SC_fnc_addGroundWeaponHolder = {
    params ["_container"];

    _container setVariable ["SC_var_timeRemaining", SC_var_unitDespawnTime];
    SC_var_GroundWeaponHolders pushBack _container;

    _container addEventHandler ["Deleted", {
        params ["_container"];

        SC_var_GroundWeaponHolders deleteAt (SC_var_GroundWeaponHolders find _container);
    }];
};

SC_fnc_playerServer = {
    params ["_player"];

    _side = side (group _player);
    _player setVariable ["SC_var_name", (name _player), true];
    _varStr = "SC_var_suspendedUnits" + (str _side);
    _pos = (call (compile _varStr)) find _player;

    if (_pos != -1) then {
        _pos call (compile (_varStr + " deleteAt _this;"));
    };

    _player setVariable ["SC_var_side", _side];
    _player setVariable ["SC_var_vehicleCooldown", 0, true];
    _player setVariable ["SC_var_vehicleActionCooldown", 0];
    _player setVariable ["SC_var_timeRemaining", SC_var_unitDespawnTime];
    _player setVariable ["SC_var_isWatched", false];

    [_player] call SC_fnc_registerEntityServer;

    _id = _player getVariable "SC_var_respawnPositionId";

    if !(isNil "_id") then {
        [_player, _id] call BIS_fnc_removeRespawnPosition;
    };
    
    [_player] remoteExecCall ["SC_fnc_addHandleHeal", 0];
};