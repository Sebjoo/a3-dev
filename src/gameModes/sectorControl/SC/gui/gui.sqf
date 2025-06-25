SC_fnc_getHudColor = {
    params ["_side"];

    switch _side do {
        case WEST: {[0, 0.4, 0.7, 0.85]};
        case EAST: {[0.7, 0, 0, 0.85]};
        case INDEPENDENT: {[0, 0.6, 0.3, 0.85]};
        default {[0, 0, 0, 0.35]};
    }
};

SC_fnc_transformAlignToSafezone = {
    params ["_x","_y","_w","_h","_align"];

    _aspectRatio = (getResolution select 0) / (getResolution select 1);
    _safezoneWCorrected = safeZoneW * ((16 / 9) / _aspectRatio);
    _safeZoneXCorrected = switch _align do {
        case "LEFT": {safeZoneX};
        case "RIGHT": {safeZoneX + safeZoneW - _safezoneWCorrected};
        case "CENTER": {safeZoneX + (safeZoneW - _safezoneWCorrected) / 2};
    };

    [
        _safeZoneXCorrected + _safezoneWCorrected * _x,
        safeZoneY + safeZoneH * (1 - _y),
        _safezoneWCorrected * _w,
        safeZoneH * _h
    ]
};

SC_fnc_writeSettingsArrToVariables = {
    SC_var_hudEnabled = SC_var_settings select 0;
    SC_var_alwaysShowHudOnMap = SC_var_settings select 1;
    SC_var_alwaysShowHudWhenUnconscious = SC_var_settings select 2;
    SC_var_showWholeHudOnMap = SC_var_settings select 3;
    SC_var_showWholeHudWhenUnconscious = SC_var_settings select 4;
    TDI_var_ShowUnitNames = SC_var_settings select 11;
    TDI_var_HideInvisibleGroupMembers = SC_var_settings select 12;
    TDI_var_groupUnitsLimitedDistance = SC_var_settings select 13;
    SC_var_showSector3DIcons = SC_var_settings select 14;
    SC_var_showAirDrop3DIcons = SC_var_settings select 15;
    MM_var_showUnitNamesOnlyOnHover = SC_var_settings select 16;
    SC_var_gpsPanelEnabled = SC_var_settings select 20;
};

SC_fnc_toggleHud = {
    SC_var_hudEnabled = !SC_var_hudEnabled;
    SC_var_settings set [0, SC_var_hudEnabled];
    profileNamespace setVariable ["SC_var_lastSettings", SC_var_settings];
    saveProfileNamespace;

    if SC_var_hudEnabled then {
        [true] call SC_fnc_setHud;
    } else {
        if !(
            (SC_var_alwaysShowHudOnMap && visibleMap) ||
            {SC_var_alwaysShowHudWhenUnconscious && (player getVariable ["AIS_unconscious", false])}
        ) then {
            [false] call SC_fnc_setHud;
        };
    };
};

SC_fnc_toggleSetting = {
    params ["_settingsIndex"];

    [_settingsIndex, !(SC_var_settings select _settingsIndex)] call SC_fnc_changeSetting;
};

SC_fnc_changeSetting = {
    params ["_settingsIndex", "_enabled"];

    SC_var_settings set [_settingsIndex, _enabled];
    call SC_fnc_writeSettingsArrToVariables;
    profileNamespace setVariable ["SC_var_lastSettings", SC_var_settings];
    saveProfileNamespace;

    [
        SC_var_hudEnabled ||
        {SC_var_alwaysShowHudOnMap && visibleMap} ||
        {SC_var_alwaysShowHudWhenUnconscious && (player getVariable ["AIS_unconscious", false])}
    ] call SC_fnc_setHud;
};

SC_fnc_setupSettingsDialog = {
    _settingsDialog = uiNamespace getVariable "SC_var_settingsDialog";

    for "_i" from 0 to ((count SC_var_settings) - 1) do {
        (_settingsDialog displayCtrl (2800 + _i)) cbSetChecked (SC_var_settings select _i);
    };

    (_settingsDialog displayCtrl 1900) sliderSetRange [0, 1];
    (_settingsDialog displayCtrl 1900) sliderSetPosition ((viewDistance - 500) / 3500);

    (_settingsDialog displayCtrl 1901) sliderSetRange [0, 1];
    (_settingsDialog displayCtrl 1901) sliderSetPosition (profileNameSpace getVariable ["SC_var_currentGrassViewDistanceFactor", 1]);
};

SC_fnc_setupLoadoutDialog = {
    _loadoutDialog = uiNamespace getVariable "SC_var_loadoutDialog";
    _controlsTable = _loadoutDialog displayCtrl 1500;
    (ctAddHeader _controlsTable) params ["", "_header"];

    _header params ["_ctrlHeaderBackground",
        "_ctrlColumn1", "_ctrlColumn2", "_ctrlColumn3",
        "_ctrlColumn4", "_ctrlColumn5"
    ];

    {_x ctrlSetBackgroundColor [0.4, 0.4, 0.4, 1];} forEach _row;

    _ctrlHeaderBackground ctrlSetBackgroundColor [0, 0.3, 0.6, 1];
    _ctrlColumn1 ctrlSetText "Weapon";
    _ctrlColumn2 ctrlSetText "Launcher";
    _ctrlColumn3 ctrlSetText "Sidearm";
    _ctrlColumn4 ctrlSetText "Apparel";
    _ctrlColumn5 ctrlSetText "Perks";

    _loadouts = (profileNameSpace getVariable ["SC_var_storedLoadouts", []]) select {(_x select 3) == SC_var_currentWorldGroup};
    _loadouts pushBack [[[],[],[],[],[],[],"","",[],["","","","","",""]], [], SC_var_baseLoadoutInfo, SC_var_currentWorldGroup];
    
    {
        _x params ["_loadout", "_perks"];
        _loadout params ["_primaryArr", "_launcherArr", "_sidearmArr", "_uniformArr", "_vestArr", "_backpackArr", "_helmet"];

        _primaryWeapon = if (_primaryArr isEqualTo []) then {""} else {_primaryArr select 0};
        _launcher = if (_launcherArr isEqualTo []) then {""} else {_launcherArr select 0};
        _sidearm = if (_sidearmArr isEqualTo []) then {""} else {_sidearmArr select 0};
        _uniform = if (_uniformArr isEqualTo []) then {""} else {_uniformArr select 0};
        _vest = if (_vestArr isEqualTo []) then {""} else {_vestArr select 0};
        _backpack = if (_backpackArr isEqualTo []) then {""} else {_backpackArr select 0};
        _helmet = if (_helmet isEqualTo "") then {""} else {_helmet};

        (ctAddRow _controlsTable) params ["", "_row"];

        _row params ["_ctrlBackground",
            "_ctrlColumn1", "_ctrlColumn2", "_ctrlColumn3",
            "_ctrlColumn4", "_ctrlColumn5", "_ctrlColumn6",
            "_ctrlColumn7", "_ctrlColumn8"
        ];

        {_x ctrlSetBackgroundColor [0.4, 0.4, 0.4, 1];} forEach _row;

        _ctrlColumn8 ctrlSetBackgroundColor [0, 0, 0, 0];

        _ctrlColumn1 ctrlSetText ([_primaryWeapon] call SC_fnc_getPicture);
        _ctrlColumn2 ctrlSetText ([_launcher] call SC_fnc_getPicture);
        _ctrlColumn3 ctrlSetText ([_sidearm] call SC_fnc_getPicture);
        _ctrlColumn4 ctrlSetText ([_uniform] call SC_fnc_getPicture);
        _ctrlColumn5 ctrlSetText ([_vest] call SC_fnc_getPicture);
        _ctrlColumn6 ctrlSetText ([_backpack] call SC_fnc_getPicture);
        _ctrlColumn7 ctrlSetText ([_helmet] call SC_fnc_getPicture);
        _ctrlColumn8 ctrlSetText (_perks joinString ", ");
    } forEach _loadouts;
};

SC_fnc_storeLoadout = {
    if !(call SC_fnc_isLoadoutValid) exitWith {
        ["loadoutNotSaved"] call BIS_fnc_showNotification;
    };

    _loadoutDialog = uiNamespace getVariable "SC_var_loadoutDialog";
    _controlsTable = _loadoutDialog displayCtrl 1500;
    _numLoadouts = (ctRowCount _controlsTable) - 1;
    _idxToStore = ctCurSel _controlsTable;
    _newLoadout = [(getUnitLoadout player), +SC_var_perks, (call SC_fnc_getLoadoutInfo), SC_var_currentWorldGroup];
    _newLoadouts = profileNameSpace getVariable ["SC_var_storedLoadouts", []];

    if (_idxToStore == _numLoadouts) then {
        _newLoadouts pushBack _newLoadout;
    } else {
        _newLoadouts set [_idxToStore, _newLoadout];
    };

    profileNameSpace setVariable ["SC_var_storedLoadouts", _newLoadouts];
    saveProfileNameSpace;

    closeDialog 2;
    createDialog "loadoutDialog";
};

SC_fnc_loadLoadout = {
    _loadoutDialog = uiNamespace getVariable "SC_var_loadoutDialog";
    _controlsTable = _loadoutDialog displayCtrl 1500;
    _numLoadouts = (ctRowCount _controlsTable) - 1;
    _idxToLoad = ctCurSel _controlsTable;

    if (_idxToLoad == _numLoadouts) then {
        SC_var_lastLoadout = +SC_var_baseLoadout;
        [SC_var_lastLoadout] call SC_fnc_setLoadout;
        SC_var_perks = [];
        SC_var_lastloadoutInfo = SC_var_baseLoadoutInfo;
    } else {
        ((profileNameSpace getVariable "SC_var_storedLoadouts") select _idxToLoad) params ["_loadout", "_perks", "_loadoutInfo"];
        SC_var_lastLoadout = +_loadout;
        SC_var_perks = +_perks;
        [SC_var_lastLoadout] call SC_fnc_setLoadout;
        SC_var_lastloadoutInfo = +_loadoutInfo;
        call SC_fnc_adjustLoadoutAndInfo;
    };

    [SC_var_equip, playerSide, (player getVariable "SC_var_rank"), +SC_var_perks] call SC_fnc_changePerks;
    call SC_fnc_saveLoadoutToProfile;

    if SC_var_hudEnabled then {
        ["loadoutLoaded"] call BIS_fnc_showNotification;
    };
};

SC_fnc_deleteLoadout = {
    _loadoutDialog = uiNamespace getVariable "SC_var_loadoutDialog";
    _controlsTable = _loadoutDialog displayCtrl 1500;
    
    _allLoadouts = profileNameSpace getVariable ["SC_var_storedLoadouts", []];
    _worldGroupsLoadouts = _allLoadouts select {
        _x params ["", "", "", ["_worldGroup", "2035"]];

        (_worldGroup == SC_var_currentWorldGroup)
    };
    _otherLoadouts = _allLoadouts - _worldGroupsLoadouts;

    _numLoadouts = (ctRowCount _controlsTable) - 1;
    _idxToDelete = ctCurSel _controlsTable;
    if ((_numLoadouts == 0) || {_idxToDelete == _numLoadouts}) exitWith {};
    _worldGroupsLoadouts deleteAt _idxToDelete;
    _allLoadouts = _otherLoadouts + _worldGroupsLoadouts;
    profileNameSpace setVariable ["SC_var_storedLoadouts", +_allLoadouts];
    saveProfileNameSpace;

    _controlsTable ctRemoveRows [_idxToDelete];
};

SC_fnc_getPerkFromPerkAbbrev = {
    params ["_perkAbbrev"];

    (SC_var_perkConfig select (SC_var_perkConfig findIf {(_x select 1) == _perkAbbrev})) select 0
};

SC_fnc_getPerkAbbrevFromPerk = {
    params ["_perk"];

    (SC_var_perkConfig select (SC_var_perkConfig findIf {(_x select 0) == _perk})) select 1
};

SC_fnc_setupPerkDialog = {
    _perkDialog = uiNamespace getVariable "SC_var_perkDialog";
    _rank = player getVariable "SC_var_rank";

    _possiblePerks = SC_var_perkConfig select {(_x select 2) <= _rank};
    _unselectedPerks = _possiblePerks select {!((_x select 1) in SC_var_perks)};
    _numPossiblePerks = {!(isNil "_x") && {_x <= _rank}} count SC_var_rankForPerkId;
    _numEquippedPerks = count SC_var_perks;
    _numUnselectedPerks = count _unselectedPerks;
    SC_var_overridePerkChange = true;

    for "_i" from 0 to 5 do {
        _combo = _perkDialog displayCtrl (2100 + _i);
        lbClear _combo;
        _numEntries = 0;
        _selectedPerk = "";

        if (_i < _numPossiblePerks) then {
            {_combo lbAdd (_x select 0);} forEach _unselectedPerks;
            _numEntries = _numUnselectedPerks + 1;

            if (_i < _numEquippedPerks) then {
                _selectedPerk = [SC_var_perks select _i] call SC_fnc_getPerkFromPerkAbbrev;
            } else {
                _selectedPerk = "----";
            };
        } else {
            _selectedPerk = "----";
            _numEntries = 1;
        };

        _combo lbAdd _selectedPerk;
        lbSort _combo;
        _idxSelectedPerk = 0;

        for "_j" from 1 to (_numEntries - 1) do {
            if ((_combo lbText _j) == _selectedPerk) then {
                _idxSelectedPerk = _j;
            };
        };

        _combo lbSetCurSel _idxSelectedPerk;
    };

    SC_var_overridePerkChange = false;
};

SC_fnc_changePerk = {
    params ["_perkSlot", "_index"];

    _perkDialog = uiNamespace getVariable "SC_var_perkDialog";
    _combo = _perkDialog displayCtrl (2100 + _perkSlot);
    _rank = player getVariable "SC_var_rank";
    _numPossiblePerks = {(_x select 2) <= _rank} count SC_var_perkConfig;

    if (!SC_var_overridePerkChange && {_perkSlot < _numPossiblePerks}) then {
        _newPerk = _combo lbText _index;
        _newPerkAbbrev = [_newPerk] call SC_fnc_getPerkAbbrevFromPerk;
        _oldPerkAbbrev = SC_var_perks select _perkSlot;
        _removedEquipment = (_newPerkAbbrev == "MEDC") || {_oldPerkAbbrev in ["MGNR", "MEDC", "LNCR", "MRKS", "ARMR", "GRND", "SUPR"]};
        SC_var_perks set [_perkSlot, _newPerkAbbrev];
        [SC_var_equip, playerSide, (player getVariable "SC_var_rank"), +SC_var_perks, _removedEquipment] call SC_fnc_changePerks;
        call SC_fnc_setupPerkDialog;
    };
};

SC_fnc_showStatistics = {
    params ["_showDeaths", "_sortByIndex"];

    _settingsDialog = uiNamespace getVariable "SC_var_statisticsDialog";

    _numKills = profileNamespace getVariable ["SC_var_numKills", 0];
    _numDeaths = profileNamespace getVariable ["SC_var_numDeaths", 0];
    _numOther = profileNamespace getVariable ["SC_var_numOther", 0];
    _headshotRate = profileNamespace getVariable ["SC_var_headshotRate", 0];
    _numCapturedSectors = profileNamespace getVariable ["SC_var_numCapturedSectors", 0];
    _numUnitsRevived = profileNamespace getVariable ["SC_var_numRevives", 0];
    _numRevived = profileNamespace getVariable ["SC_var_numRevived", 0];
    _numHeals = profileNamespace getVariable ["SC_var_numHeals", 0];
    _numSelfHeals = profileNamespace getVariable ["SC_var_numSelfHeals", 0];

    (_settingsDialog displayCtrl 1003) ctrlSetText ("Kills: " + (str _numKills));
    (_settingsDialog displayCtrl 1004) ctrlSetText ("Deaths: " + (str _numDeaths));
    (_settingsDialog displayCtrl 1005) ctrlSetText ("Assists/Finally Killed: " + (str _numOther));
    (_settingsDialog displayCtrl 1006) ctrlSetText ("Headshot Rate: " + ((str ([100 * _headshotRate, 2] call BIS_fnc_cutDecimals)) + "%"));
    (_settingsDialog displayCtrl 1007) ctrlSetText ("Sectors Captured: " + (str _numCapturedSectors));
    (_settingsDialog displayCtrl 1008) ctrlSetText ("K/D: " + (str ([_numKills / (1 max _numDeaths), 2] call BIS_fnc_cutDecimals)));
    (_settingsDialog displayCtrl 1009) ctrlSetText ("Units Revived: " + (str _numUnitsRevived));
    (_settingsDialog displayCtrl 1010) ctrlSetText ("Recieved Revives: " + (str _numRevived));
    (_settingsDialog displayCtrl 1011) ctrlSetText ("Units Healed: " + (str _numHeals));
    (_settingsDialog displayCtrl 1012) ctrlSetText ("Healed Self: " + (str _numSelfHeals));

    _controlsTable = _settingsDialog displayCtrl 1500;
    ctClear _controlsTable;
    (ctAddHeader _controlsTable) params ["", "_header"];

    _header params ["_ctrlHeaderBackground",
        "_ctrlHeaderColumn1", "_ctrlHeaderColumn2", "_ctrlHeaderColumn3",
        "_ctrlHeaderColumn4", "_ctrlHeaderColumn5", "_ctrlHeaderColumn6"
    ];

    _ctrlHeaderBackground ctrlSetBackgroundColor [0, 0.3, 0.6, 1];
    _ctrlHeaderColumn1 ctrlSetText "Picture";
    _ctrlHeaderColumn2 ctrlSetText (["Kills", "Deaths"] select _showDeaths);
    _ctrlHeaderColumn3 ctrlSetText "Assists";
    _ctrlHeaderColumn4 ctrlSetText "Headshots";
    _ctrlHeaderColumn5 ctrlSetText "Avg. Distance";
    _ctrlHeaderColumn6 ctrlSetText (["XP", ""] select _showDeaths);

    if _showDeaths then {
        _ctrlHeaderColumn2 ctrlAddEventHandler ["ButtonClick", {[true, 1] call SC_fnc_showStatistics;}];
        _ctrlHeaderColumn3 ctrlAddEventHandler ["ButtonClick", {[true, 2] call SC_fnc_showStatistics;}];
        _ctrlHeaderColumn4 ctrlAddEventHandler ["ButtonClick", {[true, 3] call SC_fnc_showStatistics;}];
        _ctrlHeaderColumn5 ctrlAddEventHandler ["ButtonClick", {[true, 4] call SC_fnc_showStatistics;}];
        _ctrlHeaderColumn6 ctrlAddEventHandler ["ButtonClick", {[true, 5] call SC_fnc_showStatistics;}];
    } else {
        _ctrlHeaderColumn2 ctrlAddEventHandler ["ButtonClick", {[false, 1] call SC_fnc_showStatistics;}];
        _ctrlHeaderColumn3 ctrlAddEventHandler ["ButtonClick", {[false, 2] call SC_fnc_showStatistics;}];
        _ctrlHeaderColumn4 ctrlAddEventHandler ["ButtonClick", {[false, 3] call SC_fnc_showStatistics;}];
        _ctrlHeaderColumn5 ctrlAddEventHandler ["ButtonClick", {[false, 4] call SC_fnc_showStatistics;}];
        _ctrlHeaderColumn6 ctrlAddEventHandler ["ButtonClick", {[false, 5] call SC_fnc_showStatistics;}];
    };

    _history = profileNameSpace getVariable [["SC_var_killHistory", "SC_var_deathHistory"] select _showDeaths, []];

    _history = [_history, [_sortByIndex], {
        if (_input0 != 3) then {
            _x select _input0
        } else {
            _x params ["", "_numKills", "_numOther", "_numHeadshots"];
            _numHeadshots / (_numKills + _numOther)
        }
    }, "DESCEND"] call BIS_fnc_sortBy;

    {
        _x params ["_source", "_numKills", "_numOther", "_numHeadshots", "_avgDis", ["_xp", 0]];
        _picture = [_source] call SC_fnc_getPicture;

        if (_picture != "") then {
            (ctAddRow _controlsTable) params ["", "_row"];

            _row params ["_ctrlBackground",
                "_ctrlColumn1", "_ctrlColumn2", "_ctrlColumn3",
                "_ctrlColumn4", "_ctrlColumn5", "_ctrlColumn6"
            ];

            if (_avgDis < 0) then {
                _avgDis = 0;
            };

            {_x ctrlSetBackgroundColor [0.4, 0.4, 0.4, 1];} forEach _row;

            _ctrlColumn1 ctrlSetText _picture;
            _ctrlColumn2 ctrlSetText (str _numKills);
            _ctrlColumn3 ctrlSetText (str _numOther);
            _ctrlColumn4 ctrlSetText ((str (round (100 * _numHeadshots / (_numKills + _numOther)))) + "%");
            _ctrlColumn5 ctrlSetText ((str (round _avgDis)) + "m");
            _ctrlColumn6 ctrlSetText ([(str _xp), ""] select _showDeaths);
        };
    } forEach _history;
};

SC_fnc_setupEquipmentDialog = {
    params ["_category"];

    _equipmentDialog = uiNamespace getVariable "SC_var_equipmentDialog";
    _controlsTable = _equipmentDialog displayCtrl 1611;
    ctClear _controlsTable;
    (ctAddHeader _controlsTable) params ["", "_header"];

    _header params ["_ctrlHeaderBackground",
        "_ctrlHeaderColumn1", "_ctrlHeaderColumn2", "_ctrlHeaderColumn3"
    ];

    _ctrlHeaderBackground ctrlSetBackgroundColor [0, 0.3, 0.6, 1];
    _ctrlHeaderColumn1 ctrlSetText "Picture";
    _ctrlHeaderColumn2 ctrlSetText "Name";
    _ctrlHeaderColumn3 ctrlSetText "Rank";
    _items = [];

    if (_category == "vehicles") then {
        _items = (getArray (missionConfigFile >> "vehicles")) call SC_fnc_filterConfigArr;
    };

    if (_category == "medic") then {
        _items = [["Medikit", 5]];
    };

    if (_category == "general") then {
        _items = ([((getarray (missionConfigFile >> "general")) + (getarray (missionConfigFile >> ((str (side (group player))) + "General")))) call SC_fnc_filterConfigArr, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy);
    };
    
    if (_category == "marksman") then {
        _items = ([((getarray (missionConfigFile >> "marksman")) + (getarray (missionConfigFile >> ((str (side (group player))) + "Marksman")))) call SC_fnc_filterConfigArr, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy);
    };

    if (_category == "machinegunner") then {
        _items = ([(getarray (missionConfigFile >> "machinegunner")) call SC_fnc_filterConfigArr, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy);
    };
    
    if (_category == "grenadier") then {
        _items = ([(getarray (missionConfigFile >> "grenadier")) call SC_fnc_filterConfigArr, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy);
    };
    
    if (_category == "launcher") then {
        _items = ([(getarray (missionConfigFile >> "launcher")) call SC_fnc_filterConfigArr, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy);
    };

    if (_category == "armor") then {
        _items = ([(getarray (missionConfigFile >> ((str (side (group player))) + "Armor"))) call SC_fnc_filterConfigArr, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy);
    };

    if (_category == "suppressor") then {
        _items = ([(getarray (missionConfigFile >> "suppressor")) call SC_fnc_filterConfigArr, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy);
    };

    _playerRank = player getVariable ["SC_var_rank", 1];

    {
        _x params ["_type", "_rank"];

        (ctAddRow _controlsTable) params ["", "_row"];
        _row params ["", "_ctrlColumn1", "_ctrlColumn2", "_ctrlColumn3"];

        _color = [0.4, 0.4, 0.4, 1];

        if (_playerRank < _rank) then {
            _color = [0.23, 0.23, 0.23, 1];
        };
        
        if ((_category == "vehicles") && {!(_x in SC_var_availableVehicles)}) then {
            _color = [0.4, 0.1, 0.1, 1];
        };

        {_x ctrlSetBackgroundColor _color;} forEach _row;

        _ctrlColumn1 ctrlSetText ([_type] call SC_fnc_getPicture);
        _ctrlColumn2 ctrlSetText ([_type] call SC_fnc_getDisplayName);
        _ctrlColumn3 ctrlSetText (str _rank);
    } forEach _items;
};

SC_fnc_setupVehicleSpawnDialog = {
    createDialog "vehicleSpawnDialog";

    _this spawn {
        params ["_allowPlanes", "_place", ["_planeSpawnIdx", -1]];

        SC_var_currentPlace = _place;
        SC_var_currentPlaneSpawnIdx = _planeSpawnIdx;

        _equipmentDialog = uiNamespace getVariable "SC_var_vehicleSpawnDialog";

        _equipmentDialog spawn {
            waitUntil {
                _this call {
                    if !(isNull _this) then {
                        _vehicleCooldown = player getVariable ["SC_var_vehicleCooldown", 9999];
                        _timeStr = [_vehicleCooldown] call SC_fnc_secondsToMinSec;
                        (_this displayCtrl 1003) ctrlSetText "Spawn Cooldown: " + _timeStr + " min";
                    };
                };

                (isNull _this)
            };
        };

        (_equipmentDialog displayCtrl 1600) ctrlAddEventHandler ["ButtonClick", {
            _equipmentDialog = uiNamespace getVariable "SC_var_vehicleSpawnDialog";
            _controlsTable = _equipmentDialog displayCtrl 1500;
            _vehicleIndex = ctCurSel _controlsTable;
            _allVehicles = (getArray (missionConfigFile >> "vehicles")) call SC_fnc_filterConfigArr;
            (_allVehicles select _vehicleIndex) params ["_type", "_rank"];
            _playerRank = player getVariable ["SC_var_rank", 1];

            if ((_playerRank >= _rank) && {(SC_var_availableVehicles findIf {(_x select 0) == _type}) != -1}) then {
                [player, SC_var_currentPlace, _type, SC_var_currentPlaneSpawnIdx] remoteExec ["SC_fnc_spawnVehicle", 2];
                closeDialog 2;
            };
        }];

        _controlsTable = _equipmentDialog displayCtrl 1500;
        ctClear _controlsTable;
        (ctAddHeader _controlsTable) params ["", "_header"];

        _header params ["_ctrlHeaderBackground",
            "_ctrlHeaderColumn1", "_ctrlHeaderColumn2", "_ctrlHeaderColumn3"
        ];

        _ctrlHeaderBackground ctrlSetBackgroundColor [0, 0.3, 0.6, 1];
        _ctrlHeaderColumn1 ctrlSetText "Picture";
        _ctrlHeaderColumn2 ctrlSetText "Name";
        _ctrlHeaderColumn3 ctrlSetText "Rank";

        _playerRank = player getVariable ["SC_var_rank", 1];

        {
            _x params ["_type", "_rank"];

            (ctAddRow _controlsTable) params ["", "_row"];
            _row params ["_ctrlBackground", "_ctrlColumn1", "_ctrlColumn2", "_ctrlColumn3"];
            _color = [0.4, 0.4, 0.4, 1];

            if (_playerRank < _rank) then {
                _color = [0.23, 0.23, 0.23, 1];
            };
            
            if (!(_x in SC_var_availableVehicles) || {(!_allowPlanes) && {(_type isKindOf "Plane_Base_F") || {_type isKindOf "Plane"}}}) then {
                _color = [0.4, 0.1, 0.1, 1];
            };

            {_x ctrlSetBackgroundColor _color;} forEach _row;

            _ctrlColumn2 ctrlSetBackgroundColor [0, 0, 0, 0];
            _ctrlColumn3 ctrlSetBackgroundColor [0, 0, 0, 0];

            _ctrlColumn1 ctrlSetText ([_type] call SC_fnc_getPicture);
            _ctrlColumn2 ctrlSetText ([_type] call SC_fnc_getDisplayName);
            _ctrlColumn3 ctrlSetText (str _rank);
        } forEach ((getArray (missionConfigFile >> "vehicles")) call SC_fnc_filterConfigArr);
    };
};