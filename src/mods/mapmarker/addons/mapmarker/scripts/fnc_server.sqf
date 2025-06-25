MM_var_serverRunning = nil;
MM_var_entityCreatedEhId = -1;
MM_var_remoteExecId = "";
MM_fnc_broadcastUnitPosAndDirLoopScript = scriptNull;
MM_var_entities = [];

_mapSizeConfig = configFile >> "CfgWorlds" >> worldName >> "mapSize";

if (isNull _mapSizeConfig) then {
    _centerPos = getArray (configfile >> "CfgWorlds" >> worldname >> "centerPosition");
    MM_var_mapScaleFactor = 0.0000001 * (_centerPos select 0) * (_centerPos select 1);
} else {
    MM_var_mapScaleFactor = 0.00035 * (getNumber (configFile >> "CfgWorlds" >> worldName >> "mapSize"));
};

MM_var_serverPosUpdateIntervalTarget = 0.1;
MM_var_ShowAllSides = false;
MM_var_ShowAllSidesOnSpectator = false;
MM_var_showUnitNames = true;
MM_var_showUnitNamesOnlyOnHover = false;
MM_var_showAliveGroupUnits = true;
MM_var_restrictUnitIcons = false;

publicVariable "MM_var_mapScaleFactor";
publicVariable "MM_var_ShowAllSides";
publicVariable "MM_var_ShowAllSidesOnSpectator";
publicVariable "MM_var_showUnitNames";
publicVariable "MM_var_showUnitNamesOnlyOnHover";
publicVariable "MM_var_showAliveGroupUnits";
publicVariable "MM_var_restrictUnitIcons";

MM_fnc_getConfigEntry = {
    params ["_typeName"];

    _entryStr = switch true do {
        case (_typeName isKindOf [_typeName, (configFile >> "CfgMagazines")]): {"CfgMagazines"};
        case (_typeName isKindOf [_typeName, (configFile >> "CfgAmmo")]): {"CfgAmmo"};
        case (_typeName isKindOf [_typeName, (configFile >> "CfgVehicles")]): {"CfgVehicles"};
        case (_typeName isKindOf [_typeName, (configFile >> "CfgWeapons")]): {"CfgWeapons"};
        default {""};
    };

    if (_entryStr == "") then {objNull} else {
        (configfile >> _entryStr >> _typeName)
    }
};

MM_fnc_GetDisplayName = {
    params ["_typeName"];

    _configEntry = [_typeName] call MM_fnc_getConfigEntry;

    if (isNull _configEntry) then {""} else {getText (_configEntry >> "displayName")}
};

MM_fnc_getName = {
    params ["_unit"];

    _name = "";

    if (unitIsUAV _unit) then {
        _name = [([typeOf _unit] call MM_fnc_GetDisplayName), "(AI)"] joinString " ";
    } else {
        _name = name _unit;

        if (isPlayer _unit) then {_name} else {
            _ss = _name splitString " ";

            if ((count _ss) > 1) then {
                _sss = (_ss select 0) splitString "-";

                if ((count _sss) > 1) then {
                    _name = ((_sss select 0) select [0,1]) + ".-" + ((_sss select 1) select [0,1]) + ". " + (_ss select 1);
                } else {
                    _name = ((_ss select 0) select [0,1]) + ". " + (_ss select 1);
                };
            };
            
            _name = _name + " (AI)";
        };
    };

    _name
};

MM_fnc_getIcon = {
    params ["_object"];

    if (_object isKindOf "Car_F") exitWith {"iconCar"};
    if (_object isKindOf "Helicopter_Base_F") exitWith {"iconHelicopter"};
    if (_object isKindOf "Tank_F") exitWith {"iconTank"};
    if ((_object isKindOf "Plane_Base_F") || {_object isKindOf "Plane"}) exitWith {"iconPlane"};
    if (_object isKindOf "Ship_F") exitWith {"iconShip"};

    "iconStaticAA"
};

MM_fnc_getTeamMapColor = {
    params ["_side"];

    switch _side do {
        case west: {[0, 0.5, 1, 1]};
        case east: {[1, 0, 0, 1]};
        case independent: {[0, 0.8, 0.27, 1]};
        default {[0.75, 0.75, 0.75, 1]};
    }
};

MM_fnc_broadcastUnitPosAndDirLoop = {
    waitUntil {
        _timeStart = time;

        {
            if (!(isNull _x) && {simulationEnabled _x} && {!(_x isKindOf "CAManBase") || {isNull (objectParent _x)}}) then {
                [_x, (getPosWorldVisual _x), (getDirVisual _x)] remoteExecCall ["MM_fnc_updateServerPosAndDir", -2];
            };
        } forEach MM_var_entities;

        sleep (0 max (0.04 - (time - _timeStart)));

        false
    };
};

MM_fnc_entityInitServer = {
    params ["_entity"];

    _startTime = time;
    waitUntil {(isNil "_entity") || {!(isNull _entity)} || {(time - _startTime) > 3}};
    if ((isNil "_entity") || {isNull _entity}) exitWith {};

    _this call {
        params ["_entity"];

        if (isNil {_entity getVariable "MM_var_initDone"}) then {
            _entity setVariable ["MM_var_initDone", true];

            if (_entity isKindOf "CAManBase") then {
                if (isNil {_entity getVariable "MM_var_name"}) then {
                    _entity setVariable ["MM_var_name", ([_entity] call MM_fnc_getName), true];
                };

                _side = side (group _entity);
                _entity setVariable ["MM_var_side", _side, true];
                _entity setVariable ["MM_var_color", ([_side] call MM_fnc_getTeamMapColor), true];
            } else {
                _entity setVariable ["MM_var_icon", [_entity] call MM_fnc_getIcon, true];
                _entity setVariable ["MM_var_iconSize", (16 * ((getMass _entity) ^ 0.04)), true];
                _entity setVariable ["MM_var_name", (getText (configfile >> "CfgVehicles" >> (typeOf _entity) >> "displayName")), true];
                _entity setVariable ["MM_var_lastDrawArrUpdateFrameNo", 0, true];
            };
            
            if isMultiplayer then {
                MM_var_entities pushBackUnique _entity;

                _id = _entity addEventHandler ["Respawn", {
	                params ["_newEntity", "_oldEntity"];
                    MM_var_entities set [MM_var_entities find _oldEntity, _newEntity];
                }];

                _entity setVariable ["MM_var_respawnEhId", _id];

                _id = _entity addEventHandler ["Deleted", {
                    params ["_entity"];
                    MM_var_entities deleteAt (MM_var_entities find _entity);
                }];

                _entity setVariable ["MM_var_deletedEhId", _id];
            };
        };

        [[_entity], {if !(isNil "MM_var_clientInitDone") then {_this call MM_fnc_entityInitClient};}] remoteExecCall ["call", 0];
    };
};

MM_fnc_startMapMarkerServer = {
    call {
        if (isNil "MM_var_serverRunning") then {
            MM_var_serverRunning = true;

            MM_var_entities = entities [["AllVehicles"], ["Animal"], true, false];

            {
                [_x] spawn MM_fnc_entityInitServer;
            } forEach MM_var_entities;

            MM_var_entityCreatedEhId = addMissionEventHandler ["EntityCreated", {
                params ["_entity"];

                if ((_entity isKindOf "AllVehicles") && {!(_entity isKindOf "Animal")}) then {
                    [_entity] spawn MM_fnc_entityInitServer;
                };
            }];

            if isMultiplayer then {
                MM_fnc_broadcastUnitPosAndDirLoopScript = [] spawn MM_fnc_broadcastUnitPosAndDirLoop;
            } else {
                MM_var_entities = [];
            };

            MM_var_remoteExecId = [[], {if hasInterface then {waitUntil {!(isNil "MM_var_clientInitDone")}; call MM_fnc_startMapMarkerClient;};}] remoteExecCall ["spawn", 0, true];

            if !isMultiplayer then {
                MM_var_loadedEhId = addMissionEventHandler ["Loaded", {
                    call MM_fnc_stopMapMarkerServer;

                    [] spawn {
                        waitUntil {isNil "MM_var_serverRunning"};
                        call MM_fnc_startMapMarkerServer;
                    };
                }];
            };
        };
    };
};

MM_fnc_stopMapMarkerServer = {
    call {
        if !(isNil "MM_var_serverRunning") then {
            MM_var_serverRunning = nil;

            if isMultiplayer then {
                terminate MM_fnc_broadcastUnitPosAndDirLoopScript;
                MM_fnc_broadcastUnitPosAndDirLoopScript = scriptNull;

                {
                    _id = _x getVariable ["MM_var_respawnEhId", -1];
                    if (_id != -1) then {_x removeEventHandler ["Respawn", _id];};
                    _id = _x getVariable ["MM_var_deletedEhId", -1];
                    if (_id != -1) then {_x removeEventHandler ["Deleted", _id];};
                    _x setVariable ["MM_var_initDone", nil];
                } forEach MM_var_entities;

                MM_var_entities = [];
            };

            removeMissionEventHandler ["EntityCreated", MM_var_entityCreatedEhId];
            MM_var_entityCreatedEhId = -1;

            remoteExecCall ["", MM_var_remoteExecId];
            MM_var_remoteExecId = "";

            [[], {if hasInterface then {waitUntil {!(isNil "MM_var_clientInitDone")}; call MM_fnc_stopMapMarkerClient;};}] remoteExecCall ["spawn", 0];

            if !isMultiplayer then {
                removeMissionEventHandler ["Loaded", MM_var_loadedEhId];
                MM_var_loadedEhId = nil;
            };
        };
    };
};

MM_var_serverInitDone = true;
publicVariable "MM_var_serverInitDone";