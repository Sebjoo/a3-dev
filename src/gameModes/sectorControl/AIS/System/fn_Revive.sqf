/*
 * Author: Psycho
 
 * Handle Revive actions from a PLAYER
 
 * Arguments:
    0: Healer Unit (Object)
    1: Injured Unit (Object)
 
 * Return value:
    Nothing
*/

params [
    ["_healer", player, [player]],
    "_injured"
];

_injured setVariable ["ais_hasHelper", _healer, true];

//_injured playMove "AinjPpneMstpSnonWrflDnon_rolltoback";    // from AIS fsm
[_injured, "AinjPpneMstpSnonWrflDnon_rolltoback"] remoteExec ["playMove", 0];

// switch to primary weapon if possible. Small delay for handling is needed.
if (primaryWeapon _healer != "") then {
    _healer switchmove "amovpercmstpsraswrfldnon";
    _healer selectWeapon (primaryWeapon _healer);
};

_healer playAction "medicStart";

// full heal anim only with primary weapon possible. 
ais_animChangeEVH = _healer addEventhandler ["AnimChanged", {
    params ["_healer","_anim"];
    if (primaryWeapon _healer isEqualTo "") then {
        if (_anim in ["amovpknlmstpsnonwnondnon","amovpknlmstpsraswlnrdnon"]) then {
            _healer playActionNow "medicStart";
        };
    };
}];

_offset = [0,0,0]; _dir = 0;
_relpos = _healer worldToModel position _injured;
if (((_healer getDir _injured) - (_injured getDir _healer)) < 0) then {_offset = [-0.2,0.7,0]; _dir = 90} else {_offset = [0.2,0.7,0]; _dir = 270};

_injured attachTo [_healer, _offset];
[_injured, _dir] remoteExec ["setDir", 0, false];

// [_healer, _injured] call AIS_Effects_fnc_medEquip;
private _duration = [_healer, _injured] call AIS_System_fnc_calculateReviveTime;
//hint format ["Revive Time Duration: %1", _duration];    // debug

[
    "Applying First Aid", 
    _duration,
    {
        params ["_injured", "_healer"];

        _injured setVariable ["ais_unconscious", false, true];
        _injured setVariable ["ais_unconscious_since", -999, true];

        if (isPlayer _healer) then {
            _xp = [50, 100] select (_healer getVariable ["SC_var_hasExprPerk", false]);
            [_xp] remoteExecCall ["SC_fnc_addXp", _healer];
            [_healer, _injured, _xp] remoteExecCall ["SC_fnc_midfeedHeal", 2];
            [_healer] remoteExecCall ["SC_fnc_addRevive", _healer];
            [_injured] remoteExecCall ["SC_fnc_addRevived", _injured];
        };
        
        _healer removeEventHandler ["AnimChanged", ais_animChangeEVH];
        detach _healer;
        detach _injured;

        _healer playAction "medicStop";
        // [_healer, 1] remoteExec ["addScore", 2];     // +1 per revive

        _injured setVariable ["ais_hasHelper", ObjNull, true];
        call AIS_Effects_fnc_garbage;
        
        // healing if enabled
        if (AIS_REVIVE_HEAL) then {
            _injured setDamage 0;
            _injured setVariable ["ais_fireDamage", 0];
        } else {
            // make sure the unit can walk after revive
            //if ((_injured getHitIndex 10) > 0.49) then {
            //    [{(_this select 0) setHitIndex [10, 0.49]}, [_injured]] call AIS_Core_fnc_onNextFrame;
            //};
        };
        
        [_injured] remoteExecCall ["AIS_System_fnc_restoreFaks", _injured, false];
        
        _injured stop false;
        // {_injured enableAI _x; nil} count ["MOVE","TARGET","AUTOTARGET","ANIM","AUTOCOMBAT"];
        _injured enableAI "all";
        [_injured, false] remoteExecCall ["AIS_System_fnc_unconcsiousRemote", 0, false]; 
        // [_injured, false] remoteExec ["setCaptive", 0, false];
        
        // ["GetOutMan"] remoteExec ["removeAllEventHandlers", _injured, false];
    },
    [_injured, _healer],
    {
        params ["_injured", "_healer"];
        
        _injured setVariable ["ais_hasHelper", ObjNull, true];
        
        _healer removeEventHandler ["AnimChanged", ais_animChangeEVH];
        detach _healer;
        detach _injured;
        
        call AIS_Effects_fnc_garbage;
        
        if (alive _healer) then {
            _healer playActionNow "medicStop";
        };
        if (!alive _injured) then {
            ["medicSystem", ["He is not with us anymore."]] call SC_fnc_showNotificationIfHudIsEnabled;
        };
    },
    (!alive _injured || _healer getVariable ["ais_unconscious",false])
] call AIS_Core_fnc_Progress_ShowBar;