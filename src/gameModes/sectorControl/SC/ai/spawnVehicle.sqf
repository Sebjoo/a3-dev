SC_fnc_spawnVehicle = {
    params ["_unit", "_place", "_type", ["_planeOrVehSpawnId", -1]];

    if (isNull _unit) exitWith {};

    _wasPlayer = isPlayer _unit;

    if (isNil "_type") exitWith {};

    scopeName "main";

    _side = side (group _unit);
    _isPlane = (_type isKindOf "Plane_Base_F") || {_type isKindOf "Plane"};

    if (isPlayer _unit) then {
        _vac = _unit getVariable "SC_var_vehicleActionCooldown";

        if (_vac != 0) then {
            if (_vac > 5) then {
                ["vehicleCooldown", ["Vehicle spawn is in progress"]] remoteExec ["BIS_fnc_showNotification", _unit];
            };
            breakOut "main";
        };

        _vc = _unit getVariable "SC_var_vehicleCooldown";

        if !(_vc == 0) then {
            ["vehicleCooldown", ["Vehicle spawn cooldown active: " + ([_vc] call SC_fnc_secondsToMinSec)]] remoteExec ["BIS_fnc_showNotification", _unit];
            _unit setVariable ["SC_var_vehicleActionCooldown", 5];
            breakOut "main";
        };

        if (!SC_var_hugeMap && {(SC_var_numVehiclesSides select (SC_var_sides find _side)) >= SC_var_maximumVehicleAmount}) then {
            ["vehicleCooldown", ["The maximum number of vehicles has been reached"]] remoteExec ["BIS_fnc_showNotification", _unit];
            _unit setVariable ["SC_var_vehicleActionCooldown", 5];
            breakOut "main";
        };

        _unit setVariable ["SC_var_vehicleCooldown", 9999, true];
        _unit setVariable ["SC_var_vehicleActionCooldown", 9999, true];
    };

    _pos = if (_planeOrVehSpawnId != -1) then {
        getPosATL (missionNamespace getVariable ("SC_var_" + (if _isPlane then {"plane"} else {"veh"}) + "Spawn" + (str _planeOrVehSpawnId)))
    } else {
        if (_place == "the Base") then {
            getPosATL (missionNamespace getVariable ("SC_var_" + (str _side) + (if _isPlane then {"Plane"} else {"Veh"}) + "Spawn"))
        } else {
            getMarkerPos ("SC_var_sector" + _place)
        };
    };
    
    _safePos = [];
    _rad = 7;
    _semaphoreVar = "SC_var_" + (["vehicle", "plane"] select _isPlane) + "SpawnSemaphore" + ([(toLower (str _side)), (str _planeOrVehSpawnId)] select (_planeOrVehSpawnId != -1));

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

    _startTime = serverTime;

    waitUntil {
        if ((isNil "_safePos") || {_safePos isEqualTo []}) then {
            waitUntil {_pos findEmptyPositionReady [0, _rad]};
            _safePos = _pos findEmptyPosition [0, _rad, _type];
            _rad = _rad + 1.5;

            ((serverTime - _startTime) > 60)
        } else {
            true
        }
    };

    if (_safePos isEqualTo []) then {
        missionNameSpace setVariable [_semaphoreVar, false];
        
        if (isPlayer _unit) then {
            ["vehiclesystem", ["Vehicle could not be spawned, cooldown reset."]] remoteExec ["BIS_fnc_showNotification", _unit];
            _unit setVariable ["SC_var_vehicleCooldown", 0, true];
            _unit setVariable ["SC_var_vehicleActionCooldown", 5, true];
        };
    } else {
        _veh = [_type, _safePos] call {
            params ["_type", "_safePos"];

            _veh = createVehicle [_type, _safePos, [], 7, "NONE"];
            _veh setVariable ["BIS_enableRandomization", false];
            [_veh, false] call ADG_fnc_allowDamage;
            [_veh] remoteExecCall ["SC_fnc_addHandleDamageToVehicle", 0, true];
            _veh disableTIEquipment true;

            _veh
        };

        waitUntil {!(isNull _veh)};

        [_veh, [
            "<img size='1.2' shadow='2' image='\A3\ui_f\data\Map\vehicleicons\iconParachute_ca.paa'/> Parachute Jump",
            {[player] spawn SC_fnc_heliParachuteJump},
            nil, 1.5, false, false, "", "((getposATL player) select 2) > 15"
        ]] remoteExecCall ["addAction", 0, true];

        [_veh, [
            "Order AI to leave Vehicle",
            {_this call SC_fnc_moveAiOutOfVehicle},
            nil, 1.5, false, false, "", "[_target] call SC_fnc_canMoveAIOutofVehicle", 5
        ]] remoteExecCall ["addAction", 0, true];

        [_veh, [
            "Lock Vehicle",
            {_this call SC_fnc_lockVehicle},
            nil, 1.5, false, false, "", "[_target] call SC_fnc_can_lockVehicle", 5
        ]] remoteExecCall ["addAction", 0, true];

        [_veh, [
            "Unlock Vehicle",
            {_this call SC_fnc_unlockVehicle},
            nil, 1.5, false, false, "", "[_target] call SC_fnc_canUnlockVehicle", 5
        ]] remoteExecCall ["addAction", 0, true];

        _veh setVariable ["SC_var_lockerUid", -1, true];
        _veh setVariable ["SC_var_timeRemaining", SC_var_vehicleDespawnTime];
        _veh setVariable ["SC_var_posAtServerTime", [_safePos, serverTime]];
        _veh setVariable ["KF_var_side", _side];
        [_veh] call SC_fnc_registerEntityServer;

        if _isPlane then {
            _veh setDir (getDir (missionNameSpace getVariable (
                if (_planeOrVehSpawnId != -1) then {
                    "SC_var_planeSpawn" + (str _planeOrVehSpawnId)
                } else {
                    "SC_var_" + (str _side) + "PlaneSpawn"
                }
            )));
        };
        
        _veh setUnloadInCombat [true, false];
        _veh allowCrewInImmobile [false, false];

        [_semaphoreVar, _isPlane, _veh] spawn {
            params ["_semaphoreVar", "_isPlane", "_veh"];

            if _isPlane then {
                _pos = getPosWorld _veh;

                waitUntil {
                    sleep 1;

                    (isNull _veh) ||
                    {!(alive _veh)} ||
                    {!(canMove _veh)} ||
                    {((getPosWorld _veh) distance _pos) > 30} ||
                    {((crew _veh) findIf {alive _x}) == -1}
                };
            } else {
                sleep 4;
            };

            missionNameSpace setVariable [_semaphoreVar, false];
        };

        _typeString = [_type] call SC_fnc_getDisplayName;
        _textEnd = format ["spawned a%1 at %2", ((if ((_typeString select [0, 1]) in ["A", "E", "I", "O", "U"]) then {"n "} else {" "}) + _typeString), _place];
        _grpUnits = ([_unit] call SC_fnc_getGroupUnits) - [_unit];

        if !(_grpUnits isEqualTo []) then {
            ["vehiclesystem", [format ["Your groupmate %1 %2", (_unit getVariable "SC_var_name"), _textEnd]]] remoteExec ["BIS_fnc_showNotification", (_grpUnits select {isPlayer _x})];
        };

        if ((isPlayer _unit) && {_wasPlayer}) then {
            _unit setVariable ["SC_var_vehicleCooldown", 300, true];
            _unit setVariable ["SC_var_vehicleActionCooldown", 5, true];
            _unitText = "You " + _textEnd;
            ["vehiclesystem", [_unitText]] remoteExec ["SC_fnc_showNotificationIfHudIsEnabled", _unit];
        } else {
            if !(unitIsUav _veh) then {
                (group _unit) addVehicle _veh;
                _unit assignAsDriver _veh;
                _unit moveInDriver _veh;

                if !(isPlayer _unit) then {
                    [_unit] spawn SC_fnc_sendUnitToAnySector;
                };
            };
        };

        (group _unit) setCombatBehaviour "COMBAT";
        _unit setCombatBehaviour "COMBAT";
        (group _unit) setCombatMode "RED";
        _unit setUnitCombatMode "RED";
        _unit enableAI "all";
        _unit setUnitPos "AUTO";

        clearBackpackCargoGlobal _veh;
        clearItemCargoGlobal _veh;
        clearMagazineCargoGlobal _veh;
        clearWeaponCargoGlobal _veh;
        _veh addItemCargoGlobal ["ToolKit", 1];

        _veh addItemCargoGlobal ["Medikit", 1];
        _veh addItemCargoGlobal ["FirstAidKit", 10];

        if (unitIsUav _veh) then {
            _side createVehicleCrew _veh;
            _crew = crew _veh;
            _grpCrew = createGroup [_side, true];
            _crew joinSilent _grpCrew;
            _grpCrew setCombatBehaviour "COMBAT";
            _grpCrew setCombatMode "RED";

            {
                _x setCombatBehaviour "COMBAT";
                _x setUnitCombatMode "RED";
                _x enableAI "all";

                _x setVariable ["SC_var_isWatched", false];
                _x setVariable ["SC_var_movingToSector", objNull];
                _x setVariable ["SC_var_movingToSectorInd", ""];

                [_x] call SC_fnc_registerEntityServer;
            } forEach _crew;
            
            {
                _x linkItem "ItemMap";
                _x linkItem "ItemGPS";
                _x linkItem "H_PilotHelmetFighter_B";
            } forEach (crew _veh);

            if ((isPlayer _unit) && {!_wasPlayer}) exitWith {};

            if ((side _veh) != _side) then {
                sleep 1;

                _veh setPosWorld (getPosWorld _unit);
                _amimationState = animationState _unit;
                _unit action ["UAVTerminalHackConnection", _veh];
                _veh setPosWorld _safePos;
                _veh setDamage 0;
                _unit switchMove _amimationState;

                sleep 1;

                _veh setVariable ["KF_var_hits", []];
            };
            
            _unit connectTerminalToUAV _veh;
        };

        if (((count _place) > 1) && {_planeOrVehSpawnId == -1}) then {
            if ((isPlayer _unit) && _wasPlayer) then {
                [_unit, _veh] remoteExecCall ["moveInDriver", _unit];
                [_unit] spawn SC_fnc_sendUnitToAnySector;
            };

            [_veh, _safePos, _side] spawn {
                params ["_veh", "_safePos", "_side"];

                _baseMarker = "SC_var_" + (str _side) + "Base";
                _radiusProtexted = 0.7 * ((((getMarkerSize _baseMarker) select 0) + ((getMarkerSize _baseMarker) select 0)) / 2);
                _baseMarkerPos = getMarkerPos _baseMarker;

                waitUntil {
                    sleep 1;
                    ((_veh distance _baseMarkerPos) > _radiusProtexted)
                };

                [_veh, true] call ADG_fnc_allowDamage;
                _playersInCrew = (crew _veh) select {isPlayer _x};

                if !(_playersInCrew isEqualTo []) then {
                    ["vehiclesystem", ["Your vehicle is now vulnerable"]] remoteExec ["BIS_fnc_showNotification", _playersInCrew];
                };
            };
        } else {
            [_veh] spawn {
                params ["_veh"];

                sleep 3;

                if (alive _veh) then {
                    [_veh, true] call ADG_fnc_allowDamage;
                };
            };
        };
    };
};