SC_fnc_cameraViewLoop = {
    params ["_initialView"];

    waitUntil {
        player switchCamera _initialView;
        cameraView isEqualTo _initialView
    };

    SC_var_lastView = _initialView;

    waitUntil {
        if (!(SC_var_lastView isEqualTo cameraView) && {cameraView in ["EXTERNAL", "INTERNAL"]}) then {
            SC_var_lastView = cameraView;
            profileNameSpace setVariable ["SC_var_lastView", SC_var_lastView];
        };
        false
    };
};

SC_fnc_forceFPPLoop = {
    waitUntil {
        if ((alive player) && {cameraView == "EXTERNAL"}) then {
            player switchCamera "INTERNAL";
        } else {
            waitUntil {alive player};
        };

        false
    };
};

SC_fnc_staminaSystemLoop = {
    waitUntil {
        waitUntil {
            _speed = vectorMagnitude (velocity player);
            _holdsSprintButton = (inputAction "turbo") == 1;
            _increase = 0;

            if (isNull (objectParent player)) then {
                if (
                    (_holdsSprintButton && {_speed > 4.3}) ||
                    {(SC_var_stamina <= 0.2) && {_speed > 3.3}} ||
                    {(SC_var_stamina <= 0.05) && {_speed > 1}}
                ) then {
                    _increase = -1;
                } else {
                    if (_speed <= 1) then {
                        _increase = 2;
                    } else {
                        if (_speed < 3.3) then {
                            _increase = 1;
                        } else {
                            if (_speed < 4.3) then {
                                _increase = 0.5;
                            };
                        };
                    };

                    _increase = _increase * (switch (stance player) do {
                        case "CROUCH": {1.2};
                        case "PRONE": {1.5};
                        default {1};
                    });
                };
            } else {
                _increase = 3;
            };

            if ("STAM" in SC_var_perks) then {
                if (_increase < 0) then {
                    _increase = 0.5 * _increase;
                } else {
                    _increase = 0.75 * _increase;
                };
            };

            SC_var_stamina = ((SC_var_stamina + (0.01 * _increase * (40 * (load player)) ^ 0.2)) max 0) min 1;
            player allowSprint (SC_var_stamina > 0.2);
            player forceWalk (SC_var_stamina <= 0.05);
            player setCustomAimCoef (if (SC_var_stamina > 0.2) then {0.3} else {0.3 + (0.7 * (1 - (SC_var_stamina / 0.2)))});

            sleep 0.5;

            !(alive player)
        };

        SC_var_stamina = 1;
        waitUntil {alive player};

        false
    };
};

SC_fnc_inventoryDisabledCooldownLoop = {
    waitUntil {
        if (SC_var_inventoryDisabledCooldown > 0) then {
            SC_var_inventoryDisabledCooldown = SC_var_inventoryDisabledCooldown - 1;
        };

        sleep 1;
        false
    };
};

SC_fnc_arsenalThermalLoop = {
    waitUntil {
        _mode = missionNamespace getVariable ["BIS_fnc_arsenal_visionMode", -1];

        if (_mode == 2) then {
            _mode = 0;
            false setCamUseTi 0;
            camUseNVG false;
            missionNamespace setVariable ["BIS_fnc_arsenal_visionMode", 0];
        };

        if (SC_var_nvGogglesEnabled != (_mode == 1)) then {
            SC_var_nvGogglesEnabled = !SC_var_nvGogglesEnabled;
        };

        false
    };
};

SC_fnc_disableThermalLoop = {
    _blackedOut = false;

    waitUntil {
        if (_blackedOut != ((currentVisionMode player) == 2)) then {
            _blackedOut = !_blackedOut;
            
            if _blackedOut then {
                cutText ["Thermal vision is disabled, press 'N' to switch to another vision mode.", "BLACK FADED", 0, false, false];
            } else {
                cutText ["", "PLAIN", 0, false, false];
            };
        };

        false
    };
};

SC_fnc_respawnPositionsLoop = {
    waitUntil {
        call {
            {
                _x params ["_unit"];

                if ((alive _unit) && {!(_unit getVariable ["ais_unconscious", false])} && {simulationEnabled _unit} && {!(_unit in (SC_var_groupResArr apply {_x select 0}))}) then {
                    ([player, _unit, (_unit getVariable "SC_var_name")] call BIS_fnc_addRespawnPosition) params ["", "_resID"];
                    SC_var_groupResArr pushBack [_unit, _resId];
                };
            } forEach (([player] call SC_fnc_getGroupUnits) - [player]);
        };

        sleep 0.5;

        call {
            _groupUnits = [player] call SC_fnc_getGroupUnits;

            {
                _x params ["_unit", "_resId"];
                
                if (!(alive _unit) || {_unit getVariable ["ais_unconscious", false]} || {!(simulationEnabled _unit)} || {!(_unit in _groupUnits)}) then {
                    [player, _resId] call BIS_fnc_removeRespawnPosition;
                };
            } forEach SC_var_groupResArr;

            SC_var_groupResArr = SC_var_groupResArr select {(alive (_x select 0)) && {!((_x select 0) getVariable ["ais_unconscious", false])} && {simulationEnabled (_x select 0)} && {(_x select 0) in _groupUnits}};
        };

        sleep 0.5;
        false
    };
};

SC_fnc_uavTerminalLoop = {
    waitUntil {
        waitUntil {!(isNull (findDisplay 160))};

        waitUntil {
            if (isNull (findDisplay 160)) then {
                SC_var_uavTerminalOpened = false;
                true
            } else {
                SC_var_mapScale = ctrlMapScale ((findDisplay 160) displayCtrl 51);
                SC_var_mapPosition = ((findDisplay 160) displayCtrl 51) ctrlMapScreenToWorld [0.5, 0.53];
                false
            }
        };
        
        false
    };
};

SC_fnc_spectatorNightVisionLoop = {
    waitUntil {
        waitUntil {!(isNull (findDisplay 60492))};

        (findDisplay 60492) displayAddEventHandler ["KeyDown", {
            params ["", "_key"];
            
            if ((_key in (actionKeys "nightVision")) || {_key in (actionKeys "TransportNightVision")}) then {
                SC_var_nvGogglesEnabled = !SC_var_nvGogglesEnabled;
                true
            };
        }];

        waitUntil {
            camUseNVG SC_var_nvGogglesEnabled;
            focusOn action [(["nvGogglesOff", "nvGoggles"] select SC_var_nvGogglesEnabled), focusOn];

            isNull (findDisplay 60492)
        };
        player action [(["nvGogglesOff", "nvGoggles"] select SC_var_nvGogglesEnabled), player];

        false
    };
};

SC_fnc_cameraNightVisionLoop = {
    waitUntil {
        waitUntil {!(isNull (findDisplay 314))};

        (findDisplay 314) displayAddEventHandler ["KeyDown", {
            params ["", "_key"];
            
            if ((_key in (actionKeys "nightVision")) || {_key in (actionKeys "TransportNightVision")}) then {
                SC_var_nvGogglesEnabled = !SC_var_nvGogglesEnabled;
                true
            };
        }];

        waitUntil {
            camUseNVG SC_var_nvGogglesEnabled;
            focusOn action [(["nvGogglesOff", "nvGoggles"] select SC_var_nvGogglesEnabled), focusOn];

            {
                false setCamUseTI _x;
            } forEach [0, 1, 2, 3, 4, 5, 6, 7];

            isNull (findDisplay 314)
        };
        player action [(["nvGogglesOff", "nvGoggles"] select SC_var_nvGogglesEnabled), player];

        false
    };
};

SC_var_broadcastCameraViewLoop = {
    waitUntil {
        if (alive player) then {
            player setVariable ["SC_var_cameraView", cameraView, true];
        };

        sleep 0.3;
        
        false
    };
};