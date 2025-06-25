player enableSimulationGlobal false;
0 fadeSound 0;

if (!isServer && !didJIP) then {
    1012 cutText ["", "BLACK FADED", 999999, true];
    ["pease_reenter", true, 0, false, false] call BIS_fnc_endMission;
};

{deleteVehicle _x;} forEach ((entities [["CAManBase"], [], true, false]) select {name _x == ""});

{
    _clientFilePath = "modsIntegrated\" + _x + "\scripts\fnc_client.sqf";
    _clientServerFilePath = "modsIntegrated\" + _x + "\scripts\fnc_clientServer.sqf";
    _serverFilePath = "modsIntegrated\" + _x + "\scripts\fnc_server.sqf";

    if (fileExists _clientServerFilePath) then {
        call (compile (preprocessFileLineNumbers _clientServerFilePath));
    };

    if (fileExists _clientFilePath) then {
        call (compile (preprocessFileLineNumbers _clientFilePath));
    };
} forEach [
    "allowdamageglobal",
    "killfeed",
    "dynamicweather",
    "tdicons",
    "disablestamina",
    "disabletacticalview",
    "holster",
    "jump",
    "killfeed",
    "lagswitchdetection",
    "mapmarker"
];

{
    call (compile (preprocessFileLineNumbers _x));
} forEach [
    "SC\gameMode\clientServer.sqf",
    "SC\gameMode\client\client.sqf",
    "SC\gameMode\client\clientLoops.sqf",
    "SC\gameMode\client\hotKeys.sqf",
    "SC\gui\gui.sqf",
    "SC\gui\guiLoops.sqf",
    "SC\gui\guiUpdate.sqf",
    "SC\gui\mapIcons.sqf",
    "SC\gui\TDIcons.sqf",
    "SC\rankSystem\client.sqf",
    "SC\rankSystem\clientServer.sqf"
];

waitUntil {!(isNull (findDisplay 46))};

cutText ["", "BLACK FADED", 99999999];
["Loading, please wait...", [safeZoneX, safeZoneW], [((safeZoneH / 2) + safezoneY), safeZoneH], 9999, 0, 0, 1011] spawn BIS_fnc_dynamicText;

call (compile preprocessFileLineNumbers "SC\gameMode\client\initVars.sqf");

[SC_var_hudEnabled] call SC_fnc_setHud;

[player] join grpNull;
showSubtitles false;
enableRadio false;
enableSentences false;
enableTeamSwitch false;
enableDynamicSimulationSystem false;

0 enableChannel [true, false];
1 enableChannel [true, false];
2 enableChannel [true, false];
3 enableChannel [true, true];
4 enableChannel [true, true];
5 enableChannel [true, true];

[player, false] call ADG_fnc_allowDamage;

waitUntil {!(isNil "SC_var_serverInitDone")};

[] spawn {
    _baseMarker = "SC_var_" + (toLower (str (side (group player)))) + "Respawn";
    _dir = markerDir _baseMarker;
    _respawnPos = getMarkerPos _baseMarker;
    player enableSimulationGlobal true;

    waitUntil {
        player setPos _respawnPos;
        sleep 1;

        ((player distance _respawnPos) < 2)
    };

    player setDir _dir;
    player switchMove "amovpercmstpsnonwnondnon";

    [[player], {
        waitUntil {!(isNil "SC_var_serverInitDone")};
        _this call SC_fnc_playerServer;
    }] remoteExecCall ["spawn", 2];

    call {
        [SC_var_lastLoadout] call SC_fnc_setLoadout;
        call SC_fnc_adjustLoadoutAndInfo;

        ["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;
        ["", 0, 0, 0, 0, 0, 1011] spawn BIS_fnc_dynamicText;
        player setUnitTrait ["Medic", ("MEDC" in SC_var_perks)];
        player setUnitTrait ["Engineer", true];
        player setUnitTrait ["UAVHacker", true];

        {
            [_x] call SC_fnc_addHandleHeal;
        } forEach (entities [["CAManBase"], [], true, false]);

        player addEventHandler ["killed", {_this spawn SC_fnc_onKilled;}];
        player addEventHandler ["Respawn", {_this spawn SC_fnc_onRespawn;}];
        player addEventHandler ["Put", {_this call SC_fnc_put;}];
        player addEventHandler ["InventoryOpened", {_this call SC_fnc_onInventoryOpened}];
        player addEventHandler ["VisionModeChanged", {_this call SC_fnc_visionModeChanged;}];
        addMissionEventHandler ["Map", {_this call SC_fnc_map;}];
        [missionNamespace, "arsenalOpened", {_this call SC_fnc_arsenalOpened;}] call BIS_fnc_addScriptedEventHandler;
        inGameUISetEventHandler ["Action", SC_fnc_actionStr];

        disableSerialization;
        (findDisplay 46) displayAddEventHandler ["KeyDown", {_this call SC_fnc_keyEarplugs}];
        (findDisplay 46) displayAddEventHandler ["KeyDown", {_this call SC_fnc_keyHud}];
        (findDisplay 46) displayAddEventHandler ["KeyDown", {_this call SC_fnc_keySettingsDialog}];
        (findDisplay 46) displayAddEventHandler ["KeyDown", {_this call SC_fnc_keyPanel}];

        if ((((getArray (missionConfigFile >> "params" >> "thirdPerson" >> "texts")) select ("thirdPerson" call BIS_fnc_getParamValue)) == "Disabled") && ((difficultyOption "thirdPersonView") == 1)) then {
            SC_var_forceFPPLoopScript = [] spawn SC_fnc_forceFPPLoop;
            (findDisplay 46) displayAddEventHandler ["KeyDown", {params ["", "_key"]; if (_key in (actionKeys "personView")) then {true};}];
            SC_var_viewSwitchable = false;
        } else {
            SC_var_viewSwitchable = (difficultyOption "thirdPersonView") == 1;
            SC_var_lastView = if SC_var_viewSwitchable then {profileNameSpace getVariable ["SC_var_lastView", "EXTERNAL"]} else {"INTERNAL"};
        };

        if (((getArray (missionConfigFile >> "params" >> "thermalVision" >> "texts")) select ("thermalVision" call BIS_fnc_getParamValue)) == "Disabled") then {
            SC_var_disableThermalLoopScript = [] spawn SC_fnc_disableThermalLoop;
        };

        SC_var_ranksystemLoopScript = [] spawn SC_fnc_rankSystemLoop;
        SC_var_inventoryDisabledCooldownLoopScript = [] spawn SC_fnc_inventoryDisabledCooldownLoop;
        SC_var_respawnPositionsLoopScript = [] spawn SC_fnc_respawnPositionsLoop;
        SC_var_spectatorMapDrawEHLoopScript = [] spawn SC_fnc_spectatorMapDrawEHLoop;
        SC_var_cameraMapDrawEHLoopScript = [] spawn SC_fnc_cameraMapDrawEHLoop;
        SC_var_uavTerminalLoopScript = [] spawn SC_fnc_uavTerminalLoop;
        SC_var_spectatorNightVisionLoopScript = [] spawn SC_fnc_spectatorNightVisionLoop;
        SC_var_cameraNightVisionLoopScript = [] spawn SC_fnc_cameraNightVisionLoop;
        SC_var_staminaSystemLoopScript = [] spawn SC_fnc_staminaSystemLoop;
        SC_var_disableLeftGpsLoopScript = [] spawn SC_fnc_disableLeftGpsLoop;
        SC_var_broadcastCameraViewLoopScript = [] spawn SC_var_broadcastCameraViewLoop;

        [] spawn {
            waitUntil {
                !(isNil "SC_fnc_getGroupUnits") &&
                {!(isNil "MM_fnc_getGroupUnits")} &&
                {!(isNil "TDI_fnc_getGroupUnits")} &&
                {!(isNil "KF_fnc_getGroupUnits")}
            };

            MM_fnc_getGroupUnits = SC_fnc_getGroupUnits;
            TDI_fnc_getGroupUnits = SC_fnc_getGroupUnits;
            KF_fnc_getGroupUnits = SC_fnc_getGroupUnits;
        };

        [] spawn {
            waitUntil {!(isNil "TDI_var_clientInitDone")};
            TDI_var_gatherDrawArraysFncs pushBack "SC_fnc_updateTDIconsDrawArray";
        };

        [] spawn {
            waitUntil {!(isNil "MM_var_clientInitDone")};
            MM_var_gatherDrawArrFncs pushBack "SC_fnc_updateMapIconsDrawArray";
        };

        player setVariable ["SC_var_clientInitDone", true];
        [] spawn SC_fnc_onRespawn;
    };
};