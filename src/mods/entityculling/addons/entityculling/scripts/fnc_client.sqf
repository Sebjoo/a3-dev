EC_fnc_isOnScreen = {
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

EC_fnc_setEntityVisibility = {
    params ["_visibleEntities", "_culledEntities"];
    
    systemChat (str [count _visibleEntities, count _culledEntities]);

    {
        if (!(isNull _x) && {!([getposAtl _x] call EC_fnc_isOnScreen)}) then {
            _x hideObject false;
        }
    } forEach _visibleEntities;
    
    {
        if !(isNull _x) then {
            _x hideObject true;
        }
    } forEach _culledEntities;
};

EC_var_clientInitDone = true;