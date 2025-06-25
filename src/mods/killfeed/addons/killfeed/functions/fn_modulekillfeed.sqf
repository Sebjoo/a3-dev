if isServer then {
    params ["_logic", "", "_activated"];

    if !_activated exitWith {};

    call (compile preprocessFileLineNumbers "killfeed\scripts\fn_init.sqf");

    KF_var_Assists = (_logic getVariable "assists") == 1;;
    KF_var_ShowFriendlyFire = (_logic getVariable "showFriendlyFire") == 1;
    KF_var_DeathCausesInversed = (_logic getVariable "deathCausesInversed") == 1;
    KF_var_MultipleDeathCauses = (_logic getVariable "multipleDeathCauses") == 1;
    KF_var_PicturesHeadIcon = (_logic getVariable "picturesHeadIcon") == 1;
    KF_var_picturesBulletIcon = (_logic getVariable "picturesBulletIcon") == 1;
    KF_var_showAiInNames = (_logic getVariable "showAiInNames") == 1;

    KF_var_KillfeedEnabled = (_logic getVariable "killfeedEnabled") == 1;
    KF_var_KillfeedInversed = (_logic getVariable "killfeedInversed") == 1;
    KF_var_KillfeedCooldown = _logic getVariable "killfeedCooldown";
    KF_var_KillfeedMaximumLength = _logic getVariable "killfeedMaximumLength";

    KF_var_MidFeedEnabled = (_logic getVariable "midFeedEnabled") == 1;
    KF_var_MidfeedCooldown = _logic getVariable "midfeedCooldown";
    KF_var_MidfeedMaximumLength = _logic getVariable "midfeedMaximumLength";
    KF_var_MidFeedYouColorYellow = (_logic getVariable "midFeedYouColorYellow") == 1;
    KF_var_MidFeedAssists = (_logic getVariable "midFeedAssists") == 1;

    KF_var_DeathFeedEnabled = (_logic getVariable "deathFeedEnabled") == 1;

    KF_var_killInfoDuration = (_logic getVariable "killInfoDuration") == 1;

    publicVariable "KF_var_KillfeedCooldown";
    publicVariable "KF_var_KillfeedMaximumLength";
    publicVariable "KF_var_MidfeedCooldown";
    publicVariable "KF_var_MidfeedMaximumLength";

    call KF_fnc_ResetKillInfo;

    call KF_fnc_startKillfeed;
};