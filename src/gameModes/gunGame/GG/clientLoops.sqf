GG_fnc_cameraViewLoop = {
    waitUntil {
        if (!(GG_var_lastView isEqualTo cameraView) && {cameraView in ["EXTERNAL", "INTERNAL"]}) then {
            GG_var_lastView = cameraView;
        };
        false
    };
};

GG_fnc_forceFPPLoop = {
    waitUntil {
        if ((alive player) && {cameraView == "EXTERNAL"}) then {
            player switchCamera "INTERNAL";
        } else {
            waitUntil {alive player};
        };

        false
    };
};

GG_fnc_guiLoop = {
    disableSerialization;
    _dialog = uiNamespace getVariable "GG_var_GUI";

    waitUntil {
        _kills = player getVariable "GG_var_weaponNum";
        _deaths = player getVariable "GG_var_deaths";
        _hp = ceil ((1 - damage(if (alive player) then {player} else {(positionCameraToWorld [0, 0, 0]) nearestObject "Man"})) * 100);

        (_dialog displayCtrl 1201) ctrlSetText ((str _hp) + " HP");
        (_dialog displayCtrl 1002) ctrlSetText (format ["Kills: %1 Deaths: %2", _kills, _deaths]);
        (_dialog displayCtrl 1003) ctrlSetText (format ["K/D: %1 Units: %2",
            ([(if (_deaths != 0) then {_kills / _deaths} else {0}), 1] call BIS_fnc_cutDecimals),
            ({if !(isPlayer _x) then {simulationEnabled _x} else {_load = _x getVariable "GG_var_isLoading"; (if !(isNil "_load") then {!_load} else {false})}} count (entities [["CAManBase"], [], true, false]))
        ]);
        (_dialog displayCtrl 1200) ctrlSetPosition [(0.89 * safezoneW + safezoneX), (0.962 * safezoneH + safezoneY), ((_hp / 100) * 0.1 * safezoneW), 0.022 * safezoneH];
        (_dialog displayCtrl 1200) ctrlCommit 0;
        sleep (1/10);
        false
    };
};

GG_fnc_playZoneLoop = {
    waitUntil {
        _lastPos = player getVariable "GG_var_lastPos";

        if !(player inArea "GG_var_playZone") then {
            if ((_lastPos inArea "GG_var_playZone") && {(player distance _lastPos) < 1}) then {
                player setPos _lastPos;
            };
        } else {
            player setVariable ["GG_var_lastPos", (getPosATL player)];
        };

        sleep 0.01;

        false
    };
};

GG_fnc_spectatorNightVisionLoop = {
    waitUntil {
        waitUntil {!(isNull (findDisplay 60492))};

        (findDisplay 60492) displayAddEventHandler ["KeyDown", {
            params ["", "_key"];
            
            if ((_key in (actionKeys "nightVision")) || {_key in (actionKeys "TransportNightVision")}) then {
                GG_var_nvGogglesEnabled = !GG_var_nvGogglesEnabled;
                true
            };
        }];

        waitUntil {
            camUseNVG GG_var_nvGogglesEnabled;
            focusOn action [(["nvGogglesOff", "nvGoggles"] select GG_var_nvGogglesEnabled), focusOn];

            isNull (findDisplay 60492)
        };
        player action [(["nvGogglesOff", "nvGoggles"] select GG_var_nvGogglesEnabled), player];

        false
    };
};