MM_var_clientRunning = nil;

MM_var_entityRespawnedEhId = -1;
MM_var_drawEhIds = [];
MM_var_uavTerminalLoopScript = scriptNull;
MM_var_cameraMapDrawEHLoopScript = scriptNull;
MM_var_updateDrawArrayLoopScript = scriptNull;
MM_var_updateDrawArrayScript = scriptNull;

MM_var_colorYellow = [1, 0.83, 0, 1];
MM_var_colorWhite = [1, 1, 1, 1];
MM_var_colorDefault = [0.75, 0.75, 0.75, 1];

uiNamespace setVariable ["MM_var_currentDisplay", displayNull];
uiNamespace setVariable ["MM_var_gpsDisplays", []];
MM_var_gatherDrawArrFncs = [];
MM_var_lastDrawArrUpdateFrameNo = 0;
MM_var_lastDrawFrameNo = 0;
MM_var_gpsOpened = false;
MM_var_showUnitNamesOverride = true;
MM_var_ShowAllSidesOverride = false;
MM_var_drawArray = [];
MM_var_preDrawArray = [];

{
    missionNamespace setVariable [("MM_var_units" + (str _x)), []];
} forEach [west, east, independent, civilian, sideEmpty, sideLogic, sideAmbientLife, sideUnknown];

MM_fnc_isUavAi = {
    params ["_unit"];
    
    "UAV_AI" in (typeOf _unit)
};

MM_fnc_getSideString = {
    params ["_side"];

    if (_side != sideAmbientLife) then {
        str _side
    } else {
        "AmbientLife"
    }
};

MM_fnc_UAVControlUnits = {
    params ["_vehicle", ["_onlyControlling", false]];

    _UAVControl = UAVControl _vehicle;
    _UAVControls = [_UAVControl select [0, 2]];

    if ((count _UAVControl) == 4) then {
        _UAVControls pushBack (_UAVControl select [2, 2]);
    };

    if _onlyControlling then {
        (_UAVControls select {(_x select 1) != ""}) apply {_x select 0}
    } else {
        (_UAVControls select {!(isNull (_x select 0))}) apply {_x select 0}
    }
};

MM_fnc_getCrew = {
    params ["_vehicle"];

    _crew = [];

    if (unitIsUav _vehicle) then {
        _crew = (crew _vehicle) select {!([_x] call MM_fnc_isUavAi)};
        
        {
            _crew pushBackUnique _x;
        } forEach ([_vehicle] call MM_fnc_UAVControlUnits);
    } else {
        _crew = crew _vehicle;
    };

    _crew
};

MM_fnc_getGroupUnits = {
    params ["_unit"];

    (units (group _unit))
};

MM_fnc_isPosVisibleOnGPS = {
    params ["_ctrlGPS", "_posWorld"];

    if (isNull _ctrlGPS) exitWith {false};

    (ctrlMapPosition _ctrlGPS) params ["_posXGPSMap", "_posYGPSMap", "_widthGPSMap", "_heightGPSMap"];
    (_ctrlGPS ctrlMapWorldToScreen _posWorld) params ["_posXGui", "_posYGui"];

    _posXOnGPS = 0.012771 - ((_posXGPSMap - _posXGui) / _widthGPSMap);
    _posYOnGPS = 1.128351 + ((_posYGPSMap - _posYGui) / _heightGPSMap);

    (
        _posXOnGPS >= 0 &&
        {_posXOnGPS <= 1} &&
        {_posYOnGPS >= 0} &&
        {_posYOnGPS <= 1}
    )
};

MM_fnc_getTeamMapColor = {
    params ["_side"];

    switch _side do {
        case west: {[0, 0.5, 1, 1]};
        case east: {[1, 0, 0, 1]};
        case independent: {[0, 0.8, 0.27, 1]};
        default {[0.75, 0.75, 0.75, 1]};
    }
};

MM_fnc_UAVControl = {
    params ["_unit", "_mode", ["_altMode", ""]];
    _ret = objNull;

    _UAVControl = UAVControl _unit;
    _UAVControls = [_UAVControl select [0, 2]];

    if ((count _UAVControl) == 4) then {
        _UAVControls pushBack (_UAVControl select [2, 2]);
    };

    _pos = (_UAVControls apply {_x select 1}) find _mode;

    if (_pos != -1) then {
        _ret = (_UAVControls select _pos) select 0;
    } else {
        if (_altMode != "") then {
            _pos = (_UAVControls apply {_x select 1}) find _altMode;

            if (_pos != -1) then {
                _ret = (_UAVControls select _pos) select 0;
            };
        };
    };

    _ret
};

MM_fnc_updateDrawArray = {
    params ["_sleep"];

    _unit = if !(unitIsUAV focusOn) then {focusOn} else {[(objectParent focusOn), "DRIVER", "GUNNER"] call MM_fnc_UAVControl};
    _isInSpectator = !(_unit isEqualTo player);
    _group = group _unit;
    _groupUnits = [_unit] call MM_fnc_getGroupUnits;
    _side = _unit getVariable ["MM_var_side", sideUnknown];
    _objectViewDistance = if isServer then {-1} else {getObjectViewDistance select 0};
    _camPos = if isServer then {[]} else {positionCameraToWorld [0, 0, 0]};

    {
        {
            if (
                !(isNull _x) &&
                {simulationEnabled _x} &&
                {!MM_var_gpsOpened || {[(uiNamespace getVariable "MM_var_currentDisplay"), (getPosWorldVisual _x)] call MM_fnc_isPosVisibleOnGPS}} &&
                {
                    MM_var_showAliveGroupUnits ||
                    {_x isEqualTo _unit} ||
                    {!(_x in _groupUnits)} ||
                    {!(alive _x)} ||
                    {_x getVariable ["AIS_unconscious", false]}
                }
            ) then {
                _parX = objectParent _x;
                _isHidden = isObjectHidden _x;

                if (isNull _parX) then {
                    if !_isHidden then {
                        _size = 20;
                        _color = [];
                        _icon = "";

                        if (alive _x) then {
                            _color = if (_x in _groupUnits) then {
                                if (_x isEqualTo _unit) then {MM_var_colorYellow} else {MM_var_colorWhite}
                            } else {
                                _x getVariable ["MM_var_color", MM_var_colorDefault]
                            };

                            if (_x getVariable ["AIS_unconscious", false]) then {
                                _size = 16.3;
                                _icon = "pictureHeal";
                            } else {
                                _icon = if MM_var_restrictUnitIcons then {
                                    if (_x getUnitTrait "Medic") then {"iconManMedic"} else {"iconMan"};
                                } else {
                                    switch true do {
                                        case (_x getUnitTrait "Medic"): {"iconManMedic"};
                                        case (_x getUnitTrait "Engineer"): {"iconManEngineer"};
                                        case (_x getUnitTrait "ExplosiveSpecialist"): {"iconManExplosive"};
                                        case ((((primaryWeapon _x) call BIS_fnc_itemType) select 1) == "MachineGun"): {"iconManMG"};
                                        case ((((primaryWeapon _x) call BIS_fnc_itemType) select 1) == "SniperRifle"): {"iconManRecon"};
                                        case ((secondaryWeapon _x) != ""): {"iconManAT"};
                                        case (_x isEqualTo (leader (group _x))): {"iconManLeader"};
                                        case ((rankId _x) >= 2): {"iconManOfficer"};
                                        default {"iconMan"};
                                    }
                                };
                            };
                        } else {
                            _size = 30;
                            _color = if (_x isEqualTo _unit) then {MM_var_colorYellow} else {_x getVariable ["MM_var_color", MM_var_colorDefault]};
                            _icon = "iconExplosiveGP";
                        };

                        _xIsWithinObjViewDistance = isServer || {(_x distance _camPos) <= _objectViewDistance};
                        MM_var_preDrawArray pushBack [_x, _xIsWithinObjViewDistance, 0, !(_x getVariable ["AIS_unconscious", false]), _icon, _color, _size, "", 1, 0, true];

                        if (MM_var_showUnitNamesOverride && {MM_var_showUnitNames}) then {
                            MM_var_preDrawArray pushBack [_x, _xIsWithinObjViewDistance, 55, false, "iconMan", [1, 1, 1, 1], 0, (_x getVariable ["MM_var_name", ""]), 2, 0.0495, false];
                        };
                    };
                } else {
                    if (!_isHidden && {_parX isKindOf "Steerable_Parachute_F"}) then {
                        _driver = driver _x;
                        _xIsWithinObjViewDistance = isServer || {(_x distance _camPos) <= _objectViewDistance};

                        MM_var_preDrawArray pushBack [
                            _x, _xIsWithinObjViewDistance, 0, false, "iconParachute",
                            (if (_driver in _groupUnits) then {
                                if (_driver isEqualTo _unit) then {MM_var_colorYellow} else {MM_var_colorWhite}
                            } else {
                                _x getVariable ["MM_var_color", MM_var_colorDefault]
                            }),
                            16, "", 1, 0, true
                        ];

                        if (MM_var_showUnitNamesOverride && {MM_var_showUnitNames}) then {
                            MM_var_preDrawArray pushBack [_x, _xIsWithinObjViewDistance, 48, false, "iconParachute", MM_var_colorWhite, 0, (_driver getVariable ["MM_var_name", ""]), 2, 0.0495, false];
                        };
                    } else {
                        if (
                            (!_isHidden && {(_parX getVariable ["MM_var_lastDrawArrUpdateFrameNo", 0]) <= MM_var_lastDrawArrUpdateFrameNo}) ||
                            {([_x] call MM_fnc_isUavAi) && {_x isEqualTo (driver _parX)}}
                        ) then {
                            _parX setVariable ["MM_var_lastDrawArrUpdateFrameNo", diag_frameNo];
                            _crew = [_parX] call MM_fnc_getCrew;
                            _crewParX = crew _parX;
                            _crewAlive = [];
                            _crewDead = [];

                            {
                                if (alive _x) then {
                                    _crewAlive pushBack _x;
                                } else {
                                    _crewDead pushBack _x;
                                };
                            } forEach _crew;

                            _groupUnitsInCrew = _crew arrayIntersect _groupUnits;

                            _color = if (_groupUnitsInCrew isEqualTo []) then {
                                if (_crew isEqualTo []) then {
                                    [(_crewParX select 0) getVariable ["MM_var_side", sideUnknown]] call MM_fnc_getTeamMapColor
                                } else {
                                    (_crew select 0) getVariable ["MM_var_color", MM_var_colorDefault]
                                }
                            } else {
                                if (_unit in _groupUnitsInCrew) then {MM_var_colorYellow} else {MM_var_colorWhite}
                            };

                            _size = _parX getVariable ["MM_var_iconSize", 0];
                            _icon = _parX getVariable ["MM_var_icon", "iconCar"];
                            _parXIsWithinObjViewDistance = isServer || {(_parX distance _camPos) <= _objectViewDistance};

                            MM_var_preDrawArray pushBack [_parX, _parXIsWithinObjViewDistance, 0, true, _icon, _color, _size, "", 1, 0, true];

                            if (MM_var_showUnitNamesOverride && {MM_var_showUnitNames}) then {
                                _crewFirstTwo = _crew select [0, 2];

                                {
                                    if (alive _x) then {
                                        _crewAlive deleteAt 0;
                                    } else {
                                        _crewDead deleteAt 0;
                                    };
                                } forEach _crewFirstTwo;

                                MM_var_preDrawArray pushBack [
                                    _parX, _parXIsWithinObjViewDistance, (3 * _size), false, _icon, MM_var_colorWhite, 0,
                                    (
                                        [
                                            (_parX getVariable ["MM_var_name", ""]),
                                            (if (unitIsUav _parX) then {" (AI)"} else {""}),
                                            (if (alive _parX) then {""} else {" (destroyed)"}),
                                            (if (_crew isEqualTo []) then {
                                                ""
                                            } else {
                                                [" [", "]"] joinString (
                                                    (
                                                        (
                                                            (_crewFirstTwo apply {
                                                                [
                                                                    (_x getVariable ["MM_var_name", ""]),
                                                                    (if (alive _x) then {
                                                                        if ((getConnectedUAV _x) isEqualTo _parX) then {
                                                                            if (_x in _crewParX) then {
                                                                                " (crew + remote)"
                                                                            } else {
                                                                                " (remote)"
                                                                            }
                                                                        } else {
                                                                            if (_x getVariable ["AIS_unconscious", false]) then {
                                                                                " (unconscious)"
                                                                            } else {
                                                                                ""
                                                                            }
                                                                        }
                                                                    } else {
                                                                        " (dead)"
                                                                    })
                                                                ] joinString ""
                                                            }) + [
                                                                (if !(_crewAlive isEqualTo []) then {["+ ", " alive"] joinString (str (count _crewAlive))} else {""}),
                                                                (if !(_crewDead isEqualTo []) then {["+ ", " dead"] joinString (str (count _crewDead))} else {""})
                                                            ]
                                                        ) select {_x != ""}
                                                    ) joinString ", "
                                                )
                                            })
                                        ] joinString ""
                                    ),
                                    2, 0.0495, false
                                ];
                            };
                        };
                    };
                };
            };

            if _sleep then {
                sleep 0.0015;
            };
        } forEach (missionNamespace getVariable _x);
    } forEach (
        if (MM_var_ShowAllSidesOverride || {MM_var_ShowAllSides} || {_isInSpectator && {MM_var_ShowAllSidesOnSpectator}}) then {
            ["MM_var_unitsWest", "MM_var_unitsEast", "MM_var_unitsGuer", "MM_var_unitsCiv"]
        } else {
            [["MM_var_units", ([_side] call MM_fnc_getSideString)] joinString ""]
        }
    );

    if _sleep then {
        {
            _hdl = [_sleep] spawn (missionNameSpace getVariable _x);
            waitUntil {scriptDone _hdl};
        } forEach MM_var_gatherDrawArrFncs;
    } else {
        {
            [_sleep] call (missionNameSpace getVariable _x);
        } forEach MM_var_gatherDrawArrFncs;
    };

    MM_var_drawArray = MM_var_preDrawArray;
    MM_var_preDrawArray = [];
    MM_var_lastDrawArrUpdateFrameNo = diag_frameNo;
};

MM_fnc_updateDrawArrayLoop = {
    waitUntil {
        waitUntil {(diag_frameNo - MM_var_lastDrawFrameNo) < 10};
        MM_var_updateDrawArrayScript = [true] spawn MM_fnc_updateDrawArray;
        waitUntil {scriptDone MM_var_updateDrawArrayScript};

        false
    };
};

MM_fnc_getPos = {
    params ["_entity", "_isWithinObjectViewDistance"];

    if _isWithinObjectViewDistance then {
        getPosWorldVisual _entity
    } else {
        _entity getVariable ["MM_var_serverPos", [0, 0, 0]]
    }
};

MM_fnc_getDir = {
    params ["_entity", "_isWithinObjectViewDistance"];

    if _isWithinObjectViewDistance then {
        getDirVisual _entity
    } else {
        _entity getVariable ["MM_var_serverDir", 0]
    }
};

MM_fnc_updateDrawArrayImmediate = {
    if !(scriptDone MM_var_updateDrawArrayScript) then {
        terminate MM_var_updateDrawArrayScript;
    };
    
    MM_var_drawArray = [];
    MM_var_preDrawArray = [];
    MM_var_lastDrawArrUpdateFrameNo = diag_frameNo;
    [false] call MM_fnc_updateDrawArray;
};

MM_fnc_drawIcons = {
    params ["_display"];

    uiNamespace setVariable ["MM_var_currentDisplay", _display];
    MM_var_gpsOpened = _display in (uiNamespace getVariable "MM_var_gpsDisplays");
    MM_var_ShowAllSidesOverride = _display isEqualTo ((findDisplay 314) displayCtrl 3141);

    if (
        (MM_var_showUnitNamesOverride == MM_var_gpsOpened) ||
        {(scriptDone MM_var_updateDrawArrayScript) && {(diag_frameNo - MM_var_lastDrawArrUpdateFrameNo) > 200}}
    ) then {
        MM_var_showUnitNamesOverride = !MM_var_gpsOpened;
        call MM_fnc_updateDrawArrayImmediate;
    };

    _ctrlMapScale = ctrlMapScale _display;
    _mousePos = getMousePosition;

    _textSizeFactor = if (_ctrlMapScale < 0.1) then {
        if (_ctrlMapScale < 0.05) then {
            0.7
        } else {
            0.3 + (6 * _ctrlMapScale)
        }
    } else {
        1
    };

    {
        if (
            (_x select 10) ||
            {
                !MM_var_gpsOpened &&
                {!MM_var_showUnitNamesOnlyOnHover || {((_display ctrlMapWorldToScreen ([(_x select 0), (_x select 1)] call MM_fnc_getPos)) distance _mousePos) < 0.02}}
            }
        ) then {
            _x params ["_entity", "_isWithinObjectViewDistance", "_offsetToRight", "_calculateDir", "_icon", "_color", "_size", "_text", "_shadow", "_textSize"];

            _display drawIcon ([
                _icon,
                (if (_color isEqualType []) then {_color} else {call _color}),
                (if (_offsetToRight == 0) then {
                    [_entity, _isWithinObjectViewDistance] call MM_fnc_getPos
                } else {
                    ([_entity, _isWithinObjectViewDistance] call MM_fnc_getPos) vectorAdd [(_offsetToRight * _ctrlMapScale * MM_var_mapScaleFactor), 0, 0]
                }),
                _size,
                _size,
                (if _calculateDir then {[_entity, _isWithinObjectViewDistance] call MM_fnc_getDir} else {0}),
                _text,
                _shadow
            ] + (if (_textSize != 0) then {[_textSizeFactor * _textSize]} else {[]}));
        };
    } forEach MM_var_drawArray;

    MM_var_lastDrawFrameNo = diag_frameNo;
};

MM_fnc_updateServerPosAndDir = {
    params ["_entity", "_pos", "_dir"];

    if !(isNull _entity) then {
        _entity setVariable ["MM_var_serverPos", _pos];
        _entity setVariable ["MM_var_serverDir", _dir];
    };
};

MM_fnc_entityInitClient = {
    params ["_entity"];

    if (_entity isKindOf "CAManBase") then {
        _id = _entity getVariable ["MM_var_deletedEhId", -1];
        if (_id != -1) then {_entity removeEventHandler ["Deleted", _id];};
        _id = _entity addEventHandler ["Deleted", {
            params ["_entity"];

            _sideStr = [_entity getVariable ["MM_var_side", sideUnknown]] call MM_fnc_getSideString;
            _entity call (compile (["MM_var_units", _sideStr, " deleteAt (MM_var_units", _sideStr," find _this);"] joinString ""));
        }];
        _entity setVariable ["MM_var_deletedEhId", _id];

        _varStr = ["MM_var_units", ([side (group _entity)] call MM_fnc_getSideString)] joinString "";
        
        if ((random 1) < 0.01) then {
            call (compile ([_varStr, " = ", _varStr, " - [objNull];"] joinString ""));
        };

        _entity call (compile ([_varStr, " pushBackUnique _this;"] joinString ""));
    };

    [_entity, (getPosWorldVisual _x), (getDirVisual _x)] call MM_fnc_updateServerPosAndDir;
};

MM_fnc_findControlArray = {
    params ["_idds", "_idc"];
    
    disableSerialization;
    ((allDisplays + (uiNamespace getVariable "IGUI_Displays")) select {((ctrlIDD _x) in _idds) && {!(isNull (_x displayCtrl _idc))}}) apply {_x displayCtrl _idc}
};

MM_fnc_getGPSDisplays = {
    [[311], 101] call MM_fnc_findControlArray
};

MM_fnc_startMapMarkerClient = {
    if (isNil "MM_var_clientRunning") then {
        [] spawn {
            call {
                _veh = "B_Quadbike_01_F" createVehicleLocal [0, 0, 100];
                deleteVehicle _veh;
            };

            waitUntil {!(isNil "MM_var_clientInitDone") && {!(isNull player)} && {!(isNull (findDisplay 46))} && {!((call MM_fnc_getGPSDisplays) isEqualTo [])}};

            call {
                {
                    [_x] call MM_fnc_entityInitClient;
                } forEach (entities [["CAManBase"], [""], true, false]);
                
                uiNamespace setVariable ["MM_var_gpsDisplays", (call MM_fnc_getGPSDisplays)];
                MM_var_entityRespawnedEhId = addMissionEventHandler ["EntityRespawned", {params ["_newEntity"]; [_newEntity] call MM_fnc_entityInitClient;}];

                {
                    MM_var_drawEhIds pushBack (_x ctrlAddEventHandler ["Draw", {_this call MM_fnc_drawIcons;}]);
                } forEach ([(findDisplay 12) displayCtrl 51] + (uiNamespace getVariable "MM_var_gpsDisplays"));

                MM_var_uavTerminalLoopScript = [] spawn {
                    waitUntil {
                        waitUntil {!(isNull (findDisplay 160))};
                        ((findDisplay 160) displayCtrl 51) ctrlAddEventHandler ["Draw", {_this call MM_fnc_drawIcons;}];
                        waitUntil {isNull (findDisplay 160)};
                        false
                    };
                };

                MM_var_cameraMapDrawEHLoopScript = [] spawn {
                    waitUntil {
                        waitUntil {!(isNull (findDisplay 314))};
                        ((findDisplay 314) displayCtrl 3141) ctrlAddEventHandler ["Draw", {_this call MM_fnc_drawIcons;}];
                        waitUntil {isNull (findDisplay 314)};
                        false
                    };
                };

                MM_var_updateDrawArrayLoopScript = [] spawn MM_fnc_updateDrawArrayLoop;
                MM_var_clientRunning = true;
            };
        };
    };
};

MM_fnc_stopMapMarkerClient = {
    call {
        if !(isNil "MM_var_clientRunning") then {
            MM_var_clientRunning = nil;

            terminate MM_var_updateDrawArrayLoopScript;
            MM_var_updateDrawArrayLoopScript = scriptNull;

            if !(scriptDone MM_var_updateDrawArrayScript) then {
                terminate MM_var_updateDrawArrayScript;
                MM_var_updateDrawArrayScript = scriptNull;
            };

            terminate MM_var_uavTerminalLoopScript;
            MM_var_uavTerminalLoopScript = scriptNull;
            
            terminate MM_var_cameraMapDrawEHLoopScript;
            MM_var_cameraMapDrawEHLoopScript = scriptNull;

            {
                missionNamespace setVariable [("MM_var_units" + (str _x)), []];
            } forEach [west, east, independent, civilian, sideEmpty, sideLogic, sideAmbientLife, sideUnknown];

            uiNamespace setVariable ["MM_var_currentDisplay", displayNull];
            MM_var_lastDrawFrameNo = 0;
            MM_var_lastDrawArrUpdateFrameNo = 0;
            MM_var_gpsOpened = false;
            MM_var_showUnitNamesOverride = true;
            MM_var_drawArray = [];
            MM_var_preDrawArray = [];

            {
                _x ctrlRemoveEventHandler ["Draw", (MM_var_drawEhIds select _forEachIndex)];
            } forEach ([(findDisplay 12) displayCtrl 51] + (uiNamespace getVariable "MM_var_gpsDisplays"));

            removeMissionEventHandler ["EntityRespawned", MM_var_entityRespawnedEhId];
            MM_var_entityRespawnedEhId = -1;

            uiNamespace setVariable ["MM_var_gpsDisplays", []];
            
            MM_var_drawEhIds = [];
        };
    };
};

MM_var_clientInitDone = true;