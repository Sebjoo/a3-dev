SC_var_airFieldPositions = [];

if (SC_var_hugeMap && {!((allAirports select 0) isEqualTo [])}) then {
    SC_var_airFieldPositions pushbackunique (getArray (configfile >> "CfgWorlds" >> worldname >> "ilsPosition"));
    0 setAirportSide sideUnknown;
    _secondaryAirfieldsConfig = (configfile >> "CfgWorlds" >> worldname >> "SecondaryAirports");

    for "_i" from 1 to (count _secondaryAirfieldsConfig) do {
        _airportPos = getarray ((_secondaryAirfieldsConfig select (_i - 1)) >> "ilsPosition");
        SC_var_airFieldPositions pushbackunique _airportPos;

        (([(SC_var_sides apply {
            [_x, ((getMarkerPos ("SC_var_" + (str _x) + "Base")) distance2D _airportPos)]
        }), [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy) select 0) params ["_nearestBasesSide", "_distanceToAirport"];

        if (_distanceToAirport <= 500) then {
            _i setAirportSide _nearestBasesSide;
        };
    };
};

if SC_var_spawnVehiclesOnSectors then {
    {
        _sectorInd = _x;
        _flag3d = missionNameSpace getVariable ("SC_var_flag" + _sectorInd + "3d");

        [
            _flag3d, [
                "<img size='1' color='#ffffff' shadow='2' image='\A3\ui_f\data\Map\Markers\NATO\c_car.paa'/> Vehicles",
                {[false, ((_this select 3) select 0), -1] call SC_fnc_setupVehicleSpawnDialog;},
                [_sectorInd], 1.5, true, false, "", ("(side (group player)) == SC_var_owner" + _sectorInd), 3
            ]
        ] remoteExecCall ["addAction", 0, true];
    } forEach SC_var_sectors;
};

SC_var_planeSpawnIds = [];
if SC_var_hugeMap then {
    _i = 1;

    while {!(isNil ("SC_var_planeShop" + (str _i)))} do {
        _shop = missionNamespace getVariable ("SC_var_planeShop" + (str _i));

        if ((getPosWorld _shop) inArea "SC_var_playZone") then {
            [
                _shop, [
                    "<img size='1' color='#ffffff' shadow='2' image='\A3\ui_f\data\Map\Markers\NATO\c_car.paa'/> Vehicles",
                    {[true, ((_this select 3) select 0), ((_this select 3) select 1)] call SC_fnc_setupVehicleSpawnDialog;},
                    [((text (nearestLocation [(getPosWorld player), "nameCity"])) + " Airfield"), _i], 1.5, true, false, "", "", 3
                ]
            ] remoteExecCall ["addAction", 0, true];

            missionNamespace setVariable [("SC_var_vehicleSpawnSemaphore" + (str _i)), false, true];
            missionNamespace setVariable [("SC_var_planeSpawnSemaphore" + (str _i)), false, true];

            _markerName = "SC_var_planeSpawnMarker" + (str _i);
            createMarker [_markerName, (getPosWorld _shop)];
            _markerName setMarkerType "c_plane";

            SC_var_planeSpawnIds pushBack _i;
        };

        _i = _i + 1;
    };
};
publicVariable "SC_var_planeSpawnIds";

{
    _side = _x;
    _inf = missionNamespace getVariable ("SC_var_" + (str _side) + "Inf");
    _CS = missionNamespace getVariable ("SC_var_" + (str _side) + "CS");
    _vehicle = missionNamespace getVariable ("SC_var_" + (str _side) + "Veh");
    _tp = missionNamespace getVariable ("SC_var_" + (str _side) + "Tp");
    _equip = missionNamespace getVariable ("SC_var_" + (str _side) + "Equip");

    [_side, (getMarkerPos ("SC_var_" + (toLower (str _side)) + "Respawn")), "Base"] call BIS_fnc_addRespawnPosition;

    [
        _equip, [
            "<img size='1.1' color='#ffffff' shadow='2' image='\A3\Ui_f\data\GUI\Cfg\RespawnRoles\assault_ca.paa'/> Change Loadout",
            {["Open", [nil, SC_var_equip, player]] call BIS_fnc_arsenal;},
            nil, 1.5, true, false, "", "true", 3
        ]
    ] remoteExecCall ["addAction", 0, true];

    [
        _equip, [
            "<img size='1.5' color='#ffffff' shadow='2' image='\A3\Ui_f\data\IGUI\Cfg\Cursors\getIn_ca.paa'/> Store/Load Loadouts",
            {createDialog "loadoutDialog";}, nil, 1.5, true, false, "", "true", 3
        ]
    ] remoteExecCall ["addAction", 0, true];

    [
        _equip, [
            "<img size='1.1' color='#ffffff' shadow='2' image='\A3\ui_f\data\IGUI\RscTitles\MPProgress\respawn_ca.paa'/> Load last saved Loadout",
            {
                [SC_var_lastLoadout] call SC_fnc_setLoadout;
                ["loadoutLoaded"] call BIS_fnc_showNotification;
            },
            nil, 1.5, true, false, "", "true", 3
        ]
    ] remoteExecCall ["addAction", 0, true];

    [
        _equip, [
            "<img size='1.1' color='#ffffff' shadow='2' image='\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\rearm_ca.paa'/> Fill magazines",
            {
                if ((count ((weapons player) + (magazines player))) > 0) then {
                    {
                        player setAmmo[_x, 1000000];
                    } forEach (weapons player);

                    {
                        player removeMagazine _x;
                        player addMagazine _x;
                    } forEach (magazines player);

                    ["magsFilled"] call BIS_fnc_showNotification;
                } else {
                    ["noMags"] call BIS_fnc_showNotification;
                };
            },
            nil, 1.5, true, false, "", "true", 3
        ]
    ] remoteExecCall ["addAction", 0, true];

    {
        _text0 = _x select 0;
        _text1 = _x select 1;
        
        [
            _inf, [
                ("<img color='#ffffff' shadow='2' image='\A3\ui_f\data\Map\MapControl\powersolar_CA.paa'/> " + _text0),
                {
                    (_this select 3) params ["_name", "_configName"];

                    if (_configName == "equipment") then {
                        createDialog "equipmentDialog";
                    } else {
                        if (_configName == "statistics") then {
                            createDialog "statisticsDialog";
                        } else {
                            createDialog "infoDialog";
                            ((uiNamespace getVariable "SC_var_infoDialog") displayCtrl 1101) ctrlSetText _name;

                            {
                                lbAdd [1500, _x];
                            } forEach (getArray (missionConfigFile >> _configName));
                        };
                    };
                },
                [_text0, _text1], 1.5, true, false, "", "", 3
            ]
        ] remoteExecCall ["addAction", 0, true];
    } forEach ([
        ["Hotkeys", "hotkeys"],
        ["Gamemode", "gameMode"],
        ["Rank System", "ranksystem"],
        ["Vehicle System", "vehiclesystem"],
        ["Equipment", "equipment"],
        ["Statistics", "statistics"],
        ["Airdrops", "airdrops"],
        ["Perks", "perks"]
    ]);

    [
        _CS,
        [
            "<img size='1.1' color='#ffffff' shadow='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\reammo_ca.paa'/>Perks",
            {createDialog "perkDialog";}, [], 1.5, true, false, "", "", 3
        ]
    ] remoteExecCall ["addAction", 0, true];

    [
        _vehicle, [
            "<img size='1' color='#ffffff' shadow='2' image='\A3\ui_f\data\Map\Markers\NATO\c_car.paa'/> Vehicles",
            {[true, "the Base", -1] call SC_fnc_setupVehicleSpawnDialog;},
            [], 1.5, true, false, "", "true", 3
        ]
    ] remoteExecCall ["addAction", 0, true];

    [
        _tp,
        [
            "<img size='1.2' shadow='2' image='\A3\ui_f\data\IGUI\Cfg\Actions\unloadVehicle_ca.paa'/> Teleport",
            {
                0 fadeSound 0;
                forceRespawn player;
                player hideObjectGlobal true;
                player enableSimulationGlobal false;
                player setPos (((getMarkerPos "SC_var_playZone") select [0, 2]) + [100]);
                setPlayerRespawnTime 0.1;
                [] spawn SC_fnc_onKilled;
                waitUntil {alive player};
                player enableSimulationGlobal true;
            },
            nil, 1.5, true, false, "", "", 3
        ]
    ] remoteExecCall ["addAction", 0, true];
} forEach SC_var_sides;