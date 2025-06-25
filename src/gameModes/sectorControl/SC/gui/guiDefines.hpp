class RscCheckBox
{
	idc = -1;
	type = 77;
	style = 0;
	checked = 0;
	x = "0.375 * safezoneW + safezoneX";
	y = "0.36 * safezoneH + safezoneY";
	w = "0.025 * safezoneW";
	h = "0.04 * safezoneH";
	color[] = 
	{
		1,
		1,
		1,
		0.7
	};
	colorFocused[] = 
	{
		1,
		1,
		1,
		1
	};
	colorHover[] = 
	{
		1,
		1,
		1,
		1
	};
	colorPressed[] = 
	{
		1,
		1,
		1,
		1
	};
	colorDisabled[] = 
	{
		1,
		1,
		1,
		0.2
	};
	colorBackground[] = 
	{
		0,
		0,
		0,
		0
	};
	colorBackgroundFocused[] = 
	{
		0,
		0,
		0,
		0
	};
	colorBackgroundHover[] = 
	{
		0,
		0,
		0,
		0
	};
	colorBackgroundPressed[] = 
	{
		0,
		0,
		0,
		0
	};
	colorBackgroundDisabled[] = 
	{
		0,
		0,
		0,
		0
	};
	textureChecked = "A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	textureUnchecked = "A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	textureFocusedChecked = "A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	textureFocusedUnchecked = "A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	textureHoverChecked = "A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	textureHoverUnchecked = "A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	texturePressedChecked = "A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	texturePressedUnchecked = "A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	textureDisabledChecked = "A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	textureDisabledUnchecked = "A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	tooltipColorText[] = 
	{
		1,
		1,
		1,
		1
	};
	tooltipColorBox[] = 
	{
		1,
		1,
		1,
		1
	};
	tooltipColorShade[] = 
	{
		0,
		0,
		0,
		0.65
	};
	soundEnter[] = 
	{
		"",
		0.1,
		1
	};
	soundPush[] = 
	{
		"",
		0.1,
		1
	};
	soundClick[] = 
	{
		"",
		0.1,
		1
	};
	soundEscape[] = 
	{
		"",
		0.1,
		1
	};
};

class RscText
{
	deletable = 0;
	fade = 0;
	access = 0;
	type = 0;
	idc = -1;
	colorBackground[] = 
	{
		0,
		0,
		0,
		0
	};
	colorText[] = 
	{
		1,
		1,
		1,
		1
	};
	text = "";
	fixedWidth = 0;
	x = 0;
	y = 0;
	h = 0.037;
	w = 0.3;
	style = 0;
	shadow = 1;
	colorShadow[] = 
	{
		0,
		0,
		0,
		0.5
	};
	font = "RobotoCondensed";
	SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	linespacing = 1;
	tooltipColorText[] = 
	{
		1,
		1,
		1,
		1
	};
	tooltipColorBox[] = 
	{
		1,
		1,
		1,
		1
	};
	tooltipColorShade[] = 
	{
		0,
		0,
		0,
		0.65
	};
};

class RscCombo
{
	deletable = 0;
	fade = 0;
	access = 0;
	type = 4;
	colorSelect[] = 
	{
		0,
		0,
		0,
		1
	};
	colorText[] = 
	{
		1,
		1,
		1,
		1
	};
	colorBackground[] = 
	{
		0,
		0,
		0,
		1
	};
	colorScrollbar[] = 
	{
		1,
		0,
		0,
		1
	};
	colorPicture[] = 
	{
		1,
		1,
		1,
		1
	};
	colorPictureSelected[] = 
	{
		1,
		1,
		1,
		1
	};
	colorPictureDisabled[] = 
	{
		1,
		1,
		1,
		0.25
	};
	colorPictureRight[] = 
	{
		1,
		1,
		1,
		1
	};
	colorPictureRightSelected[] = 
	{
		1,
		1,
		1,
		1
	};
	colorPictureRightDisabled[] = 
	{
		1,
		1,
		1,
		0.25
	};
	tooltipColorText[] = 
	{
		1,
		1,
		1,
		1
	};
	tooltipColorBox[] = 
	{
		1,
		1,
		1,
		1
	};
	tooltipColorShade[] = 
	{
		0,
		0,
		0,
		0.65
	};
	soundSelect[] = 
	{
		"\A3\ui_f\data\sound\RscCombo\soundSelect",
		0.1,
		1
	};
	soundExpand[] = 
	{
		"\A3\ui_f\data\sound\RscCombo\soundExpand",
		0.1,
		1
	};
	soundCollapse[] = 
	{
		"\A3\ui_f\data\sound\RscCombo\soundCollapse",
		0.1,
		1
	};
	maxHistoryDelay = 1;
	class ComboScrollBar
	{
		color[] = 
		{
		1,1,1,1
		};
	};
	style = "0x10 + 0x200";
	font = "RobotoCondensed";
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	shadow = 0;
	x = 0;
	y = 0;
	w = 0.12;
	h = 0.035;
	colorSelectBackground[] = 
	{
		1,
		1,
		1,
		0.7
	};
	arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";
	arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";
	wholeHeight = 0.45;
	colorActive[] = 
	{
0.761,0.357,0.337,1
	};
	colorDisabled[] = 
	{
		1,
		1,
		1,
		0.25
	};
	colorTextRight[] = 
	{
		1,
		1,
		1,
		1
	};
	colorSelectRight[] = 
	{
		0,
		0,
		0,
		1
	};
	colorSelect2Right[] = 
	{
		0,
		0,
		0,
		1
	};
};

class RscSlider
{
    style = "0x400 + 0x10";
    type = 43;  // this is the more "modern" slider. Type = 3 is the old dull one.
    shadow = 0;
    color[] = {1,1,1,0.4};
    colorActive[] = {1,1,1,1};
    colorDisabled[] = {0.5,0.5,0.5,0.2};
    arrowEmpty = "\A3\ui_f\data\gui\cfg\slider\arrowEmpty_ca.paa";
    arrowFull = "\A3\ui_f\data\gui\cfg\slider\arrowFull_ca.paa";
    border = "\A3\ui_f\data\gui\cfg\slider\border_ca.paa";
    thumb = "\A3\ui_f\data\gui\cfg\slider\thumb_ca.paa";
};

class RscPicture {
    style = 0x30 + 1;
    shadow = 2;
    colorFocused[] = {1, 1, 1, 1};
    colorBackground[] = {0, 0, 0, 0};
    SizeEx = 0.045;
    font = "RobotoCondensed";
    type = CT_STATIC;
}

class RscButton {
    access = 0;
    type = 1;
    style = 0;
    text = "";
    font = "RobotoCondensed";
    sizeEx = 0.04;
    colorText[] = {1, 1, 1, 1};
    colorDisabled[] = {0.2, 0.2, 0.2, 1};
    colorBackground[] = {0.2, 0.2, 0.2, 1};
    colorBackgroundDisabled[] = {0.2, 0.2, 0.2, 1};
    colorBackgroundActive[] = {0.4, 0.4, 0.4, 1};
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    colorFocused[] = {0.2, 0.2, 0.2, 1};
    colorShadow[] = {0, 0, 0, 0};
    shadow = 0;
    colorBorder[] = {0, 0, 0, 0};
    borderSize = 0;
    soundEnter[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEnter", 0.09, 1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundPush", 0.09, 1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundClick", 0.09, 1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEscape", 0.09, 1};
};

class RscFrame {
    type = CT_STATIC;
    style = 160;
    shadow = 2;
    colorBackground[] = {0, 0, 0, 1};
    colorText[] = {0, 0, 0, 1};
    font = "RobotoCondensed";
    sizeEx = 0.4;
    text = "";
};

class RscListBox {
    access = 0;
    type = 5;
    style = 0;
    font = "RobotoCondensed";
    sizeEx = 0.04;
    rowHeight = 0;
    colorText[] = {1, 1, 1, 1};
    colorScrollbar[] = {1, 1, 1, 1};
    colorselect[] = {1, 1, 1, 1};
    colorSelect2[] = {1, 1, 1, 1};
    colorSelectBackground[] = {0, 0, 0, 0};
    colorSelectBackground2[] = {0, 0, 0, 0};
    colorBackground[] = {0, 0, 0, 1};
    colorDisabled[] = {0, 0, 0, 1};
    maxHistoryDelay = 1.0;
    soundselect[] = {"", 0.1, 1};
    period = 1;
    autoScrollSpeed = -1;
    autoScrollDelay = 5;
    autoScrollRewind = 0;
    arrowEmpty = "#(argb, 8, 8, 3)color(1, 1, 1, 1)";
    arrowFull = "#(argb, 8, 8, 3)color(1, 1, 1, 1)";
    shadow = 0;
    class ListScrollBar {
        color[] = {1, 1, 1, 0.6};
        colorActive[] = {1, 1, 1, 1};
        colorDisabled[] = {1, 1, 1, 0.3};
        thumb = "#(argb, 8, 8, 3)color(1, 1, 1, 1)";
        arrowEmpty = "#(argb, 8, 8, 3)color(1, 1, 1, 1)";
        arrowFull = "#(argb, 8, 8, 3)color(1, 1, 1, 1)";
        border = "#(argb, 8, 8, 3)color(1, 1, 1, 1)";
        shadow = 0;
    };
};

class RscStructuredText {
    access = 0;
    type = CT_STATIC;
    style = 2;
    linespacing = 1;
    colorBackground[] = {0, 0, 0, 0};
    colorText[] = {1, 1, 1, 1};
    text = "";
    shadow = 2;
    font = "RobotoCondensed";
    SizeEx = 0.04;
    fixedWidth = 0;
    x = 0;
    y = 0;
    h = 0;
    w = 0;
};

#define CT_MAP_MAIN 101
#define ST_PICTURE 48

class RscMapControl {
    moveOnEdges = 0;
    shadow = 0;
    ptsPerSquareSea = 5;
    ptsPerSquareTxt = 20;
    ptsPerSquareCLn = 10;
    ptsPerSquareExp = 10;
    ptsPerSquareCost = 10;
    ptsPerSquareFor = 9;
    ptsPerSquareForEdge = 9;
    ptsPerSquareRoad = 6;
    ptsPerSquareObj = 9;
    showCountourInterval = 0;
    scaleMin = 0.001;
    scaleMax = 1.0;
    scaleDefault = 0.16;
    maxSatelliteAlpha = 0.85;
    alphaFadeStartScale = 2;
    alphaFadeEndScale = 2;
    colorBackground[] = {0.969, 0.957, 0.949, 1.0};
    colorText[] = {0, 0, 0, 0};
    colorSea[] = {0.467, 0.631, 0.851, 0.5};
    colorForest[] = {0.624, 0.78, 0.388, 0.5};
    colorForestBorder[] = {0.0, 0.0, 0.0, 0.0};
    colorRocks[] = {0.0, 0.0, 0.0, 0.3};
    colorRocksBorder[] = {0.0, 0.0, 0.0, 0.0};
    colorLevels[] = {0.286, 0.177, 0.094, 0.5};
    colorMainCountlines[] = {0.572, 0.354, 0.188, 0.5};
    colorCountlines[] = {0.572, 0.354, 0.188, 0.25};
    colorMainCountlinesWater[] = {0.491, 0.577, 0.702, 0.6};
    colorCountlinesWater[] = {0.491, 0.577, 0.702, 0.3};
    colorPowerLines[] = {0.1, 0.1, 0.1, 1.0};
    colorRailWay[] = {0.8, 0.2, 0.0, 1.0};
    colorNames[] = {0.1, 0.1, 0.1, 0.9};
    colorInactive[] = {1.0, 1.0, 1.0, 0.5};
    colorOutside[] = {0.0, 0.0, 0.0, 1.0};
    colorTracks[] = {0.84, 0.76, 0.65, 0.15};
    colorTracksFill[] = {0.84, 0.76, 0.65, 1.0};
    colorRoads[] = {0.7, 0.7, 0.7, 1.0};
    colorRoadsFill[] = {1.0, 1.0, 1.0, 1.0};
    colorMainRoads[] = {0.9, 0.5, 0.3, 1.0};
    colorMainRoadsFill[] = {1.0, 0.6, 0.4, 1.0};
    colorGrid[] = {0.1, 0.1, 0.1, 0.6};
    colorGridMap[] = {0.1, 0.1, 0.1, 0.6};
    font = "TahomaB";
    sizeEx = 0.040000;
    fontLabel = "RobotoCondensed";
    sizeExLabel = "(((((safezoneW/safezoneH)min 1.2)/1.2)/25)*0.8)";
    fontGrid = "TahomaB";
    sizeExGrid = 0.02;
    fontUnits = "TahomaB";
    sizeExUnits = "(((((safezoneW/safezoneH)min 1.2)/1.2)/25)*0.8)";
    fontNames = "EtelkaNarrowMediumPro";
    sizeExNames = "(((((safezoneW/safezoneH)min 1.2)/1.2)/25)*0.8)*2";
    fontInfo = "RobotoCondensed";
    sizeExInfo = "(((((safezoneW/safezoneH)min 1.2)/1.2)/25)*0.8)";
    fontLevel = "TahomaB";
    sizeExLevel = 0.02;
    text = "#(argb, 8, 8, 3)color(1, 1, 1, 1)";
    class Legend {
        x = "SafeZoneX+(((safezoneW/safezoneH)min 1.2)/40)";
        y = "SafeZoneY+safezoneH-4.5*((((safezoneW/safezoneH)min 1.2)/1.2)/25)";
        w = "10*(((safezoneW/safezoneH)min 1.2)/40)";
        h = "3.5*((((safezoneW/safezoneH)min 1.2)/1.2)/25)";
        font = "RobotoCondensed";
        sizeEx = "(((((safezoneW/safezoneH)min 1.2)/1.2)/25)*0.8)";
        colorBackground[] = {1, 1, 1, 0.5};
        color[] = {0, 0, 0, 1};
    };
    class Task {
        icon = "\A3\ui_f\data\map\mapcontrol\taskIcon_CA.paa";
        iconCreated = "\A3\ui_f\data\map\mapcontrol\taskIconCreated_CA.paa";
        iconCanceled = "\A3\ui_f\data\map\mapcontrol\taskIconCanceled_CA.paa";
        iconDone = "\A3\ui_f\data\map\mapcontrol\taskIconDone_CA.paa";
        iconFailed = "\A3\ui_f\data\map\mapcontrol\taskIconFailed_CA.paa";
        color[] = {"(profilenamespace getvariable['IGUI_TEXT_RGB_R', 0])", "(profilenamespace getvariable['IGUI_TEXT_RGB_G', 1])", "(profilenamespace getvariable['IGUI_TEXT_RGB_B', 1])", "(profilenamespace getvariable['IGUI_TEXT_RGB_A', 0.8])"};
        colorCreated[] = {1, 1, 1, 1};
        colorCanceled[] = {0.7, 0.7, 0.7, 1};
        colorDone[] = {0.7, 1, 0.3, 1};
        colorFailed[] = {1, 0.3, 0.2, 1};
        size = 27;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class Waypoint {
        icon = "\A3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
        color[] = {0.00, 0.00, 0.00, 1.00};
        size = 24;
        importance = 1.00;
        coefMin = 1.00;
        coefMax = 1.00;
    };
    class WaypointCompleted {
        icon = "\A3\ui_f\data\map\mapcontrol\waypointCompleted_ca.paa";
        color[] = {0.00, 0.00, 0.00, 1.00};
        size = 24;
        importance = 1.00;
        coefMin = 1.00;
        coefMax = 1.00;
    };
    class ActiveMarker {
        color[] = {0.30, 0.10, 0.90, 1.00};
        size = 50;
    };
    class CustomMark {
        icon = "\A3\ui_f\data\map\mapcontrol\custommark_ca.paa";
        size = 24;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
        color[] = {0, 0, 0, 1};
    };
    class Command {
        icon = "\A3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
        size = 18;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
        color[] = {1, 1, 1, 1};
    };
    class Bush {
        icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
        color[] = {0.45, 0.64, 0.33, 0.4};
        size = "14/2";
        importance = "0.2 * 14 *0.05 * 0.05";
        coefMin = 0.25;
        coefMax = 4;
    };
    class Rock {
        icon = "\A3\ui_f\data\map\mapcontrol\rock_ca.paa";
        color[] = {0.1, 0.1, 0.1, 0.8};
        size = 12;
        importance = "0.5 * 12 *0.05";
        coefMin = 0.25;
        coefMax = 4;
    };
    class SmallTree {
        icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
        color[] = {0.45, 0.64, 0.33, 0.4};
        size = 12;
        importance = "0.6 * 12 *0.05";
        coefMin = 0.25;
        coefMax = 4;
    };
    class Tree {
        icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
        color[] = {0.45, 0.64, 0.33, 0.4};
        size = 12;
        importance = "0.9 * 16 *0.05";
        coefMin = 0.25;
        coefMax = 4;
    };
    class busstop {
        icon = "\A3\ui_f\data\map\mapcontrol\busstop_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {1, 1, 1, 1};
    };
    class fuelstation {
        icon = "\A3\ui_f\data\map\mapcontrol\fuelstation_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {1, 1, 1, 1};
    };
    class hospital {
        icon = "\A3\ui_f\data\map\mapcontrol\hospital_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {1, 1, 1, 1};
    };
    class church {
        icon = "\A3\ui_f\data\map\mapcontrol\church_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {1, 1, 1, 1};
    };
    class lighthouse {
        icon = "\A3\ui_f\data\map\mapcontrol\lighthouse_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {1, 1, 1, 1};
    };
    class power {
        icon = "\A3\ui_f\data\map\mapcontrol\power_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {1, 1, 1, 1};
    };
    class powersolar {
        icon = "\A3\ui_f\data\map\mapcontrol\powersolar_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {1, 1, 1, 1};
    };
    class powerwave {
        icon = "\A3\ui_f\data\map\mapcontrol\powerwave_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {1, 1, 1, 1};
    };
    class powerwind {
        icon = "\A3\ui_f\data\map\mapcontrol\powerwind_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {1, 1, 1, 1};
    };
    class quay {
        icon = "\A3\ui_f\data\map\mapcontrol\quay_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {1, 1, 1, 1};
    };
    class transmitter {
        icon = "\A3\ui_f\data\map\mapcontrol\transmitter_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {1, 1, 1, 1};
    };
    class watertower {
        icon = "\A3\ui_f\data\map\mapcontrol\watertower_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {1, 1, 1, 1};
    };
    class Cross {
        icon = "\A3\ui_f\data\map\mapcontrol\Cross_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {0, 0, 0, 1};
    };
    class Chapel {
        icon = "\A3\ui_f\data\map\mapcontrol\Chapel_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {0, 0, 0, 1};
    };
    class Shipwreck {
        icon = "\A3\ui_f\data\map\mapcontrol\Shipwreck_CA.paa";
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1.0;
        color[] = {0, 0, 0, 1};
    };
    class Bunker {
        icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
        size = 14;
        importance = "1.5 * 14 *0.05";
        coefMin = 0.25;
        coefMax = 4;
        color[] = {0, 0, 0, 1};
    };
    class Fortress {
        icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
        size = 16;
        importance = "2 * 16 *0.05";
        coefMin = 0.25;
        coefMax = 4;
        color[] = {0, 0, 0, 1};
    };
    class Fountain {
        icon = "\A3\ui_f\data\map\mapcontrol\fountain_ca.paa";
        size = 11;
        importance = "1 * 12 *0.05";
        coefMin = 0.25;
        coefMax = 4;
        color[] = {0, 0, 0, 1};
    };
    class Ruin {
        icon = "\A3\ui_f\data\map\mapcontrol\ruin_ca.paa";
        size = 16;
        importance = "1.2 * 16 *0.05";
        coefMin = 1;
        coefMax = 4;
        color[] = {0, 0, 0, 1};
    };
    class Stack {
        icon = "\A3\ui_f\data\map\mapcontrol\stack_ca.paa";
        size = 20;
        importance = "2 * 16 *0.05";
        coefMin = 0.9;
        coefMax = 4;
        color[] = {0, 0, 0, 1};
    };
    class Tourism {
        icon = "\A3\ui_f\data\map\mapcontrol\tourism_ca.paa";
        size = 16;
        importance = "1 * 16 *0.05";
        coefMin = 0.7;
        coefMax = 4;
        color[] = {0, 0, 0, 1};
    };
    class ViewTower {
        icon = "\A3\ui_f\data\map\mapcontrol\viewtower_ca.paa";
        size = 16;
        importance = "2.5 * 16 *0.05";
        coefMin = 0.5;
        coefMax = 4;
        color[] = {0, 0, 0, 1};
    };
};

#define CT_CONTROLS_TABLE 19