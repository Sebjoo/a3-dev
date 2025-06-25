class CfgPatches {
    class mapmarker {
        units[] = {"moduleMapMarker"};
        requiredVersion = 1;
        requiredAddons[] = {"A3_Modules_F"};
    };
};

class CfgFactionClasses {
    class NO_CATEGORY;
    class moduleMapMarker: NO_CATEGORY {
        displayName = "Map Marker";
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

    class moduleMapMarker: Module_F {
        scope = 2;
        displayName = "Map Marker";
        icon = "\A3\ui_f\data\GUI\Rsc\RscDisplayGarage\animationSources_ca.paa";
        category = "NO_CATEGORY";
        function = "MM_fnc_moduleMapMarker";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 1;
        isDisposable = 0;
        is3DEN = 0;
        curatorInfoType = "RscDisplayAttributeModuleMapMarker";

        class Attributes: AttributesBase {
            class ShowAllSides: Combo {
                property = "moduleMapMarker_showAllSides";
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
                property = "moduleMapMarker_showAllSidesOnSpectator";
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

            class showUnitNames: Combo {
                property = "moduleMapMarker_showUnitNames";
                displayName = "Show Unit Names";
                tooltip = "toggles whether to show the names of units";
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

            class showUnitNamesOnlyOnHover: Combo {
                property = "moduleMapMarker_showUnitNamesOnlyOnHover";
                displayName = "Show Unit Names only on Hover";
                tooltip = "toggles whether to show the name of a unit only when hovering over it on the map";
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
            description = "This module displays map markers for all units and vehicles.";
            sync[] = {};
        };
    };
};

class CfgFunctions {
    class mapmarker {
        class main {
            file = "mapmarker\scripts";
        };
    };

    class MM {
        class NO_CATEGORY {
            file = "\mapmarker\functions";
            class moduleMapMarker {};
        };
    };
};