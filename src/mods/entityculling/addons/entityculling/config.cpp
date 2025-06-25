class CfgPatches {
    class entityculling {
        units[] = {"moduleEntityCulling"};
        requiredVersion = 1;
        requiredAddons[] = {"A3_Modules_F"};
    };
};

class CfgFactionClasses {
    class NO_CATEGORY;
    class moduleEntityCulling: NO_CATEGORY {
        displayName = "Dynamic Weather";
    };
};

class CfgVehicles {
    class Logic;

    class Module_F: Logic {
        class AttributesBase {
            class Default;
            class Edit;
            class Combo;
            class Checkbox;
            class CheckboxNumber;
            class ModuleDescription;
        };

        class ModuleDescription {
            class AnyBrain;
        };
    };

    class moduleEntityCulling: Module_F {
        scope = 2;
        displayName = "Dynamic Weather";
        icon = "\A3\ui_f\data\GUI\Rsc\RscDisplayArcadeMap\cloudly_ca.paa";
        category = "Environment";
        function = "DW_fnc_moduleEntityCulling";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 1;
        isDisposable = 0;
        is3DEN = 0;
        curatorInfoType = "RscDisplayAttributemoduleEntityCulling";

        class Attributes: AttributesBase {
            

            class ModuleDescription: ModuleDescription {};
        };

        class ModuleDescription: ModuleDescription {
            description = "This module sets random weather once it is triggered. There will be a short freeze. Then it changes the weather randomly according to the settings defined in the module. There are 2 alternating phases. In phase 1 the weather changes. In phase 2 it remains static so the clients can sync to the server. This is necesarry to ensure synced weather in multiplayer. It works in singleplayer as well. In order for this module to work correctly there should not be any other scripts trying to set the time multiplier.";
            sync[] = {};
        };
    };
};

class CfgFunctions {
    class entityculling {
        class main {
            file = "entityculling\scripts";
        };
    };

    class DW {
        class Environment {
            file = "\entityculling\functions";
            class moduleEntityCulling {};
        };
    };
};