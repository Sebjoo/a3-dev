AH_var_clientRunning = nil;
AH_var_entityCreatedEhId = -1;

AH_fnc_setDamageClientServer = {
    params ["_unit", "_newDamage", "_newHitPointsDamage"];

    _unit setDamage _newDamage;

    _i = 0;
    while {_i < 10} do {
        _unit setHitIndex [_i, (_newHitPointsDamage select _i), false];
        _i = _i + 1;
    };
};

AH_fnc_onDamaged = {
    params ["_unit"];
    
    _unit setVariable ["AH_var_notDamagedSince", time];

    if !(_unit getVariable "AH_var_isWatched") then {
        _unit setVariable ["AH_var_isWatched", true];
        [_unit] spawn AH_fnc_watchUnit;
    };
};

AH_fnc_isDamaged = {
    params ["_unit"];

    (((damage _unit) != 0) || {((((getAllHitPointsDamage _unit) select 2) select [0, 10]) findIf {_x > 0}) != -1})
};

AH_fnc_changeDamage = {
    params ["_unit", "_change"];

    if ((_change < 0) && {!(isNil "KF_var_running")}) then {
        [_unit] remoteExecCall ["KF_fnc_entityHealed", 2];
    };

    _oldDamage = damage _unit;

    if (_change != 0 && {(_change > 0) || {[_unit] call AH_fnc_isDamaged}}) then {
        _newHitPointsDamage = [];
        _hitPointsDamage = ((getAllHitPointsDamage _unit) select 2) select [0, 10];

        if (_change > 0) then {
            [_unit] call AH_fnc_onDamaged;
            _min = selectMin _hitPointsDamage;

            if ((_min + _change) >= 1) then {
                _newHitPointsDamage = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
            } else {
                _changeFactor = _change / (1 - _min);
                _i = 0;
                
                while {_i < 10} do {
                    _oldValue = _hitPointsDamage select _i;
                    _newHitPointsDamage pushBack (_oldValue + ((1 - _oldValue) * _changeFactor));
                    _i = _i + 1;
                };
            };
        } else {
            _max = selectMax _hitPointsDamage;

            if ((_max + _change) <= 0) then {
                _newHitPointsDamage = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
            } else {
                _changeFactor = (_max + _change) / _max;
                _i = 0;

                while {_i < 10} do {
                    _oldValue = _hitPointsDamage select _i;
                    _newHitPointsDamage pushBack (_oldValue * _changeFactor);
                    _i = _i + 1;
                };
            };
        };

        _newDamage = 0;
        _i = 0;

        while {_i < 10} do {
            _newDamage = _newDamage + (_newHitPointsDamage select _i);
            _i = _i + 1;
        };

        _newDamage = _newDamage / 10;

        if (_oldDamage != 0) then {
            if (_change > 0) then {
                _newDamage = selectMax [_newDamage, _oldDamage];
            } else {
                _newDamage = selectMin [_newDamage, _oldDamage];
            };
        };

        [_unit, _newDamage, _newHitPointsDamage] call AH_fnc_setDamageClientServer;

        _newDamage
    } else {
        _oldDamage
    }
};

AH_fnc_coolDownActive = {
    params ["_unit"];

    ((time - (_unit getVariable "AH_var_notDamagedSince")) < ([AH_var_HealCooldown, AH_var_HealCoolDownMedic] select (_unit getUnitTrait "Medic")))
};

AH_fnc_watchUnit = {
    params ["_unit"];

    waitUntil {
        _ret = false;

        if !(isNil "_unit") then {
            if ((alive _unit) && {local _unit} && {[_unit] call AH_fnc_isDamaged}) then {
                if !([_unit] call AH_fnc_coolDownActive) then {
                    _ret = ([_unit, -0.03 * AH_var_HealSpeed] call AH_fnc_changeDamage) == 0;
                } else {
                    _ret = false;
                };
            } else {
                _ret = true;
            };

            if _ret then {
                _unit setVariable ["AH_var_isWatched", false];
            };
        } else {
            _ret = true;
        };

        sleep 1;

        _ret
    };
};

AH_fnc_entityInitClientServer = {
    params ["_unit"];

    _unit setVariable ["AH_var_isWatched", false];
    _unit setVariable ["AH_var_notDamagedSince", (time - AH_var_HealCoolDown)];
    
    _id = _unit getVariable "AH_var_hitEhId";

    if (isNil "_id") then {
        _id = _unit addEventHandler ["Hit", {[_this select 0] call AH_fnc_onDamaged;}];
        _unit setVariable ["AH_var_hitEhId", _id];
    };

    _id = _unit getVariable "AH_var_localEhId";

    if (isNil "_id") then {
        _id = _unit addEventHandler ["Local", {
            params ["_unit", "_isLocal"];
            
            if ((local _unit) && {[_unit] call AH_fnc_isDamaged}) then {
                _unit setVariable ["AH_var_notDamagedSince", (time - AH_var_HealCoolDown)];
                [_unit] spawn AH_fnc_watchUnit;
            };
        }];

        _unit setVariable ["AH_var_localEhId", _id];
    };
};

AH_fnc_startAutoHealClientServer = {
    call {
        if (isNil "AH_var_clientRunning") then {
            AH_var_clientRunning = true;

            {
                [_x] call AH_fnc_entityInitClientServer;
            } forEach (entities [["CAManBase"], [], true, false]);

            AH_var_entityCreatedEhId = addMissionEventHandler ["EntityCreated", {
                params ["_entity"];

                if (_entity isKindOf "CAManBase") then {
                    [_entity] spawn AH_fnc_entityInitClientServer;
                };
            }];
            
            if !isMultiplayer then {
                AH_var_loadedEhId = addMissionEventHandler ["Loaded", {
                    call AH_fnc_stopAutoHealClientServer;

                    [] spawn {
                        waitUntil {isNil "AH_var_clientRunning"};
                        call AH_fnc_startAutoHealClientServer;
                    };
                }];
            };
        };
    };
};

AH_fnc_stopAutoHealClientServer = {
    call {
        if !(isNil "AH_var_clientRunning") then {
            AH_var_clientRunning = nil;

            {
                _id = _x getVariable "AH_var_hitEhId";

                if !(isNil "_id") then {
                    _x removeEventHandler ["Hit", _id];
                };

                _id = _x getVariable "AH_var_localEhId";

                if !(isNil "_id") then {
                    _x removeEventHandler ["Local", _id];
                };

                _x setVariable ["AH_var_hitEhId", nil];
                _x setVariable ["AH_var_localEhId", nil];
            } forEach (entities [["CAManBase"], [], true, false]);

            removeMissionEventHandler ["EntityCreated", AH_var_entityCreatedEhId];
            AH_var_entityCreatedEhId = -1;

            if !isMultiplayer then {
                removeMissionEventHandler ["Loaded", AH_var_loadedEhId];
                AH_var_loadedEhId = nil;
            };
        };
    };
};

AH_var_clientServerInitDone = true;