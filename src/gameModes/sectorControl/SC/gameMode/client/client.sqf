SC_fnc_getSectorColor = {
    params ["_side", "_alpha", "_colorIntensity"];

    (
        [1, 1, 1] vectorDiff (
            (
                [1, 1, 1] vectorDiff (
                    switch _side do {
                        case civilian: {[1, 1, 1]};
                        case west: {[0, 0.4, 0.7]};
                        case east: {[0.9, 0, 0]};
                        case independent: {[0, 0.6, 0.2]};
                    }
                )
            ) vectorMultiply _colorIntensity
        )
    ) + [_alpha]
};

SC_fnc_put = {
    params ["", "_container"];
    
    if ((typeOf _container) isEqualTo "GroundWeaponHolder") then {
        [_container] remoteExecCall ["SC_fnc_addGroundWeaponHolder", 2];
    };
};

SC_fnc_visionModeChanged = {
    params ["", "_visionMode", "_TIindex", "_visionModePrev", "_TIindexPrev", "_vehicle", "_turret"];

    if !(SC_var_isInVehicleVision && (cameraView != "GUNNER")) then {
        SC_var_nvGogglesEnabled = _visionMode == 1;
    };

    SC_var_isInVehicleVision = cameraView == "GUNNER";

    if !SC_var_isInVehicleVision then {
        if SC_var_nvGogglesEnabled then {
            player action ["nvGoggles", player];
        } else {
            player action ["nvGogglesOff", player];
        };
    };
};

SC_fnc_map = {
    params ["_isOpened"];

    if _isOpened then {
        if (!SC_var_uavTerminalOpened && {!(isNull (findDisplay 160))}) then {
            ((findDisplay 160) displayCtrl 51) ctrlMapAnimAdd [0, SC_var_mapScale, SC_var_mapPosition];
            ctrlMapAnimCommit ((findDisplay 160) displayCtrl 51);
            SC_var_uavTerminalOpened = true;
        } else {
            ((findDisplay 12) displayCtrl 51) ctrlMapAnimAdd [0, SC_var_mapScale, SC_var_mapPosition];
            ctrlMapAnimCommit ((findDisplay 12) displayCtrl 51);
        };

        if (SC_var_alwaysShowHudOnMap && !SC_var_hudEnabled && !SC_var_hudShown) then {
            [true] call SC_fnc_setHud;
        };
    } else {
        if !SC_var_uavTerminalOpened then {
            SC_var_mapScale = ctrlMapScale ((findDisplay 12) displayCtrl 51);
            SC_var_mapPosition = ((findDisplay 12) displayCtrl 51) ctrlMapScreenToWorld [0.5, 0.53];
        };

        if (SC_var_alwaysShowHudOnMap && !SC_var_hudEnabled && SC_var_hudShown) then {
            [false] call SC_fnc_setHud;
        };
    };
};

SC_fnc_actionStr = '
    if (unitIsUAV (_this select 0)) then {
        {
            _x linkItem "itemMap";
            _x linkItem "itemGPS";
            _x linkItem "H_PilotHelmetFighter_B";
        } forEach (crew (_this select 0));
    };
    
    false
';

SC_fnc_isNight = {
    _offset = [4, 5.666] select (worldName == "Tanoa");

    (dayTime < _offset) || {dayTime > (24 - _offset)}
};

SC_fnc_onInventoryOpened = {
    if ((getPosATL player) inArea ("SC_var_" + (str (side (group player))) + "Base")) then {
        if (SC_var_hudEnabled && {SC_var_inventoryDisabledCooldown == 0}) then {
            ["inventoryDisabled"] call BIS_fnc_showNotification;
        };

        true
    } else {
        nil
    }
};

SC_fnc_onKilled = {
    if SC_var_viewSwitchable then {
        terminate SC_var_cameraViewLoop;
    };

    3 fadesound 0;
    waitUntil {visibleMap};
    [false] call KF_fnc_EnableMidFeed;
    [] spawn SC_fnc_respawnMapDisplay;
    MM_var_showAliveGroupUnits = false;
    call MM_fnc_updateDrawArrayImmediate;
    (uiNamespace getVariable "SC_var_sectorControlDisplay" displayctrl 1999) ctrlSetTextColor [1, 1, 1, 0];
    waitUntil {alive player};
    [SC_var_hudEnabled] call KF_fnc_EnableMidFeed;
};

SC_fnc_respawnMapDisplay = {    
    waitUntil {
        call {
            _respawnMapDisplay = uiNamespace getVariable ["SC_var_respawnMapDisplay", displayNull];
            _spectatorActive = !(isNull (uiNamespace getVariable ["SC_var_spectatorDisplay", displayNull]));
            _respawnMapDisplayActive = !(isNull _respawnMapDisplay);
            _escMenuActive = !(isNull (findDisplay 49));
            _shouldDrawRespawnMapDisplay = !(alive player) && {!_spectatorActive} && {!_escMenuActive};

            if (_respawnMapDisplayActive != _shouldDrawRespawnMapDisplay) then {
                if _shouldDrawRespawnMapDisplay then {
                    (findDisplay 46) createDisplay "respawnMapDisplay";
                } else {
                    _respawnMapDisplay closeDisplay 1;
                };
            };
            
            (alive player)
        }
    };
};

SC_fnc_spectate = {
    _respawnMapDisplay = uiNamespace getVariable ["SC_var_respawnMapDisplay", displayNull];
    
    if !(isNull _respawnMapDisplay) then {
        _respawnMapDisplay closeDisplay 1;
    };

    (findDisplay 46) createDisplay "spectatorDisplay";
    waitUntil {!(isNull (uiNamespace getVariable ["SC_var_spectatorDisplay", displayNull]))};
    _spectatorDisplay = uiNamespace getVariable ["SC_var_spectatorDisplay", displayNull];
    openMap false;
    _oldDeathFeedState = KF_var_DeathFeedEnabled;
    [false] call KF_fnc_EnableDeathFeed;
    _combo = _spectatorDisplay displayCtrl 2100;
    _oldAvailableUnits = [];
    TDI_var_DrawUnitsOnSpectator = true;
    cutText ["", "BLACK FADED", 99999999];
    0 fadeSound 0;
    _fadedBlack = true;

    waitUntil {
        _availableUnits = ((player getVariable ["SC_var_groupUnits", []]) - [player]) select {
            (alive _x) && {simulationEnabled _x} && {!(_x getVariable ["ais_unconscious", false])}
        };

        if !(_availableUnits isEqualTo _oldAvailableUnits) then {
            lbClear _combo;

            {
                _combo lbAdd (_x getVariable ["SC_var_name", (name _x)]);
            } forEach _availableUnits;

            _newSelectedIndex = _availableUnits findIf {_x isEqualTo focusOn};

            if (_newSelectedIndex == -1) then {
                _newSelectedIndex = 0;
            };

            _combo lbSetCurSel _newSelectedIndex;
            _oldAvailableUnits = +_availableUnits;
        };

        _selectedIndex = lbCurSel _combo;
        _viewedIndex = _availableUnits findIf {_x isEqualTo focusOn};

        if (_selectedIndex != _viewedIndex) then {
            _newSelectedUnit = _availableUnits select _selectedIndex;
            _newSelectedUnit switchCamera (focusOn getVariable ["SC_var_cameraView", "EXTERNAL"]);
            call MM_fnc_updateDrawArrayImmediate;
        };

        if (cameraView != (focusOn getVariable ["SC_var_cameraView", "EXTERNAL"])) then {
            focusOn switchCamera (focusOn getVariable ["SC_var_cameraView", "EXTERNAL"]);
            call MM_fnc_updateDrawArrayImmediate;
        };

        if (!(alive focusOn) != _fadedBlack) then {
            if _fadedBlack then {
                cutText ["", "PLAIN", 0, false, false];
                1 fadeSound ([1, 0.3] select SC_var_earplugsOn);
            } else {
                cutText ["", "BLACK FADED", 9999999, false, false];
                0 fadeSound 0;
            };

            _fadedBlack = !_fadedBlack;
        };

        (isNull _spectatorDisplay)
    };

    player switchCamera SC_var_lastView;
    TDI_var_DrawUnitsOnSpectator = false;
    [_oldDeathFeedState] call KF_fnc_EnableDeathFeed;
    openMap true;
    cutText ["", "PLAIN", 0, false, false];
    0 fadeSound 0;
};

SC_fnc_setArsenalVisionMode = {
    missionNamespace setVariable ["BIS_fnc_arsenal_visionMode", ([0, 1] select SC_var_nvGogglesEnabled)];
    false setCamUseTi 0;
    camUseNVG SC_var_nvGogglesEnabled;
};

SC_fnc_onRespawn = {
    if (SC_var_hudEnabled && !SC_var_hudShown) then {
        [SC_var_hudEnabled] call SC_fnc_setHud;
    };
    
    MM_var_showAliveGroupUnits = true;
    cutText ["", "BLACK IN", 1];

    if SC_var_viewSwitchable then {
        SC_var_cameraViewLoop = [SC_var_lastView] spawn SC_fnc_cameraViewLoop;
    };

    if (soundVolume == 0) then {
        1 fadesound ([1, 0.3] select SC_var_earplugsOn);
    };
    
    [SC_var_lastLoadout] call SC_fnc_setLoadout;

    if SC_var_nvGogglesEnabled then {
        player action ["nvGoggles", player];
    };

    if (((getPosATL player) select 2) > 1500) then {
        [player] spawn SC_fnc_zoneParachuteJump;
    } else {
        _baseMarker = "SC_var_" + (toLower (str (side (group player)))) + "Respawn";
        _baseMarkerPos = getMarkerPos _baseMarker;
        [player, false] call ADG_fnc_allowDamage;

        if ((player distance _baseMarkerPos) < 8) then {
            player setDir (markerDir _baseMarker);
            waitUntil {((player distance _baseMarkerPos) > 8) || {!(alive player)}};
            [player, true] call ADG_fnc_allowDamage;

            if (simulationEnabled player) then {
                ["spawnprotectiondisabled"] call SC_fnc_showNotificationIfHudIsEnabled;
            };
        } else {
            sleep 4;

            if (alive player) then {
                [player, true] call ADG_fnc_allowDamage;
            };
        };
    };
};

SC_fnc_showNotificationIfHudIsEnabled = {
    if SC_var_hudEnabled then {
        _this call BIS_fnc_showNotification;
    };
};

SC_fnc_can_lockVehicle = {
    params ["_vehicle"];

    ((locked _vehicle) <= 1) &&
    {(_vehicle getVariable "SC_var_lockerUid") == -1}
};

SC_fnc_lockVehicle = {
    params ["_vehicle"];

    [_vehicle, 3] remoteExecCall ["lock", (owner _vehicle)];
    _vehicle setVariable ["SC_var_lockerUid", (call (compile (getPlayerUID player))), true];

    {
        _x params ["_crewUnit", "", "", "", "", "_assignedUnit"];

        if ((alive _assignedUnit) && {!(_assignedUnit isEqualTo _crewUnit)}) then {
            (group _assignedUnit) leaveVehicle _vehicle;
        };
    } forEach (fullCrew _vehicle);
};

SC_fnc_canUnlockVehicle = {
    params ["_vehicle"];

    ((locked _vehicle) > 1) &&
    {SC_var_playerUid isEqualTo (_vehicle getVariable "SC_var_lockerUid")}
};

SC_fnc_unlockVehicle = {
    params ["_vehicle"];

    [_vehicle, 1] remoteExecCall ["lock", (owner _vehicle)];
    _vehicle setVariable ["SC_var_lockerUid", -1, true];
};

SC_fnc_canMoveAIOutofVehicle = {
    params ["_vehicle"];

    ((locked _vehicle) > 1) &&
    {SC_var_playerUid isEqualTo (_vehicle getVariable "SC_var_lockerUid")} &&
    {
        (
            (crew _vehicle) findIf {
                (alive _x) &&
                {!(isPlayer _x)} &&
                {_x isKindOf "CAManBase"}
            }
        ) != -1
    }
};

SC_fnc_moveAiOutOfVehicle = {
    params ["_vehicle"];

    _unitsToSetOut = (crew _vehicle) select {(alive _x) && {!(isPlayer _x)} && {_x isKindOf "CAManBase"}};
    doGetOut _unitsToSetOut;

    {
        (group _x) leaveVehicle _vehicle;
    } forEach _unitsToSetOut;
    
    {
        _x params ["_crewUnit", "", "", "", "", "_assignedUnit"];

        if ((alive _assignedUnit) && {!(_assignedUnit isEqualTo _crewUnit)}) then {
            (group _assignedUnit) leaveVehicle _vehicle;
        };
    } forEach (fullCrew _vehicle);
};

SC_fnc_addToKillHistory = {
    params ["_source", "_distance", "_isRealKill", "_isHeadShot", "_xp"];
    
    _headshotRate = profileNamespace getVariable ["SC_var_headshotRate", 1];
    _numKills = profileNamespace getVariable ["SC_var_numKills", 0];
    _numOther = profileNamespace getVariable ["SC_var_numOther", 0];

    if _isRealKill then {
        profileNamespace setVariable ["SC_var_numKills", _numKills + 1];
    } else {
        profileNamespace setVariable ["SC_var_numOther", _numOther + 1];
    };

    _numAll = _numKills + _numOther;
    _newHeadshotRate = (_headshotRate * _numAll + ([0, 1] select _isHeadShot)) / (_numAll + 1);
    profileNamespace setVariable ["SC_var_headshotRate", _newHeadshotRate];

    if (isNil {profileNamespace getVariable "SC_var_killHistory"}) then {
        profileNamespace setVariable ["SC_var_killHistory", []];
    };

    _data = profileNamespace getVariable "SC_var_killHistory";
    _idx = _data findIf {(_x select 0) == _source};

    if (_idx == -1) then {
        _data pushBack [_source, 0, 0, 0, 0, 0];
        _idx = (count _data) - 1;
    };

    (_data select _idx) params ["", "_numKills", "_numOther", "_numHeadshots", "_oldAvgDis", "_oldXp"];
    
    _numAll = _numKills + _numOther;
    _newAvgDis = ((_oldAvgDis * _numAll) + _distance) / (_numAll + 1);

    _data set [_idx, [
        _source,
        _numKills + ([0, 1] select _isRealKill),
        _numOther + ([0, 1] select !_isRealKill),
        _numHeadshots + ([0, 1] select _isHeadShot),
        _newAvgDis,
        _oldXp + _xp
    ]];
};

SC_fnc_addToDeathHistory = {
    params ["_source", "_distance", "_isRealKill", "_isHeadshot"];

    if _isRealKill then {
        _numDeaths = profileNamespace getVariable ["SC_var_numDeaths", 0];
        profileNamespace setVariable ["SC_var_numDeaths", _numDeaths + 1];
    };

    if (isNil {profileNamespace getVariable "SC_var_deathHistory"}) then {
        profileNamespace setVariable ["SC_var_deathHistory", []];
    };

    _data = profileNamespace getVariable "SC_var_deathHistory";
    _idx = _data findIf {(_x select 0) == _source};

    if (_idx == -1) then {
        _data pushBack [_source, 0, 0, 0, 0];
        _idx = (count _data) - 1;
    };

    (_data select _idx) params ["", "_numKills", "_numOther", "_numHeadshots", "_oldAvgDis"];

    _numAll = _numKills + _numOther;
    _newAvgDis = ((_oldAvgDis * _numAll) + _distance) / (_numAll + 1);

    _data set [_idx, [
        _source,
        _numKills + ([0, 1] select _isRealKill),
        _numOther + ([0, 1] select !_isRealKill),
        _numHeadshots + ([0, 1] select _isHeadShot),
        _newAvgDis
    ]];
};

SC_fnc_addHeal = {
    _numHeals = profileNamespace getVariable ["SC_var_numHeals", 0];
    profileNamespace setVariable ["SC_var_numHeals", _numHeals + 1];
};

SC_fnc_addSelfHeal = {
    _numHeals = profileNamespace getVariable ["SC_var_numSelfHeals", 0];
    profileNamespace setVariable ["SC_var_numSelfHeals", _numHeals + 1];
};

SC_fnc_addCapturedSector = {
    _numCapturedSectors = profileNamespace getVariable ["SC_var_numCapturedSectors", 0];
    profileNamespace setVariable ["SC_var_numCapturedSectors", _numCapturedSectors + 1];
};

SC_fnc_addRevive = {
    params ["_reviver"];

    if (_reviver isEqualTo player) then {
        _numRevives = profileNamespace getVariable ["SC_var_numRevives", 0];
        profileNamespace setVariable ["SC_var_numRevives", _numRevives + 1];
    };
};

SC_fnc_addRevived = {
    params ["_revived"];

    if (_revived isEqualTo player) then {
        _numRevived = profileNamespace getVariable ["SC_var_numRevived", 0];
        profileNamespace setVariable ["SC_var_numRevived", _numRevived + 1];
    };
};