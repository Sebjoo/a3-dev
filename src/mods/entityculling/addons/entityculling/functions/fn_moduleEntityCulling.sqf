if isServer then {
    params ["_logic", "", "_activated"];

    if !_activated exitWith {};

    call (compile preprocessFileLineNumbers "dynamicweather\scripts\fn_init.sqf");

    DW_var_minOvercast = _logic getVariable "minOvercast";
    DW_var_maxOvercast = _logic getVariable "maxOvercast";
    DW_var_minFogSunny = _logic getVariable "minFogSunny";
    DW_var_maxFogSunny = _logic getVariable "maxFogSunny";
    DW_var_minFogStormy = _logic getVariable "minFogStormy";
    DW_var_maxFogStormy = _logic getVariable "maxFogStormy";
    DW_var_minRain = _logic getVariable "minRain";
    DW_var_maxRain = _logic getVariable "maxRain";
    DW_var_minWindSunny = _logic getVariable "minWindSunny";
    DW_var_maxWindSunny = _logic getVariable "maxWindSunny";
    DW_var_minWindStormy = _logic getVariable "minWindStormy";
    DW_var_maxWindStormy = _logic getVariable "maxWindStormy";

    DW_var_changeTimeMultiplierDay = _logic getVariable "timeMultiplierChangeDay";
    DW_var_staticTimeMultiplierDay = _logic getVariable "timeMultiplierStaticDay";
    DW_var_changeTimeMultiplierNight = _logic getVariable "timeMultiplierChangeNight";
    DW_var_staticTimeMultiplierNight = _logic getVariable "timeMultiplierStaticNight";
    
    DW_var_timeBetweenWeatherChangesMultiplierSunny = _logic getVariable "timeBetweenWeatherChangesMultiplierSunny";
    DW_var_timeBetweenWeatherChangesMultiplierStormy = _logic getVariable "timeBetweenWeatherChangesMultiplierStormy";

    _skipNight = _logic getVariable "skipNightTime";

    DW_var_skipNight = _skipNight != 0;

    if DW_var_skipNight then {
        DW_var_skipNightTime = [_skipNight, 0];
    };

    DW_var_date = date select [0, 3];

    [false] call DW_fnc_startDynamicWeather;
};