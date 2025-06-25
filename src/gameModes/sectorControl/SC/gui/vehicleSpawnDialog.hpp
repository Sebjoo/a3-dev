class vehicleSpawnDialog {
    idd = 3001;
    movingenable = true;
    enableSimulation = true;
    duration = 999999;
    fadein = 0;
    fadeout = 0;
    onLoad = "uiNamespace setVariable [""SC_var_vehicleSpawnDialog"",_this select 0];";

    class ControlsBackground {
        class RscText_1000: RscText
        {
            idc = 1000;
            x = 0.335 * safezoneW + safezoneX;
            y = 0.247 * safezoneH + safezoneY;
            w = 0.33 * safezoneW;
            h = 0.528 * safezoneH;
            colorBackground[] = {0.08,0.08,0.08,1};
        };
        class RscText_1001: RscText
        {
            idc = 1001;
            x = 0.335 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.33 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.5,0.4,0,1};
        };
        class RscText_1002: RscText
        {
            idc = 1002;
            text = "Vehicles & Aircraft";
            x = 0.463906 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.0721875 * safezoneW;
            h = 0.022 * safezoneH;
        };
        class RscButton_1600: RscButton
        {
            idc = 1600;
            style = 2;
            text = "Spawn";
            x = 0.479375 * safezoneW + safezoneX;
            y = 0.742 * safezoneH + safezoneY;
            w = 0.04125 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
        };
        class RscText_1003: RscText
        {
            idc = 1003;
            text = "Spawn Cooldown: 05:00 min";
            x = 0.443281 * safezoneW + safezoneX;
            y = 0.258 * safezoneH + safezoneY;
            w = 0.108281 * safezoneW;
            h = 0.022 * safezoneH;
        };
        class _CT_CONTROLSTABLE
		{
            idc = 1500;
            x = 0.345312 * safezoneW + safezoneX;
            y = 0.291 * safezoneH + safezoneY;
            w = 0.309375 * safezoneW;
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
					columnW = 0.309375 * (100 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Picture
				{
					controlBaseClassPath[] = {"RscPictureKeepAspect"};
					columnX = 0.309375 * (0 / 100) * safezoneW;
					columnW = 0.309375 * (20 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Name
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.309375 * (20 / 100) * safezoneW;
					columnW = 0.309375 * (60 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Rank
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.309375 * (80 / 100) * safezoneW;
					columnW = 0.309375 * (20 / 100) * safezoneW;
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
					columnW = 0.309375 * (100 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
                class Picture
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.309375 * (0 / 100) * safezoneW;
					columnW = 0.309375 * (20 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Name
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.309375 * (20 / 100) * safezoneW;
					columnW = 0.309375 * (60 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Rank
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.309375 * (80 / 100) * safezoneW;
					columnW = 0.309375 * (20 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
			};
		};
    };
};