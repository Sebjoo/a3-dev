KF_var_running = false;
publicVariable "KF_var_running";

KF_var_selectionFoldRules = [
    [["Left Arm", "Right Arm"], "Both Arms"],
    [["Left Leg", "Right Leg"], "Both Legs"],
    [["Left Foot", "Right Foot"], "Both Feet"],
    [["Both Arms", "Both Legs", "Both Feet", "Head", "Pelvis", "Spine"], "Whole Body"]
];

KF_var_typeFoldRules = [
    ["Weapon", "Weapon Headshot"],
    ["Vehicle Weapon", "Vehicle Weapon Headshot"]
];

KF_fnc_SetDefaultSettings = {
    KF_var_Assists = true;
    KF_var_KillfeedEnabled = true;
    KF_var_KillfeedInversed = true;
    KF_var_KillfeedCooldown = 30;
    KF_var_KillfeedMaximumLength = 10;
    KF_var_AddKillFeedInfo = [];
    KF_var_ShowFriendlyFire = true;
    KF_var_DeathCausesInversed = true;
    KF_var_MultipleDeathCauses = false;
    KF_var_PicturesHeadIcon = true;
    KF_var_picturesBulletIcon = true;
    KF_var_showAiInNames = true;
    KF_var_MidFeedEnabled = true;
    KF_var_MidfeedCooldown = 10;
    KF_var_MidfeedMaximumLength = 10;
    KF_var_MidFeedYouColorYellow = true;
    KF_var_MidFeedAssists = true;
    KF_var_AddMidFeedInfo = [];
    KF_var_DeathFeedEnabled = true;
    KF_var_AddDeathFeedInfo = [];
    KF_var_killInfoDuration = 20;
    KF_var_killInfoIncludeTK = false;
    KF_var_DeathTransition = true;
    KF_var_fontSize = 0.87;
    
    KF_var_handleUnitDeaths = true;
    KF_var_showFinallyKilledForUnitDeaths = false;
    KF_var_addScoreForUnitDeaths = true;
    KF_var_showUnitDeathsInKillfeed = true;
    KF_var_showUnitDeathsInMidfeed = true;
    KF_var_showUnitDeathsInDeathFeed = true;
    KF_var_showUnitDeathsInKillInfo = true;

    publicVariable "KF_var_KillfeedCooldown";
    publicVariable "KF_var_KillfeedMaximumLength";
    publicVariable "KF_var_MidfeedCooldown";
    publicVariable "KF_var_MidfeedMaximumLength";
    publicVariable "KF_var_DeathTransition";
};

call KF_fnc_SetDefaultSettings;

KF_fnc_ResetKillInfo = {
    KF_var_LongestKills = [["", civilian, "", civilian, [], "", 0]];
    KF_var_MostKillsInARow = [["", civilian, 0]];
};

call KF_fnc_ResetKillInfo;

KF_fnc_isVehicle = {
    params ["_typeName"];

    _typeName isKindOf [_typeName, (configFile >> "CfgVehicles")]
};

KF_fnc_getConfigEntry = {
    params ["_typeName"];

    _entryStr = switch true do {
        case (_typeName isKindOf [_typeName, (configFile >> "CfgMagazines")]): {"CfgMagazines"};
        case (_typeName isKindOf [_typeName, (configFile >> "CfgAmmo")]): {"CfgAmmo"};
        case (_typeName isKindOf [_typeName, (configFile >> "CfgVehicles")]): {"CfgVehicles"};
        case (_typeName isKindOf [_typeName, (configFile >> "CfgWeapons")]): {"CfgWeapons"};
        default {""};
    };

    if (_entryStr == "") then {objNull} else {
        (configfile >> _entryStr >> _typeName)
    }
};

KF_fnc_GetDisplayName = {
    params ["_typeName"];

    _configEntry = [_typeName] call KF_fnc_getConfigEntry;

    if (isNull _configEntry) then {""} else {getText (_configEntry >> "displayName")}
};

KF_fnc_GetPicture = {
    params ["_typeName"];

    _configEntry = [_typeName] call KF_fnc_getConfigEntry;

    if (isNull _configEntry) then {""} else {getText (_configEntry >> "picture")}
};

KF_fnc_getName = {
    params ["_unit"];

    _name = "";

    if (unitIsUAV _unit) then {
        _name = [([typeOf _unit] call KF_fnc_GetDisplayName), ["", "(AI)"] select KF_var_showAiInNames] joinString " ";
    } else {
        _name = name _unit;

        if (isPlayer _unit) then {_name} else {
            _ss = _name splitString " ";

            if ((count _ss) > 1) then {
                _sss = (_ss select 0) splitString "-";

                if ((count _sss) > 1) then {
                    _name = ((_sss select 0) select [0,1]) + ".-" + ((_sss select 1) select [0,1]) + ". " + (_ss select 1);
                } else {
                    _name = ((_ss select 0) select [0,1]) + ". " + (_ss select 1);
                };
            };
            
            if KF_var_showAiInNames then {
                _name = _name + " (AI)";
            };
        };
    };

    _name
};

KF_fnc_GetSidesHexColor = {
    params ["_side"];

    if (isNil "_side") then {
        "#808080"
    } else {
        switch _side do {
            case west: {"#0066B3"};
            case east: {"#E60000"};
            case independent: {"#009933"};
            default {"#808080"};
        }
    }
};

KF_fnc_getSelectionName = {
    params ["_selection"];

    if ("leg" in _selection) exitWith {if ("left" in _selection) then {"Left Leg"} else {"Right Leg"}};
    if ("arm" in _selection) exitWith {if ("left" in _selection) then {"Left Arm"} else {"Right Arm"}};
    if ("spine" in _selection) exitWith {"Spine"};
    if ("pelvis" in _selection) exitWith {"Pelvis"};
    if ("foot" in _selection) exitWith {if ("left" in _selection) then {"Left Foot"} else {"Right Foot"}};
    if ("head" in _selection) exitWith {"Head"};

    ""
};

KF_fnc_OnHit = {
    params ["_target"]; 

    _hitsTarget = _target getVariable ["KF_var_hits", []];
    _hitsTarget pushBack ((_this select [1, 6]) + [diag_frameNo]);
    _target setVariable ["KF_var_hits", _hitsTarget];
};

KF_fnc_UAVControlUnits = {
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

KF_fnc_mpHit = {
    params ["_unit", "_causedBy", "", "_instigator"];

    if ((isDamageAllowed _unit) && {!(isNull _causedBy)}) then {
        _magazine = "";
        _ammo = "";
        _distance = if (_unit isEqualTo _causedBy) then {-1} else {_unit distance _causedBy};
        _selections = [];

        if (unitIsUAV _causedBy) then {
            _uavCtrlCB = [_causedBy, "DRIVER", "GUNNER"] call KF_fnc_UAVControl;

            if ((isNull _uavCtrlCB) || {_unit isEqualTo _causedBy}) then {
                _instigator = _causedBy;
            } else {
                _instigator = _uavCtrlCB;
                _ammo = "vehHit";
            };
        };

        if ((isNull _instigator) && {_causedBy isKindOf "CAManBase"}) then {
            _instigator = _causedBy;
        };

        _parUN = objectParent _unit;
        _parIN = objectParent _instigator;

        if (_ammo == "") then {
            _ammo = if !(isNull _parIN) then {
                if ((alive _parIN) && {!(unitIsUAV _unit)} && {(isNull _parUN) || {!(_parIN isEqualTo _parUN)}}) then {
                    if (_distance > 4) then {
                        "expl"
                    } else {
                        "vehHit"
                    }
                } else {
                    "vehExpl"
                }
            } else {
                if ((_unit isEqualTo _causedBy) && {_unit isKindOf "CAManBase"}) then {
                    "fall"
                } else {
                    ""
                }
            };
        };

        if (_ammo == "") exitWith {};

        if (_unit isEqualTo _causedBy) then {
            _selections pushBack ["", true];
        } else {
            _selections pushBack [_causedBy selectionPosition "head", true];
        };

        _source = switch _ammo do {
            case "expl": {"Explosion"};
            case "fall": {"Fall Damage"};
            default {typeOf _causedBy};
        };

        [_unit, _instigator, _ammo, _magazine, _selections, _distance, _source] call KF_fnc_OnHit;
    };
};

KF_fnc_calculateHitTypeWeapon = {
    params ["_ammo", "_selections", "_source", "_isVehicle"];

    (_source call BIS_fnc_itemType) params ["_sourceCategory", "_sourceType"];

    switch true do {
        case ((_sourceType == "GrenadeLauncher") || {(_ammo find "G_") != -1}): {
            [(if _isVehicle then {""} else {"Weapon "}), "Grenade Launcher"] joinString ""
        };
        case (_sourceCategory in ["RocketLauncher", "MissileLauncher"]): {"Rocket Launcher"};
        case (["head", true] in _selections): {"Weapon Headshot"};
        default {"Weapon"};
    }
};

KF_fnc_calculateHitType = {
    params ["_ammo", "_selections", "_source"];

    _isVehicle = [_source] call KF_fnc_isVehicle;

    if _isVehicle then {
        switch _ammo do {
            case "vehHit": {"Vehicle Hit"};
            case "vehExpl": {"Vehicle Explosion"};
            default {["Vehicle", ([_ammo, _selections, _source, _isVehicle] call KF_fnc_calculateHitTypeWeapon)] joinString " "};
        }
    } else {
        switch true do {
            case (_ammo == "fall"): {"Fall Damage"};
            case (_source == "Throw"): {"Hand Grenade"};
            case (_source == "Put"): {"Explosive"};
            case (_ammo == "expl"): {"Explosion"};
            default {[_ammo, _selections, _source, _isVehicle] call KF_fnc_calculateHitTypeWeapon};
        }
    }
};

KF_fnc_CalculateHitData = {
    params ["_hits", ["_hitters", []], "_killer"];

    _hitData = _hitters apply {[_x, [], -1]};
    reverse _hits;

    {
        _x params ["_hitter"];

        _hitter = [_hitter] call KF_fnc_getRespawnedEntity;

        if (([_hitter] call KF_fnc_unitIsValid) && {KF_var_Assists || {_hitter isEqualTo _killer}}) then {
            _x params ["", "_ammo", "_magazine", "_selections", "_distance", "_source"];

            _type = [_ammo, _selections, _source] call KF_fnc_calculateHitType;

            if (_type in ["Hand Grenade", "Explosive"]) then {
                _source = _magazine;
            };

            _posHitter = _hitters find _hitter;

            if (_posHitter == -1) then {
                _hitters pushBack _hitter;
                _hitData pushBack [_hitter, [[_type, _source, _selections]], _distance];
            } else {
                (_hitData select _posHitter) params ["", "_typeSourceSelArr", "_oldDistance"];

                _posTypeSourceSel = _typeSourceSelArr findIf {((_x select 1) == _source) && {(_x select 0) == _type}};

                if (_posTypeSourceSel == -1) then {
                    _typeSourceSelArr pushBack [_type, _source, _selections];
                } else {
                    _typeSourceSel = _typeSourceSelArr select _posTypeSourceSel;
                    _typeSourceSel params ["", "", "_oldSelections"];

                    _oldSelections insert [-1, _selections, true];

                    _typeSourceSel set [2, _oldSelections];
                    _typeSourceSelArr set [_posTypeSourceSel, _typeSourceSel];
                };

                _newDistance = if (_oldDistance != -1) then {_oldDistance} else {_distance};

                _hitData set [_posHitter, [_hitter, _typeSourceSelArr, _newDistance]];
            };
        };
    } forEach _hits;

    {
        _x params ["_hitter", "_typeSourceSelArr", "_distance"];
        _indexHitter = _forEachIndex;

        _changed = false;

        _sources = _typeSourceSelArr apply {_x select 1};
        _sources = _sources arrayIntersect _sources;

        {
            _source = _x;

            {
                _x params ["_type1", "_type2"];

                _posType1 = _typeSourceSelArr findIf {((_x select 0) == _type1) && {(_x select 1) == _source}};
                _posType2 = -1;

                if ((_posType1 != -1) && {
                    _posType2 = _typeSourceSelArr findIf {((_x select 0) == _type2) && {(_x select 1) == _source}};

                    (_posType2 != -1)
                }) then {
                    if (_posType2 < _posType1) then {
                        _posTypeTmp = _posType1;
                        _posType1 = _posType2;
                        _posType2 = _posTypeTmp;

                        _typeTmp = _type1;
                        _type1 = _type2;
                        _type2 = _typeTmp;
                    };

                    _type1sSelections = (_typeSourceSelArr select _posType1) select 2;
                    _type2sSelections = (_typeSourceSelArr select _posType2) select 2;

                    _typeSourceSelArr deleteAt _posType2;
                    _type1sSelections insert [-1, _type2sSelections, true];
                    _typeSourceSelArr set [_posType1, [_type1, _source, _type1sSelections]];

                    _changed = true;
                };
            } forEach KF_var_typeFoldRules;
        } forEach _sources;

        if _changed then {
            _hitData set [_indexHitter, [_hitter, _typeSourceSelArr, _distance]];
        };
    } forEach _hitData;

    [_hitData, _hitters]
};

KF_fnc_FormatHitsPicture = {
    params ["_typeSourceSelArr", "_sizeFactor", "_resize"];

    _imageBasePath = "<img color='#dddddd' size='%1' image='\A3\";

    if (!KF_var_MultipleDeathCauses && _resize) then {
        _typeSourceSelArr resize 1;
    };

    (
        _typeSourceSelArr apply {
            _x params ["_type", "_source", "_selections"];

            format [(if KF_var_DeathCausesInversed then {"%3%2%1"} else {"%1%2%3"}),
                (
                    switch true do {
                        case (_type == "Explosion"): {""};
                        case (_type == "Tombstone"): {
                            format [([_imageBasePath, "Ui_f\data\IGUI\Cfg\MPTable\killed_ca.paa'/>"] joinString ""), (0.5 * _sizeFactor * KF_var_fontSize)]
                        };
                        case (_type == "Fall Damage"): {
                            format [([_imageBasePath, "Ui_f\data\GUI\Rsc\RscDisplayMain\menu_singleplayer_ca.paa'/>"] joinString ""), str (0.63 * _sizeFactor * KF_var_fontSize)]
                        };
                        default {
                            format [
                                "<img size='%1' image='%2'/>",
                                (
                                    if (((_type find "Vehicle") != -1) || {_type == "Hand Grenade"}) then {
                                        format ["%1' color='#dddddd", (str (0.47 * _sizeFactor * KF_var_fontSize))]
                                    } else {
                                        format ["%1' color='#ffffff", (str (0.64 * _sizeFactor * KF_var_fontSize))]
                                    }
                                ),
                                ([_source] call KF_fnc_GetPicture)
                            ]
                        };
                    }
                ),
                (
                    if (KF_var_picturesBulletIcon && {_type in (["Vehicle Weapon", "Weapon Headshot", "Weapon Grenade Launcher", "Vehicle Grenade Launcher", "Vehicle Weapon Headshot"])}) then {
                        format [([_imageBasePath, "Ui_f\data\GUI\Rsc\RscDisplayArsenal\itemMuzzle_ca.paa'/>"] joinString ""), str (0.39 * _sizeFactor * KF_var_fontSize)]
                    } else {
                        ""
                    }
                ),
                (
                    switch true do {
                        case (KF_var_PicturesHeadIcon && {_type in ["Weapon Headshot", "Vehicle Weapon Headshot"]}): {
                            format [([_imageBasePath, "Ui_f\data\GUI\Rsc\RscDisplayArsenal\face_ca.paa'/>"] joinString ""), str (0.45 * _sizeFactor * KF_var_fontSize)]
                        };
                        case (_type in ["Vehicle Grenade Launcher", "Weapon Grenade Launcher"]): {
                            format [([_imageBasePath, "Ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoThrow_ca.paa'/>"] joinString ""), str (0.53 * _sizeFactor * KF_var_fontSize)]
                        };
                        case (_type == "Vehicle Hit"): {
                            format [([_imageBasePath, "Ui_f\data\GUI\Rsc\RscDisplayMain\menu_singleplayer_ca.paa'/>"] joinString ""), str (0.63 * _sizeFactor * KF_var_fontSize)]
                        };
                        case (_type == "Fall Damage"): {
                            format [([_imageBasePath, "Ui_f\data\IGUI\Cfg\Cursors\getIn_ca.paa'/>"] joinString ""), str (0.63 * _sizeFactor * KF_var_fontSize)]
                        };
                        case ((_type find "Explos") != -1): {
                            format [([_imageBasePath, "Ui_f\data\GUI\Rsc\RscDisplayArsenal\cargoPut_ca.paa'/>"] joinString ""), str (0.53 * _sizeFactor * KF_var_fontSize)]
                        };
                        default {""};
                    }
                )
            ]
        }
    ) joinString (format ["<t size='%1'> | </t>", (0.53 * _sizeFactor * KF_var_fontSize)])
};

KF_fnc_formatSelections = {
    params ["_selections", ["_showAt", false]];

    _selectionNames = (_selections apply {[_x select 0] call KF_fnc_getSelectionName}) select {_x != ""};
    _selectionNames = _selectionNames arrayIntersect _selectionNames;

    {
        _x params ["_toReplace", "_toReplaceWith"];

        if (({!(_x in _selectionNames)} count _toReplace) == 0) then {
            _selectionNames = _selectionNames select {!(_x in _toReplace)};
            _selectionNames pushBack _toReplaceWith;
        };
    } forEach KF_var_selectionFoldRules;

    if !(_selectionNames isEqualTo []) then {
        _selectionsString = _selectionNames joinString ", ";

        if _showAt then {
            _selectionsString = ["at", _selectionsString] joinString " ";
        };

        _selectionsString
    } else {
        ""
    }
};

KF_fnc_FormatHitsText = {
    params ["_distance", "_typeSourceSelArr", "_isTk", "_showDelims", "_showSelections"];

    (
        [
            (if (_distance != -1) then {[(str (floor _distance)), "m"] joinString ""} else {""}),
            (
                (
                    (
                        _typeSourceSelArr apply {
                            _x params ["_type", "_source", "_selections"];
                            (
                                (
                                    [
                                        (
                                            if (_source != "") then {
                                                if (_type != "Explosion") then {
                                                    [_source] call KF_fnc_GetDisplayName
                                                } else {
                                                    _type
                                                }
                                            } else {
                                                ""
                                            }
                                        ),
                                        (
                                            if !(_type in ["Weapon", "Explosion", "Explosive", "Hand Grenade", "Tombstone"]) then {
                                                format ["(%1)", _type]
                                            } else {
                                                ""
                                            }
                                        ),
                                        (if _showSelections then {[_selections, true] call KF_fnc_formatSelections} else {""})
                                    ]
                                ) select {_x != ""}
                            ) joinString " "
                        }
                    ) select {_x != ""}
                ) joinString (if _showDelims then {" | "} else {" "})
            ),
            (if (KF_var_ShowFriendlyFire && _isTk) then {"<t color='#ff0000'>Friendly Fire</t>"} else {""})
        ] select {_x != ""}
    ) joinString (if _showDelims then {" | "} else {" "})
};

KF_fnc_unitIsValid = {
    params ["_unit"];

    (
        !(isNil "_unit") &&
        {!(isNull _unit)} &&
        {(_unit isKindOf "CAManBase") || {unitIsUAV _unit}} &&
        {!([_unit] call KF_fnc_isUavAi)} &&
        {_var = _unit getVariable "KF_var_hits"; !(isNil "_var")}
    )
};

KF_fnc_OnKill = {
    params ["_unit", "_killer", "_instigator", "_parUnit", "_externalUnitDeathCall", "_tryFindKillerByThisAmmo"];

    _unitIsUav = unitIsUAV _unit;
    _hits = _unit getVariable ["KF_var_hits", []];
    _parHits = _parUnit getVariable ["KF_var_hits", []];

    if !(_parHits isEqualTo []) then {
        _hits append _parHits;
        _hits = [_hits, [], {_x select 6}, "ASCEND"] call BIS_fnc_sortBy;
    };

    if !([_killer] call KF_fnc_unitIsValid) then {
        _killer = _instigator;
    };

    if ((_killer isEqualTo _unit) && {_tryFindKillerByThisAmmo != ""}) then {
        _pos = _hits findIf {
            _x params ["_hitter", "_ammo"];
            (!(_hitter isEqualTo _killer) && {_ammo == _tryFindKillerByThisAmmo})
        };
        
        if (_pos != -1) then {
            _killer = (_hits select _pos) select 0;
        };
    };

    _killIsTk = ((_killer getVariable ["KF_var_side", sideUnknown]) == (_unit getVariable ["KF_var_side", sideUnknown])) && {(rating _unit) >= -2000};

    _typeOfKilledVehicle = if (!(_killer isEqualTo _unit) && {_killer isKindOf "CAManBase"}) then {
        [_unit, _parUnit, _killer, _killIsTk, _externalUnitDeathCall, _unitIsUav] call {
            params ["_unit", "_parUnit", "_killer", "_killIsTk", "_externalUnitDeathCall", "_unitIsUav"];
            _typeOfParUnit = typeof _parUnit;

            (switch true do {
                case (unitIsUAV _unit): {
                    _wasKilled = _unit getVariable ["KF_var_wasKilled", false];
                    _unit setVariable ["KF_var_wasKilled", true];
                    
                    if _wasKilled then {
                        [[0, 0, 0, 0, 0], ""]
                    } else {
                        _typeOfUnit = typeof _unit;

                        switch true do {
                            case (_unit isKindOf "Car_F"): {[[0, 1, 0, 0, 0], _typeOfUnit]};
                            case ((_unit isKindOf "Tank_F") || {_unit isKindOf "StaticWeapon"} || {_unit isKindOf "Ship_F"}): {[[0, 0, 1, 0, 0], _typeOfUnit]};
                            case ((_unit isKindOf "Helicopter_Base_F") || {_unit isKindOf "Plane_Base_F"}): {[[0, 0, 0, 1, 0], _typeOfUnit]};
                            default {[[0, 0, 0, 0, 0], ""]};
                        }                        
                    }
                };
                case ((isNull _parUnit) || {alive _parUnit} || {
                    _wasKilled = _parUnit getVariable ["KF_var_wasKilled", false];
                    _parUnit setVariable ["KF_var_wasKilled", true];

                    _wasKilled
                }): {[[1, 0, 0, 0, 0], ""]};
                case (_parUnit isKindOf "Car_F"): {[[1, 1, 0, 0, 0], _typeOfParUnit]};
                case ((_parUnit isKindOf "Tank_F") || {_parUnit isKindOf "StaticWeapon"} || {_parUnit isKindOf "Ship_F"}): {[[1, 0, 1, 0, 0], _typeOfParUnit]};
                case ((_parUnit isKindOf "Helicopter_Base_F") || {_parUnit isKindOf "Plane_Base_F"}): {[[1, 0, 0, 1, 0], _typeOfParUnit]};
                default {[[1, 0, 0, 0, 0], _typeOfParUnit]};
            }) params ["_diffScoresAbs", "_typeOfKilledVehicle"];

            if (_unitIsUav || _externalUnitDeathCall || KF_var_addScoreForUnitDeaths) then {
                _scoreToAdd = _diffScoresAbs apply {_x * ([1, -1] select _killIsTk)};
                _killer addPlayerScores _scoreToAdd;
                _ratingSum = 0;
                {_ratingSum = _ratingSum + _x;} forEach _scoreToAdd;
                [_killer, (1000 * _ratingSum)] remoteExecCall ["addRating", _killer];
            };

            _typeOfKilledVehicle
        }
    } else {
        ""
    };

    ([_hits, [], _killer] call KF_fnc_CalculateHitData) params ["_hitData", "_hitters"];

    _killdata = _hitData select {(_x select 0) isEqualTo _killer};
    _tombstoneKilldata = [_killer, [["Tombstone", "", []]], -1];

    if !(_killData isEqualTo []) then {
        _killData = _killData select 0;

        if ((count (_killdata select 1)) == 0) then {
            _pos = _hitData find _killData;

            if (_pos != -1) then {
                _hitData set [_pos, _tombstoneKilldata];
            } else {
                _hitData pushBack _tombstoneKilldata;
            };

            _killData = _tombstoneKilldata;
        };
    } else {
        _hitData pushBack _tombstoneKilldata;
        _killData = _tombstoneKilldata;
    };

    _killData params ["", "_killerTypeSourceSelArr", "_killDistance"];

    if (KF_var_MidFeedEnabled && {_unitIsUav || _externalUnitDeathCall || KF_var_showUnitDeathsInMidfeed}) then {
        {
            _x params ["_hitter", "_hitterTypeSourceSelArr", "_hitterDistance"];

            _assistIsKill = _hitter == _killer;
            _assistIsTk = ((_hitter getVariable ["KF_var_side", sideUnknown]) == (_unit getVariable ["KF_var_side", sideUnknown])) && {(rating _unit) >= -2000};

            [format [
                "<t size='%1' shadow='1' shadowOffset='%2'><t color='%3'>You</t> %4 <t color='%5'>%6</t> %7</t>",
                (0.6 * KF_var_fontSize),
                (0.05 * KF_var_fontSize),
                (if KF_var_MidFeedYouColorYellow then {"#ffd400"} else {"#ffffff"}),
                (if _assistIsKill then {["killed", "finally killed"] select (!(_externalUnitDeathCall || {_unitIsUav}) && {KF_var_showFinallyKilledForUnitDeaths})} else {format [
                    "assisted <t color='%1'>%2</t> to%3 kill",
                    ([_killer getVariable ["KF_var_side", sideUnknown]] call KF_fnc_GetSidesHexColor),
                    (_killer getVariable ["KF_var_name", "Error: no unit"]),
                    (["", " finally"] select (!_externalUnitDeathCall && KF_var_showFinallyKilledForUnitDeaths))
                ]}),
                ([_unit getVariable ["KF_var_side", sideUnknown]] call KF_fnc_GetSidesHexColor),
                (_unit getVariable ["KF_var_name", "Error: no unit"]),
                ((
                    [[_hitterDistance, [], _assistIsTk, false, false] call KF_fnc_FormatHitsText] +
                    ((KF_var_AddMidFeedInfo apply {[_unit, _hitter, _assistIsKill, _assistIsTk, _hitterDistance, _hitterTypeSourceSelArr, _typeOfKilledVehicle, _externalUnitDeathCall] call _x}) select {_x != ""})
                ) joinString " ")
            ]] remoteExecCall ["KF_fnc_AddMidFeedLine", _hitter];
        } forEach ((if KF_var_MidFeedAssists then {_hitData} else {[_killData]}) select {(alive (_x select 0)) && {isPlayer (_x select 0)}});
    };

    if (KF_var_KillfeedEnabled && {_unitIsUav || _externalUnitDeathCall || KF_var_showUnitDeathsInKillfeed}) then {
        _addKillInfoArgArr = [_unit, _killer, _killIsTk, _killDistance, _killerTypeSourceSelArr];

        [
            [format [
                "<t size='%1' align='right' shadow='1' shadowOffset='%2'>%3%4</t>",
                (0.5 * KF_var_fontSize),
                (0.05 * KF_var_fontSize),
                (format [
                    (if KF_var_KillfeedInversed then {"%1 %2 %3"} else {"%3 %2 %1"}),
                    (format ["<t color='%1'>%2</t>", ([_unit getVariable ["KF_var_side", sideUnknown]] call KF_fnc_GetSidesHexColor), (_unit getVariable ["KF_var_name", "Error: no unit"])]),
                    ([_killerTypeSourceSelArr, 1, true] call KF_fnc_FormatHitsPicture),
                    ((((([_killer] + ((_hitters - [_killer]) select [0, 1])) apply {
                        format ["<t color='%1'>%2</t>", ([_x getVariable ["KF_var_side", sideUnknown]] call KF_fnc_GetSidesHexColor), (_x getVariable ["KF_var_name", "Error: no unit"])]
                    }) + [if (((count _hitters) - 2) > 0) then {str ((count _hitters) - 2)} else {""}]
                    ) select {_x != ""}) joinstring " + ")
                ]),
                ((KF_var_AddKillFeedInfo apply {_addKillInfoArgArr call _x}) joinString "")
            ]],
            {if (!isNil "KF_fnc_AddKillFeedLine") then {_this call KF_fnc_AddKillFeedLine;};}
        ] remoteExecCall ["call", 0];
    };

    _hitDataCopy = _hitData; // I have to do this, because _hitdata magically shrinks to size 1 after this

    if (KF_var_DeathFeedEnabled && {_unitIsUav || _externalUnitDeathCall || KF_var_showUnitDeathsInDeathFeed}) then {
        _deathFeedUnits = [];
        
        if (unitIsUAV _unit) then {
            _deathFeedUnits = _unit getVariable "KF_var_parUAVControlUnits";
        } else {
            _deathFeedUnits = [_unit];
        };

        _deathFeedUnits = _deathFeedUnits select {isPlayer _x};

        if !(_deathFeedUnits isEqualTo []) then {
            _hitsKiller = [];

            if !(_killer in [_unit, _parUnit]) then {
                _hitsKiller = _killer getVariable ["KF_var_hits", []];
                _hitsKiller insert [0, ((objectParent _killer) getVariable ["KF_var_hits", []]), false];
            };

            _unitsHitSelections = [];
            
            {
                _unitsHitSelections insert [-1, (_x select 2), true];
            } forEach _killerTypeSourceSelArr;

            _unitsHitSelections = _unitsHitSelections arrayIntersect _unitsHitSelections;
            _selectionsText = [_unitsHitSelections, false] call KF_fnc_formatSelections;

            {
                _deathFeedUnit = _x;

                ([_hitsKiller, [_deathFeedUnit], _deathFeedUnit] call KF_fnc_CalculateHitData) params ["_counterHitData"];
                (_counterHitData select 0) params ["", "_counterTypeSourceSelArr", "_counterDistance"];

                _counterHitsText = if (_counterTypeSourceSelArr isEqualTo []) then {""} else {
                    if (_counterTypeSourceSelArr isEqualTo []) then {""} else {
                        format [
                            "<t color='#ffd400'>You</t> also hit <t color='%1'>%2</t> [%3]",
                            ([_killer getVariable ["KF_var_side", sideUnknown]] call KF_fnc_GetSidesHexColor),
                            (_killer getVariable ["KF_var_name", "Error: no unit"]),
                            ([_counterDistance, _counterTypeSourceSelArr, _killIsTk, true, true] call KF_fnc_FormatHitsText)
                        ]
                    }
                };

                _assistsText = (
                    (_hitDataCopy select {!((_x select 0) isEqualTo _killer)}) apply {
                        _x params ["_hitter", "_hitterTypeSourceSelArr", "_hitterDistance"];

                        _assistIsTk = if (_hitter isEqualTo _deathFeedUnit) then {false} else {
                            ((_hitter getVariable ["KF_var_side", sideUnknown]) == (_unit getVariable ["KF_var_side", sideUnknown])) && {(rating _unit) >= -2000}
                        };

                        format [
                            "<t color='%1'>%2</t> [%3]",
                            (if (_hitter isEqualTo _deathFeedUnit) then {"#ffd400"} else {[_hitter getVariable ["KF_var_side", sideUnknown]] call KF_fnc_GetSidesHexColor}),
                            (if (_hitter isEqualTo _deathFeedUnit) then {"You"} else {_hitter getVariable ["KF_var_name", "Error: no unit"]}),
                            ([_hitterDistance, _hitterTypeSourceSelArr, _assistIsTk, true, true] call KF_fnc_FormatHitsText)
                        ]
                    }
                ) joinString "<br/>";

                [
                    [
                        format [
                            "<t align='left' size='%1' shadow='1' shadowOffset='%2'>%3 killed by %12<t color='%4'>%5</t>%6:<br/>%7<br/><br/>%8%9%10<br/><br/>%11</t>",
                            (0.6 * KF_var_fontSize),
                            (0.05 * KF_var_fontSize),
                            (if (unitIsUAV _unit) then {format ["<t color='#ffd400'>Your</t> <t color='%1'>%2</t> was",
                                ([_unit getVariable ["KF_var_side", sideUnknown]] call KF_fnc_GetSidesHexColor),
                                (_unit getVariable ["KF_var_name", "Error: no unit"])
                            ]} else {"<t color='#ffd400'>You</t> were"}),
                            ([_killer getVariable ["KF_var_side", sideUnknown]] call KF_fnc_GetSidesHexColor),
                            (_killer getVariable ["KF_var_name", "Error: no unit"]),
                            (if (_killDistance == -1) then {""} else {format [" from %1m", (round _killDistance)]}),
                            ([_killerTypeSourceSelArr, 2.5, false] call KF_fnc_FormatHitsPicture),
                            (if (_selectionsText != "") then {format ["%1 got hit at the body parts: %2<br/>",
                                (if (unitIsUAV _unit) then {format ["<t color='%1'>It</t>", ([_unit getVariable ["KF_var_side", sideUnknown]] call KF_fnc_GetSidesHexColor)]} else {"<t color='#ffd400'>You</t>"}),
                                _selectionsText
                            ]} else {""}),
                            (if (_counterHitsText != "") then {_counterHitsText} else {""}),
                            (if (_assistsText != "") then {["<br/><br/><t underline='true'>Assistants:</t><br/>", _assistsText] joinString ""} else {""}),
                            ((KF_var_AddDeathFeedInfo apply {[_deathFeedUnit, _killer, _killIsTk, _killDistance, _hitDataCopy, _counterDistance, _counterTypeSourceSelArr, _externalUnitDeathCall] call _x}) joinString ""),
                            (if (isNil "SC_var_serverInitDone") then {""} else {"[" + (str (_killer getVariable ["SC_var_rank", 1])) + "] "})
                        ]
                    ],
                    {if !(isNil "KF_fnc_addDeathFeed") then {_this spawn KF_fnc_addDeathFeed;};}
                ] remoteExecCall ["call", _deathFeedUnit];
            } forEach _deathFeedUnits;
        };
    };

    if ((KF_var_killInfoIncludeTK || !_killIsTk) && {_unitIsUav || _externalUnitDeathCall || KF_var_showUnitDeathsInKillInfo}) then {
        _killer setVariable ["KF_var_killsInARow", ((_killer getVariable ["KF_var_killsInARow", 0]) + 1)];
        [_killer, _unit, (_hitters - [_killer]), _killerTypeSourceSelArr, _killDistance] call KF_fnc_ChangeKillInfo;
    };

    _unit setVariable ["KF_var_killsInARow", 0];
};

KF_fnc_ChangeKillInfo = {
    params ["_killer", "_unit", "_hitters", "_typeSourceSelArr", "_distance"];

    _kIAR = _killer getVariable ["KF_var_killsInARow", 0];
    _mK = (KF_var_MostKillsInARow select 0) select 2;

    if (_kIAR >= _mK) then {
        if (_kIAR > _mK) then {
            KF_var_MostKillsInARow = [];
        } else {
            _pos = (KF_var_MostKillsInARow apply {_x select 0}) find (_killer getVariable ["KF_var_name", "Error: no unit"]);

            if (_pos != -1) then {
                KF_var_MostKillsInARow deleteAt _pos;
            };
        };

        KF_var_MostKillsInARow pushBack [(_killer getVariable ["KF_var_name", "Error: no unit"]), (_killer getVariable ["KF_var_side", sideUnknown]), _kIAR];
    };

    if (_distance != -1) then {
        _longestDistance = (KF_var_LongestKills select 0) select 6;

        if (_distance >= _longestDistance) then {
            if (_distance > _longestDistance) then {
                KF_var_LongestKills = [];
            } else {
                _pos = (KF_var_LongestKills apply {_x select 0}) find (_killer getVariable ["KF_var_name", "Error: no unit"]);

                if (_pos != -1) then {
                    KF_var_LongestKills deleteAt _pos;
                };
            };

            KF_var_LongestKills pushBack [
                (_killer getVariable ["KF_var_name", "Error: no unit"]),
                (_killer getVariable ["KF_var_side", sideUnknown]),
                (_unit getVariable ["KF_var_name", "Error: no unit"]),
                (_unit getVariable ["KF_var_side", sideUnknown]),
                (_hitters apply {[(_x getVariable ["KF_var_name", "Error: no unit"]), (_x getVariable ["KF_var_side", sideUnknown])]}),
                _typeSourceSelArr,
                _distance
            ];
        };
    };
};

KF_fnc_DisplayKillInfo = {
    if ((((KF_var_MostKillsInARow select 0) select 2) != 0) && (((KF_var_LongestKills select 0) select 6) != 0)) then {
        _id = [[([
                    "<t size='0.75' align='center' shadow='1' shadowOffset='0.05'>Longest Kill: ",
                    ((KF_var_LongestKills apply {
                        _x params ["_killerName", "_killerSide", "_unitName", "_unitSide", "_hittersNameArr", "_typeSourceSelArr", "_distance"];
                        format [
                            "%4 %3 <t color='%1'>%2</t> %5",
                            ([_unitSide] call KF_fnc_GetSidesHexColor),
                            _unitName,
                            ([_typeSourceSelArr, 1.5, true] call KF_fnc_FormatHitsPicture),
                            (((([[_killerName, _killerSide]]) apply {format ["<t color='%1'>%2</t>", ([_x select 1] call KF_fnc_GetSidesHexColor), (_x select 0)]}) select {_x != ""}) joinstring " + "),
                            (format ["%1m", ([_distance, 1] call BIS_fnc_cutDecimals)])
                        ]
                    }) joinString "<br/>"),
                    "<br/>Most Kills in a row: ",
                    ((KF_var_MostKillsInARow apply {
                        _x params ["_unitName", "_unitSide", "_killNumber"];
                        format [
                            "<t color='%1'>%2</t> %3 Kills",
                            ([_unitSide] call KF_fnc_GetSidesHexColor),
                            _unitName,
                            _killNumber
                        ]
                    }) joinString ", "),
                    "</t>"
                ] joinString ""),
                0, -0.02, KF_var_killInfoDuration, 0, 0, 700
            ],
            {if hasInterface then {_this spawn BIS_fnc_dynamicText;};}
        ] remoteExecCall ["call", 0, true];

        if !(isNil "_id") then {
            [_id] spawn {
                params ["_id"];

                sleep KF_var_killInfoDuration;
                remoteExecCall ["", _id];

                [["", 0, 0, 0, 0, 0, 700],{if hasInterface then {_this spawn BIS_fnc_dynamicText;};}] remoteExecCall ["call", 0];
            };
        };
    };
};

KF_fnc_EntityKilled = {
    params ["_unit", "_killer", "_instigator", ["_externalUnitDeathCall", false], ["_tryFindKillerByThisAmmo", ""]];

    if (
        ([_unit] call KF_fnc_unitIsValid) &&
        {time - (_unit getVariable ["KF_var_initTime", time]) > 2} &&
        {
            KF_var_handleUnitDeaths ||
            {!(_unit isKindOf "CAManBase")} ||
            {_externalUnitDeathCall && {!(_unit getVariable ["KF_var_calledKilled", false])}}
        }
    ) then {
        _parUnit = objectParent _unit;
        _parKiller = objectParent _killer;
        _parInstigator = objectParent _instigator;

        if (unitIsUAV _unit) then {
            _unit setVariable ["KF_var_parUAVControlUnits", ([_unit, true] call KF_fnc_UAVControlUnits)];
        };
        
        if (unitIsUAV _killer) then {
            _uavCtrlKiller = [_killer, "DRIVER", "GUNNER"] call KF_fnc_UAVControl;

            if ((isNull _uavCtrlKiller) || {_unit isEqualTo _killer}) then {
                _instigator = _killer;
            } else {
                _instigator = _uavCtrlKiller;
                _killer = _uavCtrlKiller;
            };
        };

        if !([_instigator] call KF_fnc_unitIsValid) then {
            _instigator = _unit;
        };

        _killer = [_killer] call KF_fnc_getRespawnedEntity;
        _instigator = [_instigator] call KF_fnc_getRespawnedEntity;

        [_unit, _killer, _instigator, _parUnit, _externalUnitDeathCall, _tryFindKillerByThisAmmo] spawn {sleep (1/3); _this call KF_fnc_OnKill;};
        _unit setVariable ["KF_var_calledKilled", true];
    };
};

KF_fnc_addHandleScore = {
    params ["_unit"];

    _id = _unit getVariable ["KF_var_handleScoreEhId", -1];
    if (_id != -1) then {_unit removeEventHandler ["HandleScore", _id];};
    _id = _unit addEventHandler ["HandleScore", {false}];
    _unit setVariable ["KF_var_handleScoreEhId", _id];
};

KF_fnc_entityHealed = {
    params ["_entity"];

    _entity setVariable ["KF_var_hits", []];
};

KF_fnc_EntityInitServer = {
    params ["_entity"];

    _startTime = time;
    waitUntil {(isNil "_entity") || {!(isNull _entity)} || {(time - _startTime) > 3}};
    if ((isNil "_entity") || {isNull _entity}) exitWith {};

    [_entity] call {
        params ["_entity"];

        if (isNil {_entity getVariable "KF_var_initDone"} && {(name _entity) != ""}) then {
            _entity setVariable ["KF_var_initDone", true];

            if ((_entity isKindOf "CAManBase") || {unitIsUAV _entity}) then {
                [_entity] call KF_fnc_addHandleScore;

                {_entity setVariable _x;} forEach [
                    ["KF_var_name", ([_entity] call KF_fnc_getName), true],
                    ["KF_var_side", (side (group _entity))],
                    ["KF_var_killsInARow", 0],
                    ["KF_var_calledKilled", false],
                    ["KF_var_initTime", time]
                ];
            };

            _entity setVariable ["KF_var_hits", []];

            _id = _entity getVariable ["KF_var_mpHitEhId", -1];
            if (_id != -1) then {_entity removeMPEventHandler ["MPHit", _id];};
            _id = _entity addMPEventHandler ["MPHit", {if isServer then {_this call KF_fnc_mpHit;};}];
            _entity setVariable ["KF_var_mpHitEhId", _id];

            [[_entity], {
                waitUntil {!(isNil "KF_var_clientServerInitDone")};
                _this call KF_fnc_EntityInitClientServer;
            }] remoteExecCall ["spawn", 0];
        };
    };
};

KF_fnc_AddHitPartServer = {
    params ["_entity"];

    [[_entity], {
        if !(isNil "KF_var_clientServerInitDone") then {
            _this call KF_fnc_AddHitPartClientServer;
        };
    }] remoteExecCall ["call", 0];
};

KF_fnc_getRespawnedEntity = {
    params ["_entity"];

    _var = _entity getVariable "KF_var_respawnedEntity";

    while {!(isNil "_var") && {!(isNull _var)}} do {
        _entity = _var;
        _var = _entity getVariable "KF_var_respawnedEntity";
    };

    _entity
};

KF_fnc_EntityRespawned = {
    params ["_newEntity", "_oldEntity"];

    _oldEntity setVariable ["KF_var_respawnedEntity", _newEntity];
    _newEntity setVariable ["KF_var_wasKilled", nil];
    _newEntity setVariable ["KF_var_calledKilled", false];

    if (_newEntity isKindOf "CAManBase") then {
        [_newEntity] call KF_fnc_addHandleScore;
    };

    if !(isNil {_newEntity getVariable "KF_var_hits"}) then {
        _newEntity setVariable ["KF_var_hits", []];
    };

    [_newEntity] call KF_fnc_AddHitPartServer;
};

KF_fnc_addHitPartToAllEntities = {
    {
        [_x] call KF_fnc_AddHitPartServer;
    } forEach (entities [["AllVehicles"], ["Animal"], true, false]);
};

KF_fnc_startKillfeed = {
    if !KF_var_running then {
        {
            [_x] spawn KF_fnc_EntityInitServer;
        } forEach (entities [["AllVehicles"], ["Animal"], true, false]);

        addMissionEventHandler ["EntityCreated", {
            params ["_entity"];

            if ((_entity isKindOf "AllVehicles") && {!(_entity isKindOf "Animal")}) then {
                [_entity] spawn KF_fnc_EntityInitServer;
            };
        }];

        addMissionEventHandler ["EntityRespawned", {
            _this call KF_fnc_EntityRespawned;
        }];

        addMissionEventHandler ["EntityKilled", {
            (_this select [0, 3]) call KF_fnc_EntityKilled;
        }];

        [[], {if hasInterface then {waitUntil {!(isNil "KF_var_clientInitDone")}; _this call KF_fnc_startKillfeedClient;};}] remoteExecCall ["spawn", 0, true];

        if !isMultiplayer then {
            addMissionEventHandler ["Loaded", {if !(isNil "KF_var_serverInitDone") then {call KF_fnc_addHitPartToAllEntities;};}];
        };

        KF_var_running = true;
        publicVariable "KF_var_running";
    };
};

KF_var_serverInitDone = true;
publicVariable "KF_var_serverInitDone";