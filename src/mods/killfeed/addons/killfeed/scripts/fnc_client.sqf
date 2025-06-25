KF_var_TeamHexColor = switch playerSide do {
    case west: {"#0066B3"};
    case east: {"#E60000"};
    case independent: {"#009933"};
    default {"#808080"};
};

KF_var_KillfeedEnabled = true;
KF_var_MidFeedEnabled = true;
KF_var_DeathFeedEnabled = true;

KF_var_KillFeed = [];
KF_var_MidFeed = [];
KF_var_DeathFeed = "";

KF_var_groupLoopScript = scriptNull;
KF_var_KillFeedWaitScripts = [];
KF_var_MidFeedWaitScripts = [];

KF_fnc_getGroupUnits = {
    params ["_unit"];

    (units (group _unit))
};

KF_fnc_EnableKillFeed = {
    params ["_enable"];

    if (KF_var_KillfeedEnabled != _enable) then {
        KF_var_KillfeedEnabled = _enable;
        call KF_fnc_DrawKillFeed;
    };
};

KF_fnc_EnableMidFeed = {
    params ["_enable"];

    if (KF_var_MidFeedEnabled != _enable) then {
        KF_var_MidFeedEnabled = _enable;
        call KF_fnc_DrawMidFeed;
    };
};

KF_fnc_EnableDeathFeed = {
    params ["_enable"];

    if (KF_var_DeathfeedEnabled != _enable) then {
        KF_var_DeathfeedEnabled = _enable;
        call KF_fnc_drawDeathFeed;
    };
};

KF_fnc_recolorName = {
    params ["_string", "_name", "_oldColor", "_newColor"];

    _text = format ["<t color='%1'>%2</t>", _oldColor, _name];
    _pos = -1;

    while {
        _pos = _string find _text;
        (_pos != -1)
    } do {
        _string = format [
            "%1%2%3",
            (_string select [0, _pos]),
            (format ["<t color='%1'>%2</t>", _newColor, _name]),
            (_string select [(_pos + (count _text)), ((count _string) - ((_pos + (count _text))))])
        ];
    };

    _string
};

KF_fnc_recolorText = {
    params ["_text"];

    {
        _x params ["_name", "_oldColor", "_newColor"];
        _text = [_text, _name, _oldColor, _newColor] call KF_fnc_recolorName;
    } forEach (
        [[(player getVariable ["KF_var_name", ""]), KF_var_TeamHexColor, "#ffd400"]] +
        ((([player] call KF_fnc_getGroupUnits) - [player]) apply {[(_x getVariable ["KF_var_name", ""]), KF_var_TeamHexColor, "#ffffff"]})
    );

    _text
};

KF_fnc_updateFeedColors = {
    params ["_lastGroup", "_group"];

    _unitsToRemove = _lastGroup select {!(_x in _group)};
    _unitsToAdd = _group select {!(_x in _lastGroup)};

    for "_i" from 0 to ((count KF_var_KillFeed) - 1) do {
        {
            KF_var_KillFeed set [_i, ([(KF_var_KillFeed select _i), (_x getVariable ["KF_var_name", ""]), "#ffffff", KF_var_TeamHexColor] call KF_fnc_recolorName)];
        } forEach _unitsToRemove;

        {
            KF_var_KillFeed set [_i, ([(KF_var_KillFeed select _i), (_x getVariable ["KF_var_name", ""]), KF_var_TeamHexColor, "#ffffff"] call KF_fnc_recolorName)];
        } forEach _unitsToAdd;
    };

    call KF_fnc_DrawKillFeed;

    for "_i" from 0 to ((count KF_var_MidFeed) - 1) do {
        {
            KF_var_MidFeed set [_i, ([(KF_var_MidFeed select _i), (_x getVariable ["KF_var_name", ""]), "#ffffff", KF_var_TeamHexColor] call KF_fnc_recolorName)];
        } forEach _unitsToRemove;

        {
            KF_var_MidFeed set [_i, ([(KF_var_MidFeed select _i), (_x getVariable ["KF_var_name", ""]), KF_var_TeamHexColor, "#ffffff"] call KF_fnc_recolorName)];
        } forEach _unitsToAdd;
    };

    call KF_fnc_DrawMidFeed;

    {
        KF_var_DeathFeed = [KF_var_DeathFeed, (_x getVariable ["KF_var_name", ""]), "#ffffff", KF_var_TeamHexColor] call KF_fnc_recolorName;
    } forEach _unitsToRemove;

    {
        KF_var_DeathFeed = [KF_var_DeathFeed, (_x getVariable ["KF_var_name", ""]), KF_var_TeamHexColor, "#ffffff"] call KF_fnc_recolorName;
    } forEach _unitsToAdd;
    
    call KF_fnc_DrawDeathFeed;
};

KF_fnc_AddKillFeedLine = {
    params ["_newLine"];

    _newLine = [_newLine] call KF_fnc_recolorText;
    KF_var_KillFeed pushBack _newLine;

    if ((KF_var_KillfeedMaximumLength != -1) && {(count KF_var_KillFeed) > KF_var_KillfeedMaximumLength}) then {
        KF_var_KillFeed deleteAt 0;
        terminate (KF_var_KillFeedWaitScripts select 0);
        KF_var_KillFeedWaitScripts deleteAt 0;
    };

    if KF_var_KillfeedEnabled then {
        call KF_fnc_DrawKillFeed;
    };

    KF_var_KillFeedWaitScripts pushBack (
        [] spawn {
            sleep KF_var_KillfeedCooldown;

            call {
                KF_var_KillFeed deleteAt 0;
                KF_var_KillFeedWaitScripts deleteAt 0;
                
                if KF_var_KillfeedEnabled then {
                    call KF_fnc_DrawKillFeed;
                };
            };
        }
    );
};

KF_fnc_AddMidfeedLine = {
    params ["_newLine"];

    _newLine = [_newLine] call KF_fnc_recolorText;
    KF_var_MidFeed insert [0, [_newLine]];

    if ((KF_var_MidfeedMaximumLength != -1) && {(count KF_var_MidFeed) > KF_var_MidfeedMaximumLength}) then {
        KF_var_MidFeed deleteAt ((count KF_var_MidFeed) - 1);
        terminate (KF_var_MidFeedWaitScripts select 0);
        KF_var_MidFeedWaitScripts deleteAt 0;
    };

    if KF_var_MidfeedEnabled then {
        call KF_fnc_DrawMidFeed;
    };

    KF_var_MidFeedWaitScripts pushBack (
        [] spawn {
            sleep KF_var_MidfeedCooldown;

            call {
                KF_var_MidFeed deleteAt ((count KF_var_MidFeed) - 1);
                KF_var_MidFeedWaitScripts deleteAt 0;
                
                if KF_var_MidfeedEnabled then {
                    call KF_fnc_DrawMidFeed;
                };
            };
        }
    );
};

KF_fnc_playerHasRespawned = {
    (alive player) && {!(player getVariable ["AIS_unconscious", false])} && {focusOn isEqualTo player}
};

KF_fnc_addDeathFeed = {
    params ["_text"];

    if !(call KF_fnc_playerHasRespawned) then {
        KF_var_DeathFeed = [_text] call KF_fnc_recolorText;
        call KF_fnc_drawDeathFeed;
        _startTime = time;

        waitUntil {(call KF_fnc_playerHasRespawned) || {(time - _startTime) >= 2}};

        if !(call KF_fnc_playerHasRespawned) then {
            sleep (2 - (time - _startTime));
            _oldSound = soundVolume;

            if KF_var_DeathTransition then {
                if (!visibleMap) then {
                    cutText ["", "BLACK OUT", 1, true];
                };
                
                1 fadesound 0;
            };
            
            sleep 1;
            waitUntil {call KF_fnc_playerHasRespawned};

            if KF_var_DeathTransition then {
                cutText ["", "BLACK IN", 1, true];
                1 fadesound _oldSound;
            };
        };

        KF_var_DeathFeed = "";
        call KF_fnc_drawDeathFeed;
    };
};

KF_fnc_DrawKillFeed = {
    _text = "";

    if KF_var_KillfeedEnabled then {
        _text = KF_var_KillFeed joinString "<br/>";
    };

    [_text, [(0.98 * ((safeZoneW / 2) + safezoneX)), (safeZoneW / 2)], [((safeZoneH / 8) + safezoneY), safeZoneH], (if (_text != "") then {9999} else {0}), 0, 0, 790] spawn BIS_fnc_dynamicText;
};

KF_fnc_DrawMidFeed = {
    _text = "";

    if KF_var_MidfeedEnabled then {
        _text = KF_var_MidFeed joinString "<br/>";
    };

    [_text, 0, [((safeZoneH / 1.3) + safezoneY), safeZoneH], (if (_text != "") then {9999} else {0}), 0, 0, 787] spawn BIS_fnc_dynamicText;
};

KF_fnc_drawDeathFeed = {
    _text = "";

    if KF_var_DeathFeedEnabled then {
        _text = KF_var_DeathFeed;
    };

    [_text, [safeZoneX, (safeZoneW / 2)], [(0.66 * ((safeZoneH / 8) + safezoneY)), safeZoneH], (if (_text != "") then {9999} else {0}), 0, 0, 788] spawn BIS_fnc_dynamicText;
};

KF_fnc_groupLoop = {
    _lastGroup = [player] call KF_fnc_getGroupUnits;

    waitUntil {
        _group = [player] call KF_fnc_getGroupUnits;

        if !(_group isEqualTo _lastGroup) then {
            [_lastGroup, _group] call KF_fnc_updateFeedColors;
            _lastGroup = _group;
        };

        sleep 1;

        false
    };
};

KF_fnc_startKillfeedClient = {
    KF_var_groupLoopScript = [] spawn KF_fnc_groupLoop;
};

KF_var_clientInitDone = true;