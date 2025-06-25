class CfgPatches {
    class autoheal {
        units[] = {"moduleAutoHeal"};
        requiredVersion = 1;
        requiredAddons[] = {"A3_Modules_F"};
    };
};

class CfgFactionClasses {
    class NO_CATEGORY;
    class moduleAutoHeal: NO_CATEGORY {
        displayName = "Auto Heal";
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

    class moduleAutoHeal: Module_F {
        scope = 2;
        displayName = "Auto Heal";
        icon = "\A3\ui_f\data\GUI\Rsc\RscDisplayGarage\animationSources_ca.paa";
        category = "NO_CATEGORY";
        function = "AH_fnc_moduleAutoHeal";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 1;
        isDisposable = 0;
        is3DEN = 0;
        curatorInfoType = "RscDisplayAttributeModuleAutoHeal";

        class Attributes: AttributesBase {
            class healSpeed: Combo {
                property = "moduleAutoHeal_healSpeed";
                displayName = "Heal speed";
                tooltip = "factor, by which the default speed of healing gets multiplied";
                typeName = "NUMBER";
                defaultValue = "1";
                
                class Values {
                    class 0_1 {
                        name = "10%";
                        value = 0.1;
                    };
                    class 0_25 {
                        name = "25%";
                        value = 0.25;
                    };
                    class 0_5 {
                        name = "50%";
                        value = 0.5;
                    };
                    class 0_75 {
                        name = "75%";
                        value = 0.75;
                    };
                    class 1 {
                        name = "100%";
                        value = 1;
                    };
                    class 1_25 {
                        name = "125%";
                        value = 1.25;
                    };
                    class 1_5 {
                        name = "150%";
                        value = 1.5;
                    };
                    class 2 {
                        name = "200%";
                        value = 2;
                    };
                    class 5 {
                        name = "500%";
                        value = 5;
                    };
                    class 10 {
                        name = "1000%";
                        value = 10;
                    };
                };
            };

            class healCooldown: Combo {
                property = "moduleAutoHeal_healCooldown";
                displayName = "Heal cooldown";
                tooltip = "time, after which a unit starts to heal";
                typeName = "NUMBER";
                defaultValue = "12";
                
                class Values {
                    class 1 {
                        name = "1s";
                        value = 1;
                    };
                    class 2 {
                        name = "2s";
                        value = 2;
                    };
                    class 5 {
                        name = "5s";
                        value = 5;
                    };
                    class 8 {
                        name = "8s";
                        value = 8;
                    };
                    class 10 {
                        name = "10s";
                        value = 10;
                    };
                    class 12 {
                        name = "12s";
                        value = 12;
                    };
                    class 15 {
                        name = "15s";
                        value = 15;
                    };
                    class 20 {
                        name = "20s";
                        value = 20;
                    };
                    class 30 {
                        name = "30s";
                        value = 30;
                    };
                    class 40 {
                        name = "40s";
                        value = 40;
                    };
                    class 50 {
                        name = "50s";
                        value = 50;
                    };
                    class 60 {
                        name = "60s";
                        value = 60;
                    };
                };
            };

            class healCooldownMedic: Combo {
                property = "moduleAutoHeal_healCooldownMedic";
                displayName = "Medic heal cooldown";
                tooltip = "time, after which a medic unit starts to heal";
                typeName = "NUMBER";
                defaultValue = "8";
                
                class Values {
                    class 1 {
                        name = "1s";
                        value = 1;
                    };
                    class 2 {
                        name = "2s";
                        value = 2;
                    };
                    class 5 {
                        name = "5s";
                        value = 5;
                    };
                    class 8 {
                        name = "8s";
                        value = 8;
                    };
                    class 10 {
                        name = "10s";
                        value = 10;
                    };
                    class 12 {
                        name = "12s";
                        value = 12;
                    };
                    class 15 {
                        name = "15s";
                        value = 15;
                    };
                    class 20 {
                        name = "20s";
                        value = 20;
                    };
                    class 30 {
                        name = "30s";
                        value = 30;
                    };
                    class 40 {
                        name = "40s";
                        value = 40;
                    };
                    class 50 {
                        name = "50s";
                        value = 50;
                    };
                    class 60 {
                        name = "60s";
                        value = 60;
                    };
                };
            };

            class ModuleDescription: ModuleDescription {};
        };

        class ModuleDescription: ModuleDescription {
            description = "This module makes every unit heal automatically at a configurable speed after a configurable time.";
            sync[] = {};
        };
    };
};

class CfgFunctions {
    class autoheal {
        class main {
            file = "autoheal\scripts";
        };
    };

    class AH {
        class NO_CATEGORY {
            file = "\autoheal\functions";
            class moduleAutoHeal {};
        };
    };
};