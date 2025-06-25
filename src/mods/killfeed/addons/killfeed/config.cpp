class CfgPatches {
    class killfeed {
        units[] = {"moduleKillfeed"};
        requiredVersion = 1;
        requiredAddons[] = {"A3_Modules_F"};
    };
};

class CfgFactionClasses {
    class NO_CATEGORY;
    class killfeed: NO_CATEGORY {
        displayName = "Killfeed";
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

    class moduleKillfeed: Module_F {
        scope = 2;
        displayName = "Killfeed";
        icon = "\A3\ui_f\data\GUI\Rsc\RscDisplayGarage\animationSources_ca.paa";
        category = "NO_CATEGORY";
        function = "KF_fnc_moduleKillfeed";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 1;
        isDisposable = 0;
        is3DEN = 0;
        curatorInfoType = "RscDisplayAttributeModuleKillfeed";

        class Attributes: AttributesBase {
            class assists: Combo {
                property = "moduleKillfeed_assists";
                displayName = "Assists";
                tooltip = "toggles assist functionality";
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

            class showFriendlyFire: Combo {
                property = "moduleKillfeed_showFriendlyFire";
                displayName = "Show 'Friendly Fire'";
                tooltip = "shows a red 'Friendly Fire' text in the midfeed and the deathfeed in case of friendly fire";
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

            class deathCausesInversed: Combo {
                property = "moduleKillfeed_deathCausesInversed";
                displayName = "Invert order of death causes";
                tooltip = "flips the order of death causes";
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

            class multipleDeathCauses: Combo {
                property = "moduleKillfeed_multipleDeathCauses";
                displayName = "Show multiple death causes per line";
                tooltip = "toggles whether there can be multiple death causes displayed per line, in case the hitter hit the killed by multiple different means";
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

            class picturesHeadIcon: Combo {
                property = "moduleKillfeed_picturesHeadIcon";
                displayName = "Show head icon in case of headshot";
                tooltip = "toggles whether a head icon is displayed in front of the weapon, in case of a headshot";
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

            class picturesBulletIcon: Combo {
                property = "moduleKillfeed_picturesBulletIcon";
                displayName = "Show bullet icon";
                tooltip = "toggles whether a bullet icon is displayed between the head and the weapon, in case of a headshot";
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

            class showAiInNames: Combo {
                property = "moduleKillfeed_showAiInNames";
                displayName = "Show AI in names";
                tooltip = "toggles whether ' (AI)' is appended to the names of AI units and vehicles";
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

            class killfeedEnabled: Combo {
                property = "moduleKillfeed_killfeedEnabled";
                displayName = "Show killfeed";
                tooltip = "toggles killfeed functionality";
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

            class killfeedCooldown: Combo {
                property = "moduleKillfeed_killfeedCooldown";
                displayName = "Killfeed cooldown";
                tooltip = "determines for how long kills should be displayed in the killfeed";
                typeName = "Number";
                defaultValue = "30";
                
                class Values {
                    class 5 {
                        name = "5";
                        value = 5;
                    };
                    class 10 {
                        name = "10";
                        value = 10;
                    };
                    class 15 {
                        name = "15";
                        value = 15;
                    };
                    class 20 {
                        name = "20";
                        value = 20;
                    };
                    class 30 {
                        name = "30";
                        value = 30;
                    };
                    class 45 {
                        name = "45";
                        value = 45;
                    };
                    class 60 {
                        name = "60";
                        value = 60;
                    };
                };
            };

            class killfeedMaximumLength: Combo {
                property = "moduleKillfeed_killfeedMaximumLength";
                displayName = "Maximum killfeed length";
                tooltip = "maximum number of kills displayed at one time in the killfeed";
                typeName = "Number";
                defaultValue = "10";
                
                class Values {
                    class 5 {
                        name = "5";
                        value = 5;
                    };
                    class 10 {
                        name = "10";
                        value = 10;
                    };
                    class 15 {
                        name = "15";
                        value = 15;
                    };
                    class 20 {
                        name = "20";
                        value = 20;
                    };
                    class 30 {
                        name = "30";
                        value = 30;
                    };
                    class 45 {
                        name = "45";
                        value = 45;
                    };
                    class 60 {
                        name = "60";
                        value = 60;
                    };
                };
            };

            class killfeedInversed: Combo {
                property = "moduleKillfeed_killfeedInversed";
                displayName = "Flip killer and killed";
                tooltip = "flips the positions of killer and killed in the killfeed";
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

            class midFeedEnabled: Combo {
                property = "moduleKillfeed_midFeedEnabled";
                displayName = "Show midfeed";
                tooltip = "toggles midfeed functionality";
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

            class midfeedCooldown: Combo {
                property = "moduleKillfeed_midfeedCooldown";
                displayName = "Midfeed cooldown";
                tooltip = "determines for how long kills should be displayed in the midfeed";
                typeName = "Number";
                defaultValue = "10";
                
                class Values {
                    class 5 {
                        name = "5";
                        value = 5;
                    };
                    class 10 {
                        name = "10";
                        value = 10;
                    };
                    class 15 {
                        name = "15";
                        value = 15;
                    };
                    class 20 {
                        name = "20";
                        value = 20;
                    };
                    class 30 {
                        name = "30";
                        value = 30;
                    };
                    class 45 {
                        name = "45";
                        value = 45;
                    };
                    class 60 {
                        name = "60";
                        value = 60;
                    };
                };
            };

            class midfeedMaximumLength: Combo {
                property = "moduleKillfeed_midfeedMaximumLength";
                displayName = "Maximum midfeed length";
                tooltip = "maximum number of kills displayed at one time in the midfeed";
                typeName = "Number";
                defaultValue = "10";
                
                class Values {
                    class 5 {
                        name = "5";
                        value = 5;
                    };
                    class 10 {
                        name = "10";
                        value = 10;
                    };
                    class 15 {
                        name = "15";
                        value = 15;
                    };
                    class 20 {
                        name = "20";
                        value = 20;
                    };
                    class 30 {
                        name = "30";
                        value = 30;
                    };
                    class 45 {
                        name = "45";
                        value = 45;
                    };
                    class 60 {
                        name = "60";
                        value = 60;
                    };
                };
            };

            class midFeedYouColorYellow: Combo {
                property = "moduleKillfeed_midFeedYouColorYellow";
                displayName = "Yellow 'You' in the midfeed";
                tooltip = "toggles whether the text 'You' in 'You killed ...' should also be displayed in yellow in the midfeed";
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

            class midFeedAssists: Combo {
                property = "moduleKillfeed_midFeedAssists";
                displayName = "Show assists in the midfeed";
                tooltip = "toggles whether there should be assists displayed in the midfeed";
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


            class deathFeedEnabled: Combo {
                property = "moduleKillfeed_deathFeedEnabled";
                displayName = "Show deathfeed";
                tooltip = "toggles death-feed functionality";
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

            class killInfoDuration: Combo {
                property = "moduleKillfeed_killInfoDuration";
                displayName = "Kill-info duration";
                tooltip = "determines for how long the kill-info should be displayed";
                typeName = "Number";
                defaultValue = "20";
                
                class Values {
                    class 5 {
                        name = "5";
                        value = 5;
                    };
                    class 10 {
                        name = "10";
                        value = 10;
                    };
                    class 15 {
                        name = "15";
                        value = 15;
                    };
                    class 20 {
                        name = "20";
                        value = 20;
                    };
                    class 30 {
                        name = "30";
                        value = 30;
                    };
                    class 45 {
                        name = "45";
                        value = 45;
                    };
                    class 60 {
                        name = "60";
                        value = 60;
                    };
                };
            };

            class ModuleDescription: ModuleDescription {};
        };

        class ModuleDescription: ModuleDescription {
            description = "This module provides kill-feed, mid-feed, death-feed and kill-info functionality.";
            sync[] = {};
        };
    };
};

class CfgFunctions {
    class killfeed {
        class main {
            file = "killfeed\scripts";
        };
    };

    class KF {
        class NO_CATEGORY {
            file = "\killfeed\functions";
            class moduleKillfeed {};
        };
    };
};