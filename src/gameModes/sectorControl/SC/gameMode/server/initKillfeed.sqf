[] spawn {
    waitUntil {!(isNil "KF_var_serverInitDone")};

    KF_var_AddMidFeedInfo pushBack {
        params ["_unit", "_hitter", "_isKill", "_isTk", "_hitterDistance", "_hitterTypeSourceSelArr", "_typeOfKilledVehicle", "_externalUnitDeathCall"];

        if _isTk then {""} else {
            _message = "";
            _xp = 0;

            if !(unitIsUAV _unit) then {
                _xp = 100;
            };

            if (_typeOfKilledVehicle != "") then {
                _posVehicle = SC_var_availableVehicles findIf {(_x select 0) == _typeOfKilledVehicle};

                if (_posVehicle != -1) then {
                    if !((unitIsUAV _unit) || {[_typeOfKilledVehicle] call KF_fnc_isTypeUnmanned}) then {
                        _message = _message + "in <t color='" + ([_unit getVariable ["KF_var_side", civilian]] call KF_fnc_GetSidesHexColor) + "'>" + ([_typeOfKilledVehicle] call KF_fnc_GetDisplayName) + "</t> ";
                    };
                    
                    _xp = _xp + (900 * (0.15 + ((((SC_var_availableVehicles select _posVehicle) select 1) ^ 0.8) / 35)));
                };
            };

            _xp = _xp * (exp (_hitterDistance / 2000));

            if (_hitter getVariable ["SC_var_hasExprPerk", false]) then {
                _xp = 1.5 * _xp;
            };
            
            if !_isKill then {
                _xp = _xp / 3;
            };

            if !_externalUnitDeathCall then {
                _xp = _xp / 3;
            };

            _xp = 10 * (round (_xp / 10));
            [_xp] remoteExecCall ["SC_fnc_addXp", _hitter];
            (_hitterTypeSourceSelArr select 0) params ["_type", "_source"];

            if (_source != "") then {
                _isHeadShot = "Headshot" in _type;
                _isRealKill = _externalUnitDeathCall && _isKill;

                [_source, _hitterDistance, _isRealKill, _isHeadShot, _xp] remoteExecCall ["SC_fnc_addToKillHistory", _hitter];
            };
            
            (_message + (str _xp) + " XP")
        }
    };

    KF_var_AddDeathFeedInfo pushBack {
        params ["_unit", "_killer", "", "", "_hitData", "", "", "_externalUnitDeathCall"];

        {
            _x params ["_hitter", "_hitterTypeSourceSelArr", "_distance"];

            _isRealKill = (_hitter isEqualTo _killer) && _externalUnitDeathCall;

            if _isRealKill then {
                _source = (_hitterTypeSourceSelArr select 0) select 1;
                _isHeadshot = "Headshot" in ((_hitterTypeSourceSelArr select 0) select 0);
            
                [_source, _distance, _isRealKill, _isHeadshot] remoteExecCall ["SC_fnc_addToDeathHistory", _unit];
            } else {
                {
                    _x params ["_type", "_source"];
                    _isHeadShot = "Headshot" in _type;

                    [_source, _distance, _isRealKill, _isHeadshot] remoteExecCall ["SC_fnc_addToDeathHistory", _unit];
                } forEach _hitterTypeSourceSelArr;
            };
        } forEach _hitData;

        ""
    };
};

call KF_fnc_startKillfeed;
KF_var_handleUnitDeaths = true;
KF_var_showFinallyKilledForUnitDeaths = true;
KF_var_addScoreForUnitDeaths = false;
KF_var_showUnitDeathsInKillfeed = false;
KF_var_showUnitDeathsInMidfeed = true;
KF_var_showUnitDeathsInDeathFeed = false;
KF_var_showUnitDeathsInKillInfo = false;