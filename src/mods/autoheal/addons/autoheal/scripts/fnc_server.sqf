AH_var_serverRunning = nil;
AH_var_remoteExecId = "";

AH_var_HealSpeed = 1;
AH_var_HealCooldownMedic = 8;
AH_var_HealCoolDown = 12;

publicVariable "AH_var_HealSpeed";
publicVariable "AH_var_HealCooldownMedic";
publicVariable "AH_var_HealCoolDown";

AH_fnc_setDamageServer = {
    params ["_unit", "_newDamage", "_newHitPointsDamage"];

    if (local _unit) then {
        _this call AH_fnc_setDamageClientServer;
    } else {
        _this remoteExecCall ["AH_fnc_setDamageClientServer", _unit];
    };
};

AH_fnc_entityInitServer = {
    params ["_unit"];

    _startTime = time;
    waitUntil {(!(isNil "_unit") && {!(isNull _unit)}) || {(time - _startTime) > 3}};
    if ((isNil "_unit") || {isNull _unit}) exitWith {};

    _this call {
        params ["_unit"];

        [[_unit], {if !(isNil "AH_var_clientServerInitDone") then {_this call AH_fnc_entityInitClientServer};}] remoteExecCall ["call", 0];
    };
};

AH_fnc_startAutoHealServer = {
    call {
        if !isMultiplayer then {
            call AH_fnc_startAutoHealClientServer;
        } else {
            if (isNil "AH_var_serverRunning") then {
                AH_var_serverRunning = true;
                AH_var_remoteExecId = [[], {waitUntil {!(isNil "AH_var_clientServerInitDone")}; call AH_fnc_startAutoHealClientServer;}] remoteExecCall ["spawn", 0, true];
            };
        };
    };
};

AH_fnc_stopAutoHealServer = {
    call {
        if !isMultiplayer then {
            call AH_fnc_stopAutoHealClientServer;
        } else {
            if !(isNil "AH_var_serverRunning") then {
                AH_var_serverRunning = nil;

                remoteExec ["", AH_var_remoteExecId];
                AH_var_remoteExecId = "";

                [{if !(isNil "AH_var_clientServerInitDone") then {call AH_fnc_stopAutoHealClientServer};}] remoteExecCall ["call", 0];
            };
        };
    };
};

AH_var_serverInitDone = true;
publicVariable "AH_var_serverInitDone";