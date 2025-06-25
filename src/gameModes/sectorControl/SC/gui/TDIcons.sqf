SC_fnc_updateTDIconsDrawArray = {
    params ["_unit", "_par", "_drawUnit", "_group", "_groupUnits", "_side", "_uav", "_hasUav", "_isInUav", "_groupUnitsUavs", "_viewDis", "_camPos", "_camPosAsl", "_zoom", "_sqrtZoom", "_isInSpectator"];

    _sideStr = str _side;

    {
        sleep 0.0001;

        _x params ["_end", "_text", "_icon"];

        _obj = missionNamespace getVariable (["SC_var_", _end] joinString "");
        _pos = _obj modelToWorld [0, 0.1, 0.45];
        _dis = _camPos distance _pos;

        if (
            (_dis < 15) &&
            {[_pos] call TDI_fnc_isOnScreen} &&
            {
                _objsToIgnore = [];

                if !(isNull _par) then {
                    _objsToIgnore pushBack _par;
                };

                if (cameraView != "EXTERNAL") then {
                    _objsToIgnore pushBack _unit;
                };

                if ((count _objsToIgnore) < 2) then {
                    _objsToIgnore pushBack _obj;
                };

                while {(count _objsToIgnore) < 2} do {
                    _objsToIgnore pushBack objNull;
                };

                ([(_objsToIgnore select 0), "FIRE", (_objsToIgnore select 1)] checkVisibility [_camPosAsl, (AGLToASL _pos)]) != 0
            }
        ) then {
            sleep 0.0002;

            _sizeFactorModification = [1, 1.5] select ((count _end) == 9);

            TDI_var_preDrawArray pushBack [
                _dis,
                4, _obj,
                [_icon, [1, 1, 1, (if (_dis <= 10) then {1} else {(-2 * ((_dis - 10) / 10)) + 1})]],
                ((1.5 * _sizeFactorModification) / (sqrt (sqrt _dis))), false,
                0, 0, _text, 2, (20 * _sizeFactorModification)
            ];
        };
    } forEach ([
        [([_sideStr, "inf"] joinString ""), "Information", "\A3\ui_f\data\Map\MapControl\powersolar_CA.paa"],
        [([_sideStr, "tp"] joinString ""), "Teleport", "\A3\ui_f\data\IGUI\Cfg\Actions\unloadVehicle_ca.paa"],
        [([_sideStr, "cs"] joinString ""), "Perks", "\A3\ui_f\data\IGUI\Cfg\Actions\reammo_ca.paa"],
        [([_sideStr, "equip"] joinString ""), "Loadout", "\A3\ui_f\data\IGUI\Cfg\Actions\gear_ca.paa"],
        [([_sideStr, "veh"] joinString ""), "Vehicles", "\A3\ui_f\data\Map\Markers\NATO\c_car.paa"]
    ] + (
        SC_var_planeSpawnIds apply {[(format ["planeShop%1", _x]), "Vehicles", "\A3\ui_f\data\Map\Markers\NATO\c_plane.paa"]}
    ));

    if SC_var_showSector3DIcons then {
        {
            sleep 0.0001;

            _sector = _x;
            _flag = missionNameSpace getVariable (["SC_var_flag", "3d"] joinString _sector);
            _pos = _flag modelToWorldVisual [0, 0, 1.05];
            _dis = _pos distance _camPos;
            _sizeFactor = 0;
            _size = 0;

            if (
                (_dis <= _viewDis) &&
                {
                    _sizeFactor = 1.4 / (sqrt (sqrt _dis));
                    _size = _sizeFactor * _sqrtZoom;
                    (_size >= 0.55)
                } &&
                {[_pos] call TDI_fnc_isOnScreen} &&
                {
                    _objsToIgnore = [_flag];

                    if !(isNull _par) then {
                        _objsToIgnore pushBack _par;
                    };

                    if (cameraView != "EXTERNAL") then {
                        _objsToIgnore pushBack _unit;
                    };

                    while {(count _objsToIgnore) < 2} do {
                        _objsToIgnore pushBack objNull;
                    };

                    ([(_objsToIgnore select 0), "FIRE", (_objsToIgnore select 1)] checkVisibility [_camPosAsl, (AGLToASL _pos)]) != 0
                }
            ) then {
                sleep 0.0002;

                _holder = missionNameSpace getVariable (["SC_var_holder", _sector] joinString "");

                TDI_var_preDrawArray pushBack [
                    _dis,
                    3, _flag,
                    [
                        (format ["\A3\ui_f\data\IGUI\Cfg\simpleTasks\letters\%1_ca.paa", _sector]),
                        (
                            [
                                _holder,
                                (if (_size >= 0.7) then {1} else {1 - ((0.7 - _size) / 0.15)}),
                                ((missionNameSpace getVariable (["SC_var_flag", _sector] joinString "")) / 100)
                            ] call SC_fnc_getSectorColor
                        )
                    ],
                    _sizeFactor, true,
                    0, 0, "", 2
                ];
            };
        } forEach SC_var_sectors;
    };

    if SC_var_showAirDrop3DIcons then {
        {
            sleep 0.0001;

            _pos = [];
            _dis = 0;
            _sizeFactor = 0;
            _size = 0;
            _timeRemaining = _x getVariable "SC_var_timeRemaining";

            if (
                !(isNil "_timeRemaining") &&
                {
                    _pos = _x modelToWorldVisual [0, 0, 0];
                    _dis = _camPos distance _pos;

                    (
                        (_dis <= _viewDis) &&
                        {
                            _sizeFactor = 1.7 / (sqrt (sqrt _dis));
                            _size = _sizeFactor * _sqrtZoom;
                            (_size >= 0.55)
                        } &&
                        {[_pos] call TDI_fnc_isOnScreen} &&
                        {
                            _objsToIgnore = [_x];
                            _parachute = attachedTo _x;

                            if !(isNull _parachute) then {
                                _objsToIgnore pushBack _parachute;
                            };

                            if !(isNull _par) then {
                                _objsToIgnore pushBack _par;
                            };

                            if (cameraView != "EXTERNAL") then {
                                _objsToIgnore pushBack _unit;
                            };

                            while {(count _objsToIgnore) < 2} do {
                                _objsToIgnore pushBack objNull;
                            };

                            (([(_objsToIgnore select 0), "FIRE", (_objsToIgnore select 1)] checkVisibility [_camPosAsl, (AGLToASL _pos)]) != 0)
                        }
                    )
                }
            ) then {
                sleep 0.0002;

                TDI_var_preDrawArray pushBack [
                    _dis,
                    2, _x,
                    ["\A3\ui_f\data\Map\vehicleicons\iconParachute_ca.paa", [1, 1, 1, (if (_size >= 0.7) then {1} else {1 - ((0.7 - _size) / 0.15)})]],
                    _sizeFactor, true,
                    0, 0, _timeRemaining, 2, 20
                ];
            };
        } forEach (entities "box_NATO_equip_F");
    };
};