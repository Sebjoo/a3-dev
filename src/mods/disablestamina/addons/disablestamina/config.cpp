class CfgPatches {
    class disablestamina {
        units[] = {"moduleDisableStamina"};
        requiredVersion = 1;
        requiredAddons[] = {"A3_Modules_F"};
    };
};

class CfgFactionClasses {
    class NO_CATEGORY;
    class moduleDisableStamina: NO_CATEGORY {
        displayName = "Disable Stamina";
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

    class moduleDisableStamina: Module_F {
        scope = 2;
        displayName = "Disable Stamina";
        icon = "\A3\ui_f\data\GUI\Rsc\RscDisplayGarage\animationSources_ca.paa";
        category = "NO_CATEGORY";
        function = "DS_fnc_moduleDisableStamina";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 1;
        isDisposable = 0;
        is3DEN = 0;
        curatorInfoType = "RscDisplayAttributeModuleDisableStamina";

        class Attributes: AttributesBase {
            class weaponSwayEnabled: Combo {
                property = "moduleDisableStamina_weaponSwayEnabled";
                displayName = "Weapon sway when enabled";
                tooltip = "Amount of weapon sway when stamina is enabled";
                typeName = "NUMBER";
                defaultValue = "1";
                
                class Values {
                    class 0 {
                        name = "0%";
                        value = 0;
                    };
                    class 0_1 {
                        name = "10%";
                        value = 0.1;
                    };
                    class 0_2 {
                        name = "20%";
                        value = 0.2;
                    };
                    class 0_3 {
                        name = "30%";
                        value = 0.3;
                    };
                    class 0_4 {
                        name = "40%";
                        value = 0.4;
                    };
                    class 0_5 {
                        name = "50%";
                        value = 0.5;
                    };
                    class 0_6 {
                        name = "60%";
                        value = 0.6;
                    };
                    class 0_7 {
                        name = "70%";
                        value = 0.7;
                    };
                    class 0_8 {
                        name = "80%";
                        value = 0.8;
                    };
                    class 0_9 {
                        name = "90%";
                        value = 0.9;
                    };
                    class 1 {
                        name = "100%";
                        value = 1;
                    };
                };
            };

            class weaponSwayDisabled: Combo {
                property = "moduleDisableStamina_weaponSwayDisabled";
                displayName = "Weapon sway when disabled";
                tooltip = "Amount of weapon sway when stamina is disabled";
                typeName = "NUMBER";
                defaultValue = "0.3";
                
                class Values {
                    class 0 {
                        name = "0%";
                        value = 0;
                    };
                    class 0_1 {
                        name = "10%";
                        value = 0.1;
                    };
                    class 0_2 {
                        name = "20%";
                        value = 0.2;
                    };
                    class 0_3 {
                        name = "30%";
                        value = 0.3;
                    };
                    class 0_4 {
                        name = "40%";
                        value = 0.4;
                    };
                    class 0_5 {
                        name = "50%";
                        value = 0.5;
                    };
                    class 0_6 {
                        name = "60%";
                        value = 0.6;
                    };
                    class 0_7 {
                        name = "70%";
                        value = 0.7;
                    };
                    class 0_8 {
                        name = "80%";
                        value = 0.8;
                    };
                    class 0_9 {
                        name = "90%";
                        value = 0.9;
                    };
                    class 1 {
                        name = "100%";
                        value = 1;
                    };
                };
            };

            class ModuleDescription: ModuleDescription {};
        };

        class ModuleDescription: ModuleDescription {
            description = "This module disables stamina for all units.";
            sync[] = {};
        };
    };
};

class CfgFunctions {
    class disablestamina {
        class main {
            file = "disablestamina\scripts";
        };
    };

    class DS {
        class NO_CATEGORY {
            file = "\disablestamina\functions";
            class moduleDisableStamina {};
        };
    };
};