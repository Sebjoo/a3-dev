SC_fnc_getName = {
    params ["_unit"];

    _name = "";

    if (unitIsUAV _unit) then {
        _name = [([typeOf _unit] call SC_fnc_GetDisplayName), "(AI)"] joinString " ";
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

SC_fnc_getConfigEntry = {
    params ["_typeName"];

    (configfile >> (
        switch true do {
            case (_typeName isKindOf [_typeName, (configFile >> "CfgMagazines")]): {"CfgMagazines"};
            case (_typeName isKindOf [_typeName, (configFile >> "CfgVehicles")]): {"CfgVehicles"};
            case (_typeName isKindOf [_typeName, (configFile >> "CfgWeapons")]): {"CfgWeapons"};
            default {"CfgVehicles"};
        }
    ) >> _typeName)
};

SC_fnc_getDisplayName = {
    params ["_typeName"];

    getText (([_typeName] call SC_fnc_getConfigEntry) >> "displayName")
};

SC_fnc_getPicture = {
    params ["_typeName"];

    getText (([_typeName] call SC_fnc_getConfigEntry) >> "picture")
};

SC_fnc_safelyDeleteVehicle = {
    params ["_vehicle"];
    
    _startTime = time;
    waitUntil {((crew _vehicle) isEqualTo []) || {(time - _startTime) > 1}};

    _posVehicle = getPos _vehicle;

    {
        _x setPos _posVehicle;
    } forEach (crew _vehicle);
    
    if ((crew _vehicle) isEqualTo []) then {
        {
            _vehicle deleteVehicleCrew _x;
        } forEach (crew _vehicle);
    };

    if isServer then {
        [_vehicle] call SC_fnc_deregisterEntityServer;
    } else {
        [_vehicle] remoteExecCall ["SC_fnc_deregisterEntityServer", 2];
        sleep 0.5;
    };

    deleteVehicle _vehicle;
};

SC_fnc_getGroupUnits = {
    params ["_unit"];

    _unit getVariable ["SC_var_groupUnits", [_unit]]
};

SC_fnc_zoneParachuteJump = {
    params ["_unit"];

    _pos = [];
    _side = side (group _unit);
    _enemySides = SC_var_sides - [_side];
    _enemySidesBaseMarkers = _enemySides apply {"SC_var_" + (str _x) + "Base"};
    _enemySidesSectorMarkers = SC_var_sectors select {(missionNameSpace getVariable ("SC_var_holder" + _x)) != _side};

    waitUntil {
        _pos = if SC_var_hugeMap then {
            "SC_var_playZone" call BIS_fnc_randomPosTrigger
        } else {
            [
                SC_var_playZoneMiddle,
                (
                    ((markerSize "SC_var_playZone") apply {0.3 * _x}) +
                    [
                        (markerDir "SC_var_playZone"),
                        ((markerShape "SC_var_playZone") isEqualTo "RECTANGLE")
                    ]
                )
            ] call BIS_fnc_randomPosTrigger
        };

        !(surfaceIsWater _pos) &&
        {(
            (_enemySidesBaseMarkers + ([[], _enemySidesSectorMarkers] select SC_var_hugeMap)) findIf
            {(_pos distance (getMarkerPos _x)) < (1.2 * (selectMax (getMarkerSize _x)))}
        ) == -1}
    };

    _unit setPos (_pos vectorAdd [0, 0, SC_var_parachuteJumpHeight]);
    [_unit] spawn SC_fnc_parachuteJump;
};

SC_fnc_heliParachuteJump = {
    params ["_unit"];
    
    _heli = objectParent _unit;
    _posAslHeli = getPosASL _heli;
    _posAslHeli set [2, (_posAslHeli select 2) - 3];
    _unit setPosASL _posAslHeli;
    [_unit, _heli] spawn SC_fnc_parachuteJump;
};

SC_fnc_parachuteJump = {
    params ["_unit", ["_heli", objNull]];

    _unit switchMove "AfalPpneMstpSnonWnonDnon";
    _unit setDir (random 360);
    _backPack = typeOf (unitBackpack _unit);
    _backpackItems = backpackItems _unit;
    removeBackpack _unit;
    _unit addBackpackGlobal "B_Parachute";

    if !(isNull _heli) then {
        _unit setVelocity (velocity _heli);
    };

    sleep 1;
    waitUntil {sleep 0.5; ((getPos _unit) select 2) <= 100};
    _unit action ["OpenParachute", _unit];
    waitUntil {sleep 0.2; isNull (unitBackpack _unit)};
    _unit addBackpackGlobal _backPack;

    {
        _unit addItemToBackpack _x;
    } forEach _backpackItems;
};

SC_fnc_isConfigEntryValid = {
    (SC_var_lxws_active || {((toLower (_x select 0)) select [(count (_x select 0)) - 5, 5]) != "_lxws"}) &&
    {SC_var_rf_active || {((toLower (_x select 0)) select [(count (_x select 0)) - 3, 3]) != "_rf"}} &&
    {SC_var_ef_active || {((toLower (_x select 0)) select [0, 3]) != "ef_"}}
};

SC_fnc_filterConfigArr = {
    _this select {_x call SC_fnc_isConfigEntryValid}
};

SC_fnc_addHandleHeal = {
    params ["_unit"];

    _id = _unit getVariable ["SC_var_handleHealEhId", -1];
    if (_id != -1) then {_unit removeEventHandler ["HandleHeal", _id];};
    _id = _unit addEventHandler ["HandleHeal", {_this spawn SC_fnc_onHeal; false}];
    _unit setVariable ["SC_var_handleHealEhId", _id];
};

SC_fnc_onHeal = {
    params ["_injured", "_healer"];

    if (((isPlayer _injured) || (isPlayer _healer)) && !(_injured getVariable ["SC_var_isBeingHealed", false])) then {
        _damage = damage _injured;
        _injured setVariable ["SC_var_isBeingHealed", true];

        waitUntil {(damage _injured) != _damage};

        if ((damage _injured) < _damage) then {
            _injured setVariable ["SC_var_isBeingHealed", false];

            if (_healer isEqualTo _injured) then {
                remoteExecCall ["SC_fnc_addSelfHeal", _injured];
            } else {
                if (isPlayer _healer) then {
                    remoteExecCall ["SC_fnc_addHeal", _healer];
                };
            };
        };
    };
};

SC_fnc_secondsToMinSec = {
    params ["_time"];

    _mins = floor (_time / 60);
    _secs = _time - (_mins * 60);
    _str = format ["%1:%2", _mins, _secs];
    _pos = _str find ":";
    _length = count _str;

    _ret = if ((_length - _pos) == 2) then {
        [(_str select [0, _pos + 1]), (_str select [(_pos + 1), (_length - _pos)])] joinString "0"
    } else {
        _str
    };

    if ((count _ret) == 4) then {
        _ret = "0" + _ret;
    };

    _ret
};

SC_fnc_handleVehicleDamage = {
    params ["_unit", "", "_newDamage", "", "_projectile", "_hitPartIndex", "", "", "_directHit"];

    if ((_directHit && {_projectile == ""}) || {SC_var_launcherAmmos getOrDefault [_projectile, false]}) then {
        _oldDamage = _unit getHitIndex _hitPartIndex;
        _oldDamage + ((_newDamage - _oldDamage) * SC_var_vehicleDamageFactor)
    }
};

SC_fnc_addHandleDamageToVehicle = {
    params ["_vehicle"];

    _vehicle addEventHandler ["HandleDamage", {if (local (_this select 0)) then {_this call SC_fnc_handleVehicleDamage}}];
};