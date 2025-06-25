SC_fnc_playZoneAndVehicleCooldownLoop = {
    waitUntil {
        {
            _side = _x;

            _sleepTime = 1 / (1 max (SC_var_numunitsWest + SC_var_numunitsEast + SC_var_numunitsGuer + SC_var_numuavAiUnitsWest + SC_var_numuavAiUnitsEast + SC_var_numuavAiUnitsGuer));
            
            {
                _unit = if (!([_x] call SC_fnc_isUavAi) || {_x isEqualTo (driver (objectParent _x))}) then {_x} else {objNull};
                
                if !(isNull _unit) then {
                    if (isPlayer _unit) then {
                        _vehicleCoolDown = _unit getVariable "SC_var_vehicleCooldown";
                        _vehicleActionCoolDown = _unit getVariable "SC_var_vehicleActionCooldown";

                        if (!(isNil "_vehicleCoolDown") && {_vehicleCoolDown > 0}) then {
                            _unit setVariable ["SC_var_vehicleCooldown", (_vehicleCoolDown - 1), true];
                        };

                        if (!(isNil "_vehicleActionCoolDown") &&  {_vehicleActionCoolDown > 0}) then {
                            _unit setVariable ["SC_var_vehicleActionCooldown", (_vehicleActionCoolDown - 1)];
                        };
                    };

                    if ((alive _x) && {!(_x getVariable "SC_var_isWatched")}) then {
                        _otherSides = SC_var_sides - [_side];
                        _posWorldUnit = getPosWorld _unit;

                        {
                            _curSide = _x;
                            _base = "SC_var_" + (str _curSide) + "Base";

                            if (_posWorldUnit inArea _base) then {
                                [_unit, _base, true, 15] spawn SC_fnc_zoneTimeOut;
                            };
                        } forEach _otherSides;

                        if (!SC_var_wholeMap && {!(_posWorldUnit inArea "SC_var_playZone")}) then {
                            [_unit, "SC_var_playZone", false, 30] spawn SC_fnc_zoneTimeOut;
                        };
                    };
                };

                sleep _sleepTime;
            } forEach (([_side] call SC_fnc_getSidesUnits) + ([_side] call SC_fnc_getSidesUavAiUnits));
        } forEach SC_var_sides;

        false
    };
};

SC_fnc_gameModeLoop = {
    _ended = false;
    _sleepTime = 1 / (count SC_var_sectors);

    waitUntil {
        {
            _sectorInd = _x;

            _sectorMarker = "SC_var_sector" + _sectorInd;

            _unitsOnSectorWest = [];
            _unitsOnSectorEast = [];
            _unitsOnSectorGuer = [];
            _unitsOnSectorCiv = [];
            _unitsOnSectorEmpty = [];
            _unitsOnSectorLogic = [];
            _unitsOnSectorAmbientLife = [];
            _unitsOnSectorUnknown = [];

            {
                if ((alive _x) && {!(_x getVariable ["AIS_unconscious", false])}) then {
                    _pos = (getPosATL _x);

                    if (((_pos select 2) <= 25) && {_pos inArea _sectorMarker}) then {
                        if (_x isKindOf "CAManBase") then {
                            call (compile (["_unitsOnSector", (str (side (group _x))), " pushBack _x;"] joinString ""));
                        } else {
                            _uavControlUnits = if (unitIsUAV _x) then {[_x, true] call SC_fnc_UAVControlUnits};
                            _driver = driver _x;

                            _units = if ((unitIsUAV _x) && {!(_uavControlUnits isEqualTo [])}) then {_uavControlUnits} else {
                                (crew _x) select {!([_x] call SC_fnc_isUavAi) || {_x isEqualTo _driver}}
                            };

                            call (compile (["_unitsOnSector", (str (side (group _x))), " append _units;"] joinString ""));
                        };
                    };
                };
            } forEach (nearestObjects [((getMarkerPos _sectorMarker) select [0,2]), [], ((selectMax (getMarkerSize _sectorMarker)) * (if ((markerShape _sectorMarker) == "RECTANGLE") then {sqrt 2} else {1})), true]);

            _numUnitsOnSector = (count _unitsOnSectorWest) + (count _unitsOnSectorEast) + (count _unitsOnSectorGuer);
            _holder = missionNamespace getVariable ("SC_var_holder" + _sectorInd);
            _flag = missionNamespace getVariable ("SC_var_flag" + _sectorInd);
            _lastDecapturingSide = missionNamespace getVariable ("SC_var_lastDecapturingSide" + _sectorInd);

            {
                _side = _x;
                _sidesUnitsOnSector = call (compile (["_unitsOnSector", (str _x)] joinString ""));
                _numSidesUnitsOnSector = count _sidesUnitsOnSector;
                _sidesRelativeUnitAmount = (if (_numSidesUnitsOnSector == _numUnitsOnSector) then {
                    1.001 * _numSidesUnitsOnSector
                } else {
                    _numSidesUnitsOnSector / (_numUnitsOnSector - _numSidesUnitsOnSector)
                });

                if (_sidesRelativeUnitAmount > 1) then {
                    if (_flag == 0) then {
                        _holder = _side;
                        missionNamespace setVariable [("SC_var_holder" + _sectorInd), _holder];
                        publicVariable ("SC_var_holder" + _sectorInd);

                        _lastDecapturingSide = _side;
                        missionNamespace setVariable ["SC_var_lastDecapturingSide" + _sectorInd, _lastDecapturingSide];
                        publicVariable ("SC_var_lastDecapturingSide" + _sectorInd);
                    };

                    if ((_flag <= 100) && {_flag > 0} && {_holder != _side}) then {
                        _flag = 0 max (_flag - ((_sidesRelativeUnitAmount ^ 0.7) * SC_var_sectorCaptureRate));
                        missionNamespace setVariable [("SC_var_flag" + _sectorInd), _flag];
                        publicVariable ("SC_var_flag" + _sectorInd);

                        {
                            if (isPlayer _x) then {
                                [[4, 6] select (_x getVariable ["SC_var_hasExprPerk", false])] remoteExecCall ["SC_fnc_addXp", _x];
                            };
                        } forEach _sidesUnitsOnSector;
                    };

                    if ((_flag < 100) && {_flag >= 0} && {_holder == _side}) then {
                        _flag = 100 min (_flag + ((_sidesRelativeUnitAmount ^ 0.7) * SC_var_sectorCaptureRate));
                        missionNamespace setVariable [("SC_var_flag" + _sectorInd), _flag];
                        publicVariable ("SC_var_flag" + _sectorInd);

                        {
                            if (isPlayer _x) then {
                                [[4, 6] select (_x getVariable ["SC_var_hasExprPerk", false])] remoteExecCall ["SC_fnc_addXp", _x];
                            };
                        } forEach _sidesUnitsOnSector;

                        if (_flag == 100) then {
                            [
                                [format [
                                    "<t size='%1' align='right' shadow='1' shadowOffset='%2'><t color='%3'>%4</t> %5 %6</t>",
                                    (0.5 * KF_var_fontSize),
                                    (0.05 * KF_var_fontSize),
                                    ([_side] call KF_fnc_GetSidesHexColor),
                                    (["Blufor", "Opfor", "Independent"] select (SC_var_sides find _side)),
                                    "<img image='\a3\ui_f\data\Map\VehicleIcons\iconLogic_ca.paa'/>",
                                    _sectorInd
                                ]],
                                {if (!isNil "KF_fnc_AddKillFeedLine") then {_this call KF_fnc_AddKillFeedLine;};}
                            ] remoteExecCall ["call", 0];

                            if (_lastDecapturingSide == _side) then {
                                {
                                    if (isPlayer _x) then {
                                        _xp = [200, 300] select (_x getVariable ["SC_var_hasExprPerk", false]);
                                        [_xp] remoteExecCall ["SC_fnc_addXp", _x];

                                        [format [
                                            "<t size='%1' shadow='1' shadowOffset='%2'><t color='%3'>You</t> captured <t color='%4'>%5</t> %6 XP</t>",
                                            (0.6 * KF_var_fontSize),
                                            (0.05 * KF_var_fontSize),
                                            (if KF_var_MidFeedYouColorYellow then {"#ffd400"} else {"#ffffff"}),
                                            ([_holder] call KF_fnc_GetSidesHexColor),
                                            _sectorInd,
                                            _xp
                                        ]] remoteExecCall ["KF_fnc_AddMidFeedLine", _x];

                                        remoteExecCall ["SC_fnc_addCapturedSector", _x];
                                    };
                                } forEach _sidesUnitsOnSector;

                                _lastDecapturingSide = civilian;
                                missionNamespace setVariable [("SC_var_lastDecapturingSide" + _sectorInd), _lastDecapturingSide];
                                publicVariable ("SC_var_lastDecapturingSide" + _sectorInd);
                            };
                        };
                    };

                    if (_flag == 100) then {
                        _owner = _holder;
                        missionNameSpace setVariable [("SC_var_owner" + _sectorInd), _owner];
                    } else {
                        _owner = civilian;
                        missionNameSpace setVariable [("SC_var_owner" + _sectorInd), _owner];
                    };

                    publicVariable ("SC_var_owner" + _sectorInd);
                };
            } forEach SC_var_sides;

            sleep _sleepTime;
        } forEach SC_var_sectors;

        {
            _sectorInd = _x;
            _owner = missionNameSpace getVariable ("SC_var_owner" + _sectorInd);
            _lastOwner = missionNameSpace getVariable ("SC_var_lastOwner" + _sectorInd);

            if (_lastOwner != _owner) then {
                _holder = missionNameSpace getVariable ("SC_var_holder" + _sectorInd);
                _sectorMarker = "SC_var_sector" + _sectorInd;
                _respawnPos = missionNameSpace getVariable ("SC_var_" + _sectorInd + "RespawnPos");
                _respawnPos call BIS_fnc_removeRespawnPosition;
                _respawnPos = [];
                _flag = missionNamespace getVariable ("SC_var_flag" + _sectorInd);

                if (_flag == 100) then {
                    _flag3d = missionNameSpace getVariable ("SC_var_flag" + _sectorInd + "3d");
                    _respawnPos = [_owner, (getPosATL _flag3d), _sectorInd] call BIS_fnc_addRespawnPosition;
                    _sideString = [_owner] call SC_fnc_getSidestring;
                    
                    if (SC_var_sectorCapturedMessages != 0) then {
                        if (SC_var_sectorCapturedMessages == 1) then {
                            ["captured", [_sideString, _sectorInd]] remoteExec ["SC_fnc_showNotificationIfHudIsEnabled", 0];
                        } else {
                            (_sideString + " captured " + _sectorInd) remoteExecCall ["systemChat", 0];
                        };
                    };
                };

                missionNameSpace setVariable [("SC_var_" + _sectorInd + "RespawnPos"), _respawnPos];
            };
        } forEach SC_var_sectors;

        sleep 0.1;

        {
            _side = _x;
            _sideString = [_side] call SC_fnc_getSidestring;
            _sidesTickets = missionNameSpace getVariable ("SC_var_" + (str _side) + "Tickets");
            _sidesRelativeSectors = ({missionNamespace getVariable ("SC_var_owner" + _x) == _side} count SC_var_sectors) / (count SC_var_sectors);
            _sidesTickets = _sidesTickets + (_sidesRelativeSectors * SC_var_ticketGainFactor);
            _sidesLastDrop = missionNameSpace getVariable ("SC_var_last" + (str _side) + "Drop");

            if ((_sidesTickets <= 100) && {_sidesTickets >= (_sidesLastDrop + SC_var_sideDropStep)}) then {
                _sidesLastDrop = _sidesLastDrop + SC_var_sideDropStep;
                _dropPos = [];
                _possibleDropSectors = [];
                _dropText = "";

                {
                    _sectorInd = _x;
                    _owner = missionNameSpace getVariable ("SC_var_owner" + _sectorInd);
                    if (_owner == _side) then {
                        _possibleDropSectors pushBack _sectorInd;
                    };
                } forEach SC_var_sectors;

                _bestSectorsMinDistanceToDrop = 0;
                _dropSectorIndex = -1;

                {
                    _sectorPos = getMarkerPos ("SC_var_sector" + _x);
                    _sectorsMinDistanceToDrop = selectMin ((entities "box_NATO_equip_F") apply {_x distance2D _sectorPos});

                    if (_sectorsMinDistanceToDrop > _bestSectorsMinDistanceToDrop) then {
                        _bestSectorsMinDistanceToDrop = _sectorsMinDistanceToDrop;
                        _dropSectorIndex = _forEachIndex;
                    }
                } forEach _possibleDropSectors;

                _dropSector = _possibleDropSectors select _dropSectorIndex;
                [("SC_var_sector" + _dropSector)] spawn SC_fnc_airDrop;
                ["sideAirDrop", [_sideString, _dropSector]] remoteExec ["SC_fnc_showNotificationIfHudIsEnabled", 0];
                missionNameSpace setVariable [("SC_var_last" + (str _side) + "Drop"), _sidesLastDrop];
            };

            missionNameSpace setVariable [("SC_var_" + (str _side) + "Tickets"), _sidesTickets];
            publicVariable ("SC_var_" + (str _side) + "Tickets");

            if ((floor _sidesTickets) >= 100) then {
                if !(isNil "KF_fnc_DisplayKillInfo") then {
                    call KF_fnc_DisplayKillInfo;
                };

                sleep 5;
                ("end_" + str (_side)) call BIS_fnc_endMissionServer;
                _ended = true;
            };
        } forEach SC_var_sides;

        sleep 0.1;

        {
            missionNamespace setVariable ["SC_var_lastOwner" + _x, (missionNamespace getVariable ("SC_var_owner" + _x))];
        } forEach SC_var_sectors;

        if ((SC_var_westTickets + SC_var_eastTickets + SC_var_guerTickets) > (SC_var_lastDrop + SC_var_dropStep)) then {
            SC_var_lastDrop = SC_var_lastDrop + SC_var_dropStep;
            ["airDrop", []] remoteExec ["SC_fnc_showNotificationIfHudIsEnabled", 0];
            ["SC_var_playZone"] spawn SC_fnc_airDrop;
        };

        _ended
    };
};

SC_fnc_weaponHolderLoop = {
    waitUntil {
        _weaponHoldersSimulated = entities "WeaponHolderSimulated";
        _groundWeaponHolders = SC_var_GroundWeaponHolders;

        _sleepTime = 10 / (1 max ((count _weaponHoldersSimulated) + (count _groundWeaponHolders)));

        {
            _timeRemaining = _x getVariable ["SC_var_timeRemaining", SC_var_unitDespawnTime];
            _distanceNearest = [_x, ["CAManBase"], 3 * SC_var_minDistanceFromUnitToDespawn] call SC_fnc_distanceOfNearestObject;

            if (_distanceNearest < SC_var_minDistanceFromUnitToDespawn) then {
                _timeRemaining = SC_var_unitDespawnTime min (_timeRemaining + (4 * (SC_var_minDistanceFromUnitToDespawn - _distanceNearest)));
            } else {
                _timeRemaining = 0 max (_timeRemaining - (_distanceNearest - SC_var_minDistanceFromUnitToDespawn));
            };

            if (_timeRemaining <= 0) then {
                [_x] remoteExecCall ["deleteVehicle", _x];
            } else {
                _x setVariable ["SC_var_timeRemaining", _timeRemaining];
            };

            sleep _sleepTime;
        } forEach _weaponHoldersSimulated;

        {
            _timeRemaining = _x getVariable "SC_var_timeRemaining";
            _distanceNearest = [_x, ["CAManBase"], 3 * SC_var_minDistanceFromUnitToDespawn] call SC_fnc_distanceOfNearestObject;

            if (_distanceNearest < SC_var_minDistanceFromUnitToDespawn) then {
                _timeRemaining = SC_var_unitDespawnTime min (_timeRemaining + (4 * (SC_var_minDistanceFromUnitToDespawn - _distanceNearest)));
            } else {
                _timeRemaining = 0 max (_timeRemaining - (_distanceNearest - SC_var_minDistanceFromUnitToDespawn));
            };

            if (_timeRemaining <= 0) then {
                [_x] remoteExecCall ["deleteVehicle", _x];
            } else {
                _x setVariable ["SC_var_timeRemaining", _timeRemaining];
            };

            sleep _sleepTime;
        } forEach _groundWeaponHolders;

        false
    };
};