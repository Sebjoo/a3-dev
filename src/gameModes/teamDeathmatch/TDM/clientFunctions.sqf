DM_fnc_openArs = {
    ["Open", [nil, DM_var_equip, player]] call bis_fnc_arsenal;
};

DM_fnc_closeArs = {
    disableSerialization;
    _disp = uinamespace getvariable "RSCDisplayArsenal";

    if !(isNil "_disp") then {
        waitUntil {
            if !(isNull _disp) then {
                _disp closeDisplay 2;
                false
            } else {
                true
            }
        };
    };

    player setVariable ["DM_var_arsenalOpened", false, true];
};

DM_fnc_applyItemsOnArsenal = {
    params ["_relRoundNumber", "_items"];

    if !(isNil "DM_var_equip") then {
        if !(isNull DM_var_equip) then {
            deleteVehicle DM_var_equip;
        };
    };

    DM_var_equip = "Land_HelipadEmpty_F" createVehicleLocal [0, 0, 0];

    waitUntil {!(isNull DM_var_equip)};

    _hdl = ["AmmoboxInit", [DM_var_equip, false]] spawn BIS_fnc_arsenal;

    {
        _items set [1, ((_items select 1) + (getArray (missionConfigFile >> (["itemsRound", (str _x), (toLower (str (side (group player))))] joinString ""))))];
    } forEach ([1, 13, 19] select {_x <= _relRoundNumber});

    _typeArr = ["weapon", "item", "magazine", "backpack"];
    waitUntil {scriptDone _hdl};

    {
        [DM_var_equip, (_items select (_typeArr find _x)), false, false] call (missionNameSpace getVariable (["BIS_fnc_addVirtual", _x, "Cargo"] joinString ""));
    } forEach _typeArr;
};

DM_fnc_movementClient = {
    _on = _this;

    if !_on then {
        if (isNil "DM_var_movementEH") then {

            DM_var_movementEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
                    params ["", "_key"];

                    if (_key in (
                            (actionKeys "moveForward") +
                            (actionKeys "moveBack") +
                            (actionKeys "TurnLeft") +
                            (actionKeys "TurnRight") +
                            (actionKeys "MoveFastForward") +
                            (actionKeys "MoveSlowForward")
                        )
                    ) then {
                        true
                    };
                }
            ];

            DM_var_fireId = player addAction ["", {}, "", 0, false, true, "DefaultAction"];
        };
    } else {
        if !(isNil "DM_var_movementEH") then {
            (findDisplay 46) displayRemoveEventHandler ["KeyDown", DM_var_movementEH];
            DM_var_movementEH = nil;
        };

        if !(isNil "DM_var_fireId") then {
            player removeAction DM_var_fireId;
            DM_var_fireId = nil;
        };
    };
};

DM_fnc_keyDownThirdPerson = {
    params ["", "_key"];

    if (_key in (actionKeys "personView")) then {
        true
    }
};

DM_fnc_map = {
    params ["_isOpened"];
    
    if _isOpened then {
        mapAnimAdd [0, (DM_var_mapScaleFactor * DM_var_maxZoneSize * 10 ^ -4), (getMarkerPos "DM_mrk_playZone")];
        mapAnimCommit;
    };
};

DM_fnc_killed = {
    if !(isNull DM_var_cameraViewLoopScript) then {
        terminate DM_var_cameraViewLoopScript;
    };

    if (simulationEnabled player) then {
        [] spawn {
            sleep 4;

            if (playerRespawnTime > 10) then {
                ["<t align='center'>Press space to spectate</t>", [safeZoneX, safeZoneW], [((safeZoneH / 2) + safezoneY), safeZoneH], 9999, 0, 0, 1011] spawn BIS_fnc_dynamicText;

                DM_var_spectate = false;

                _id = (findDisplay 46) displayAddEventHandler ["KeyDown", {
                    params ["", "_key"];
                    if (_key == 57) then {
                        DM_var_spectate = true;
                    };
                }];

                waitUntil {DM_var_spectate || (alive player)};
                DM_var_spectate = nil;
                ["", 0, 0, 0, 0, 0, 1011] spawn BIS_fnc_dynamicText;
                ["", 0, 0, 0, 0, 0, 788] spawn BIS_fnc_dynamicText;
                (findDisplay 46) displayRemoveEventHandler ["KeyDown", _id];

                if !(alive player) then {
                    [] spawn DM_fnc_spectator;
                };
            };
        };
    };
};

DM_fnc_respawn = {
    params ["", "_corpse"];

    player enableSimulationGlobal true;
    ["Terminate"] call BIS_fnc_EGSpectator;
    [isNull _corpse] call DM_fnc_ehRespawnClient;

    player addAction ["<img size='1.1' color='#ffffff' shadow='2' image='\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\rearm_ca.paa'/> Change Loadout",
        {call DM_fnc_openArs;}, nil, 1.5, true, false, "", '((player distance (getMarkerPos ("DM_mrk_" + (toLower (str (side (group player)))) + "HQ"))) <= 7) && !DM_var_gameRunning', 0
    ];

    if (!DM_var_gameRunning && {!(isNull _corpse)}) then {
        deleteVehicle _corpse;
    };
};

DM_fnc_isNight = {
    (dayTime < 4.5) || {dayTime > 19.5}
};

DM_fnc_visionModeChanged = {
    params ["_unit", "_visionMode", "_TIindex", "_visionModePrev", "_TIindexPrev", "_vehicle", "_turret"];

    if !(DM_var_isInVehicleVision && (cameraView != "GUNNER")) then {
        DM_var_nvGogglesEnabled = _visionMode == 1;
    };

    DM_var_isInVehicleVision = cameraView == "GUNNER";

    if !DM_var_isInVehicleVision then {
        if DM_var_nvGogglesEnabled then {
            player action ["nvGoggles", player];
        } else {
            player action ["nvGogglesOff", player];
        };
    };
};

DM_fnc_arsenalOpened = {
    params ["_display"];

    player setVariable ["DM_var_arsenalOpened", true, true];

    call DM_fnc_setArsenalVisionMode;

    [_display] spawn {
        params ["_display"];

        _nightVisionScript = [] spawn DM_fnc_arsenalThermalLoop;
        waitUntil {isNull _display};

        if DM_var_nvGogglesEnabled then {
            player action ["nvGoggles", player];
        };

        terminate _nightVisionScript;
    };
};

DM_fnc_setArsenalVisionMode = {
    missionNamespace setVariable ["BIS_fnc_arsenal_visionMode", ([0, 1] select DM_var_nvGogglesEnabled)];
    false setCamUseTi 0;
    camUseNVG DM_var_nvGogglesEnabled;
};

DM_fnc_arsenalClosed = {
    _mags = magazines player;
    {
        _weapon = _x;
        {
            _muzzle = _x;
            {
                _mag = _x;
                if (_mag in _mags) then {
                    player addWeaponItem [_weapon, _mag, true];
                };
            } forEach (getArray (configFile >> "CfgWeapons" >> _weapon >> _muzzle >> "magazines"));                
        } forEach (getArray (configFile >> "CfgWeapons" >> _weapon >> "muzzles"));
    } forEach (weapons player);

    player setVariable ["DM_var_lastLoadout", (getUnitLoadout player)];
    player setVariable ["DM_var_arsenalOpened", false, true];
    ["Terminate"] call BIS_fnc_EGSpectator;
};

DM_fnc_keyDownEarplugs = {
    params ["", "_key"];

    if ((_key == 59) || (_key == 0x3B)) then {
        if ((DM_var_earplugsCooldown == 0) && (soundVolume != 0)) then {
            DM_var_earplugsCooldown = 3;
            0.5 fadesound ([0.3, 1] select DM_var_earplugsOn);

            ["earplugs", [["_crossed", "on"], ["", "off"]] select DM_var_earplugsOn] call BIS_fnc_showNotification;

            DM_var_earplugsOn = !DM_var_earplugsOn;

            [] spawn {
                for "_i" from 1 to DM_var_earplugsCooldown do {
                    sleep 1;
                    DM_var_earplugsCooldown = DM_var_earplugsCooldown - 1;
                };
            };
        };
        
        true
    }
};

DM_fnc_resetLoadout = {
    waitUntil {(alive player) && ((getUnitLoadout player) isEqualTo (player getVariable "DM_var_lastLoadout"))};
    _startLoadout = player getVariable "DM_var_startLoadout";
    _tmp = DM_var_nvGogglesEnabled;

    waitUntil {
        player setUnitLoadout _startLoadout;
        (getUnitLoadout player) isEqualTo _startLoadout
    };

    DM_var_nvGogglesEnabled = _tmp;

    if !DM_var_autoHealEnabled then {
        if (DM_var_roundNumber >= 19) then {
            player addItem "Medikit";
        } else {
            for "_i" from 1 to 4 do {
                player addItem "FirstAidKit";
            };
        };
    };

    player setVariable ["DM_var_lastLoadout", _startLoadout];
};

DM_fnc_setToSpawn = {
    params ["_transitionEnabled"];
    
    if _transitionEnabled then {
        1 fadeSound 0;
        cutText ["", "BLACK OUT", 0, true];
        sleep 1;
    };

    _pos = getMarkerPos ("DM_mrk_" + (str (side (group player))) + "HQ");

    _safePos = [];
    _rad = 3;
    _startTime = serverTime;

    waitUntil {
        waitUntil {_pos findEmptyPositionReady [0, _rad]};
        _safePos = _pos findEmptyPosition [0, _rad, "B_Soldier_F"];
        _rad = _rad + 0.5;

        (
            (
                !(_safePos isEqualTo []) &&
                {(_safePos distance _pos) < 5} &&
                {
                    _safePosAsl = _safePos;
                    _safePosAsl set [2, 0];
                    _safePosAsl = AGLToASL _safePosAsl;
                    _safePosAsl set [2, ((_safePosAsl select 2) + 0.5)];

                    (([objNull, "VIEW"] checkVisibility [_safePosAsl, (_safePosAsl vectorAdd [0, 0, 100])]) != 0)
                }
            ) ||
            {if ((serverTime - _startTime) > 2) then {_safePos = _pos; true} else {false}}
        )
    };

    player setPos _safePos;
    _timeStart = time;
    player setDamage 0;
    [_transitionEnabled] call DM_fnc_ehRespawnClient;

    waitUntil {
        if ((player distance _safePos) > 10) then {
            player setPos _safePos;
            player setDir (markerDir("respawn_" + (str (side (group player)))));
            player setVelocity [0, 0, 0];
        };

        ((time - _timeStart) > 2)
    };
};

DM_fnc_ehRespawnClient = {
    params ["_transitionEnabled"];

    if !DM_var_gpsSet then {
        player enableInfoPanelComponent ["right", "MinimapDisplay", true];
        player enableInfoPanelComponent ["left", "MinimapDisplay", false];
        opengps true;
        player enableInfoPanelComponent ["left", "MinimapDisplay", true];
        DM_var_gpsSet = true;
    };

    [player, false] call ADG_fnc_allowDamage;
    call TDI_fnc_startTdIconsClient;
    _nightVisionWasEnabled = DM_var_nvGogglesEnabled;
    player switchCamera DM_var_lastview;
    DM_var_cameraViewLoopScript = [] spawn DM_fnc_cameraViewLoop;
    player setDir (markerDir("respawn_" + (str (side (group player)))));
    1 fadesound ([1, 0.3] select DM_var_earplugsOn);
    player setUnitLoadout (player getVariable "DM_var_lastLoadout");

    [_nightVisionWasEnabled] spawn {
        params ["_nightVisionWasEnabled"];

        if _nightVisionWasEnabled then {
            waitUntil {!DM_var_nvGogglesEnabled};
            DM_var_nvGogglesEnabled = true;
        };

        waitUntil {!(isNull player)};
        player switchMove "UP";

        if DM_var_nvGogglesEnabled then {
            player action ["nvGoggles", player];
        };
    };

    if _transitionEnabled then {
        cutText ["", "BLACK IN", 0, true];
    };

    [] spawn {
        sleep 3;
        waitUntil {DM_var_movingEnabled};
        [player, true] call ADG_fnc_allowDamage;
    };
};

DM_fnc_spawnSpawn = {
    params ["_resetLoadout", "_relRoundNumber", "_items"];

    _hdl = [] spawn DM_fnc_closeArs;

    waitUntil {scriptDone _hdl};

    if (alive player) then {
        _hdl = [true] spawn DM_fnc_setToSpawn;

        waitUntil {scriptDone _hdl};
    } else {
        setPlayerRespawnTime 0;
        waitUntil {alive player};
    };

    if _resetLoadout then {
        _hdl = [] spawn DM_fnc_resetLoadout;

        waitUntil {scriptDone _hdl};
    };

    _hdl = scriptNull;

    if DM_var_loadoutsRestricted then {
        _hdl = [_relRoundNumber, _items] spawn DM_fnc_applyItemsOnArsenal;
    };

    waitUntil {!(isNull player) && !(player getVariable "DM_var_isLoading") && (scriptDone _hdl)};

    call DM_fnc_openArs;
};

DM_fnc_spectator = {
    ["", 0, 0, 0, 0, 0, 788] spawn BIS_fnc_dynamicText;

    ["Initialize", [
        player,
        (if !TDI_var_ShowAllSidesOnSpectator then {[side (group player)]} else {[west, east]}),
        true,
        RscSpectator_allowFreeCam,
        RscSpectator_allowFreeCam,
        true,
        false,
        false,
        false,
        true
    ]] call BIS_fnc_EGSpectator;
    call TDI_fnc_stopTdIconsClient;

    if !RscSpectator_allowFreeCam then {
        [] spawn {
            _on = false;

            waitUntil {
                if (((simulationEnabled focusOn) && {alive focusOn} && {((positionCameraToWorld [0, 0, 0]) distance [0, 0, 0]) > 100}) isEqualTo !_on) then {
                    _on = !_on;
                    cutText ["", (if _on then {"PLAIN"} else {"BLACK FADED"}), 0, true];
                    0 fadesound (if _on then {1} else {0});
                };

                (simulationEnabled player) && {alive player} && {!(isNull (findDisplay 46))}
            };

            ["Terminate"] call BIS_fnc_EGSpectator;
            cutText ["", "BLACK FADED", 9999, true];
        };
    } else {
        cutText ["", "PLAIN", 0, true];
        0.5 fadesound ([1, 0.3] select DM_var_earplugsOn);
    };
};