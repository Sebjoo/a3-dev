class equipmentDialog {
    idd = 3001;
    movingenable = true;
    enableSimulation = true;
    duration = 999999;
    fadein = 0;
    fadeout = 0;
    onLoad = "uiNamespace setVariable [""SC_var_equipmentDialog"",_this select 0]; [""general""] call SC_fnc_setupEquipmentDialog;";

    class ControlsBackground {
        class RscText_1000: RscText
        {
            idc = 1000;
            x = 0.341406 * safezoneW + safezoneX;
            y = 0.247 * safezoneH + safezoneY;
            w = 0.322344 * safezoneW;
            h = 0.528 * safezoneH;
            colorBackground[] = {0.08,0.08,0.08,1};
        };
        class RscText_1001: RscText
        {
            idc = 1001;
            x = 0.341406 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.322344 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.5,0.4,0,1};
        };
        class RscText_1002: RscText
        {
            idc = 1002;
            text = "Equipment";
            x = 0.474219 * safezoneW + safezoneX;
            y = 0.225 * safezoneH + safezoneY;
            w = 0.0515625 * safezoneW;
            h = 0.022 * safezoneH;
        };
        class RscButton_1600: RscButton
        {
            idc = 1600;
            style = 2;
            text = "General Equipment";
            x = 0.407187 * safezoneW + safezoneX;
            y = 0.258 * safezoneH + safezoneY;
            w = 0.0876563 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "[""general""] call SC_fnc_setupEquipmentDialog;";
        };
        class RscButton_1601: RscButton
        {
            idc = 1601;
            style = 2;
            text = "MRKS [Rank 7]";
            x = 0.469062 * safezoneW + safezoneX;
            y = 0.291 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "[""marksman""] call SC_fnc_setupEquipmentDialog;";
        };
        class RscButton_1602: RscButton
        {
            idc = 1602;
            style = 2;
            text = "EXPR [Rank 1]";
            x = 0.391719 * safezoneW + safezoneX;
            y = 0.291 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "[""experience""] call SC_fnc_setupEquipmentDialog;";
        };
        class RscButton_1603: RscButton
        {
            idc = 1603;
            style = 2;
            text = "MEDC [Rank 5]";
            x = 0.391719 * safezoneW + safezoneX;
            y = 0.324 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "[""medic""] call SC_fnc_setupEquipmentDialog;";
        };
        class RscButton_1604: RscButton
        {
            idc = 1604;
            style = 2;
            text = "SUPR [Rank 25]";
            x = 0.546406 * safezoneW + safezoneX;
            y = 0.357 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "[""suppressor""] call SC_fnc_setupEquipmentDialog;";
        };
        class RscButton_1605: RscButton
        {
            idc = 1605;
            style = 2;
            text = "MGNR [Rank 10]";
            x = 0.469062 * safezoneW + safezoneX;
            y = 0.324 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "[""machinegunner""] call SC_fnc_setupEquipmentDialog;";
        };
        class RscButton_1606: RscButton
        {
            idc = 1606;
            style = 2;
            text = "LNCR [Rank 15]";
            x = 0.469062 * safezoneW + safezoneX;
            y = 0.357 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "[""launcher""] call SC_fnc_setupEquipmentDialog;";
        };
        class RscButton_1607: RscButton
        {
            idc = 1607;
            style = 2;
            text = "ARMR [Rank 18]";
            x = 0.546406 * safezoneW + safezoneX;
            y = 0.291 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "[""armor""] call SC_fnc_setupEquipmentDialog;";
        };
        class RscButton_1608: RscButton
        {
            idc = 1608;
            style = 2;
            text = "GRND [Rank 20]";
            x = 0.546406 * safezoneW + safezoneX;
            y = 0.324 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "[""grenadier""] call SC_fnc_setupEquipmentDialog;";
        };
        class RscButton_1609: RscButton
        {
            idc = 1609;
            style = 2;
            text = "STAM [Rank 5]";
            x = 0.391719 * safezoneW + safezoneX;
            y = 0.357 * safezoneH + safezoneY;
            w = 0.0670312 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "[""stamina""] call SC_fnc_setupEquipmentDialog;";
        };
        class RscButton_1610: RscButton
        {
            idc = 1610;
            style = 2;
            text = " Vehicles & Aircraft";
            x = 0.510312 * safezoneW + safezoneX;
            y = 0.258 * safezoneH + safezoneY;
            w = 0.0876563 * safezoneW;
            h = 0.022 * safezoneH;
            colorBackground[] = {0.2,0.2,0.2,1};
            onButtonClick = "[""vehicles""] call SC_fnc_setupEquipmentDialog;";
        };
        class _CT_CONTROLSTABLE
		{
			idc = 1611;
            x = 0.351719 * safezoneW + safezoneX;
            y = 0.39 * safezoneH + safezoneY;
            w = 0.301719 * safezoneW;
            h = 0.363 * safezoneH;
			
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
					controlBaseClassPath[] = {"RscText"};
					columnX = 0;
					columnW = 0.301719 * (100 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Picture
				{
					controlBaseClassPath[] = {"RscPictureKeepAspect"};
					columnX = 0.301719 * (0 / 100) * safezoneW;
					columnW = 0.301719 * (20 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Name
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.301719 * (20 / 100) * safezoneW;
					columnW = 0.301719 * (60 / 100) * safezoneW;
					controlH = 0.036 * safezoneH;
					controlOffsetY = 0;
				};
				class Rank
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.301719 * (80 / 100) * safezoneW;
					columnW = 0.301719 * (20 / 100) * safezoneW;
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
					columnW = 0.301719 * (100 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
                class Picture
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.301719 * (0 / 100) * safezoneW;
					columnW = 0.301719 * (20 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Name
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.301719 * (20 / 100) * safezoneW;
					columnW = 0.301719 * (60 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
				class Rank
				{
					controlBaseClassPath[] = {"RscText"};
					columnX = 0.301719 * (80 / 100) * safezoneW;
					columnW = 0.301719 * (20 / 100) * safezoneW;
					controlH = 0.025 * safezoneH;
					controlOffsetY = 0;
				};
			};
		};
    };
};