class loadoutDialog {
    idd = 3001;
    movingenable = true;
    enableSimulation = true;
    duration = 999999;
    fadein = 0;
    fadeout = 0;
    onLoad = "uiNamespace setVariable [""SC_var_loadoutDialog"",_this select 0]; call SC_fnc_setupLoadoutDialog;";

    class ControlsBackground {
        class RscText_1000: RscText
        {
            idc = 1000;
            x = 0.29375 * safezoneW + safezoneX;
            y = 0.247 * safezoneH + safezoneY;
            w = 0.4125 * safezoneW;
            h = 0.528 * safezoneH;
            colorBackground[] = {0.08,0.08,0.08,1};
        };
        class RscText_1001: RscText
        {
            idc = 1001;
            x = 0.29375 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.4125 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.5,0.4,0,1};
        };
        class RscText_1002: RscText
        {
            idc = 1002;
            text = "Change Loadout";
            x = 0.463906 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.022 * safezoneH;
        };
        class _CT_CONTROLSTABLE
		{
			idc = 1500;
            x = 0.304062 * safezoneW + safezoneX;
            y = 0.313 * safezoneH + safezoneY;
            w = 0.391875 * safezoneW;
            h = 0.44 * safezoneH;
			
			type = CT_CONTROLS_TABLE;
			style = SL_TEXTURES;
			
			lineSpacing = 0;
			rowHeight = 0.036 * safezoneH;
			headerHeight = 0.025 * safezoneH;
			
			firstIDC = 42000;
			lastIDC = 44999;
			
			// Colours which are used for animation (i.e. change of colour) of the selected line.
			selectedRowColorFrom[]  = {0.6, 0.6, 0.6, 1.0};
			selectedRowColorTo[]    = {0.6, 0.6, 0.6, 1.0};
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
					controlBaseClassPath[] = {"RscButton"};
					columnX = 0;
					columnW = 0.391875 * (100 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Weapon_1
				{
					controlBaseClassPath[] = {"RscPictureKeepAspect"};
					columnX = 0.391875 * (0 / 100) * safezoneW;
					columnW = 0.391875 * (12 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Weapon_2
				{
					controlBaseClassPath[] = {"RscPictureKeepAspect"};
					columnX = 0.391875 * (12 / 100) * safezoneW;
					columnW = 0.391875 * (12 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Weapon_3
				{
					controlBaseClassPath[] = {"RscPictureKeepAspect"};
					columnX = 0.391875 * (24 / 100) * safezoneW;
					columnW = 0.391875 * (12 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Uniform
				{
					controlBaseClassPath[] = {"RscPictureKeepAspect"};
					columnX = 0.391875 * (36 / 100) * safezoneW;
					columnW = 0.391875 * (6 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Headgear
				{
					controlBaseClassPath[] = {"RscPictureKeepAspect"};
					columnX = 0.391875 * (42 / 100) * safezoneW;
					columnW = 0.391875 * (6 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
                class Vest
				{
					controlBaseClassPath[] = {"RscPictureKeepAspect"};
					columnX = 0.391875 * (48 / 100) * safezoneW;
					columnW = 0.391875 * (6 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
                class Backpack
				{
					controlBaseClassPath[] = {"RscPictureKeepAspect"};
					columnX = 0.391875 * (54 / 100) * safezoneW;
					columnW = 0.391875 * (6 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
                class Perks
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.391875 * (60 / 100) * safezoneW;
					columnW = 0.391875 * (40 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
			};
			class HeaderTemplate
			{
				class RowBackground
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0;
					columnW = 0.391875 * (100 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Weapon_1
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.391875 * (0 / 100) * safezoneW;
					columnW = 0.391875 * (12 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Weapon_2
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.391875 * (12 / 100) * safezoneW;
					columnW = 0.391875 * (12 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Weapon_3
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.391875 * (24 / 100) * safezoneW;
					columnW = 0.391875 * (12 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Apparel
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.391875 * (36 / 100) * safezoneW;
					columnW = 0.391875 * (24 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
                class Perks
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.391875 * (60 / 100) * safezoneW;
					columnW = 0.391875 * (40 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
			};
		};
        class RscButton_1600: RscButton
        {
            idc = 1600;
            style = 2;
            text = "Load Loadout";
            x = 0.386562 * safezoneW + safezoneX;
            y = 0.269 * safezoneH + safezoneY;
            w = 0.061875 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "call SC_fnc_loadLoadout;";
        };
        class RscButton_1601: RscButton
        {
            idc = 1601;
            style = 2;
            text = "Overwrite Loadout";
            x = 0.463906 * safezoneW + safezoneX;
            y = 0.269 * safezoneH + safezoneY;
            w = 0.0721875 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "call SC_fnc_storeLoadout;";
        };
        class RscButton_1602: RscButton
        {
            idc = 1602;
            style = 2;
            text = "Delete Loadout";
            x = 0.551562 * safezoneW + safezoneX;
            y = 0.269 * safezoneH + safezoneY;
            w = 0.061875 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "call SC_fnc_deleteLoadout;";
        };
    };
};