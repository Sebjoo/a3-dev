TDI_var_clientRunning = nil;

TDI_var_colorYellow = [1, 1, 0, 1];
TDI_var_colorWhite = [1, 1, 1, 1];
TDI_var_colorBlack = [0, 0, 0, 1];

TDI_var_entityRespawnedEhId = -1;
TDI_var_draw3dEhId = -1;
TDI_var_updateDrawArrayLoopScript = scriptNull;
TDI_var_gatherDrawArraysFncs = [];
TDI_var_drawArray = [];
TDI_var_preDrawArray = [];

{
    missionNamespace setVariable [("TDI_var_units" + (str _x)), []];
} forEach [west, east, independent, civilian, sideEmpty, sideLogic, sideAmbientLife, sideUnknown];

TDI_fnc_isUavAi = {
    params ["_unit"];

    "UAV_AI" in (typeOf _unit)
};

TDI_fnc_getZoom = {
    ([0.5, 0.5] distance2D worldToScreen positionCameraToWorld [0, 3, 4]) * (getResolution select 5) * 1.5
};

TDI_fnc_isOnScreen = {
    params ["_pos"];

    _screenPos = worldToScreen _pos;
    
    !(_screenPos isEqualTo []) &&
    {
        ((_screenPos select 0) > safeZoneX) &&
        {(_screenPos select 0) < (safeZoneX + safeZoneW)} &&
        {(_screenPos select 1) > safeZoneY} &&
        {(_screenPos select 1) < (safeZoneY + safeZoneH)}
    }
};

TDI_fnc_getSideString = {
    params ["_side"];

    if (_side != sideAmbientLife) then {
        str _side
    } else {
        "AmbientLife"
    }
};

TDI_fnc_getIcon = {
    params ["_unit", "_side"];

    format [
        "\A3\ui_f\data\Map\Diary\Icons\player%1%2_ca.paa",
        (if (alive _unit) then {""} else {"Brief"}),
        (
            switch _side do {
                case west: {"West"};
                case east: {"East"};
                case independent: {"Guer"};
                case civilian: {"Civ"};
                default {"Unknown"};
            }
        )
    ]
};

TDI_fnc_UAVControlUnits = {
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

TDI_fnc_getGroupUnits = {
    params ["_unit"];

    (units (group _unit))
};

TDI_fnc_UAVControl = {
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

TDI_fnc_updateDrawArrayLoop = {
    waitUntil {
        waitUntil {isNull (findDisplay 49)};

        _unit = if !(unitIsUAV focusOn) then {focusOn} else {[(objectParent focusOn), "DRIVER", "GUNNER"] call TDI_fnc_UAVControl};
        _isInSpectator = !(_unit isEqualTo player);
        _par = objectParent _unit;
        _group = group _unit;
        _side = side (group _unit);
        _groupUnits = [_unit] call TDI_fnc_getGroupUnits;
        _uav = getConnectedUAV _unit;
        _hasUav = !(isNull _uav);
        _isInUav = _hasUav && {_unit in ([_uav, true] call TDI_fnc_UAVControlUnits)};
        _drawUnit = _isInUav || {(cameraView == "EXTERNAL") && {!(isNull _par)} && {((typeOf _par) find "arachute") == -1}};
        _groupUnitsUavs = [];
        {_groupUnitsUavs pushBackUnique (getConnectedUAV _x);} forEach _groupUnits;
        _groupUnitsUavs = _groupUnitsUavs - [objNull];
        _viewDis = viewDistance;
        _camPos = positionCameraToWorld [0, 0, 0];
        _camPosAsl = AglToAsl _camPos;
        _zoom = sqrt (call TDI_fnc_getZoom);
        _sqrtZoom = sqrt _zoom;

        {
            {
                sleep 0.0003;

                _pos = [];
                _xIsUav = false;
                _dis = 0;
                _sizeFactor = 0;
                _size = 0;
                _parX = objNull;

                if (
                    (simulationEnabled _x) &&
                    {
                        _xIsUav = [_x] call TDI_fnc_isUavAi;
                        if (_isInSpectator && {!TDI_var_DrawUnitsOnSpectator} && {!_xIsUav}) exitWith {false};
                        _parX = objectParent _x;

                        (
                            (
                                if _xIsUav then {
                                    _x isEqualTo (driver _parX)
                                } else {
                                    !(isObjectHidden _x)
                                }
                            ) &&
                            {
                                if _isInUav then {
                                    !_xIsUav || {!(_parX isEqualTo _uav)}
                                } else {
                                    _drawUnit || {!(_x isEqualTo _unit)}
                                }
                            } &&
                            {
                                _pos = _x modelToWorldVisual (_x selectionPosition "head");
                                _dis = _camPos distance _pos;

                                (_dis <= _viewDis) &&
                                {[_pos] call TDI_fnc_isOnScreen} &&
                                {
                                    _sizeFactor = 1.8 / (sqrt _dis);
                                    _size = _sizeFactor * _zoom;
                                    (_size >= 0.08)
                                } &&
                                {
                                    !TDI_var_HideInvisible ||
                                    {
                                        _objsToIgnore = [];

                                        if !(isNull _parX) then {
                                            _objsToIgnore pushBack _parX;
                                        };

                                        if (cameraView != "EXTERNAL") then {
                                            if _isInUav then {
                                                _objsToIgnore pushBack _uav;
                                            } else {
                                                if !(isNull _par) then {
                                                    _objsToIgnore pushBack _par;
                                                };
                                            };

                                            _objsToIgnore pushBack _unit;
                                        };

                                        if ((count _objsToIgnore) < 2) then {
                                            _objsToIgnore pushBack _x;
                                        };

                                        while {(count _objsToIgnore) < 2} do {
                                            _objsToIgnore pushBack objNull;
                                        };

                                        _view = if (_xIsUav || {(!(isNull _par) || {_isInUav}) && {cameraView != "EXTERNAL"}}) then {"VIEW"} else {"FIRE"}; 

                                        (
                                            [(_objsToIgnore select 0), _view, (_objsToIgnore select 1)]
                                            checkVisibility
                                            [_camPosAsl, (AglToAsl _pos)]
                                        ) != 0
                                    }
                                }
                            }
                        )
                    }
                ) then {
                    TDI_var_preDrawArray pushBack [
                        _dis,
                        0, _x,
                        [([_x, (_x getVariable ["TDI_var_side", sideUnknown])] call TDI_fnc_getIcon), TDI_var_colorWhite],
                        _sizeFactor, false,
                        0,
                        0.35,
                        (
                            if TDI_var_ShowUnitNames then {
                                if !_xIsUav then {
                                    _x getVariable ["TDI_var_name", ""]
                                } else {
                                    _parX = objectParent _x;
                                    _uavControlUnits = [_parX] call TDI_fnc_UAVControlUnits;
                                    
                                    [
                                        (_parX getVariable ["TDI_var_name", ""]),
                                        (if (_uavControlUnits isEqualTo []) then {""} else {
                                            [" [", "]"] joinString ((_uavControlUnits apply {[(_x getVariable ["TDI_var_name", ""]), " (remote)"] joinString ""}) joinString ", ")
                                        })
                                    ] joinString (if (unitIsUav _parX) then {" (AI)"} else {""})
                                }
                            } else {""}
                        ),
                        2, 20
                    ];

                    if ((alive _x) && {_x getVariable ["AIS_unconscious", false]} && {!(_x in _groupUnits)}) then {
                        TDI_var_preDrawArray pushBack [
                            _dis,
                            1, _x,
                            ["\A3\ui_f\data\IGUI\Cfg\Actions\heal_ca.paa", TDI_var_colorWhite],
                            (1.11 * _sizeFactor), true,
                            0, 0, "", 2
                        ];
                    };

                    sleep 0.0006;
                };
            } forEach (missionNamespace getVariable _x);
        } forEach (
            if (!(isNull (findDisplay 314)) || {TDI_var_ShowAllSides} || {_isInSpectator && {TDI_var_ShowAllSidesOnSpectator}}) then {
                ["TDI_var_unitsWest", "TDI_var_unitsEast", "TDI_var_unitsGuer", "TDI_var_unitsCiv"]
            } else {
                [["TDI_var_units", ([_side] call TDI_fnc_getSideString)] joinString ""]
            }
        );

        {
            sleep 0.0003;

            _xIsUav = unitIsUAV _x;
            _parX = objNull;
            _pos = [];
            _dis = 0;

            if _xIsUav then {
                _pos = _x modelToWorldVisual [0, 0, 0];
            } else {
                _parX = objectParent _x;
                _pos = _x modelToWorldVisual (((_x selectionPosition "head") vectorAdd (_x selectionPosition "pelvis")) vectorMultiply 0.5);
            };

            if (
                (simulationEnabled _x) &&
                {
                    if _isInUav then {
                        !_xIsUav || {!(_x isEqualTo _uav)}
                    } else {
                        _drawUnit || {!(_x isEqualTo _unit)}
                    }
                } &&
                {
                    !TDI_var_groupUnitsLimitedDistance ||
                    {
                        _dis = _camPos distance _pos;
                        (_dis <= _viewDis)
                    }
                } &&
                {[_pos] call TDI_fnc_isOnScreen} &&
                {
                    !TDI_var_HideInvisibleGroupMembers ||
                    {
                        _objsToIgnore = [];

                        if _xIsUav then {
                            _objsToIgnore pushBack _x;
                        } else {
                            if !(isNull _parX) then {
                                _objsToIgnore pushBack _parX;
                            };
                        };

                        if (cameraView != "EXTERNAL") then {
                            if _isInUav then {
                                _objsToIgnore pushBack _uav;
                            } else {
                                if !(isNull _par) then {
                                    _objsToIgnore pushBack _par;
                                };
                            };

                            _objsToIgnore pushBack _unit;
                        };

                        if ((count _objsToIgnore) < 2) then {
                            _objsToIgnore pushBackUnique _x;
                        };

                        while {(count _objsToIgnore) < 2} do {
                            _objsToIgnore pushBack objNull;
                        };

                        _view = if ((!(isNull _par) || {_isInUav}) && {cameraView != "EXTERNAL"}) then {"VIEW"} else {"FIRE"}; 

                        (
                            [(_objsToIgnore select 0), _view, (_objsToIgnore select 1)]
                            checkVisibility
                            [_camPosAsl, (AglToAsl _pos)]
                        ) != 0
                    }
                }
            ) then {
                if !TDI_var_groupUnitsLimitedDistance then {
                    _dis = _camPos distance _pos;
                };

                _sizeFactor = ([2.025, 1.5] select (alive _x)) / (sqrt (sqrt _dis));

                TDI_var_preDrawArray pushBack [
                    _dis,
                    1, _x,
                    [
                        (if (alive _x) then {
                            if (_x getVariable ["AIS_unconscious", false]) then {
                                "\A3\ui_f\data\IGUI\Cfg\Revive\overlayIconsGroup\r100_ca.paa"
                            } else {
                                "\A3\ui_f\data\IGUI\Cfg\Cursors\select_ca.paa"
                            };
                        } else {
                            "\A3\ui_f\data\IGUI\Cfg\Revive\overlayIconsGroup\d75_ca.paa"
                        }),
                        (if (
                            if _xIsUav then {
                                !_isInUav && {_x isEqualTo _uav}
                            } else {
                                _x isEqualTo _unit
                            }
                        ) then {
                            TDI_var_colorYellow
                        } else {
                            TDI_var_colorWhite
                        })
                    ],
                    _sizeFactor, true,
                    0, 0, "", 2
                ];

                sleep 0.0006;
            };
        } forEach (_groupUnits + _groupUnitsUavs);

        if !(TDI_var_gatherDrawArraysFncs isEqualTo []) then {
            _argArr = [_unit, _par, _drawUnit, _group, _groupUnits, _side, _uav, _hasUav, _isInUav, _groupUnitsUavs, _viewDis, _camPos, _camPosAsl, _zoom, _sqrtZoom, _isInSpectator];

            {
                _hdl = _argArr spawn (missionNameSpace getVariable _x);
                waitUntil {scriptDone _hdl};
            } forEach TDI_var_gatherDrawArraysFncs;
        };

        TDI_var_preDrawArray sort false;
        TDI_var_drawArray = TDI_var_preDrawArray;
        TDI_var_preDrawArray = [];

        false
    };
};

TDI_fnc_entityInitClient = {
    params ["_entity"];

    if (_entity isKindOf "CAManBase") then {
        _id = _entity getVariable ["TDI_var_deletedEhId", -1];
        if (_id != -1) then {_entity removeEventHandler ["Deleted", _id];};
        _id = _entity addEventHandler ["Deleted", {
            params ["_entity"];

            _sideStr = [_entity getVariable ["TDI_var_side", sideUnknown]] call TDI_fnc_getSideString;
            _entity call (compile (["TDI_var_units", _sideStr, " deleteAt (TDI_var_units", _sideStr," find _this);"] joinString ""));
        }];
        _entity setVariable ["TDI_var_deletedEhId", _id];

        _varStr = ["TDI_var_units", ([side (group _entity)] call TDI_fnc_getSideString)] joinString "";
        
        if ((random 1) < 0.01) then {
            call (compile ([_varStr, " = ", _varStr, " - [objNull];"] joinString ""));
        };

        _entity call (compile ([_varStr, " pushBackUnique _this;"] joinString ""));
    };
};

TDI_fnc_drawIcons = {
    _zoom = sqrt (call TDI_fnc_getZoom);
    _sqrtZoom = sqrt _zoom;

    if (isNull (findDisplay 49)) then {
        {
            _x params ["_dis", "_type", "_obj", "_iconColor", "_sizeFactor", "_useSqrtZoom", "_angle", "_textSizeCutoff", "_text", "_shadow", ["_textSizeDivisor", 0]];

            _size = _sizeFactor * (if _useSqrtZoom then {_sqrtZoom} else {_zoom});

            drawIcon3d (_iconColor +
                [
                    switch _type do {
                        case 0: {(_obj modelToWorldVisual (_obj selectionPosition "head")) vectorAdd [0, 0, (1.6 - (exp (_dis / 8000)))]};
                        case 1: {_obj modelToWorldVisual (((_obj selectionPosition "head") vectorAdd (_obj selectionPosition "pelvis")) vectorMultiply 0.5)};
                        case 2: {_obj modelToWorldVisual [0, 0, 0]};
                        case 3: {_obj modelToWorldVisual [0, 0, 1.05]};
                        case 4: {_obj modelToWorld [0, 0.1, 0.45]};
                        default {[0, 0, 0]};
                    },
                    _size,
                    _size,
                    _angle,
                    (if (_size >= _textSizeCutoff) then {_text} else {""}),
                    _shadow
                ] +
                (if (_textSizeDivisor == 0) then {[]} else {[_size / _textSizeDivisor]})
            );
        } forEach TDI_var_drawArray;
    };
};

TDI_fnc_startTdIconsClient = {
    call {
        if (isNil "TDI_var_clientRunning") then {
            TDI_var_clientRunning = true;

            {
                [_x] call TDI_fnc_entityInitClient;
            } forEach (entities [["CAManBase"], [""], true, false]);

            TDI_var_entityRespawnedEhId = addMissionEventHandler ["EntityRespawned", {params ["_entity"]; [_entity] call TDI_fnc_entityInitClient;}];
            TDI_var_draw3dEhId = addMissionEventHandler ["Draw3D", TDI_fnc_drawIcons];

            TDI_var_updateDrawArrayLoopScript = [] spawn TDI_fnc_updateDrawArrayLoop;
        };
    };
};

TDI_fnc_stopTdIconsClient = {
    call {
        if !(isNil "TDI_var_clientRunning") then {
            TDI_var_clientRunning = nil;

            {
                missionNamespace setVariable [("TDI_var_units" + (str _x)), []];
            } forEach [west, east, independent, civilian, sideEmpty, sideLogic, sideAmbientLife, sideUnknown];

            removeMissionEventHandler ["EntityRespawned", TDI_var_entityRespawnedEhId];
            removeMissionEventHandler ["Draw3D", TDI_var_draw3dEhId];

            terminate TDI_var_updateDrawArrayLoopScript;
            TDI_var_updateDrawArrayLoopScript = scriptNull;

            TDI_var_entityRespawnedEhId = -1;
            TDI_var_draw3dEhId = -1;
        };
    };
};

TDI_var_clientInitDone = true;