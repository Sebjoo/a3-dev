/*
 * by Psycho

 * Arguments:
 * 0: Unit That Was Hit (Object)
 * 1: Hit Selection (String)
 * 2: Damage (Number)
 * 3: Shooter (object)
 * 4: Projectile (string)
 * 5: HitPartIndex (number)
 * 6: Instigator (object)
 * 7: HitPoint CfgName (String)

 * Return Value:
 * Damage
*/

params [
    "_unit",            // Object the event handler is assigned to.
    "_hitSelection",    // Name of the selection where the unit was damaged. "" for over-all structural damage, "?" for unknown selections.
    "_damage",            // Resulting level of damage for the selection.
    "_source",            // The source unit (shooter) that caused the damage.
    "_projectile",        // Classname of the projectile that caused inflicted the damage. ("" for unknown, such as falling damage.) (String)
    "_hitPartIndex",    // Hit part index of the hit point, -1 otherwise.
    "_instigator",        // Person who pulled the trigger. (Object)
    "_hitPoint",            // hit point Cfg name (String)
    "_directHit"
];

if !(local _unit) exitWith {false};

private _new_damage = if (_hitPartIndex >= 0) then {_damage - (_unit getHitIndex _hitPartIndex)} else {_damage - (damage _unit)};
if (diag_frameNo < (_unit getVariable ["ais_protector_delay", 0])) exitWith {_damage - _new_damage};

if !(isNull _source) then {
    _unit setVariable ["AIS_lastSource", [_source, time]];
} else {
    (_unit getVariable ["AIS_lastSource", [objNull, -1]]) params ["_lastSource", "_timeOfLastHit"];

    if (!(isNull _lastSource) && {(time - _timeOfLastHit) <= 1}) then {
        _source = _lastSource;
    };
};

if !(isNull _instigator) then {
    _unit setVariable ["AIS_lastInstigator", [_instigator, time]];
} else {
    (_unit getVariable ["AIS_lastInstigator", [objNull, -1]]) params ["_lastInstigator", "_timeOfLastHit"];

    if (!(isNull _lastInstigator) && {(time - _timeOfLastHit) <= 1}) then {
        _instigator = _lastInstigator;
    };
};

_hitPart = [_unit, _hitSelection] call AIS_Damage_fnc_getHitIndexValue;

if (_unit getVariable ["ais_unconscious", false]) exitWith {
    _new_damage = _new_damage * AIS_UNCONSCIOUS_DAMAGE_TOLLERANCE_FACTOR;
    _damage = (_hitPart select 2) + _new_damage;

    if ((_hitPartIndex < 0) && {_damage >= 1}) then {
        [_unit,_source,_instigator] call AIS_Damage_fnc_goToDead;
    };

    _damage
};

_new_damage = AIS_DAMAGE_TOLLERANCE_FACTOR * _new_damage;

if (!(isNull (objectParent _unit)) && {(_directHit && {_projectile == ""}) || {SC_var_launcherAmmos getOrDefault [_projectile, false]}}) then {
    _new_damage = _new_damage * 0.5 * SC_var_vehicleDamageFactor;
};

_damage = (_hitPart select 2) + _new_damage;

if (_hitPartIndex >= 0) then {
    if (_damage >= 1) then {
        _damage = 0.9999;
    };

    // _unit setHitIndex [_hitPart select 1, _damage];
} else {
    if (_damage >= 0.8) then {
        _damage = 0.8;
        _unit setVariable ["ais_protector_delay", (diag_frameNo + 5)];
        [_unit, _source, _instigator, true] remoteExecCall ["KF_fnc_EntityKilled", 2];
        _unit setVariable ["ais_unconscious", true, true];
        _unit setVariable ["ais_unconscious_since", time, true];
        [{[(_this select 0)] call AIS_System_fnc_setUnconscious}, [_unit]] call AIS_Core_fnc_onNextFrame;
    };
};

_damage