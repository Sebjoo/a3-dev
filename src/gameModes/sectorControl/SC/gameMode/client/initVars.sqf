SC_var_playerUid = call (compile (getplayerUid player));
SC_var_xpRanks = [3000];
for "_i" from 2 to 1000 do {
    SC_var_xpRanks pushBack (1000 * (floor ((1000 + (2000 * (1.05 ^ _i))) / 1000)));
};
SC_var_xpRanks pushBack 0;

SC_var_rf_active = isClass (configFile >> "CfgWeapons" >> "SMG_01_black_RF");
SC_var_lxws_active = isClass (configFile >> "CfgWeapons" >> "arifle_Velko_lxWS");
SC_var_ef_active = isClass (configFile >> "CfgWeapons" >> "arifle_Velko_lxWS");

SC_var_perkConfig = [
    ["Experience", "EXPR", 1],
    ["Medic", "MEDC", 1],
    ["Stamina", "STAM", 5],
    ["Marksman", "MRKS", 7],
    ["Machinegunner", "MGNR", 10],
    ["Launcher", "LNCR", 15],
    ["Armor", "ARMR", 18],
    ["Grenadier", "GRND", 20],
    ["Suppressor", "SUPR", 25]
];
SC_var_overridePerkChange = false;

_hudConfig = [
    ["HUD (press F2 to toggle)", true],
    ["Always show HUD when on map", true],
    ["Always show HUD when unconscious", true],
    ["Show all HUD components when on map", true],
    ["Show all HUD components when unconscious", true],
    ["Sector overview", true],
    ["Player stats", true],
    ["Group overview", true],
    ["Killfeed", true],
    ["Midfeed", true],
    ["Deathfeed", true],
    ["Unit names below 3D unit icons", true],
    ["Hide invisible 3D group icons", false],
    ["Limit 3D group icon draw distance", false],
    ["Sector 3D icons", true],
    ["Airdrop 3D icons", true],
    ["Show unit names on map only when hovered over", false],
    ["Vehicle-, soldier- and weapon info panels", true],
    ["Vehicle radar", true],
    ["Vehicle compass", true],
    ["GPS-/vehicle panel", true]
];
SC_var_defaultSettings = _hudConfig apply {_x select 1};

SC_var_neededXp = 0;
SC_var_inventoryDisabledCooldown = 0;
SC_var_earplugsOn = false;
SC_var_earplugsCooldown = 0;
SC_var_showPlayerNames = false;
SC_var_groupResArr = [];
SC_var_playerColor = [1, 0.83, 0, 1];
SC_var_hudEnabled = true;
SC_var_hudShown = false;
SC_var_isInVehicleVision = false;
SC_var_nvGogglesEnabled = call SC_fnc_isNight;
SC_var_hudSwitchCooldown = 0;
SC_var_mapPosition = [];
SC_var_mapScale = -1;
SC_var_uavTerminalOpened = false;
SC_var_stamina = 1;
SC_var_hudDisplayIsOpen = false;
SC_var_showSettingsActions = false;

SC_var_cameraViewLoop = scriptNull;
SC_var_forceFPPLoopScript = scriptNull;
SC_var_ranksystemLoopScript = scriptNull;
SC_var_inventoryDisabledCooldownLoopScript = scriptNull;
SC_var_respawnPositionsLoopScript = scriptNull;
SC_var_uavTerminalLoopScript = scriptNull;
SC_var_disableThermalLoopScript = scriptNull;
SC_var_spectatorNightVisionLoopScript = scriptNull;
SC_var_cameraNightVisionLoopScript = scriptNull;
SC_var_staminaSystemLoopScript = scriptNull;
SC_var_hudUpdateSectorOverviewLoopScript = scriptNull;
SC_var_hudUpdateGroupOverviewLoopScript = scriptNull;
SC_var_hudUpdatePlayerStatsLoopScript = scriptNull;
SC_var_disableLeftGpsLoopScript = scriptNull;
SC_var_broadcastCameraViewLoopScript = scriptNull;

[profileNameSpace getVariable ["SC_var_currentViewDistanceFactor", 0.1]] call SC_fnc_setViewDistance;
[profileNameSpace getVariable ["SC_var_currentGrassViewDistanceFactor", 0]] call SC_fnc_setGrassViewDistance;

if (isNil {profileNamespace getVariable "SC_var_killHistory"}) then {
    profileNamespace setVariable ["SC_var_killHistory", []];
};

if (isNil {profileNamespace getVariable "SC_var_deathHistory"}) then {
    profileNamespace setVariable ["SC_var_deathHistory", []];
};

if (isNil {profileNamespace getVariable "SC_var_numKills"}) then {
    profileNamespace setVariable ["SC_var_numKills", 0];
};

if (isNil {profileNamespace getVariable "SC_var_numOther"}) then {
    profileNamespace setVariable ["SC_var_numOther", 0];
};

if (isNil {profileNamespace getVariable "SC_var_numDeaths"}) then {
    profileNamespace setVariable ["SC_var_numDeaths", 0];
};

if (isNil {profileNamespace getVariable "SC_var_headshotRate"}) then {
    profileNamespace setVariable ["SC_var_headshotRate", 1];
};

if (isNil {profileNamespace getVariable "SC_var_numHeals"}) then {
    profileNamespace setVariable ["SC_var_numHeals", 0];
};

if (isNil {profileNamespace getVariable "SC_var_numSelfHeals"}) then {
    profileNamespace setVariable ["SC_var_numSelfHeals", 0];
};

if (isNil {profileNamespace getVariable "SC_var_numSectorsCaptured"}) then {
    profileNamespace setVariable ["SC_var_numSectorsCaptured", 0];
};

if (isNil {profileNamespace getVariable "SC_var_numRevives"}) then {
    profileNamespace setVariable ["SC_var_numRevives", 0];
};

if (isNil {profileNamespace getVariable "SC_var_numRevived"}) then {
    profileNamespace setVariable ["SC_var_numRevived", 0];
};

SC_var_teamMapColor = switch playerSide do {
    case west: {[0, 4/7, 1, 1]};
    case east: {[1, 0, 0, 1]};
    case independent: {[0, 0.8, 0.27, 1]};
};

SC_var_teamHexColor = switch playerSide do {
    case west: {"#0066B3"};
    case east: {"#E60000"};
    case independent: {"#009933"};
};

SC_var_tp = missionNamespace getVariable ("SC_var_" + (str (side (group player))) + "Tp");

SC_var_baseLoadout = switch (side (group player)) do {
    case west: {[[],[],[],["U_B_CombatUniform_mcam",[["HandGrenade",2,1]]],["V_TacVest_khk",[]],["B_AssaultPack_mcamo",[]],"H_HelmetB_light_sand","",["","","","",[],[],""],["ItemMap","B_UavTerminal","","ItemCompass","ItemWatch","NVGoggles"]]};
    case east: {[[],[],[],["U_O_CombatUniform_ocamo",[["HandGrenade",2,1]]],["V_TacVest_brn",[]],["B_AssaultPack_ocamo",[]],"H_HelmetO_ocamo","",["","","","",[],[],""],["ItemMap","O_UavTerminal","","ItemCompass","ItemWatch","NVGoggles_OPFOR"]]};
    case independent: {[[],[],[],["U_I_CombatUniform",[["HandGrenade",2,1]]],["V_TacVest_camo",[]],["B_AssaultPack_dgtl",[]],"H_HelmetIA","",["","","","",[],[],""],["ItemMap","I_UavTerminal","","ItemCompass","ItemWatch","NVGoggles_INDEP"]]};
};

SC_var_baseLoadoutInfo = [playerSide, 1, 1, 1, 1, 1];

if DW_var_skipNight then {
    _tmp = SC_var_baseLoadout select 9;
    _tmp set [5, ""];
    SC_var_baseLoadout set [9, _tmp];
};

TDI_var_DrawUnitsOnSpectator = false;
KF_var_DeathTransition = false;

SC_var_mapPosition = getMarkerPos "SC_var_playZone";
SC_var_mapScale = SC_var_mapZoomFactor * SC_var_maxZoneSize * 10 ^ -4;

if (isNil "SC_var_maximumVehicleAmount") then {
    SC_var_maximumVehicleAmount = 0;
};

SC_var_settings = profileNamespace getVariable ["SC_var_lastSettings", SC_var_defaultSettings];
call SC_fnc_writeSettingsArrToVariables;
profileNamespace setVariable ["SC_var_lastSettings", +SC_var_settings];

_rank = profileNamespace getVariable ["SC_var_rank", 1];
_xp = profileNamespace getVariable ["SC_var_xp", 0];
player setVariable ["SC_var_rank", _rank, true];
player setVariable ["SC_var_xp", _xp];
profileNamespace setVariable ["SC_var_rank", _rank];
profileNamespace setVariable ["SC_var_xp", _xp];

try {
    
    _lastLoadout = profileNamespace getVariable ["SC_var_lastLoadout", []];
    if (
        !(_lastLoadout isEqualType []) ||
        {(_lastLoadout findIf {
            !(_x isEqualType []) ||
            {(count _x) != 2} ||
            {!((_x select 0) isEqualType "")} ||
            {!((_x select 1) isEqualType [])}
        }) != -1}
    ) then {
        profileNamespace setVariable ["SC_var_lastLoadout", +SC_var_baseLoadout];
        throw "";
    };
    _pos = _lastLoadout findIf {(_x select 0) == SC_var_currentWorldGroup};
    SC_var_lastLoadout = if (_pos != -1) then {(_lastLoadout select _pos) select 1} else {+SC_var_baseLoadout};

    _lastLoadoutInfo = profileNamespace getVariable ["SC_var_lastLoadoutInfo", []];
    if (
        !(_lastLoadoutInfo isEqualType []) ||
        {(_lastLoadoutInfo findIf {
            !(_x isEqualType []) ||
            {(count _x) != 2} ||
            {!((_x select 0) isEqualType "")} ||
            {!((_x select 1) isEqualType [])}
        }) != -1}
    ) then {
        profileNamespace setVariable ["SC_var_lastLoadoutInfo", +SC_var_baseLoadoutInfo];
        throw "";
    };
    _pos = _lastLoadoutInfo findIf {(_x select 0) == SC_var_currentWorldGroup};
    SC_var_lastLoadoutInfo = if (_pos != -1) then {(_lastLoadoutInfo select _pos) select 1} else {+SC_var_baseLoadoutInfo};

    _perks = profileNamespace getVariable ["SC_var_perks", []];
    if (
        !(_perks isEqualType []) ||
        {(_perks findIf {
            !(_x isEqualType []) ||
            {(count _x) != 2} ||
            {!((_x select 0) isEqualType "")} ||
            {!((_x select 1) isEqualType [])}
        }) != -1}
    ) then {
        profileNamespace setVariable ["SC_var_perks", []];
        throw "";
    };
    _pos = _perks findIf {(_x select 0) == SC_var_currentWorldGroup};
    SC_var_perks = if (_pos != -1) then {(_perks select _pos) select 1} else {["EXPR"]};
} catch {
    SC_var_lastLoadout = +SC_var_baseLoadout;
    SC_var_lastLoadoutInfo = +SC_var_baseLoadoutInfo;
    SC_var_perks = ["EXPR"];
};

call SC_fnc_saveLoadoutToProfile;

player setVariable ["SC_var_hasExprPerk", ("EXPR" in SC_var_perks), true];
player setVariable ["ais_side", side (group player), true];