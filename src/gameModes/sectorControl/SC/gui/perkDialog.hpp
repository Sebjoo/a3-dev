class perkDialog {
    idd = 3002;
    movingenable = true;
    enableSimulation = true;
    duration = 999999;
    fadein = 0;
    fadeout = 0;
    onLoad = "uiNamespace setVariable [""SC_var_perkDialog"",_this select 0]; call SC_fnc_setupperkDialog;";

    class ControlsBackground {
        class RscText_1000: RscText
        {
            idc = 1000;
            x = 0.4175 * safezoneW + safezoneX;
            y = 0.401 * safezoneH + safezoneY;
            w = 0.165 * safezoneW;
            h = 0.231 * safezoneH;
            colorBackground[] = {0,0,0,0.8};
        };
        class RscText_1001: RscText
        {
            idc = 1001;
            x = 0.4175 * safezoneW + safezoneX;
            y = 0.379 * safezoneH + safezoneY;
            w = 0.165 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.6,0.6,0,0.8};
        };
        class RscText_1002: RscText
        {
            idc = 1002;
            text = "Perk 1";
            x = 0.422656 * safezoneW + safezoneX;
            y = 0.423 * safezoneH + safezoneY;
            w = 0.0309375 * safezoneW;
            h = 0.022 * safezoneH;
        };
        class RscText_1008: RscText
        {
            idc = 1008;
            text = "Perks";
            x = 0.4175 * safezoneW + safezoneX;
            y = 0.379 * safezoneH + safezoneY;
            w = 0.0567187 * safezoneW;
            h = 0.022 * safezoneH;
        };
        class RscText_1003: RscText
        {
            idc = 1003;
            text = "Perk 2";
            x = 0.422656 * safezoneW + safezoneX;
            y = 0.456 * safezoneH + safezoneY;
            w = 0.0309375 * safezoneW;
            h = 0.022 * safezoneH;
        };
        class RscText_1004: RscText
        {
            idc = 1004;
            text = "Perk 3";
            x = 0.422656 * safezoneW + safezoneX;
            y = 0.489 * safezoneH + safezoneY;
            w = 0.0309375 * safezoneW;
            h = 0.022 * safezoneH;
        };
        class RscText_1005: RscText
        {
            idc = 1005;
            text = "Perk 4";
            x = 0.422656 * safezoneW + safezoneX;
            y = 0.522 * safezoneH + safezoneY;
            w = 0.0309375 * safezoneW;
            h = 0.022 * safezoneH;
        };
        class RscText_1006: RscText
        {
            idc = 1006;
            text = "Perk 5";
            x = 0.422656 * safezoneW + safezoneX;
            y = 0.555 * safezoneH + safezoneY;
            w = 0.0309375 * safezoneW;
            h = 0.022 * safezoneH;
        };
        class RscText_1007: RscText
        {
            idc = 1007;
            text = "Perk 6";
            x = 0.422656 * safezoneW + safezoneX;
            y = 0.588 * safezoneH + safezoneY;
            w = 0.0309375 * safezoneW;
            h = 0.022 * safezoneH;
        };
        class RscCombo_2100: RscCombo
        {
            idc = 2100;
            x = 0.453594 * safezoneW + safezoneX;
            y = 0.423 * safezoneH + safezoneY;
            w = 0.118594 * safezoneW;
            h = 0.022 * safezoneH;
            onLBSelChanged = "[0, (_this select 1)] call SC_fnc_changePerk;";
        };
        class RscCombo_2101: RscCombo
        {
            idc = 2101;
            x = 0.453594 * safezoneW + safezoneX;
            y = 0.456 * safezoneH + safezoneY;
            w = 0.118594 * safezoneW;
            h = 0.022 * safezoneH;
            onLBSelChanged = "[1, (_this select 1)] call SC_fnc_changePerk;";
        };
        class RscCombo_2102: RscCombo
        {
            idc = 2102;
            x = 0.453594 * safezoneW + safezoneX;
            y = 0.489 * safezoneH + safezoneY;
            w = 0.118594 * safezoneW;
            h = 0.022 * safezoneH;
            onLBSelChanged = "[2, (_this select 1)] call SC_fnc_changePerk;";
        };
        class RscCombo_2103: RscCombo
        {
            idc = 2103;
            x = 0.453594 * safezoneW + safezoneX;
            y = 0.522 * safezoneH + safezoneY;
            w = 0.118594 * safezoneW;
            h = 0.022 * safezoneH;
            onLBSelChanged = "[3, (_this select 1)] call SC_fnc_changePerk;";
        };
        class RscCombo_2104: RscCombo
        {
            idc = 2104;
            x = 0.453594 * safezoneW + safezoneX;
            y = 0.555 * safezoneH + safezoneY;
            w = 0.118594 * safezoneW;
            h = 0.022 * safezoneH;
            onLBSelChanged = "[4, (_this select 1)] call SC_fnc_changePerk;";
        };
        class RscCombo_2105: RscCombo
        {
            idc = 2105;
            x = 0.453594 * safezoneW + safezoneX;
            y = 0.588 * safezoneH + safezoneY;
            w = 0.118594 * safezoneW;
            h = 0.022 * safezoneH;
            onLBSelChanged = "[5, (_this select 1)] call SC_fnc_changePerk;";
        };
    };
};