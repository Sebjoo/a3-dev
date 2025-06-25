class spectatorDisplay {
    idd = 5000;
    movingenable = false;
    enableSimulation = true;
    duration = 999999;
    fadein = 0;
    fadeout = 0;
    onLoad = "uiNamespace setVariable [""SC_var_spectatorDisplay"", _this select 0]";

    class controls {
        class RscText_1000: RscText
        {
            idc = 1000;
            x = 0.4175 * safezoneW + safezoneX;
            y = 0.918 * safezoneH + safezoneY;
            w = 0.165 * safezoneW;
            h = 0.077 * safezoneH;
            colorBackground[] = {0.1,0.1,0.1,0.7};
        };
        class RscButton_1600: RscButton
        {
            idc = 1600;
            text = "OPEN MAP";
            style = 2;
            x = 0.422656 * safezoneW + safezoneX;
            y = 0.929 * safezoneH + safezoneY;
            w = 0.154687 * safezoneW;
            h = 0.055 * safezoneH;
            onButtonClick = "(uiNamespace getVariable ""SC_var_spectatorDisplay"") closeDisplay 1;";
            font = "PuristaLight";
            colorFocused[] = {0.6484375,0.44140625,0.08984375,0.95};
            colorFocusedSecondary[] = {0.6484375,0.44140625,0.08984375,0.95};
            colorBackground[] = {0.6484375,0.44140625,0.08984375,0.95};
            colorFocused2[] = {0.6484375,0.44140625,0.08984375,0.95};
            colorBackgroundActive[] = {1, 1, 1, 1};
            colorActive[] = {0, 0, 0, 1};
            colorTextActive[] = {0, 0, 0, 1};
            colorText[] = {1, 1, 1, 1};
            onMouseEnter = "(_this select 0) ctrlSetTextColor [0,0,0,1];";
            onMouseExit = "(_this select 0) ctrlSetTextColor [1,1,1,1];";
        };
        class RscCombo_2100: RscCombo
        {
            idc = 2100;
            x = 0.438125 * safezoneW + safezoneX;
            y = 0.885 * safezoneH + safezoneY;
            w = 0.12375 * safezoneW;
            h = 0.022 * safezoneH;
        };
        class RscText_1001: RscText
        {
            idc = 1001;
            x = 0.432969 * safezoneW + safezoneX;
            y = 0.874 * safezoneH + safezoneY;
            w = 0.134062 * safezoneW;
            h = 0.044 * safezoneH;
            colorBackground[] = {0.1,0.1,0.1,0.7};
        };
    };
};