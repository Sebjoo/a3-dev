class statisticsDialog {
    idd = 3002;
    movingenable = true;
    enableSimulation = true;
    duration = 999999;
    fadein = 0;
    fadeout = 0;
    onLoad = "uiNamespace setVariable [""SC_var_statisticsDialog"",_this select 0]; [false, 1] call SC_fnc_showStatistics;";

    class ControlsBackground {
        class RscText_1000: RscText
        {
            idc = 1000;
            x = 0.365937 * safezoneW + safezoneX;
            y = 0.247 * safezoneH + safezoneY;
            w = 0.268125 * safezoneW;
            h = 0.528 * safezoneH;
            colorBackground[] = {0.08,0.08,0.08,1};
        };
        class RscText_1001: RscText
        {
            idc = 1001;
            x = 0.365937 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.268125 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.5,0.4,0,1};
        };
        class RscText_1002: RscText
        {
            idc = 1002;
            text = "Player Statistics";
            x = 0.469062 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.061875 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RscText_1003: RscText
        {
            idc = 1003;
            text = "Kills:";
            x = 0.371094 * safezoneW + safezoneX;
            y = 0.258 * safezoneH + safezoneY;
            w = 0.134062 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RscText_1004: RscText
        {
            idc = 1004;
            text = "Deaths:";
            x = 0.371094 * safezoneW + safezoneX;
            y = 0.28 * safezoneH + safezoneY;
            w = 0.134062 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RscText_1005: RscText
        {
            idc = 1005;
            text = "Assists/Finally Killed:";
            x = 0.371094 * safezoneW + safezoneX;
            y = 0.346 * safezoneH + safezoneY;
            w = 0.134062 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RscText_1006: RscText
        {
            idc = 1006;
            text = "Headshot Rate:";
            x = 0.371094 * safezoneW + safezoneX;
            y = 0.324 * safezoneH + safezoneY;
            w = 0.134062 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RscText_1007: RscText
        {
            idc = 1007;
            text = "Sectors Captured:";
            x = 0.5 * safezoneW + safezoneX;
            y = 0.258 * safezoneH + safezoneY;
            w = 0.128906 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RscText_1008: RscText
        {
            idc = 1008;
            text = "K/D:";
            x = 0.371094 * safezoneW + safezoneX;
            y = 0.302 * safezoneH + safezoneY;
            w = 0.134062 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RscText_1009: RscText
        {
            idc = 1009;
            text = "Units Revived:";
            x = 0.5 * safezoneW + safezoneX;
            y = 0.28 * safezoneH + safezoneY;
            w = 0.128906 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RscText_1010: RscText
        {
            idc = 1010;
            text = "Recieved Revives:";
            x = 0.5 * safezoneW + safezoneX;
            y = 0.302 * safezoneH + safezoneY;
            w = 0.128906 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RscText_1011: RscText
        {
            idc = 1011;
            text = "Units Healed:";
            x = 0.5 * safezoneW + safezoneX;
            y = 0.324 * safezoneH + safezoneY;
            w = 0.128906 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RscText_1012: RscText
        {
            idc = 1012;
            text = "Healed Self:";
            x = 0.5 * safezoneW + safezoneX;
            y = 0.346 * safezoneH + safezoneY;
            w = 0.128906 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };
        class RscButton_1600: RscButton
        {
            idc = 1600;
            style = 2;
            text = "Show Kill Statistics";
            x = 0.396875 * safezoneW + safezoneX;
            y = 0.379 * safezoneH + safezoneY;
            w = 0.0773437 * safezoneW;
            h = 0.022 * safezoneH;
            onButtonClick = "[false, 1] call SC_fnc_showStatistics;";
        };
        class RscButton_1601: RscButton
        {
            idc = 1601;
            style = 2;
            text = "Show Death Statistics";
            x = 0.520625 * safezoneW + safezoneX;
            y = 0.379 * safezoneH + safezoneY;
            w = 0.0876563 * safezoneW;
            h = 0.022 * safezoneH;
            onButtonClick = "[true, 1] call SC_fnc_showStatistics;";
        };
        class _CT_CONTROLSTABLE
		{
			idc = 1500;
            x = 0.371096 * safezoneW + safezoneX;
            y = 0.412 * safezoneH + safezoneY;
            w = 0.257813 * safezoneW;
            h = 0.352 * safezoneH;
			
			type = CT_CONTROLS_TABLE;
			style = SL_TEXTURES;
			
			lineSpacing = 0;
			rowHeight = 0.036 * safezoneH;
			headerHeight = 0.025 * safezoneH;
			
			firstIDC = 42000;
			lastIDC = 44999;
			
			// Colours which are used for animation (i.e. change of colour) of the selected line.
			selectedRowColorFrom[]  = {0.7, 0.85, 1, 0.25};
			selectedRowColorTo[]    = {0.7, 0.85, 1, 0.5};
			// Length of the animation cycle in seconds.
			selectedRowAnimLength = 1.2;
			
			class VScrollBar: ScrollBar
			{
				width = 0.021;
				autoScrollEnabled = 0;
				autoScrollDelay = 1;
				autoScrollRewind = 1;
				autoScrollSpeed = 1;
			};
		
			class HScrollBar: ScrollBar
			{
				height = 0.028;
			};
			
			// Template for selectable rows
			class RowTemplate
			{
				class RowBackground
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0;
					columnW = 0.257813 * (100 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Picture
				{
					controlBaseClassPath[] = {"RscPictureKeepAspect"};
					columnX = 0;
					columnW = 0.257813 * (20 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Kills
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.257813 * (20 / 100) * safezoneW;
					columnW = 0.257813 * (11 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Assists
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.257813 * (31 / 100) * safezoneW;
					columnW = 0.257813 * (13 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Headshot_Rate
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.257813 * (44 / 100) * safezoneW;
					columnW = 0.257813 * (17 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Avg_Distance
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.257813 * (61 / 100) * safezoneW;
					columnW = 0.257813 * (23 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class XP
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.257813 * (84 / 100) * safezoneW;
					columnW = 0.257813 * (16 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
			};
			
			// Template for headers (unlike rows, cannot be selected)
			class HeaderTemplate
			{
				class RowBackground
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0;
					columnW = 0.257813 * (100 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Picture
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0;
					columnW = 0.257813 * (20 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Kills
				{
					controlBaseClassPath[] = {"RscButton"};
					columnX = 0.257813 * (20 / 100) * safezoneW;
					columnW = 0.257813 * (11 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Assists
				{
					controlBaseClassPath[] = {"RscButton"};
					columnX = 0.257813 * (31 / 100) * safezoneW;
					columnW = 0.257813 * (13 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Headshot_Rate
				{
					controlBaseClassPath[] = {"RscButton"};
					columnX = 0.257813 * (44 / 100) * safezoneW;
					columnW = 0.257813 * (17 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Avg_Distance
				{
					controlBaseClassPath[] = {"RscButton"};
					columnX = 0.257813 * (61 / 100) * safezoneW;
					columnW = 0.257813 * (23 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class XP
				{
					controlBaseClassPath[] = {"RscButton"};
					columnX = 0.257813 * (84 / 100) * safezoneW;
					columnW = 0.257813 * (16 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
			};
		};
    };
};