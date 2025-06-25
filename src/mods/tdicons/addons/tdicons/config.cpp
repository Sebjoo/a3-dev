class CfgPatches {
    class tdicons {
        units[] = {"moduleTdIcons"};
        requiredVersion = 1;
        requiredAddons[] = {"A3_Modules_F"};
    };
};

class CfgFactionClasses {
    class NO_CATEGORY;
    class moduleTdIcons: NO_CATEGORY {
        displayName = "3D Icons";
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

    class moduleTdIcons: Module_F {
        scope = 2;
        displayName = "3D Icons";
        icon = "\A3\ui_f\data\GUI\Rsc\RscDisplayGarage\animationSources_ca.paa";
        category = "NO_CATEGORY";
        function = "TDI_fnc_moduleTdIcons";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 1;
        isDisposable = 0;
        is3DEN = 0;
        curatorInfoType = "RscDisplayAttributeModuleTdIcons";

        class Attributes: AttributesBase {
            class ShowAllSides: Combo {
                property = "moduleTdIcons_showAllSides";
                displayName = "Show all sides";
                tooltip = "toggles whether units of all sides are displayed";
                typeName = "NUMBER";
                defaultValue = "0";
                
                class Values {
                    class Enabled {
                        name = "Enabled";
                        value = 1;
                    };
                    class Disabled {
                        name = "Disabled";
                        value = 0;
                    };
                };
            };

            class showAllSidesOnSpectator: Combo {
                property = "moduleTdIcons_showAllSidesOnSpectator";
                displayName = "Show all sides when in spectator";
                tooltip = "toggles whether units of all sides are displayed when in spectator";
                typeName = "NUMBER";
                defaultValue = "0";
                
                class Values {
                    class Enabled {
                        name = "Enabled";
                        value = 1;
                    };
                    class Disabled {
                        name = "Disabled";
                        value = 0;
                    };
                };
            };

            class shoWUnitNames: Combo {
                property = "moduleTdIcons_shoWUnitNames";
                displayName = "Show Unit Names";
                tooltip = "toggles whether the names of units are shown below the icons";
                typeName = "NUMBER";
                defaultValue = "1";
                
                class Values {
                    class Enabled {
                        name = "Enabled";
                        value = 1;
                    };
                    class Disabled {
                        name = "Disabled";
                        value = 0;
                    };
                };
            };

            class hideInvisible: Combo {
                property = "moduleTdIcons_hideInvisible";
                displayName = "Hide invisible";
                tooltip = "toggles whether the icons of units, that are not visible, are hidden";
                typeName = "NUMBER";
                defaultValue = "1";
                
                class Values {
                    class Enabled {
                        name = "Enabled";
                        value = 1;
                    };
                    class Disabled {
                        name = "Disabled";
                        value = 0;
                    };
                };
            };

            class showGroupIcons: Combo {
                property = "moduleTdIcons_showGroupIcons";
                displayName = "Show Group Icons";
                tooltip = "toggles whether to show group icons (if enabled, please disable group icons in the difficulty settings)";
                typeName = "NUMBER";
                defaultValue = "0";
                
                class Values {
                    class Enabled {
                        name = "Enabled";
                        value = 1;
                    };
                    class Disabled {
                        name = "Disabled";
                        value = 0;
                    };
                };
            };

            class hideInvisibleGroupMembers: Combo {
                property = "moduleTdIcons_hideInvisibleGroupMembers";
                displayName = "Hide invisible Group Members";
                tooltip = "toggles whether the icons of group members, that are not visible, are hidden";
                typeName = "NUMBER";
                defaultValue = "0";
                
                class Values {
                    class Enabled {
                        name = "Enabled";
                        value = 1;
                    };
                    class Disabled {
                        name = "Disabled";
                        value = 0;
                    };
                };
            };

            class ModuleDescription: ModuleDescription {};
        };

        class ModuleDescription: ModuleDescription {
            description = "This module displays 3D Icons for each unit and UAVs controlled by it.";
            sync[] = {};
        };
    };
};

class CfgFunctions {
    class tdicons {
        class main {
            file = "tdicons\scripts";
        };
    };

    class TDI {
        class NO_CATEGORY {
            file = "\tdicons\functions";
            class moduleTdIcons {};
        };
    };
};