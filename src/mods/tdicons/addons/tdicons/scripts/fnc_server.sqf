TDI_var_serverRunning = nil;
TDI_var_entityCreatedEhId = -1;
TDI_var_remoteExecId = "";

TDI_var_ShowAllSides = false;
TDI_var_ShowAllSidesOnSpectator = false;
TDI_var_DrawUnitsOnSpectator = true;
TDI_var_ShowUnitNames = true;
TDI_var_HideInvisible = true;
TDI_var_ShowGroupIcons = false;
TDI_var_HideInvisibleGroupMembers = false;
TDI_var_groupUnitsLimitedDistance = false;

publicVariable "TDI_var_ShowAllSides";
publicVariable "TDI_var_ShowAllSidesOnSpectator";
publicVariable "TDI_var_DrawUnitsOnSpectator";
publicVariable "TDI_var_ShowUnitNames";
publicVariable "TDI_var_HideInvisible";
publicVariable "TDI_var_ShowGroupIcons";
publicVariable "TDI_var_HideInvisibleGroupMembers";
publicVariable "TDI_var_groupUnitsLimitedDistance";

TDI_fnc_getConfigEntry = {
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

TDI_fnc_GetDisplayName = {
    params ["_typeName"];

    _configEntry = [_typeName] call TDI_fnc_getConfigEntry;

    if (isNull _configEntry) then {""} else {getText (_configEntry >> "displayName")}
};

TDI_fnc_getName = {
    params ["_unit"];

    _name = "";

    if (unitIsUAV _unit) then {
        _name = [([typeOf _unit] call TDI_fnc_GetDisplayName), "(AI)"] joinString " ";
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

TDI_fnc_getIcon = {
    params ["_unit", "_side"];

    format [
        "\A3\ui_f\data\Map\Diary\Icons\player%1%2_ca.paa",
        (if (alive _unit) then {""} else {"Brief"}),
        (
            switch _side do {
                case west: {"West"};
                case east: {"East"};
                case independent: {"Guer"};
                case civilian: {"Civ"};
                default {"Unknown"};
            }
        )
    ]
};

TDI_fnc_entityInitServer = {
    params ["_entity"];

    _startTime = time;
    waitUntil {(isNil "_entity") || {!(isNull _entity)} || {(time - _startTime) > 3}};
    if ((isNil "_entity") || {isNull _entity}) exitWith {};

    _this call {
        params ["_entity"];

        if (isNil {_entity getVariable "TDI_var_initDone"}) then {
            _entity setVariable ["TDI_var_initDone", true];

            if (_entity isKindOf "CAManBase") then {
                if (isNil {_entity getVariable "TDI_var_name"}) then {
                    _entity setVariable ["TDI_var_name", ([_entity] call TDI_fnc_getName), true];
                };

                _entity setVariable ["TDI_var_side", (side (group _entity)), true];
            } else {
                _entity setVariable ["TDI_var_name", (getText (configfile >> "CfgVehicles" >> (typeOf _entity) >> "displayName")), true];
            };
        };

        [[_entity], {if !(isNil "TDI_var_clientInitDone") then {_this call TDI_fnc_entityInitClient};}] remoteExecCall ["call", 0];
    };
};

TDI_fnc_startTdIconsServer = {
    call {
        if (isNil "TDI_var_serverRunning") then {
            TDI_var_serverRunning = true;

            {
                [_x] spawn TDI_fnc_entityInitServer;
            } forEach (entities [["CAManBase"], [""], true, false]);

            TDI_var_entityCreatedEhId = addMissionEventHandler ["EntityCreated", {
                params ["_entity"];

                if (_entity isKindOf "CAManBase") then {
                    [_entity] spawn TDI_fnc_entityInitServer;
                };
            }];

            TDI_var_remoteExecId = [[], {if hasInterface then {waitUntil {!(isNil "TDI_var_clientInitDone")}; call TDI_fnc_startTdIconsClient;};}] remoteExecCall ["spawn", 0, true];
        };
    };
};

TDI_fnc_stopTdIconsServer = {
    call {
        if !(isNil "TDI_var_serverRunning") then {
            TDI_var_serverRunning = nil;

            remoteExecCall ["", TDI_var_remoteExecId];
            TDI_var_remoteExecId = "";

            removeMissionEventHandler ["EntityCreated", TDI_var_entityCreatedEhId];
            TDI_var_entityCreatedEhId = -1;

            [[], {if hasInterface then {waitUntil {!(isNil "TDI_var_clientInitDone")}; call TDI_fnc_stopTdIconsClient;};}] remoteExecCall ["spawn", 0];
        };
    };
};

TDI_var_serverInitDone = true;
publicVariable "TDI_var_serverInitDone";