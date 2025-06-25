EC_fnc_UAVControlUnits = {
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

EC_fnc_serverLoop = {
    waitUntil {
        _entities = entities [["AllVehicles"], ["Animal"], true, false];

        {
            _player = _x;
            _posPlayer = getPosASL _player;
            _objectViewDistance = _player getVariable ["EC_var_objectViewDistance", 999999];
            _viewNotExternal = (_player getVariable ["EC_var_cameraView", "INTERNAL"]) != "EXTERNAL";
            _parPlayer = objectParent _player;
            _uav = getConnectedUAV _player;
            _hasUav = !(isNull _uav);
            _isInUav = _hasUav && {_player in ([_uav, true] call EC_fnc_UAVControlUnits)};
            _culledEntities = [];
            _visibleEntities = [];

            {
                _entity = _x;
                if (_player isEqualTo _entity) exitWith {};
                _posEntity = getPosASL _entity;
                _entityIsUav = unitIsUAV _x;

                if (
                    ((_posPlayer distance _posEntity) > _objectViewDistance) ||
                    {
                        _objsToIgnore = [];
                        _parEntity = objectParent _entity;

                        if !(isNull _parEntity) then {
                            _objsToIgnore pushBack _parEntity;
                        };

                        if _viewNotExternal then {
                            if _isInUav then {
                                _objsToIgnore pushBack _uav;
                            } else {
                                if !(isNull _parPlayer) then {
                                    _objsToIgnore pushBack _parPlayer;
                                };
                            };

                            _objsToIgnore pushBack _player;
                        };

                        if ((count _objsToIgnore) < 2) then {
                            _objsToIgnore pushBack _entity;
                        };

                        while {(count _objsToIgnore) < 2} do {
                            _objsToIgnore pushBack objNull;
                        };

                        _view = if (_entityIsUav || {(!(isNull _parPlayer) || {_isInUav}) && {_viewNotExternal}}) then {"VIEW"} else {"FIRE"}; 

                        ([(_objsToIgnore select 0), _view, (_objsToIgnore select 1)] checkVisibility [_posPlayer, _posEntity]) == 0
                    }
                ) then {
                    _culledEntities pushBack _entity;
                } else {
                    _visibleEntities pushBack _entity;
                };

                [[_visibleEntities, _culledEntities]] remoteExec ["EC_fnc_setEntityVisibility", _player, false];
            } forEach _entities;
        } forEach allPlayers;

        false
    };
};

EC_var_serverInitDone = true;
publicVariable "EC_var_serverInitDone";