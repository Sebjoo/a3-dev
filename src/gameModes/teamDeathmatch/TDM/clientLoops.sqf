DM_fnc_guiLoop = {
    disableSerialization;
    _dialog = uiNamespace getVariable "GUI";

    waitUntil {
        _hp = ceil ((1 - (damage focusOn)) * 100);

        (_dialog displayCtrl 1201) ctrlSetText ((str _hp) + " HP");
        (_dialog displayCtrl 1200) ctrlSetPosition [
            safeZoneX + (0.5 * safeZoneW) - (0.5 * 0.12375 * safezoneW),
            (0.962 * safezoneH + safezoneY),
            ((_hp / 100) * 0.12375 * safezoneW),
            0.022 * safezoneH
        ];
        (_dialog displayCtrl 1200) ctrlCommit 0;
        (_dialog displayCtrl 1100) ctrlSetText (str DM_var_westPoints);
        (_dialog displayCtrl 1102) ctrlSetText (str DM_var_eastPoints);
        (_dialog displayCtrl 1101) ctrlSetText DM_var_timerStr;

        _alivePlayers = [west, east] apply {
            _side = _x;
            (
                {
                    ((side (group _x)) == _side) &&
                    {!((isPlayer _x) && {_x getVariable "DM_var_isLoading"})} &&
                    {simulationEnabled _x} &&
                    {!([_x] call KF_fnc_isUavAi)}
                } count (entities [["CAManBase"], [], true, true])
            )
        };
        (_dialog displayCtrl 1000) ctrlSetText (str (_alivePlayers select 0));
        (_dialog displayCtrl 1001) ctrlSetText (str (_alivePlayers select 1));

        false
    };
};

DM_fnc_cameraViewLoop = {
    waitUntil {
        if (!(DM_var_lastView isEqualTo cameraView) && {cameraView in ["EXTERNAL", "INTERNAL"]}) then {
            DM_var_lastView = cameraView;
        };
        false
    };
};

DM_fnc_arsenalThermalLoop = {
    waitUntil {
        _mode = missionNamespace getVariable ["BIS_fnc_arsenal_visionMode", -1];

        if (_mode == 2) then {
            _mode = 0;
            false setCamUseTi 0;
            camUseNVG false;
            missionNamespace setVariable ["BIS_fnc_arsenal_visionMode", 0];
        };

        if (DM_var_nvGogglesEnabled != (_mode == 1)) then {
            DM_var_nvGogglesEnabled = !DM_var_nvGogglesEnabled;
        };

        false
    };
};

DM_fnc_thirdPersonLoop = {
    waitUntil {
        if (alive player) then {
            if (cameraView == "EXTERNAL") then {
                player switchCamera "INTERNAL";
            };
        } else {
            waitUntil {alive player};
        };

        false
    };
};

DM_fnc_respawnTimeLoop = {
    _lastResTime = 9999;
    
    waitUntil {
        if (DM_var_respawnTime != _lastResTime) then {
            _lastResTime = DM_var_respawnTime;
            setplayerrespawntime _lastResTime;

            if ((_lastResTime == 4) && {!(simulationEnabled player)}) then {
                sleep 3;
                player enableSimulationGlobal true;
            };
        };

        false
    };
};

DM_fnc_movementLoop = {
    _enabled = true;

    waitUntil {
        if (DM_var_movingEnabled != _enabled) then {
            DM_var_movingEnabled call DM_fnc_movementClient;
            _enabled = DM_var_movingEnabled;
        };

        false
    };
};

DM_fnc_spectatorNightVisionLoop = {
    waitUntil {
        waitUntil {!(isNull (findDisplay 60492))};

        (findDisplay 60492) displayAddEventHandler ["KeyDown", {
            params ["", "_key"];
            
            if ((_key in (actionKeys "nightVision")) || {_key in (actionKeys "TransportNightVision")}) then {
                DM_var_nvGogglesEnabled = !DM_var_nvGogglesEnabled;
                true
            };
        }];

        waitUntil {
            camUseNVG DM_var_nvGogglesEnabled;
            focusOn action [(["nvGogglesOff", "nvGoggles"] select DM_var_nvGogglesEnabled), focusOn];

            isNull (findDisplay 60492)
        };
        player action [(["nvGogglesOff", "nvGoggles"] select DM_var_nvGogglesEnabled), player];

        false
    };
};