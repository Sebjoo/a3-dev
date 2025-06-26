DS_var_serverRunning = nil;
DS_var_entityCreatedEhId = -1;
DS_var_remoteExecId = "";

DS_var_weaponSwayEnabled = 1;
DS_var_weaponSwayDisabled = 0.3;

publicVariable "DS_var_weaponSwayEnabled";
publicVariable "DS_var_weaponSwayDisabled";

DS_fnc_entityInitServer = {
    params ["_entity"];

    _startTime = time;
    waitUntil {(isNil "_entity") || {!(isNull _entity)} || {(time - _startTime) > 3}};
    if ((isNil "_entity") || {isNull _entity}) exitWith {};

    [_entity] call DS_fnc_disableStamina;
};

DS_fnc_enableStaminaForAiUnits = {
    {
        if (!(isNull _x) && {!(isPlayer _x)}) then {
            [_x] call DS_fnc_enableStamina;
        };
    } forEach (entities [["CAManBase"], [], true, true]);
};

DS_fnc_disableStaminaForAiUnits = {
    {
        if (!(isNull _x) && {!(isPlayer _x)}) then {
            [_x] call DS_fnc_disableStamina;
        };
    } forEach (entities [["CAManBase"], [], true, true]);
};

DS_fnc_startDisableStaminaServer = {
    call {
        if !isMultiplayer then {
            call DS_fnc_startDisableStaminaClient;
            call DS_fnc_disableStaminaForAiUnits;

            DS_var_entityCreatedEhId = addMissionEventHandler ["EntityCreated", {
                params ["_entity"];

                if (_entity isKindOf "CAManBase") then {
                    [_entity] spawn DS_fnc_entityInitServer;
                };
            }];
        } else {
            if (isNil "DS_var_serverRunning") then {
                DS_var_remoteExecId = [[], {if hasInterface then {waitUntil {!(isNil "DS_var_clientInitDone")}; call DS_fnc_startDisableStaminaClient;};}] remoteExecCall ["spawn", 0, true];
                DS_var_serverRunning = true;
            };
        };
    };
};

DS_fnc_stopDisableStaminaServer = {
    call {
        if !isMultiplayer then {
            call DS_fnc_stopDisableStaminaClient;
            call DS_fnc_enableStaminaForAiUnits;

            removeMissionEventHandler ["EntityCreated", DS_var_entityCreatedEhId];
            DS_var_entityCreatedEhId = -1;
        } else {
            if !(isNil "DS_var_serverRunning") then {
                DS_var_serverRunning = nil;
                
                remoteExecCall ["", DS_var_remoteExecId];
                DS_var_remoteExecId = "";

                [[], {if hasInterface then {waitUntil {!(isNil "DS_var_clientInitDone")}; call DS_fnc_stopDisableStaminaClient;};}] remoteExecCall ["spawn", 0];
                call DS_fnc_disableStaminaForAiUnits;
            };
        };
    };
};

DS_var_serverInitDone = true;
publicVariable "DS_var_serverInitDone";