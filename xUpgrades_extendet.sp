/************************************************************************
* -----------------------------------------------------------------------
* xUpgrades by PENT
* Author: PENT
* My L4D2 Server: nxtgaming.fhg.ro
* -----------------------------------------------------------------------
*
* - The Story -
* -----------------------------------------------------------------------
* Upgrades for survivors
* Only works for L4D2
* A while ago there was a very nice plugin called KrX's survivor upgrades
* And he never did it for L4D2 and so i decided to do it.
*
* That plugin inspired me so much that i spent all my time to make one
* like the original KrX's Upgrades for survivors.
* The last update was 1.1.6 and he never made one for l4d2
*
* Whosat (the author of KrX upgrades) made a rewrite of the original
* Upgrades for survivor plugin and then made one for l4d2 called 
* [L4D2] [L4D2] Survivor Upgrades Reloaded but it's still not like
* The original KrX plugin so i was very dissapointed for that.
* -----------------------------------------------------------------------
*
* - Survior Upgrades Reloaded Info
* -----------------------------------------------------------------------
* plugin name = [L4D2] Survivor Upgrades Reloaded
* author = "Marcus101RR, Whosat & Jerrith"
* description = "Survivor Upgrades Returns, Reloaded!"
* version = 1.7.4
* url = "http://forums.alliedmods.net"
* -----------------------------------------------------------------------
*
* - KrX's Survivor Upgrades Info
* -----------------------------------------------------------------------
* KrX's Survivor Upgrades
* by KrX a.k.a Whosat
* AlliedModders https://forums.alliedmods.net/showthread.php?t=100507
* Plugin Homepage: http://krx.ath.cx/l4d/plugins/KrX_surup/
* -----------------------------------------------------------------------
* 
* - Changelog -
* -----------------------------------------------------------------------
* Version 1.0.0
*   -Initial release.
* Version 1.0.1
*	-Added Laser Sight
*	-New convars and fast reload.
* Version 1.0.2
*	-Fixed laser Sight bug and added Hollow Ammunition upgrade.
* Version 1.0.3
*	-Fixed perkslots and added kerosene upgrade.
* Version 1.0.4
*	-Configured Awardtitle.
* Version 1.0.5
*	-Added Kevlar body, Hot meal and Ointment upgrades.
* Version 1.0.6
*	-Fixed out of index problem.
* Version 1.0.7
*	-Added more awardtitle and set the lenght of guns as 64.
* Version 1.0.8
*	-Hot meal ugprade renamed to Aloe Vera instead.
* Version 1.0.9
*	-Made the code much cleaner
* Version 1.1.0
*	-Added a convar to allows survivors to get upgrades at roundstart
* Version 1.1.1
*	-Fixed grenade launcher bug after shooting it keeps reloading. 
* Fixed Ammunition bug when sometimes survivors didn't got the upgrade
* Version 1.1.2
*	-Fixed bug when Jockey / Charger didn't die by knife upgrade.
* Version 1.1.3
*	-Added iKnifeMaxUse to use the knife upgrade multiple times.
* Version 1.1.4
*	-Added Second Wind Upgrade. Survivors can now reviving self by using
* Adrenaline / Pills by pressing E button.
* Version 1.1.5
*	-Added iSecondWindMaxUse to use the Second Wind upgrade multiple times.
* Added a convar xupgrade_second_wind_health to easy change the health after
* Reviving.
* Version 1.1.6
*	-Fixed when survivors didn't get iKnifeMaxUse and iSecondWindMaxUse by 
* losing a round. Removed mission_lost event.
* Version 1.1.7
*	-Added Bandages upgrade + message when subject gets revive_succes.
* Version 1.1.8
*	-Fixed when survivors still get knife and second wind message when
* The round was over or dead.
* Version 1.1.9
*	-Added and fixed Hot Meal upgrade. Now Survivors when they earn an
* Award and if they receive Hot Meal upgrade they receive 150 HP immediatly
* And Aloe Vera gives 100 HP when survivors reach safe-house and round end.
* Version 1.2.0
*	-Removed colors.inc and rewriten all the colors in chat
* Version 1.2.1
*	-Reupdated colors for a better eye-view.
* Version 1.2.2
*	-Code looks much cleaner and disabled some upgrades.
* Version 1.2.3
*	-Removed UpgradeRoundStart[] and added UpgradeEvent[]
* Version 1.2.4
*	-Fixed UpgradeEvent[] and decreased delay for UpgradeKnifetimer and
* UpgradeSecondWindTimer.
* Version 1.2.5
*	-Fixed knife when sometimes the plugin doesn't give upgrade to survivor.
*	-Code clean-up.
* Version 1.2.6
*	-Added m_isProneTongueDrag, m_isHangingFromTongue, m_reachedTongueOwner
* To UpgradeKnife.
* -----------------------------------------------------------------------
* 
* - Colors -
* -----------------------------------------------------------------------
* \x01 - Default
* \x02 - Team Color
* \x03 - Light Green
* \x04 - Orange
* \x05 - Green
* -----------------------------------------------------------------------
************************************************************************/
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

/*Plugin settings*/						/*Values*/
#define PLUGIN_VERSION					"1.2.6"
#define UPGRADEID						34
#define MAX_UPGRADES					34
#define AWARDID							128
#define CVAR_FLAGS						FCVAR_NOTIFY
#define UPGRADE_LOAD_TIME				1.0
#define LEN64 							64

/*Plugin Tag & Message*/				/*Values*/
#define xUpgrade_tag					"\x04[\x03xUpgrades\x04]"							// Tag which appears at the start of every chat line output
#define xUpgrade_message				"\x04[\x03xUpgrades\x04] \x01xUpgrades by PENT"		// Message which appears at the start of every round

new Float:f_UpgradeFastReloadRate;
new Handle:UpgradeFastReloadRate;

/*Track of DF Values*/					/*Values*/					
const Float:g_fl_AutoS 					= 0.666666;
const Float:g_fl_AutoI 					= 0.4;
const Float:g_fl_AutoE 					= 0.675;
const Float:g_fl_SpasS 					= 0.5;
const Float:g_fl_SpasI 					= 0.375;
const Float:g_fl_SpasE 					= 0.699999;
const Float:g_fl_PumpS 					= 0.5;
const Float:g_fl_PumpI 					= 0.5;
const Float:g_fl_PumpE 					= 0.6;

new g_i_L4D_12 							= 0;

/*Offsets*/								/*Values*/
new g_iNextPAttO						= -1;
new g_iActiveWO							= -1;
new g_iShotStartDurO					= -1;
new g_iShotInsertDurO					= -1;
new g_iShotEndDurO						= -1;
new g_iPlayRateO						= -1;
new g_iShotRelStateO					= -1;
new g_iNextAttO							= -1;
new g_iTimeIdleO						= -1;
new g_iVMStartTimeO						= -1;
new g_iViewModelO						= -1;

/*Offsets*/								/*Values*/
#define	RIFLE_OFFSET_AMMO				12
#define	SMG_OFFSET_AMMO					20
#define	SHOTGUN_OFFSET_AMMO				28
#define	AUTOSHOTGUN_OFFSET_AMMO			32
#define	HUNTING_RIFLE_OFFSET_AMMO		36
#define	SNIPER_OFFSET_AMMO				40
#define	GRENADE_LAUNCHER_OFFSET_AMMO	68

/*Offsets*/								/*Values*/
#define	RIFLE_AMMO						360
#define	SMG_AMMO						650
#define	SHOTGUN_AMMO					56
#define	AUTOSHOTGUN_AMMO				90
#define	HUNTING_RIFLE_AMMO				150
#define	SNIPER_AMMO						180
#define	GRENADE_LAUNCHER_AMMO			30

/*Entity models*/						/*Models*/
#define ENTITY_GASCAN					"models/props_junk/gascan001a.mdl"
#define ENTITY_PROPANE					"models/props_junk/propanecanister001a.mdl"

public Plugin:myinfo =
{
	name = "[L4D2] xUpgrades by PENT (Extendet)",
    author = "PENT",
    description = "Upgrades for survivors",
    version = PLUGIN_VERSION,
    url = "http://forums.alliedmods.net"
}

new Handle:UpgradeEnabled[MAX_UPGRADES + 1] 			= INVALID_HANDLE;
new Handle:UpgradeLosable[MAX_UPGRADES + 1] 			= INVALID_HANDLE;
new Handle:UpgradeEvent[MAX_UPGRADES + 1] 				= INVALID_HANDLE;
new Handle:AwardIndex[AWARDID + 1] 						= INVALID_HANDLE;
new Handle:RegenerationTimer[MAXPLAYERS + 1] 			= INVALID_HANDLE;
new Handle:AwardsCooldownTimer[MAXPLAYERS + 1] 			= INVALID_HANDLE;
new Handle:KnifeCooldownTimer[MAXPLAYERS + 1] 			= INVALID_HANDLE;
new Handle:SecondWindCooldownTimer[MAXPLAYERS + 1]	 	= INVALID_HANDLE;
new Handle:UpgradeSecondWindHealth 						= INVALID_HANDLE;
new Handle:gSecondWindHealth 							= INVALID_HANDLE;
new Handle:HotMealCooldown[MAXPLAYERS + 1] 				= INVALID_HANDLE;
new Handle:AloeVeraCooldown[MAXPLAYERS + 1] 			= INVALID_HANDLE;
new Handle:CombatGlovesCooldownTimer[MAXPLAYERS + 1] 	= INVALID_HANDLE;
new Handle:penalty_upgrades;
new Handle:SetClientUpgrades[MAXPLAYERS + 1] 			= INVALID_HANDLE;
new Handle:ReloadCooldown[MAXPLAYERS + 1] 				= INVALID_HANDLE;
new Handle:g_PerkMode 									= INVALID_HANDLE;
new Handle:PerkSlots 									= INVALID_HANDLE;
new Handle:PerkBonusSlots 								= INVALID_HANDLE;
new Handle:BoosterSlots 								= INVALID_HANDLE;

new Handle:g_VarFirstAidDuration 						= INVALID_HANDLE;
new Handle:g_VarReviveDuration 							= INVALID_HANDLE;
new Handle:g_VarAdrenalineDuration 						= INVALID_HANDLE;

new bool:b_round_end;
new bool:iKnifeReady 									= false;
new bool:iSecondWindReady 								= false;
new iKnifeMaxUse[MAXPLAYERS + 1] 						= 0;
new iSecondWindMaxUse[MAXPLAYERS + 1] 					= 0;
new RefreshRewards[MAXPLAYERS + 1] 						= 0;
new PILLS_ADRENALINE_SLOT 								= 4;

new String:iGrenadeItems[MAXPLAYERS+1][2][LEN64];
new UpgradeIndex[MAX_UPGRADES + 1] = 0;
new String:UpgradeTitle[MAX_UPGRADES + 1][128];
new String:UpgradeShort[MAX_UPGRADES + 1][64];
new String:PerkTitle[MAX_UPGRADES + 1][64];
new BoosterAllowed[MAX_UPGRADES + 1];
new String:AwardTitle[AWARDID + 1][128];
new iBitsUpgrades[MAXPLAYERS + 1] 						= 0;
new iUpgrade[MAXPLAYERS + 1][UPGRADEID + 1];
new iUpgradeDisabled[MAXPLAYERS + 1][UPGRADEID + 1];
new iCount[MAXPLAYERS + 1][AWARDID + 1];
new iAnnounceText[MAXPLAYERS + 1] 						= 0;
new iSaveFeature[MAXPLAYERS + 1] 						= 0;
new AwardsCooldownID[MAXPLAYERS + 1];
new iActiveWeapon[MAXPLAYERS + 1];
new iPerkBonusSlots[MAXPLAYERS + 1] 					= 0;
new iCombatGloves[MAXPLAYERS + 1] 						= 0;
new iHotMeal[MAXPLAYERS + 1] 							= 0;
new iAloeVera[MAXPLAYERS + 1] 							= 0;
new iBoosterSlots[MAXPLAYERS + 1] 						= 0;
new iBooster[MAXPLAYERS + 1][UPGRADEID + 1];

new String:iPrimaryItems[MAXPLAYERS + 1][2][LEN64];
new String:iSecondaryItems[MAXPLAYERS + 1][2][LEN64];
new iAutoinjectors[MAXPLAYERS + 1];

new iCountTimer[MAXPLAYERS + 1];

new Float:FirstAidDuration;
new Float:ReviveDuration;
new Float:PipeBombDuration;
new Float:AdrenalineDuration;

public OnPluginStart()
{
	decl String:game_name[64];
	GetGameFolderName(game_name, sizeof(game_name));
	if (!StrEqual(game_name, "left4dead2", false))
	{
		SetFailState("Plugin Supports Left 4 Dead 2 Only.");
	}
	else if (StrEqual(game_name, "left4dead2", false)==true)
	{
		g_i_L4D_12 = 2;
	}

	CreateConVar("xupgrades_version", PLUGIN_VERSION, "Survivor Upgrades Reloaded Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	penalty_upgrades = CreateConVar("xupgrades_awards_death_amount", "2", "Number of Upgrades Lost per Death", CVAR_FLAGS, true, 1.0, true, 8.0);
	g_PerkMode = CreateConVar("xupgrades_perk_mode", "0", "Option for Perk style gameplay", CVAR_FLAGS, true, 0.0, true, 1.0);
	PerkSlots = CreateConVar("xupgrades_perk_slots", "0", "The number of perks allowed in the game.", CVAR_FLAGS, true, 0.0, true, 6.0);
	PerkBonusSlots = CreateConVar("xupgrades_perk_bonus_slots", "0", "The number of bonus perks obtainable in the game.", CVAR_FLAGS, true, 0.0, true, 6.0);
	BoosterSlots = CreateConVar("xupgrades_booster_slots", "0", "The number of bonus boosters obtainable in the game.", CVAR_FLAGS, true, 0.0, true, 3.0);

	AwardIndex[0] = CreateConVar("survivor_upgrade_awards_death", "3", "Lose All Upgrades (0 - Disable, 1 - Bots Only, 2 - Humans Only, 3 - All Players", CVAR_FLAGS, true, 0.0, true, 3.0);
	AwardTitle[0] = "\x05Death Penalty\x01";
	AwardIndex[14] = CreateConVar("survivor_upgrade_awards_blind_luck", "1", "Number of Blind Luck Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[14] = "\x05Blind Luck Award\x01";
	AwardIndex[15] = CreateConVar("survivor_upgrade_awards_pyrotechnician", "2", "Number of Pyrotechnician Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[15] = "\x05Pyrotechnician Award\x01";
	AwardIndex[18] = CreateConVar("survivor_upgrade_awards_witch_hunter", "1", "Number of Witch Hunter Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[18] = "\x05Witch Hunter Award\x01";
	AwardIndex[19] = CreateConVar("survivor_upgrade_awards_crowned", "1", "Number of Crowned Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[19] = "\x05Crowned Award\x01";
	AwardIndex[21] = CreateConVar("survivor_upgrade_awards_dead_stop", "1", "Number of Dead Stop Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[21] = "\x05Dead Stop Award\x01";
	AwardIndex[22] = CreateConVar("survivor_upgrade_awards_brawler", "10", "Number of Brawler Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[22] = "\x05Brawler Award\x01";
	AwardIndex[26] = CreateConVar("survivor_upgrade_awards_boom_cork", "1", "Number of Boom-Cork Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[26] = "\x05Boom-Cork Award\x01";
	AwardIndex[27] = CreateConVar("survivor_upgrade_awards_tongue_twister", "1", "Number of Tongue Twister Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 10.0);
	AwardTitle[27] = "\x05Tongue Twister Award\x01";
	AwardIndex[66] = CreateConVar("survivor_upgrade_awards_helping_hand", "4", "Number of Helping Hand Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[66] = "\x05Helping Hand Award\x01";
	AwardIndex[67] = CreateConVar("survivor_upgrade_awards_my_bodyguard", "4", "Number of My Bodyguard Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[67] = "\x05My Bodyguard Award\x01";
	AwardIndex[68] = CreateConVar("survivor_upgrade_awards_pharm_assist", "4", "Number of Pharm-Assist Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[68] = "\x05Pharm-Assist Award\x01";
	AwardIndex[69] = CreateConVar("survivor_upgrade_awards_adrenaline", "4", "Number of Adrenaline Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[69] = "\x05Adrenaline Award\x01";
	AwardIndex[70] = CreateConVar("survivor_upgrade_awards_medic", "4", "Number of Medic Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[70] = "\x05Medic Award\x01";
	AwardIndex[76] = CreateConVar("survivor_upgrade_awards_special_savior", "4", "Number of Special Savior Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[76] = "\x05Special Savior Award\x01";
	AwardIndex[80] = CreateConVar("survivor_upgrade_awards_hero_closet", "1", "Number of Hero Closet Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 10.0);
	AwardTitle[80] = "\x05Hero Closet Award\x01";
	AwardIndex[81] = CreateConVar("survivor_upgrade_awards_tankbusters", "1", "Number of Tankbusters Award To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[81] = "\x05Tankbusters Award\x01";
	AwardIndex[84] = CreateConVar("survivor_upgrade_awards_teamkill", "1", "Number of Team Kill Penalties To Lose Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[84] = "\x05Team-Kill Penalty\x01";
	AwardIndex[85] = CreateConVar("survivor_upgrade_awards_teamincapacitate", "1", "Number of Team-Incapacitate Penalty To Lose Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[85] = "\x05Team-Incapacitate Penalty\x01";
	AwardIndex[87] = CreateConVar("survivor_upgrade_awards_friendly_fire", "4", "Number of Friendly-Fire Penalty To Lose Upgrade", CVAR_FLAGS, true, 0.0, true, 64.0);
	AwardTitle[87] = "\x05Friendly-Fire Penalty\x01";
	AwardIndex[100] = CreateConVar("survivor_upgrade_awards_101_cremations", "101", "Number of 101 Cremations To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 101.0);
	AwardTitle[100] = "\x05101 Cremations Award\x01";
	AwardIndex[102] = CreateConVar("survivor_upgrade_awards_brain_salad", "30", "Number of Brain Salad Awards To Earn Upgrade", CVAR_FLAGS, true, 0.0, true, 100.0);
	AwardTitle[102] = "\x05Brain Salad Award\x01";
	AwardIndex[103] = CreateConVar("survivor_upgrade_awards_barf_bagged", "2", "Number of Barf Bagged Penalty To Lose Upgrade", CVAR_FLAGS, true, 0.0, true, 10.0);
	AwardTitle[103] = "\x05Barf Bagged Penalty\x01";
	AwardIndex[104] = CreateConVar("survivor_upgrade_awards_vomit_bomb", "2", "Number of Vomit Bomb Penalty To Lose Upgrade", CVAR_FLAGS, true, 0.0, true, 10.0);
	AwardTitle[104] = "\x05Vomit Bomb Penalty\x01";
	AwardIndex[105] = CreateConVar("survivor_upgrade_awards_acid_burn", "2", "Number of Acid Burn Penalty To Lose Upgrade", CVAR_FLAGS, true, 0.0, true, 10.0);
	AwardTitle[105] = "\x05Acid Burn Penalty\x01";
	AwardIndex[106] = CreateConVar("survivor_upgrade_awards_incapicated", "1", "Number of Incapacitated Penalty To Lose Upgrade", CVAR_FLAGS, true, 0.0, true, 10.0);
	AwardTitle[106] = "\x05Incapacitated Penalty\x01";
	
	RegConsoleCmd("sm_upgrades", PrintToChatUpgrades, "List Upgrades.");
	RegConsoleCmd("sm_xupgrades", PrintToChatxUpgrades, "List Upgrades.");
	RegConsoleCmd("sm_perks", OpenPerkMenu, "Opens up the Perk Menu.");
	RegConsoleCmd("sm_laser", UpgradeLaserSightToggle, "Toggle the Laser Sight upgrade.");
	RegConsoleCmd("sm_resetupgrades", ResetUpgradesSurvivor, "Reset survivor's upgrades.");
	RegAdminCmd("sm_giveupgrade", CommandGiveUpgrade, ADMFLAG_CHEATS,  "Give player specfied upgrade.");
	RegAdminCmd("sm_giverandomupgrade", CommandGiveRandomUpgrade, ADMFLAG_CHEATS,  "Give player random upgrade.");

	UpgradeIndex[0] = 1;
	UpgradeTitle[0] = "\x01Autoinjectors \x05(Increased Incapacitation Limit)";
	UpgradeShort[0] = "\x03Autoinjectors";
	UpgradeEnabled[0] = CreateConVar("xupgrades_autoinjectors_enable", "1", "Enable/Disable Autoinjectors", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[0] = CreateConVar("xupgrades_autoinjectors_losable", "0", "Is Autoinjectors losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[0] = 0;
	PerkTitle[0] = "\x03Autoinjectors";
	BoosterAllowed[0] = 0;

	UpgradeIndex[1] = 2;
	UpgradeTitle[1] = "\x01Kerosene \x05(Increased Molotov Burn Duration)";
	UpgradeShort[1] = "\x03Kerosene";
	UpgradeEnabled[1] = CreateConVar("xupgrades_kerosene_enable", "1", "Enable/Disable Kerosene", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[1] = CreateConVar("xupgrades_kerosene_losable", "1", "Is Kerosene losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[1] = 0;
	PerkTitle[1] = "Kerosene";
	BoosterAllowed[1] = 0;

	UpgradeIndex[2] = 4;
	UpgradeTitle[2] = "\x01Laser Sight \x05(Increased Accuracy)";
	UpgradeShort[2] = "\x03Laser Sight";
	UpgradeEnabled[2] = CreateConVar("xupgrades_laser_sight_enable", "1", "Enable/Disable Laser Sight", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[2] = CreateConVar("xupgrades_laser_sight_losable", "0", "Is Laser Sight losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[2] = 0;
	PerkTitle[2] = "Laser Sight";
	BoosterAllowed[2] = 0;

	UpgradeIndex[3] = 8;
	UpgradeTitle[3] = "\x01Kevlar Body Armor \x05(Reduced Damage)";
	UpgradeShort[3] = "\x03Kevlar Body Armor";
	UpgradeEnabled[3] = CreateConVar("xupgrades_kevlar_armor_enable", "1", "Enable/Disable Kevlar Body Armor", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[3] = CreateConVar("xupgrades_kevlar_armor_losable", "1", "Is Kevlar Body Armor losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[3] = 0;
	PerkTitle[3] = "Kevlar Body Armor";
	BoosterAllowed[3] = 1;

	UpgradeIndex[4] = 16;
	UpgradeTitle[4] = "\x01Hot Meal \x05(Gives 150 HP)";
	UpgradeShort[4] = "\x03Hot Meal";
	UpgradeEnabled[4] = CreateConVar("xupgrades_hot_meal_enable", "1", "Enable/Disable Hot Meal", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[4] = CreateConVar("xupgrades_hot_meal_losable", "1", "Is Hot Meal losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[4] = 0;
	PerkTitle[4] = "Hot Meal";
	BoosterAllowed[4] = 1;

	UpgradeIndex[5] = 32;
	UpgradeTitle[5] = "\x01Ointment \x05(Increased Healing Effect)";
	UpgradeShort[5] = "\x03Ointment";
	UpgradeEnabled[5] = CreateConVar("xupgrades_ointment_enable", "1", "Enable/Disable Ointment", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[5] = CreateConVar("xupgrades_ointment_losable", "1", "Is Ointment losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[5] = 0;
	PerkTitle[5] = "Ointment";
	BoosterAllowed[5] = 0;

	UpgradeIndex[6] = 64;
	UpgradeTitle[6] = "\x01High Ammunition Backpack \x05(Increased Ammunition Reserve)";
	UpgradeShort[6] = "\x03High Ammunition Backpack";
	UpgradeEnabled[6] = CreateConVar("xupgrades_high_ammo_backpack_enable", "1", "Enable/Disable High Ammunition Backpak", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[6] = CreateConVar("xupgrades_high_ammo_backpack_losable", "1", "Is High Ammunition Backpak losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[6] = 0;
	PerkTitle[6] = "High Ammunition Backpak";
	BoosterAllowed[6] = 1;

	UpgradeIndex[7] = 128;
	UpgradeTitle[7] = "\x01Steroids \x05(Increased Temporary Health Effect)";
	UpgradeShort[7] = "\x03Steroids";
	UpgradeEnabled[7] = CreateConVar("xupgrades_steroids_enable", "1", "Enable/Disable Steroids", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[7] = CreateConVar("xupgrades_steroids_losable", "1", "Is Steroids losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[7] = 0;
	PerkTitle[7] = "Steroids";
	BoosterAllowed[7] = 1;

	UpgradeIndex[8] = 256;
	UpgradeTitle[8] = "\x01Barrel Chamber \x05(Increased Upgrade Pack Ammo)";
	UpgradeShort[8] = "\x03Barrel Chamber";
	UpgradeEnabled[8] = CreateConVar("xupgrades_barrel_chamber_enable", "1", "Enable/Disable Barrel Chamber", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[8] = CreateConVar("xupgrades_barrel_chamber_losable", "1", "Is Barrel Chamber losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[8] = 0;
	PerkTitle[8] = "Barrel Chamber";
	BoosterAllowed[8] = 1;

	UpgradeIndex[9] = 512;
	UpgradeTitle[9] = "\x01Heavy Duty Batteries \x05(Increased Defibrillator Effect)";
	UpgradeShort[9] = "\x03Heavy Duty Batteries";
	UpgradeEnabled[9] = CreateConVar("xupgrades_heavy_duty_enable", "0", "Enable/Disable Heavy Duty Batteries", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[9] = CreateConVar("xupgrades_heavy_duty_losable", "1", "Is Heavy Duty losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[9] = 0;
	PerkTitle[9] = "Heavy Duty Batteries";
	BoosterAllowed[9] = 1;

	UpgradeIndex[10] = 1024;
	UpgradeTitle[10] = "\x01Bandages \x05(Increased Revive Health)";
	UpgradeShort[10] = "\x03Bandages";
	UpgradeEnabled[10] = CreateConVar("xupgrades_bandages_enable", "1", "Enable/Disable Bandages", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[10] = CreateConVar("xupgrades_bandages_losable", "1", "Is Bandages losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[10] = 1;
	PerkTitle[10] = "Bandages";
	BoosterAllowed[10] = 1;

	UpgradeIndex[11] = 2048;
	UpgradeTitle[11] = "\x01Beta-Blockers \x05(Increased Incapacitation Health)";
	UpgradeShort[11] = "\x03Beta-Blockers";
	UpgradeEnabled[11] = CreateConVar("xupgrades_beta_blockers_enable", "0", "Enable/Disable Beta-Blockers", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[11] = CreateConVar("xupgrades_beta_blockers_losable", "1", "Is Beta-Blockers losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[11] = 0;
	PerkTitle[11] = "Beta-Blockers";
	BoosterAllowed[11] = 1;

	UpgradeIndex[12] = 4092;
	UpgradeTitle[12] = "\x01Aloe Vera \x05(Gives Full HP At Safe-House)";
	UpgradeShort[12] = "\x03Aloe Vera";
	UpgradeEnabled[12] = CreateConVar("xupgrades_aloe_vera_enable", "1", "Enable/Disable Aloe Vera", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[12] = CreateConVar("xupgrades_aloe_vera_losable", "0", "Is Aloe Vera losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[12] = 1;
	PerkTitle[12] = "Aloe Vera";
	BoosterAllowed[12] = 1;

	UpgradeIndex[13] = 8184;
	UpgradeTitle[13] = "\x01Fast Reload \x05(Increased Reload Speed)";
	UpgradeShort[13] = "\x03Fast Reload";
	UpgradeEnabled[13] = CreateConVar("xupgrades_fast_reload_enable", "1", "Enable/Disable Fast Reload", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[13] = CreateConVar("xupgrades_fast_reload_losable", "0", "Is Fast Reload losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[13] = 0;
	PerkTitle[13] = "Fast Reload";
	BoosterAllowed[13] = 0;
	UpgradeFastReloadRate = CreateConVar("xupgrade_fast_reload_rate", "0.4894" ,"Fast Reload rate (between 0.2 < 0.9)", CVAR_FLAGS, true, 0.2, true, 0.9);
	HookConVarChange(UpgradeFastReloadRate, Convar_Reload);
	f_UpgradeFastReloadRate = 0.4894;

	UpgradeIndex[14] = 16384;
	UpgradeTitle[14] = "\x01Bandoliers \x05(Allows M60 Ammo Supply Pile)";
	UpgradeShort[14] = "\x03Bandoliers";
	UpgradeEnabled[14] = CreateConVar("xupgrades_bandoliers_enable", "0", "Enable/Disable Bandoliers", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[14] = CreateConVar("xupgrades_bandoliers_losable", "1", "Is Bandoliers losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[14] = 0;
	PerkTitle[14] = "Bandoliers";
	BoosterAllowed[14] = 0;

	UpgradeIndex[15] = 32768;
	UpgradeTitle[15] = "\x01Hollow Point Ammunition \x05(Increased Bullet Damage)";
	UpgradeShort[15] = "\x03Hollow Point Ammunition";
	UpgradeEnabled[15] = CreateConVar("xupgrades_hollow_point_enable", "1", "Enable/Disable Hollow Point Ammunition", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[15] = CreateConVar("xupgrades_hollow_point_losable", "1", "Is Hollow Point Ammunition losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[15] = 0;
	PerkTitle[15] = "Hollow Point Ammunition";
	BoosterAllowed[15] = 1;

	UpgradeIndex[16] = 65536;
	UpgradeTitle[16] = "\x01Knife \x05(Self-Save Pinned)";
	UpgradeShort[16] = "\x03Knife";
	UpgradeEnabled[16] = CreateConVar("xupgrades_knife_enable", "1", "Enable/Disable Knife", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[16] = CreateConVar("xupgrades_knife_losable", "0", "Is Knife losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[16] = 1;
	PerkTitle[16] = "Knife";
	BoosterAllowed[16] = 0;

	UpgradeIndex[17] = 131072;
	UpgradeTitle[17] = "\x01Stimpacks \x05(Reduced Healing Duration)";
	UpgradeShort[17] = "\x03Stimpacks";
	UpgradeEnabled[17] = CreateConVar("xupgrades_stimpacks_enable", "1", "Enable/Disable Stimpacks", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[17] = CreateConVar("xupgrades_stimpacks_losable", "1", "Is Stimpacks losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[17] = 0;
	PerkTitle[17] = "Stimpacks";
	BoosterAllowed[17] = 1;

	UpgradeIndex[18] = 262144;
	UpgradeTitle[18] = "\x01Smelling Salts \x05(Reduced Revive Duration)";
	UpgradeShort[18] = "\x03Smelling Salts";
	UpgradeEnabled[18] = CreateConVar("xupgrades_smelling_salts_enable", "1", "Enable/Disable Smelling Salts", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[18] = CreateConVar("xupgrades_smelling_salts_losable", "1", "Is Smelling Salts losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[18] = 0;
	PerkTitle[18] = "Smelling Salts";
	BoosterAllowed[18] = 1;

	UpgradeIndex[19] = 524288;
	UpgradeTitle[19] = "\x01Second Wind \x05(Self-revive using pills/adrenaline)";
	UpgradeShort[19] = "\x03Second Wind";
	UpgradeEnabled[19] = CreateConVar("xupgrades_second_wind_enable", "1", "Enable/Disable Second Wind Aid Kit", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[19] = CreateConVar("xupgrades_second_wind_losable", "0", "Is Second Wind losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[19] = 1;
	PerkTitle[19] = "Second Wind";
	BoosterAllowed[19] = 0;
	UpgradeSecondWindHealth = CreateConVar("xupgrade_second_wind_health", "45.0", "How much health after reviving from incapacitation.", CVAR_FLAGS, true, 45.0, true, 80.0);

	UpgradeIndex[20] = 1048576;
	UpgradeTitle[20] = "\x01Hydration Belt \x05(Increased Secondary Item Usage)";
	UpgradeShort[20] = "\x03Hydration Belt";
	UpgradeEnabled[20] = CreateConVar("xupgrades_large_pain_pills_enable", "0", "Enable/Disable Hydration Belt", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[20] = CreateConVar("xupgrades_large_pain_pills_losable", "1", "Is Hydration Belt losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[20] = 0;
	PerkTitle[20] = "Hydration Belt";
	BoosterAllowed[20] = 0;

	UpgradeIndex[21] = 2097152;
	UpgradeTitle[21] = "\x01High Capacity Magazine \x05(Increased Magazine Clip)";
	UpgradeShort[21] = "\x03High Capacity Magazine";
	UpgradeEnabled[21] = CreateConVar("xupgrades_high_capacity_magazine_enable", "1", "Enable/Disable High Capacity Magazine", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[21] = CreateConVar("xupgrades_high_capacity_magazine_losable", "0", "Is High Capacity Magazine losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[21] = 0;
	PerkTitle[21] = "High Capacity Magazine";
	BoosterAllowed[21] = 1;

	UpgradeIndex[22] = 4194304;
	UpgradeTitle[22] = "\x01Healthcare \x05(Gives Adrenaline at roundstart)";
	UpgradeShort[22] = "\x03Healthcare";
	UpgradeEnabled[22] = CreateConVar("xupgrades_healthcare_enable", "1", "Enable/Disable Healthcare", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[22] = CreateConVar("xupgrades_healthcare_losable", "1", "Is Healthcare losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[22] = 1;
	PerkTitle[22] = "Healthcare";
	BoosterAllowed[22] = 1;

	UpgradeIndex[23] = 8388608;
	UpgradeTitle[23] = "\x01Shin Guards \x05(Increased Maximum Health)";
	UpgradeShort[23] = "\x03Shin Guards";
	UpgradeEnabled[23] = CreateConVar("xupgrades_shin_guards_enable", "0", "Enable/Disable Shin Guards", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[23] = CreateConVar("xupgrades_shin_guards_losable", "1", "Is Shin Guards losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[23] = 0;
	PerkTitle[23] = "Shin Guards";
	BoosterAllowed[23] = 1;

	UpgradeIndex[24] = 16777216;
	UpgradeTitle[24] = "\x01Safety Fuse \x05(Increased Pipebomb Duration)";
	UpgradeShort[24] = "\x03Safety Fuse";
	UpgradeEnabled[24] = CreateConVar("xupgrades_safety_fuse_enable", "1", "Enable/Disable Safety Fuse", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[24] = CreateConVar("xupgrades_safety_fuse_losable", "1", "Is Safety Fuse losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[24] = 0;
	PerkTitle[24] = "Safety Fuse";
	BoosterAllowed[24] = 1;

	UpgradeIndex[25] = 33554432;
	UpgradeTitle[25] = "\x01Syringe Pouch \x05(Increased Secondary Item Usage)";
	UpgradeShort[25] = "\x04Syringe Pouch";
	UpgradeEnabled[25] = CreateConVar("xupgrades_syringe_pouch_enable", "0", "Enable/Disable Syringe Pouch", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[25] = CreateConVar("xupgrades_syringe_pouch_losable", "1", "Is Syringe Pouch losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[25] = 0;
	PerkTitle[25] = "Syringe Pouch";
	BoosterAllowed[25] = 0;

	UpgradeIndex[26] = 67108864;
	UpgradeTitle[26] = "\x01Grenade Pouch \x05(Increased Grenade Capacity)";
	UpgradeShort[26] = "\x03Grenade Pouch";
	UpgradeEnabled[26] = CreateConVar("xupgrades_grenade_pouch_enable", "1", "Enable/Disable Grenade Pouch", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[26] = CreateConVar("xupgrades_grenade_pouch_losable", "1", "Is Grenade Pouch losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[26] = 0;
	PerkTitle[26] = "Grenade Pouch";
	BoosterAllowed[26] = 0;

	UpgradeIndex[27] = 134217728;
	UpgradeTitle[27] = "\x01Ammunition Satchel \x05(Increased Primary Item Capacity)";
	UpgradeShort[27] = "\x03Ammunition Satchel";
	UpgradeEnabled[27] = CreateConVar("xupgrades_ammunition_satchel_enable", "1", "Enable/Disable Ammunition Satchel", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[27] = CreateConVar("xupgrades_ammunition_satchel_losable", "1", "Is Ammunition Satchel losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[27] = 0;
	PerkTitle[27] = "Ammunition Satchel";
	BoosterAllowed[27] = 0;

	UpgradeIndex[28] = 1;
	UpgradeTitle[28] = "\x01Ocular Implants \x05(Infected Drop Items)";
	UpgradeShort[28] = "\x03Ocular Implants";
	UpgradeEnabled[28] = CreateConVar("xupgrades_ocular_implants_enable", "1", "Enable/Disable Ocular Implants", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[28] = CreateConVar("xupgrades_ocular_implants_losable", "1", "Is Ocular Implants losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[28] = 0;
	PerkTitle[28] = "Ocular Implants";
	BoosterAllowed[28] = 1;

	UpgradeIndex[29] = 1;
	UpgradeTitle[29] = "\x01Helmet \x05(Increased Maximum Health)";
	UpgradeShort[29] = "\x03Helmet";
	UpgradeEnabled[29] = CreateConVar("xupgrades_helmet_enable", "0", "Enable/Disable Helmet", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[29] = CreateConVar("xupgrades_helmet_losable", "1", "Is Helmet losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[29] = 0;
	PerkTitle[29] = "Helmet";
	BoosterAllowed[29] = 1;

	UpgradeIndex[30] = 1;
	UpgradeTitle[30] = "\x01Medical Chart \x05(Heal Other Players Nearby)";
	UpgradeShort[30] = "\x03Medical Chart";
	UpgradeEnabled[30] = CreateConVar("xupgrades_medical_chart_enable", "0", "Enable/Disable Medical Chart", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[30] = CreateConVar("xupgrades_medical_chart_losable", "1", "Is Medical Chart losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[30] = 0;
	PerkTitle[30] = "Medical Chart";
	BoosterAllowed[30] = 0;

	UpgradeIndex[31] = 1;
	UpgradeTitle[31] = "\x01Combat Gloves \x05(Decreased Melee Fatigue)";
	UpgradeShort[31] = "\x03Combat Gloves";
	UpgradeEnabled[31] = CreateConVar("xupgrades_combat_gloves_enable", "0", "Enable/Disable Combat Gloves", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[31] = CreateConVar("xupgrades_combat_gloves_losable", "1", "Is Combat Gloves losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[31] = 0;
	PerkTitle[31] = "Combat Gloves";
	BoosterAllowed[31] = 0;

	UpgradeIndex[32] = 1;
	UpgradeTitle[32] = "\x01Endocrine \x05(Increased Adrenaline Effect)";
	UpgradeShort[32] = "\x03Endocrine";
	UpgradeEnabled[32] = CreateConVar("xupgrades_endocrine_enable", "1", "Enable/Disable Endocrine", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[32] = CreateConVar("xupgrades_endocrine_losable", "1", "Is Endocrine losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[32] = 0;
	PerkTitle[32] = "Endocrine";
	BoosterAllowed[32] = 1;

	UpgradeIndex[33] = 1;
	UpgradeTitle[33] = "\x01Pills Addiction \x05(Consuming Pills Affects Other Players)";
	UpgradeShort[33] = "\x03Pills Addiction";
	UpgradeEnabled[33] = CreateConVar("xupgrades_pills_addiction_enable", "1", "Enable/Disable Pills Addiction", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeLosable[33] = CreateConVar("xupgrades_pills_addiction_losable", "1", "Is Pills Addiction losable?", CVAR_FLAGS, true, 0.0, true, 1.0);
	UpgradeEvent[33] = 0;
	PerkTitle[33] = "Pills Addiction";
	BoosterAllowed[33] = 0;

	HookEvent("adrenaline_used", event_AdrenalineUsedPre, EventHookMode_Pre);
	HookEvent("adrenaline_used", event_AdrenalineUsed, EventHookMode_Post);
	HookEvent("pills_used", event_PillsUsed, EventHookMode_Post);
	HookEvent("defibrillator_used", event_DefibrillatorUsed, EventHookMode_Post);
	HookEvent("upgrade_pack_used", event_UpgradePackUsed, EventHookMode_Post);
	HookEvent("player_spawn", event_PlayerSpawn, EventHookMode);
	HookEvent("player_bot_replace", event_PlayerBotReplace, EventHookMode_Post);	
	HookEvent("item_pickup", event_ItemPickup, EventHookMode_Post);
	HookEvent("player_use", event_PlayerUse, EventHookMode_Pre);
	HookEvent("ammo_pickup", event_AmmoPickup, EventHookMode_Post);
	HookEvent("player_death", event_PlayerDeath);
	HookEvent("award_earned", event_AwardEarned);
	HookEvent("round_start", round_start);
	HookEvent("round_end", round_end, EventHookMode_Pre);
	HookEvent("heal_success", event_HealSuccess);
	HookEvent("map_transition", round_end, EventHookMode_Pre);
	HookEvent("receive_upgrade", event_ReceiveUpgrade, EventHookMode_Post);
	HookEvent("revive_success", event_ReviveSuccess);
	HookEvent("player_incapacitated", event_PlayerIncapacitated);
	HookEvent("player_ledge_grab", event_PlayerLedgeGrab);
	HookEvent("heal_begin", event_HealBegin, EventHookMode_Pre);
	HookEvent("revive_begin", event_ReviveBegin, EventHookMode_Pre);
	HookEvent("weapon_reload", event_WeaponReload, EventHookMode_Pre);
	HookEvent("weapon_fire", event_WeaponFire, EventHookMode_Pre);
	HookEvent("break_prop", event_BreakProp, EventHookMode_Post);

	HookEvent("player_hurt", event_PlayerHurt, EventHookMode_Post);
	HookEvent("weapon_given", event_WeaponGiven, EventHookMode_Post);
	HookEvent("bot_player_replace", event_BotPlayerReplace, EventHookMode_Post);
	
	// Custom Awards
	HookEvent("infected_death", event_InfectedDeath);
	HookEvent("infected_hurt", event_InfectedHurt, EventHookMode_Post);
	HookEvent("player_now_it", event_PlayerNowIt, EventHookMode_Post);
	HookEvent("entered_spit", event_EnteredSpit);
	
	// Knife Tracking
	HookEvent("choke_start", event_KnifeCooldownCheck);
	HookEvent("lunge_pounce", event_KnifeCooldownCheck);
	HookEvent("charger_pummel_start", event_KnifeCooldownCheck);
	HookEvent("jockey_ride", event_KnifeCooldownCheck);
	
	HookEvent("choke_end", event_KnifeUnReady);
	HookEvent("pounce_end", event_KnifeUnReady);
	HookEvent("charger_pummel_end", event_KnifeUnReady);
	HookEvent("jockey_ride_end", event_KnifeUnReady);
			
	SetConVarInt(FindConVar("first_aid_kit_max_heal"), 250, false, false);
	SetConVarInt(FindConVar("pain_pills_health_threshold"), 250, false, false);
	SetConVarInt(FindConVar("first_aid_kit_use_duration"), 5, false, false);
	SetConVarInt(FindConVar("survivor_revive_duration"), 5, false, false);
	SetConVarInt(FindConVar("pipe_bomb_timer_duration"), 6, false, false);
	SetConVarInt(FindConVar("adrenaline_health_buffer"), 50, false, false);
	SetConVarFloat(FindConVar("adrenaline_duration"), 30.0, false, false);
	SetConVarInt(FindConVar("pain_pills_health_value"), 50, false, false);
	
	FirstAidDuration = GetConVarFloat(FindConVar("first_aid_kit_use_duration"));
	ReviveDuration = GetConVarFloat(FindConVar("survivor_revive_duration"));
	PipeBombDuration = GetConVarFloat(FindConVar("pipe_bomb_timer_duration"));
	AdrenalineDuration = GetConVarFloat(FindConVar("adrenaline_duration"));
	
	g_VarFirstAidDuration = FindConVar("first_aid_kit_use_duration");
	g_VarReviveDuration = FindConVar("survivor_revive_duration");
	g_VarAdrenalineDuration = FindConVar("adrenaline_duration");

	//get offsets
	g_iNextPAttO		=	FindSendPropInfo("CBaseCombatWeapon","m_flNextPrimaryAttack");
	g_iActiveWO			=	FindSendPropInfo("CBaseCombatCharacter","m_hActiveWeapon");
	g_iShotStartDurO	=	FindSendPropInfo("CBaseShotgun","m_reloadStartDuration");
	g_iShotInsertDurO	=	FindSendPropInfo("CBaseShotgun","m_reloadInsertDuration");
	g_iShotEndDurO		=	FindSendPropInfo("CBaseShotgun","m_reloadEndDuration");
	g_iPlayRateO		=	FindSendPropInfo("CBaseCombatWeapon","m_flPlaybackRate");
	g_iShotRelStateO	=	FindSendPropInfo("CBaseShotgun","m_reloadState");
	g_iNextAttO			=	FindSendPropInfo("CTerrorPlayer","m_flNextAttack");
	g_iTimeIdleO		=	FindSendPropInfo("CTerrorGun","m_flTimeWeaponIdle");
	g_iVMStartTimeO		=	FindSendPropInfo("CTerrorViewModel","m_flLayerStartTime");
	g_iViewModelO		=	FindSendPropInfo("CTerrorPlayer","m_hViewModel");

	AutoExecConfig(true, "xUpgrades_extendet");
}

public Action:timer_LoadxUpgrades(Handle:hTimer, any:client)
{
	LoadxUpgrades(client);
}

stock LoadxUpgrades(client)
{
	if(IsClientConnected(client))
	{
		GiveUpgrade(client, 21);
		GiveUpgrade(client, 15);
		GiveUpgrade(client, 2);
		GiveUpgrade(client, 6);
		GiveUpgrade(client, 13);
		GiveUpgrade(client, 12);
		iKnifeMaxUse[client] = 2;
		iSecondWindMaxUse[client] = 2;
		iAnnounceText[client] = 1;
	}
}

public Convar_Reload (Handle:convar, const String:oldValue[], const String:newValue[])
{
	new Float:flF=StringToFloat(newValue);
	if (flF<0.02)
		flF=0.02;
	else if (flF>0.9)
		flF=0.9;
	f_UpgradeFastReloadRate = flF;
}

public Action:CommandGiveUpgrade(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage:sm_giveupgrade <#userid|name> <index>");
		return Plugin_Handled;
	}
	decl String:arg[MAX_NAME_LENGTH], String:arg2[32];
	GetCmdArg(1, arg, sizeof(arg));
	if (args > 1)
	{
		GetCmdArg(2, arg2, sizeof(arg2));
	}
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	new targetclient;
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) > 0)
	{
		for (new i = 0; i < target_count; i++)
		{
			targetclient = target_list[i];
			GiveUpgrade(targetclient, StringToInt(arg2));
		}
	}
	else
	{
		ReplyToTargetError(client, target_count);
	}
	return Plugin_Handled;
}

public Action:CommandGiveRandomUpgrade(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage:sm_giverandomupgrade <#userid|name> <index>");
		return Plugin_Handled;
	}
	decl String:arg[MAX_NAME_LENGTH], String:arg2[32];
	GetCmdArg(1, arg, sizeof(arg));
	if (args > 1)
	{
		GetCmdArg(2, arg2, sizeof(arg2));
	}
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	new targetclient;
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) > 0)
	{
		for (new i = 0; i < target_count; i++)
		{
			targetclient = target_list[i];
			GiveSurvivorUpgrade(targetclient, StringToInt(arg2), 0);
		}
	}
	else
	{
		ReplyToTargetError(client, target_count);
	}
	return Plugin_Handled;
}

public OnMapEnd()
{
	OnGameEnd();
}

OnGameEnd()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(RegenerationTimer[i] != INVALID_HANDLE)
		{
			CloseHandle(RegenerationTimer[i]);
			RegenerationTimer[i] = INVALID_HANDLE;
		}
		if(SetClientUpgrades[i] != INVALID_HANDLE)
		{
			CloseHandle(SetClientUpgrades[i]);
			SetClientUpgrades[i] = INVALID_HANDLE;
		}
		if(AwardsCooldownTimer[i] != INVALID_HANDLE)
		{
			CloseHandle(AwardsCooldownTimer[i]);
			AwardsCooldownTimer[i] = INVALID_HANDLE;
		}		
		if(KnifeCooldownTimer[i] != INVALID_HANDLE)
		{
			CloseHandle(KnifeCooldownTimer[i]);
			KnifeCooldownTimer[i] = INVALID_HANDLE;
		}
		if(SecondWindCooldownTimer[i] != INVALID_HANDLE)
		{
			CloseHandle(SecondWindCooldownTimer[i]);
			SecondWindCooldownTimer[i] = INVALID_HANDLE;
		}
	}
}

public OnClientPostAdminCheck(client)
{
	iPerkBonusSlots[client] = 0;
	for(new i = 0; i < MAX_UPGRADES; i++)
	{
		iUpgrade[client][i] = 0;
		iUpgradeDisabled[client][i] = 0;
		iBooster[client][i] = 0;
	}
	if(client > 0 && IsClientInGame(client))
		CreateTimer(0.2, timer_LoadxUpgrades, client);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);	
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponCanUsePost, OnWeaponEquip);
}

public event_PlayerBotReplace(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	iSaveFeature[client] = 0;
	if(client> 0 && IsClientInGame(client) && IsFakeClient(client))
		CreateTimer(0.5, timer_LoadxUpgrades, client);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	//PrintToChatAll("%s", m_attacker);
	if(iUpgrade[victim][3] > 0 && GetClientTeam(victim) == 2)
	{
		//PrintToChat(victim, "Damage: %f, New: %f", damage, damage*0.5);
		damage = damage * (0.5-CheckBoosters(victim, 3));
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:OnWeaponEquip(client, entity)
{
	UpgradeLaserSight(client);
	return Plugin_Continue;
}

public SetClientUpgradesCheck(client)
{
	if(SetClientUpgrades[client] != INVALID_HANDLE)
	{
		CloseHandle(SetClientUpgrades[client]);
		SetClientUpgrades[client] = INVALID_HANDLE;
	}
	if(SetClientUpgrades[client] == INVALID_HANDLE)
	{
		SetClientUpgrades[client] = CreateTimer(UPGRADE_LOAD_TIME, SetSurvivorUpgrades, client);
	}
	
}

public event_WeaponFire(Handle:event, const String:name[], bool:Broadcast)
{
	//14 - PipeBomb, 13 - Molotov, 25 - VomitJar
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new WeaponID = GetEventInt(event, "weaponid");
	if(WeaponID == 13)
	{
		UpgradeKerosene(client);
	}	
	if(WeaponID == 14)
	{
		UpgradeSafetyFuse(client);
		CreateTimer(1.0, timer_SafetyFuseStop, client);
	}
	if(iUpgrade[client][26] > 0 && (WeaponID == 13 || WeaponID == 14 || WeaponID == 25))
	{
		UpgradeGrenadePouch(client);
	}
}

public event_WeaponReload(Handle:event, const String:name[], bool:Broadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	iActiveWeapon[client] = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	UpgradeHighCapacityMag(client);
	UpgradeFastReload(client);
}

public event_PlayerSpawn(Handle:event, const String:name[], bool:Broadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(client > 0 && GetClientTeam(client) == 2)
	{
		CreateTimer(2.0, event_TimerPlayerSpawn, client);
	}
}

public event_PlayerDeath(Handle:event, const String:name[], bool:Broadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new entityid = GetEventInt(event, "entityid");
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new bool:headshot = GetEventBool(event, "headshot");
	
	iHotMeal[client] = 0;
	iAloeVera[client] = 0;
	
	if(headshot == true && entityid > 0)
	{
		UpgradeOcularImplants(attacker, entityid);
	}
	
	if(client > 0 && IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		for(new i = 0; i < 2; i++)
		{
			if(!StrEqual(iPrimaryItems[client][i], ""))
			{
				GivePlayerItem(client, iPrimaryItems[client][i]);
				iPrimaryItems[client][i] = "";
			}
			if(!StrEqual(iSecondaryItems[client][i], ""))
			{
				GivePlayerItem(client, iSecondaryItems[client][i]);
				iSecondaryItems[client][i] = "";
			}
			if(!StrEqual(iGrenadeItems[client][i], ""))
			{
				GivePlayerItem(client, iGrenadeItems[client][i]);
				iGrenadeItems[client][i] = "";
			}
		}
	}
	
	// 0 - Disabled
	if(GetConVarInt(AwardIndex[0]) == 0)
	{
		return;
	}
	if(GetConVarInt(g_PerkMode) == 0)
	{
		// 1 - Bots Only
		if(client > 0 && GetConVarInt(AwardIndex[0]) == 1 && IsFakeClient(client) && GetClientTeam(client) == 2)
			RemoveSurvivorUpgrade(client, GetConVarInt(penalty_upgrades), 0);
		// 2 - Humans Only
		if(client > 0 && GetConVarInt(AwardIndex[0]) == 2 && !IsFakeClient(client) && GetClientTeam(client) == 2)
			RemoveSurvivorUpgrade(client, GetConVarInt(penalty_upgrades), 0);
		// 3 - All Players
		if(client > 0 && GetConVarInt(AwardIndex[0]) == 3 && GetClientTeam(client) == 2)
			RemoveSurvivorUpgrade(client, GetConVarInt(penalty_upgrades), 0);
	}
}

public Action:event_TimerPlayerSpawn(Handle:timer, any:client)
{
	if(b_round_end == true || !IsClientInGame(client) || !IsPlayerAlive(client) || HasIdlePlayer(client))
	{
		return;
	}
	if(GetClientTeam(client) == 2 && IsPlayerAlive(client))
	{
		SetClientUpgradesCheck(client);
	}
}

public Action:SetSurvivorUpgrades(Handle:timer, any:client)
{
	SetClientUpgrades[client] = INVALID_HANDLE;
	if(b_round_end == true)
	{
		return;
	}

	if(client > 0 && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !HasIdlePlayer(client))
	{
		UpgradeLaserSight(client);
	}
	if(IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && iBitsUpgrades[client] > 0)
	{
		EmitSoundToClient(client, "player/orch_hit_Csharp_short.wav");
	}
}

public event_ItemPickup(Handle:event, const String:name[], bool:Broadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new String:iWeaponName[32];
	GetEventString(event, "item", iWeaponName, 32);

	if(client > 0)
	{
		UpgradeLaserSight(client);
		if(iUpgrade[client][6] > 0)
		{
			if(StrContains(iWeaponName, "smg", false) != -1 || StrContains(iWeaponName, "rifle", false) != -1 || StrContains(iWeaponName, "shotgun", false) != -1 || StrContains(iWeaponName, "sniper", false) != -1)
			{
				GivePlayerAmmoX(client);
			}
			if(StrEqual(iWeaponName, "weapon_rifle_m60"))
			{
				UpgradeBandoliers(client);
			}
		}
		if(IsFakeClient(client))
		{
			if(StrEqual(iWeaponName, "first_aid_kit"))
			{
				new maxslots = 0;
				if(iUpgrade[client][27] > 0)
					maxslots++;
				for(new item = 0; item < maxslots; item++)
				{
					new slot = GetAvailableExtraSlot(client, 1);
					if(slot != -1)
					{
						Format(iWeaponName, sizeof(iWeaponName), "weapon_%s", iWeaponName);
						iPrimaryItems[client][slot] = iWeaponName;
					}
				}
			}
			if(StrEqual(iWeaponName, "pain_pills") || StrEqual(iWeaponName, "adrenaline"))
			{
				new maxslots = 0;
				if(iUpgrade[client][20] > 0)
					maxslots++;
				if(iUpgrade[client][25] > 0)
					maxslots++;
				for(new item = 0; item < maxslots; item++)
				{
					new slot = GetAvailableExtraSlot(client, 1);
					if(slot != -1)
					{
						Format(iWeaponName, sizeof(iWeaponName), "weapon_%s", iWeaponName);
						iSecondaryItems[client][slot] = iWeaponName;
					}
				}
			}
		}
	}
}

public Action:event_PlayerUse(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	decl String:item[64];
	new targetid = GetEventInt(event, "targetid");
	if(targetid > 0)
	{
		GetEdictClassname(targetid, item, sizeof(item));
		if(StrContains(item, "ammo", false) != -1)
		{
			ClearPlayerAmmo(client);
			CheatCommand(client, "give", "ammo", "");
			GivePlayerAmmoX(client);
			if(iUpgrade[client][14] > 0)
			{
				UpgradeBandoliers(client);
			}
		}
	}

	if(iUpgrade[client][26] > 0 && GetPlayerWeaponSlot(client, 2) > 0)
	{
		decl String:iWeaponName[LEN64];
		if(targetid != -1)
		{
			GetEdictClassname(targetid, iWeaponName, sizeof(iWeaponName));
			if(StrContains(iWeaponName, "molotov", false) != -1 || StrContains(iWeaponName, "pipe_bomb", false) != -1 || StrContains(iWeaponName, "vomitjar", false) != -1)
			{
				if((StrContains(iWeaponName, "_spawn", false) != -1 && GetEntProp(targetid, Prop_Data, "m_itemCount") > 0) || (StrContains(iWeaponName, "_spawn", false) == -1 && GetEntPropEnt(targetid, Prop_Data, "m_hOwner") != client))
				{
					new slot = GetAvailableExtraSlot(client, 0);
					if(slot != -1)
					{
						if(StrContains(iWeaponName, "_spawn", false) != -1 && GetEntProp(targetid, Prop_Data, "m_itemCount") > 0)
							SetEntProp(targetid, Prop_Data, "m_itemCount", 0);
						AcceptEntityInput(targetid, "kill");
						ReplaceStringEx(iWeaponName, sizeof(iWeaponName), "_spawn", "");
						iGrenadeItems[client][slot] = iWeaponName;
						if(StrContains(iWeaponName, "molotov", false) != -1)
							PrintToChat(client, "You picked up an Extra Molotov.");
						if(StrContains(iWeaponName, "pipe_bomb", false) != -1)
							PrintToChat(client, "You picked up an Extra Pipe Bomb.");
						if(StrContains(iWeaponName, "vomitjar", false) != -1)
							PrintToChat(client, "You picked up an Extra Vomit Jar.");
						EmitSoundToClient(client, "sound/items/itempickup.wav");
						return Plugin_Handled;
					}
				}
			}
		}
	}
	if(iUpgrade[client][27] > 0 && GetPlayerWeaponSlot(client, 3) > 0)
	{
		decl String:iWeaponName[LEN64];
		if(targetid != -1)
		{
			GetEdictClassname(targetid, iWeaponName, sizeof(iWeaponName));
			if(StrContains(iWeaponName, "first_aid_kit", false) != -1 || StrContains(iWeaponName, "defibrillator", false) != -1 || StrContains(iWeaponName, "upgradepack_explosive", false) != -1 || StrContains(iWeaponName, "upgradepack_incendiary", false) != -1)
			{
				if((StrContains(iWeaponName, "_spawn", false) != -1 && GetEntProp(targetid, Prop_Data, "m_itemCount") > 0) || (StrContains(iWeaponName, "_spawn", false) == -1 && GetEntPropEnt(targetid, Prop_Data, "m_hOwner") != client))
				{
					new slot = GetAvailableExtraSlot(client, 1);
					if(slot != -1)
					{
						if(StrContains(iWeaponName, "_spawn", false) != -1 && GetEntProp(targetid, Prop_Data, "m_itemCount") > 0)
							SetEntProp(targetid, Prop_Data, "m_itemCount", 0);
						AcceptEntityInput(targetid, "kill");
						ReplaceStringEx(iWeaponName, sizeof(iWeaponName), "_spawn", "");
						iPrimaryItems[client][slot] = iWeaponName;
						if(StrContains(iWeaponName, "first_aid_kit", false) != -1)
							PrintToChat(client, "You picked up an Extra First Aid Kit.");
						if(StrContains(iWeaponName, "defibrillator", false) != -1)
							PrintToChat(client, "You picked up an Extra Defibrillator.");
						if(StrContains(iWeaponName, "upgradepack_explosive", false) != -1)
							PrintToChat(client, "You picked up an Extra Explosive Pack.");
						if(StrContains(iWeaponName, "upgradepack_incendiary", false) != -1)
							PrintToChat(client, "You picked up an Extra Incendiary Pack.");
						return Plugin_Handled;
					}
				}
			}
		}
	}
	if(iUpgrade[client][20] > 0 || iUpgrade[client][25] > 0 && GetPlayerWeaponSlot(client, 4) > 0)
	{
		decl String:iWeaponName[LEN64];
		if(targetid != -1)
		{
			GetEdictClassname(targetid, iWeaponName, sizeof(iWeaponName));
			if(StrContains(iWeaponName, "pain_pills", false) != -1 || StrContains(iWeaponName, "adrenaline", false) != -1)
			{
				if((StrContains(iWeaponName, "_spawn", false) != -1 && GetEntProp(targetid, Prop_Data, "m_itemCount") > 0) || (StrContains(iWeaponName, "_spawn", false) == -1 && GetEntPropEnt(targetid, Prop_Data, "m_hOwner") != client))
				{
					new slot = GetAvailableExtraSlot(client, 2);
					if(slot != -1)
					{
						if(StrContains(iWeaponName, "_spawn", false) != -1 && GetEntProp(targetid, Prop_Data, "m_itemCount") > 0)
							SetEntProp(targetid, Prop_Data, "m_itemCount", 0);
						AcceptEntityInput(targetid, "kill");
						ReplaceStringEx(iWeaponName, sizeof(iWeaponName), "_spawn", "");
						iSecondaryItems[client][slot] = iWeaponName;
						if(StrContains(iWeaponName, "pain_pills", false) != -1)
							PrintToChat(client, "You picked up an Extra Pain Pills.");
						if(StrContains(iWeaponName, "adrenaline", false) != -1)
							PrintToChat(client, "You picked up an Extra Adrenaline.");
						return Plugin_Handled;
					}
				}
			}
		}
	}

	return Plugin_Handled;
}

public event_AmmoPickup(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	if (client == 0)
		return;

	if(client > 0 && iUpgrade[client][6] > 0)
	{
		GivePlayerAmmoX(client);
	}
}
public event_KnifeCooldownCheck(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new victim = GetClientOfUserId(GetEventInt(event,"victim"));
	iKnifeReady = true;
	if(iKnifeReady > 0 && iKnifeMaxUse[victim] > 0 && IsPlayerAlive(victim) && b_round_end == false)
	{
		PrintHintText(victim, "Press MOUSE2 to use the knife.");
		if(KnifeCooldownTimer[victim] == INVALID_HANDLE)
		{
			KnifeCooldownTimer[victim] = CreateTimer(0.8, timer_KnifeCooldownTimer, victim);
		}
	}

	else if(iKnifeMaxUse[victim] == 0)
	{
		PrintHintText(victim, "You can use knife only 2 times.");
	}
}

public event_KnifeUnReady(Handle:event, const String:name[], bool:dontBroadcast) 
{
	iKnifeReady = false;
}

public event_WeaponGiven(Handle:event, const String:name[], bool:dontBroadcast) 
{
	// 15 - Pain Pills, 23 - Adrenaline Shot
	new client = GetClientOfUserId(GetEventInt(event,"giver"));
	new weapon = GetEventInt(event,"weapon");

	if(weapon == 15 || weapon == 23)
	{
		UpgradeSecondaryItems(client);
	}
}

public Action:OnPreThink(client)
{
	new ActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	decl String:WEAPON_NAME[64];
	
	if(ActiveWeapon == -1)
		return;
		
	GetEdictClassname(ActiveWeapon, WEAPON_NAME, sizeof(WEAPON_NAME));
	
	new m_bInReload = GetEntProp(ActiveWeapon, Prop_Send, "m_bInReload");
	
	if(StrContains(WEAPON_NAME, "shotgun", false) != -1 || ActiveWeapon != iActiveWeapon[client])
	{
		SDKUnhook(client, SDKHook_PreThink, OnPreThink);
		return;
	}	
	if(m_bInReload)
	{
		// Do Nothing
	}
	else
	{
		new m_iClip1 = GetEntProp(ActiveWeapon, Prop_Send, "m_iClip1");
		new m_iAmmo = GetEntData(client, (FindDataMapInfo(client, "m_iAmmo") + CheckWeaponAmmoType(ActiveWeapon))); 
		new button=GetClientButtons(client);
		
		if(CheckWeaponUpgradeLimit(ActiveWeapon, client, false) == m_iClip1 && (button & IN_RELOAD))
		{
			SetEntProp(ActiveWeapon, Prop_Send, "m_iClip1", 0, 4);
		}
		else if(m_iClip1 > 0)
		{
			if(StrEqual(WEAPON_NAME, "weapon_pistol") || StrEqual(WEAPON_NAME, "weapon_pistol_magnum"))
			{
				SetEntProp(ActiveWeapon, Prop_Send, "m_iClip1", CheckWeaponUpgradeLimit(ActiveWeapon, client, true), 4);
			}
			else
			{
				if(m_iAmmo < RoundToFloor(float(CheckWeaponUpgradeLimit(ActiveWeapon, client, false)))*(0.5+CheckBoosters(client, 21)))
				{
					SetEntProp(ActiveWeapon, Prop_Send, "m_iClip1", m_iClip1 + m_iAmmo, 4);
					SetEntData(client, (FindDataMapInfo(client, "m_iAmmo") + CheckWeaponAmmoType(ActiveWeapon)), 0, 4, true);
				}
				else
				{
					SetEntProp(ActiveWeapon, Prop_Send, "m_iClip1", CheckWeaponUpgradeLimit(ActiveWeapon, client, true), 4);
					SetEntData(client, (FindDataMapInfo(client, "m_iAmmo") + CheckWeaponAmmoType(ActiveWeapon)), m_iAmmo - RoundToFloor(float(CheckWeaponUpgradeLimit(ActiveWeapon, client, false))*(0.5+CheckBoosters(client, 21))), 4, true);
				}
			}
			SDKUnhook(client, SDKHook_PreThink, OnPreThink);
		}
	}
}

public Action:OnWeaponCanUse(client, weapon)
{
	if(iUpgrade[client][26] > 0)
	{
		decl String:iWeaponName[LEN64];
		if(weapon != -1)
		{
			GetEdictClassname(weapon, iWeaponName, sizeof(iWeaponName));
			if(StrContains(iWeaponName, "molotov", false) != -1 || StrContains(iWeaponName, "pipe_bomb", false) != -1 || StrContains(iWeaponName, "vomitjar", false) != -1)
			{
				if(GetPlayerWeaponSlot(client, 2) > 0 && GetAvailableExtraSlot(client, 0) != -1)
				{
					return Plugin_Handled;
				}
			}
		}
	}
	if(iUpgrade[client][27] > 0)
	{
		decl String:iWeaponName[LEN64];
		if(weapon != -1)
		{
			GetEdictClassname(weapon, iWeaponName, sizeof(iWeaponName));
			if(StrContains(iWeaponName, "first_aid_kit", false) != -1 || StrContains(iWeaponName, "defibrillator", false) != -1 || StrContains(iWeaponName, "upgradepack_explosive", false) != -1 || StrContains(iWeaponName, "upgradepack_incendiary", false) != -1)
			{
				if(GetPlayerWeaponSlot(client, 3) > 0 && GetAvailableExtraSlot(client, 1) != -1)
				{
					return Plugin_Handled;
				}
			}
		}
	}
	if(iUpgrade[client][20] > 0 || iUpgrade[client][25] > 0)
	{
		decl String:iWeaponName[LEN64];
		if(weapon != -1)
		{
			GetEdictClassname(weapon, iWeaponName, sizeof(iWeaponName));
			if(StrContains(iWeaponName, "pain_pills", false) != -1 || StrContains(iWeaponName, "adrenaline", false) != -1)
			{
				if(GetPlayerWeaponSlot(client, 4) > 0 && GetAvailableExtraSlot(client, 2) != -1)
				{
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Continue;
}

GetAvailableExtraSlot(client, type)
{
	if(type == 0)
	{
		new maxslots = 0;
		if(iUpgrade[client][26] > 0)
			maxslots = 2;
		for(new slot = 0; slot < maxslots; slot++)
		{
			if(StrEqual(iGrenadeItems[client][slot], ""))
			{
				return slot;
			}
		}
		return -1;
	}
	if(type == 1)
	{
		new maxslots = 0;
		if(iUpgrade[client][27] > 0)
			maxslots++;
		for(new slot = 0; slot < maxslots; slot++)
		{
			if(StrEqual(iPrimaryItems[client][slot], ""))
			{
				return slot;
			}
		}
		return -1;
	}
	if(type == 2)
	{
		new maxslots = 0;
		if(iUpgrade[client][20] > 0)
			maxslots++;
		if(iUpgrade[client][25] > 0)
			maxslots++;
		for(new slot = 0; slot < maxslots; slot++)
		{
			if(StrEqual(iSecondaryItems[client][slot], ""))
			{
				return slot;
			}
		}
		return -1;
	}
	return -1;
}

GivePlayerAmmoX(client)
{
	new iWEAPON = GetPlayerWeaponSlot(client, 0);
	if(iWEAPON > 0)
	{
		//GetEntProp(iWEAPON, Prop_Send, "m_iClip1");
		new m_iAmmo = FindDataMapInfo(client, "m_iAmmo");

		if(iUpgrade[client][6] > 0)
		{
			SetEntData(client, m_iAmmo+RIFLE_OFFSET_AMMO, RoundToNearest((RIFLE_AMMO * (2.0))) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
			SetEntData(client, m_iAmmo+SMG_OFFSET_AMMO, RoundToNearest((SMG_AMMO * (1.5))) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
			SetEntData(client, m_iAmmo+SHOTGUN_OFFSET_AMMO, RoundToNearest((SHOTGUN_AMMO * (2.5))) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
			SetEntData(client, m_iAmmo+AUTOSHOTGUN_OFFSET_AMMO, RoundToNearest((AUTOSHOTGUN_AMMO * (4.5))) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
			SetEntData(client, m_iAmmo+HUNTING_RIFLE_OFFSET_AMMO, RoundToNearest((HUNTING_RIFLE_AMMO * (2.1))) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
			SetEntData(client, m_iAmmo+SNIPER_OFFSET_AMMO, RoundToNearest((SNIPER_AMMO * (1.8))) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
		}
		else
		{
			SetEntData(client, m_iAmmo+RIFLE_OFFSET_AMMO, GetConVarInt(FindConVar("ammo_assaultrifle_max")) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
			SetEntData(client, m_iAmmo+SMG_OFFSET_AMMO, GetConVarInt(FindConVar("ammo_smg_max")) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
			SetEntData(client, m_iAmmo+SHOTGUN_OFFSET_AMMO, GetConVarInt(FindConVar("ammo_shotgun_max")) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
			SetEntData(client, m_iAmmo+AUTOSHOTGUN_OFFSET_AMMO, GetConVarInt(FindConVar("ammo_autoshotgun_max")) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
			SetEntData(client, m_iAmmo+HUNTING_RIFLE_OFFSET_AMMO, GetConVarInt(FindConVar("ammo_huntingrifle_max")) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
			SetEntData(client, m_iAmmo+SNIPER_OFFSET_AMMO, GetConVarInt(FindConVar("ammo_sniperrifle_max")) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
		}
	}
}

ClearPlayerAmmo(client)
{
	new m_iAmmo = FindDataMapInfo(client, "m_iAmmo");
	SetEntData(client, m_iAmmo+RIFLE_OFFSET_AMMO, 0);
	SetEntData(client, m_iAmmo+SMG_OFFSET_AMMO, 0);
	SetEntData(client, m_iAmmo+SHOTGUN_OFFSET_AMMO, 0);
	SetEntData(client, m_iAmmo+AUTOSHOTGUN_OFFSET_AMMO, 0);
	SetEntData(client, m_iAmmo+HUNTING_RIFLE_OFFSET_AMMO, 0);
	SetEntData(client, m_iAmmo+SNIPER_OFFSET_AMMO, 0);
}


CheckWeaponUpgradeLimit(weapon, client, bool:status)
{
	new UpgradeLimit = 0;
	decl String:WEAPON_NAME[64];
	GetEdictClassname(weapon, WEAPON_NAME, 32);

	if(StrEqual(WEAPON_NAME, "weapon_rifle") || StrEqual(WEAPON_NAME, "weapon_rifle_sg552") || StrEqual(WEAPON_NAME, "weapon_smg") || StrEqual(WEAPON_NAME, "weapon_smg_silenced") || StrEqual(WEAPON_NAME, "weapon_smg_mp5"))
	{
		UpgradeLimit = 50;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_rifle_desert"))
	{		 
		UpgradeLimit = 60;
	}			
	else if(StrEqual(WEAPON_NAME, "weapon_rifle_ak47"))
	{
		UpgradeLimit = 40;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_pumpshotgun") || StrEqual(WEAPON_NAME, "weapon_shotgun_chrome"))
	{
		UpgradeLimit = 8;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_autoshotgun") || StrEqual(WEAPON_NAME, "weapon_shotgun_spas"))
	{
		UpgradeLimit = 10;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_hunting_rifle") || StrEqual(WEAPON_NAME, "weapon_sniper_scout"))
	{
		UpgradeLimit = 15;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_sniper_awp"))
	{
		UpgradeLimit = 20;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_sniper_military"))
	{
		UpgradeLimit = 30;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_grenade_launcher"))
	{
		UpgradeLimit = 1;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_pistol"))
	{
		if(GetEntProp(weapon, Prop_Send, "m_isDualWielding") > 0)
		{
			UpgradeLimit = 30;
		}
		else
		{
			UpgradeLimit = 15;
		}
	}
	else if(StrEqual(WEAPON_NAME, "weapon_pistol_magnum"))
	{
		UpgradeLimit = 8;
	}
	if(iUpgrade[client][21] > 0 && status == true)
	{
		UpgradeLimit = RoundFloat(UpgradeLimit * (1.5+CheckBoosters(client, 21)));
	}
	return UpgradeLimit;
}

CheckWeaponAmmoType(weapon)
{
	new AmmoType = 0;
	decl String:WEAPON_NAME[64];
	GetEdictClassname(weapon, WEAPON_NAME, 32);

	if(StrEqual(WEAPON_NAME, "weapon_smg") || StrEqual(WEAPON_NAME, "weapon_smg_silenced") || StrEqual(WEAPON_NAME, "weapon_smg_mp5"))
	{
		AmmoType = SMG_OFFSET_AMMO;
	}
	if(StrEqual(WEAPON_NAME, "weapon_rifle") || StrEqual(WEAPON_NAME, "weapon_rifle_desert") || StrEqual(WEAPON_NAME, "weapon_rifle_ak47"))
	{
		AmmoType = RIFLE_OFFSET_AMMO;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_pumpshotgun") || StrEqual(WEAPON_NAME, "weapon_shotgun_chrome"))
	{
		AmmoType = SHOTGUN_OFFSET_AMMO;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_autoshotgun") || StrEqual(WEAPON_NAME, "weapon_shotgun_spas"))
	{
		AmmoType = AUTOSHOTGUN_OFFSET_AMMO;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_hunting_rifle") || StrEqual(WEAPON_NAME, "weapon_sniper_scout"))
	{
		AmmoType = HUNTING_RIFLE_OFFSET_AMMO;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_sniper_military"))
	{
		AmmoType = SNIPER_OFFSET_AMMO;
	}
	else if(StrEqual(WEAPON_NAME, "weapon_grenade_launcher"))
	{
		AmmoType = GRENADE_LAUNCHER_OFFSET_AMMO;
	}
	return AmmoType;
}

public OnClientDisconnect(client)
{
	// if(IsClientInGame(client) && GetClientTeam(client) != 3)
	// 	SaveData(client);
}

public GiveSurvivorUpgrade(client, amount, awardid)
{
	for(new num = 0; num < amount; num++)
	{
		decl String:ClientUserName[MAX_NAME_LENGTH];
		GetClientName(client, ClientUserName, sizeof(ClientUserName));

		new numOwned = GetSurvivorUpgrades(client);
		if(numOwned == GetEnabledUpgrades() || numOwned == GetAvailableUpgrades(client))
		{
			if(IsClientInGame(client) && iAnnounceText[client] == 1)
				PrintToChat(client, "%s \x01You earned the %s.", xUpgrade_tag, AwardTitle[awardid]);
			return;
		}
		new offset = GetRandomInt(0,MAX_UPGRADES-(GetAbSurvivorUpgrades(client)+1));
		new val = 0;
		while(offset > 0 || iUpgrade[client][val] || GetConVarInt(UpgradeEnabled[val]) != 1 || iUpgradeDisabled[client][val] != 0)
		{
			if((!iUpgrade[client][val]) && GetConVarInt(UpgradeEnabled[val]) == 1 || iUpgradeDisabled[client][val] == 1)
			{
				offset--;
			}
			val++;
			//PrintToChatAll("Offset: %d, UpgradeID: %d", offset, val);
		}

		if(client > 0 && IsPlayerAlive(client) && UpgradeEvent[val] == 0)
		{
			GiveUpgrade(client, val);
			if(IsClientInGame(client) && iAnnounceText[client] == 1)
				PrintToChat(client, "%s \x01You earned %s \x01from %s.", xUpgrade_tag, UpgradeShort[val], AwardTitle[awardid]);
		}
	}
}

public RemoveSurvivorUpgrade(client, amount, awardid)
{
	for(new num = 0; num < amount; num++)
	{
		decl String:ClientUserName[MAX_NAME_LENGTH];
		GetClientName(client, ClientUserName, sizeof(ClientUserName));

		new numMiss = MissingSurvivorUpgrades(client);
		if(numMiss == MAX_UPGRADES)
		{
			if(IsClientInGame(client) && iAnnounceText[client] == 1 && GetClientTeam(client) == 2)
				PrintToChat(client, "%s \x01You lost all upgrades.", xUpgrade_tag);
			return;
		}
		new offset = GetRandomInt(0,MAX_UPGRADES-(numMiss+1));
		new val = 0;
		while(offset > 0 || !iUpgrade[client][val])
		{
			if((iUpgrade[client][val]))
			{
				offset--;
			}
			val++;
		}

		if(GetConVarInt(UpgradeLosable[val]) > 0)
		{
			RemoveUpgrade(client, val);
			if(IsClientInGame(client) && iAnnounceText[client] == 1)
				PrintToChat(client, "%s \x01You lost %s \x01from %s.", xUpgrade_tag, UpgradeShort[val], AwardTitle[awardid]);
		}	
	}
}

public GiveUpgrade(client, upgrade)
{
	if(UpgradeEnabled[upgrade] > 0)
	{
		for(new i = 0; i < MAX_UPGRADES; i++)
		{
			if(client > 0 && i == upgrade)
			{
				iUpgrade[client][upgrade] = UpgradeIndex[upgrade];
				iBitsUpgrades[client] += iUpgrade[client][upgrade];
				SetClientUpgradesCheck(client);
			}
		}
	}	
}

public RemoveUpgrade(client, upgrade)
{
	if(UpgradeEnabled[upgrade] > 0)
	{
		for(new i = 0; i < MAX_UPGRADES; i++)
		{
			if(client > 0 && i == upgrade && GetConVarInt(UpgradeLosable[i]) > 0)
			{
				iUpgrade[client][upgrade] = 0;
				iBitsUpgrades[client] -= UpgradeIndex[upgrade];
				SetClientUpgradesCheck(client);
			}
		}
	}
}

public GetEnabledUpgrades()
{
	new upgrades = 0;
	for(new i = 0; i < MAX_UPGRADES; i++)
	{
		if(GetConVarInt(UpgradeEnabled[i]) > 0)
		{
			upgrades++;
		}
	}
	return upgrades;
}

public GetAvailableUpgrades(client)
{
	new upgrades = 0;
	for(new i = 0; i < MAX_UPGRADES; i++)
	{
		if(iUpgradeDisabled[client][i] == 0 && GetConVarInt(UpgradeEnabled[i]) == 1)
		{
			upgrades++;
		}
	}
	return upgrades;
}

public GetSurvivorUpgrades(client)
{
	new upgrades = 0;
	for(new i = 0; i < MAX_UPGRADES; i++)
	{
		if(iUpgrade[client][i] > 0)
		{
			upgrades++;
		}
	}
	return upgrades;
}

public GetAbSurvivorUpgrades(client)
{
	new upgrades = 0;
	for(new i = 0; i < MAX_UPGRADES; i++)
	{
		if(iUpgrade[client][i] > 0 || iUpgradeDisabled[client][i] == 1)
		{
			upgrades++;
		}
	}
	return upgrades;
}

public SetUpgradeBitVec(client)
{
	new upgradeBitVec = 0;
	for(new i = 0; i < 31; i++)
	{
		if(iUpgrade[client][i] > 0 && iUpgradeDisabled[client][i] != 1)
		{
			upgradeBitVec += iUpgrade[client][i];
		}
	}
	return upgradeBitVec;
}

public ResetClientUpgrades(client)
{
	for(new i = 0; i < MAX_UPGRADES; i++)
	{
		iUpgrade[client][i] = 0;
	}
	iBitsUpgrades[client] = 0;
	SetClientUpgrades[client] = CreateTimer(UPGRADE_LOAD_TIME, SetSurvivorUpgrades, client);
}

public ResetClientSpecificUpgrade(client, upgrade)
{
	iUpgrade[client][upgrade] = 0;
	iBitsUpgrades[client] = 0;
	SetClientUpgrades[client] = CreateTimer(UPGRADE_LOAD_TIME, SetSurvivorUpgrades, client);
}

public MissingSurvivorUpgrades(client)
{
	new upgrades = 0;
	for(new i = 0; i < MAX_UPGRADES; i++)
	{
		if(iUpgrade[client][i] <= 0)
		{
			upgrades++;
		}
	}
	return upgrades;
}

public Action:UpgradeLaserSightToggle(client, args)
{
	if(GetClientTeam(client) == 2)
	{
		if(iUpgrade[client][2] == 0 && GetConVarInt(UpgradeEnabled[2]) == 1 && iUpgradeDisabled[client][2] != 1)
		{
			PrintToChat(client, "%s \x01Laser Sight is \x04On\x01.", xUpgrade_tag);
			GiveUpgrade(client, 2);
		}
		else if(iUpgrade[client][2] > 0)
		{
			PrintToChat(client, "%s \x01Laser Sight is \x04Off\x01.", xUpgrade_tag);
			RemoveUpgrade(client, 2);
		}
		else if(iUpgradeDisabled[client][2] == 1)
		{
			PrintToChat(client, "%s \x01Laser Sight is \x04Disabled\x01. Please \x04Enable \x01Laser Sight before using the command.", xUpgrade_tag);
		}
		else if(GetConVarInt(g_PerkMode) == 1 && iUpgrade[client][2] == 0 && GetSurvivorUpgrades(client) >= GetConVarInt(PerkSlots) + iPerkBonusSlots[client])
		{
			PrintToChat(client, "%s \x01You cannot equip more perks.", xUpgrade_tag);
		}
	}
	else
	{
		PrintToChat(client, "%s \x01You must be on the \x04Survivor Team\x01.", xUpgrade_tag);
	}
}

public Action:ResetUpgradesSurvivor(client, args)
{
	ResetClientUpgrades(client);
	PrintToChat(client, "%s \x01Your upgrades has been reseted!", xUpgrade_tag);
}

public Action:PrintToChatUpgrades(client, args)
{
	DisplayUpgrades(client);
}

public Action:PrintToChatxUpgrades(client, args)
{
	DisplayUpgrades(client);
}

public Action:OpenPerkMenu(client, args)
{
	PerkMenu(client);
}

public DisplayUpgrades(client)
{
	for(new upgrade = 0; upgrade < UPGRADEID + 1; upgrade++)
	{
		if(iUpgrade[client][upgrade] > 0)
		{
			PrintToChat(client, "%s %s", xUpgrade_tag, UpgradeTitle[upgrade]);
		}
	}
}

public PerkMenu(client)
{	
	new Handle:menu = CreateMenu(PerkMenuHandler);
	
	new slot = 1;
	decl String:buffer[32], String:booster[8];		
	for(new upgrade = 0; upgrade < UPGRADEID + 1; upgrade++)
	{
		if(iUpgrade[client][upgrade] > 0 && slot <= GetConVarInt(PerkSlots) + iPerkBonusSlots[client])
		{
			if(iBooster[client][upgrade] > 0)
				booster = "(★)";
			else
				booster = "";
			Format(buffer, sizeof(buffer), "%s %s", PerkTitle[upgrade], booster);
			AddMenuItem(menu, PerkTitle[upgrade], buffer);
			slot++;
		}
	}
	while(slot <= GetConVarInt(PerkSlots) + GetConVarInt(PerkBonusSlots))
	{
		if(slot <= GetConVarInt(PerkSlots) + iPerkBonusSlots[client])
		{
			AddMenuItem(menu, "<EMPTY>", "<EMPTY>");
			slot++;
		}
		else
		{
			AddMenuItem(menu, "<LOCKED>", "<LOCKED>", ITEMDRAW_DISABLED);
			slot++;
		}
	}
	AddMenuItem(menu, "Booster", "Equip Booster");
	SetMenuTitle(menu, "Equip Perks\nYou can select perks in this menu \nby choosing which slot to equip with.\nBooster Point(s): %d", iBoosterSlots[client] - TotalBoostersUsed(client));
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public PerkMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	new client = param1;
	switch(action)
	{
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				UpgradesEnabledMenu(param1);
			}
		}
		case MenuAction_Select:
		{
			new String:item1[56];
			GetMenuItem(menu, param2, item1, sizeof(item1));
			if(StrEqual(item1, "<EMPTY>", false))
			{
				PerkSelectionMenu(client);
			}
			if(StrEqual(item1, "Booster", false))
			{
				BoosterSelectionMenu(client);
			}
			for(new i = 0; i < MAX_UPGRADES; i++)
			{
				if(StrEqual(item1, PerkTitle[i], false))
				{
					if(iUpgrade[client][i] > 0)
					{
						iUpgrade[client][i] = 0;
						PerkSelectionMenu(client);
					}					
				}
			}
		}
	}
}

public PerkSelectionMenu(client)
{	
	new Handle:menu = CreateMenu(PerkSelectionMenuHandler);
	
	SetMenuTitle(menu, "Select A Perk\n\nYou can choose the perk that you \nwant to equip in the slots");
	for(new upgrade = 0; upgrade < MAX_UPGRADES; upgrade++)
	{
		if(iUpgrade[client][upgrade] == 0)
		{
			decl String:buffer[32];
			Format(buffer, sizeof(buffer), "%s", PerkTitle[upgrade]);

			AddMenuItem(menu, buffer, buffer);
		}
	}

	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public PerkSelectionMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	new client = param1;
	switch(action)
	{
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				UpgradesEnabledMenu(param1);
			}
		}
		case MenuAction_Select:
		{
			new String:item1[56];
			GetMenuItem(menu, param2, item1, sizeof(item1));
			for(new i = 0; i <= MAX_UPGRADES; i++)
			{
				if(StrEqual(item1, PerkTitle[i], false))
				{
					iUpgrade[client][i] = UpgradeIndex[i];
					PrintToChat(client, "%s", UpgradeTitle[i]);
					PerkMenu(client);
					if(iSaveFeature[client] == 0)
						iSaveFeature[client] = 1;
				}
			}
		}
	}
}

public BoosterSelectionMenu(client)
{	
	new Handle:menu = CreateMenu(BoosterSelectionMenuHandler);
	
	new slot = 1;
	decl String:buffer[32], String:booster[8];		
	for(new upgrade = 0; upgrade < UPGRADEID + 1; upgrade++)
	{
		if(iUpgrade[client][upgrade] > 0 && slot <= GetConVarInt(PerkSlots) + iPerkBonusSlots[client])
		{
			if(iBooster[client][upgrade] > 0)
				booster = "(★)";
			else
				booster = "";
			Format(buffer, sizeof(buffer), "%s %s", PerkTitle[upgrade], booster);
			AddMenuItem(menu, PerkTitle[upgrade], buffer);
			slot++;
		}
	}
	while(slot <= GetConVarInt(PerkSlots) + GetConVarInt(PerkBonusSlots))
	{
		if(slot <= GetConVarInt(PerkSlots) + iPerkBonusSlots[client])
		{
			AddMenuItem(menu, "<EMPTY>", "<EMPTY>");
			slot++;
		}
		else
		{
			AddMenuItem(menu, "<LOCKED>", "<LOCKED>", ITEMDRAW_DISABLED);
			slot++;
		}
	}
	SetMenuTitle(menu, "Equip Booster\nYou can select which perk you wish to boost \nby choosing the slot.\nBooster Point(s): %d", iBoosterSlots[client] - TotalBoostersUsed(client));
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public BoosterSelectionMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	new client = param1;
	switch(action)
	{
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				UpgradesEnabledMenu(param1);
			}
		}
		case MenuAction_Select:
		{
			new String:item1[56];
			GetMenuItem(menu, param2, item1, sizeof(item1));
			if(StrEqual(item1, "<EMPTY>", false))
			{
				BoosterSelectionMenu(client);
			}
			for(new i = 0; i < MAX_UPGRADES; i++)
			{
				if(StrEqual(item1, PerkTitle[i], false))
				{
					if(iBooster[client][i] > 0)
					{
						iBooster[client][i] = 0;
						BoosterSelectionMenu(client);
					}
					else
					{
						if(CanUseBooster(client) == true && BoosterAllowed[i] > 0)
						{
							iBooster[client][i] = 1;
							PrintToChat(client, "Booster has been equipped to %s", PerkTitle[i]);
							BoosterSelectionMenu(client);
						}
						else
							PrintToChat(client, "You must have a booster available.");
					}
				}
			}
		}
	}
}

public UpgradesEnabledMenu(client)
{
	if(GetClientTeam(client) == 2 || GetClientTeam(client) == 1)
	{
		new Handle:menu = CreateMenu(UpgradesEnabledMenuHandler);

		for(new upgrade = 0; upgrade < MAX_UPGRADES; upgrade++)
		{
			decl String:buffer[255];
			decl String:buffer2[32];
			decl String:status[10];
			if(iUpgradeDisabled[client][upgrade] == 1)
			{
				Format(status, sizeof(status), "Disabled");
			}
			else
			{
				Format(status, sizeof(status), "Active");
			}
			Format(buffer, sizeof(buffer), "%s (%s)", PerkTitle[upgrade], status);
			Format(buffer2, sizeof(buffer2), "%s", PerkTitle[upgrade]);
			AddMenuItem(menu, buffer2, buffer);
		}
		AddMenuItem(menu, "Disable All", "Disable All");
		SetMenuTitle(menu, "Toggle Upgrades\nIn this menu you can toggle \nthe upgrades you wish to earn. Choose which \nupgrade you wish to toggle [Active/Inactive].");
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
}

public UpgradesEnabledMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	new client = param1;
	switch(action)
	{
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				UpgradesEnabledMenu(param1);
			}
		}
		case MenuAction_Select:
		{
			new String:item1[56];
			GetMenuItem(menu, param2, item1, sizeof(item1));
			for(new i = 0; i <= MAX_UPGRADES; i++)
			{
				if(StrEqual(item1, PerkTitle[i], false))
				{
					if(iUpgradeDisabled[client][i] == 0)
					{
						iUpgradeDisabled[client][i] = 1;
						if(iUpgrade[client][i] > 0)
						{
							iUpgrade[client][i] = 0;
							SetClientUpgradesCheck(client);
						}
					}
					else
					{
						iUpgradeDisabled[client][i] = 0;					
					}
					UpgradesEnabledMenu(client);
				}
			}
		}
	}
}

public AwardStatusMenu(client)
{
	new Handle:AwardStatusPanel = CreatePanel();
	SetPanelTitle(AwardStatusPanel, "Award Completion List");

	for(new award = 0; award < AWARDID; award++)
	{
		decl String:buffer[32], String:buffer2[32];
		if(iCount[client][award] > 0)
		{
			Format(buffer2, sizeof(buffer2), "%d/%d", iCount[client][award], GetConVarInt(AwardIndex[award]));
			Format(buffer, sizeof(buffer), "%s (%s)", AwardTitle[award], buffer2);
			DrawPanelText(AwardStatusPanel, buffer);
		}
	}
	DrawPanelItem(AwardStatusPanel, "Refresh");
	DrawPanelItem(AwardStatusPanel, "Back");
	
	SendPanelToClient(AwardStatusPanel, client, AwardStatusPanelHandler, 30);
	CloseHandle(AwardStatusPanel);
}


public AwardStatusPanelHandler(Handle:AwardStatusPanel, MenuAction:action, param1, param2)
{
	new client = param1;
	if (action == MenuAction_Select)
	{
		if(param2 == 1)
		{
			AwardStatusMenu(client);
		}
		else if(param2 == 2)
		{
			RefreshRewards[client] = 0;
		}
	}
	else if(action == MenuAction_Cancel)
	{
		// Nothing
	}
}

public event_AwardEarnedExtended(client, achievementid, penalty)
{
	if(GetConVarInt(g_PerkMode) == 1)
		return;
	
 	if(penalty == 0 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	if(penalty == 1 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			RemoveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}

	if(AwardsCooldownTimer[client] == INVALID_HANDLE)
	{
		AwardsCooldownTimer[client] = CreateTimer(3.0, event_AwardsCooldownTimer, client);
	}
	if(RefreshRewards[client] == 1)
	{
		AwardStatusMenu(client);
	}	
	AwardsCooldownID[client] = achievementid;
}

public event_AwardEarned(Handle:event, const String:name[], bool:Broadcast) 
{
	if(b_round_end == true || GetConVarInt(g_PerkMode) == 1)
		return;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new achievementid = GetEventInt(event, "award");
	
	if(AwardsCooldownTimer[client] != INVALID_HANDLE && achievementid == AwardsCooldownID[client])
	{
		return;
	}
	
	// 14 - Blind Luck
	if(achievementid == 14 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 15 - Pyrotechnician
	if(achievementid == 15 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 18 - Witch Hunter
	if(achievementid == 18 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 19 - Crowned Witch
	if(achievementid == 19 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 21 - Dead Stop
	if(achievementid == 21 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 22 - Brawler
	if(achievementid == 22 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 26 - Boom-Cork
	if(achievementid == 26 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 27 - Tongue Twister
	if(achievementid == 27 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 66 - Helping Hand
	if(achievementid == 66 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 67 - My Bodyguard
	if(achievementid == 67 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 68 - Pharm-Assist
	if(achievementid == 68 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 69 - Adrenaline
	if(achievementid == 69 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 70 - Medic
	if(achievementid == 70 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 76 - Special Savior
	if(achievementid == 76 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 80 Hero Closet
	if(achievementid == 80 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 81 Tankbusters
	if(achievementid == 81 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			GiveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 84 - Team-Kill
	if(achievementid == 84 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			RemoveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 85 - Team-Incapacitate
	if(achievementid == 85 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			RemoveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	// 87 - Friendly-Fire
	if(achievementid == 87 && GetConVarInt(AwardIndex[achievementid]) > 0)
	{
		iCount[client][achievementid] += 1;
		if(iCount[client][achievementid] >= GetConVarInt(AwardIndex[achievementid]))
		{
			RemoveSurvivorUpgrade(client, 1, achievementid);
			iCount[client][achievementid] = 0;
		}
	}
	if(AwardsCooldownTimer[client] == INVALID_HANDLE)
	{
		AwardsCooldownTimer[client] = CreateTimer(3.0, event_AwardsCooldownTimer, client);
	}	
	AwardsCooldownID[client] = achievementid;
	UpgradeHotMeal(client);
}

public Action:event_AwardsCooldownTimer(Handle:timer, any:client)
{
	AwardsCooldownTimer[client] = INVALID_HANDLE;
}

public Action:event_HotMealCooldown(Handle:timer, any:client)
{
	HotMealCooldown[client] = INVALID_HANDLE;
}

public Action:event_AloeVeraCooldown(Handle:timer, any:client)
{
	AloeVeraCooldown[client] = INVALID_HANDLE;
}

public Action:round_start(Handle:event, const String:name[], bool:dontBroadcast)
{
	b_round_end = false;
	CreateTimer(30.0, Timer_Healthcare);
}

public Action:round_end(Handle:event, const String:name[], bool:dontBroadcast)
{
	b_round_end = true;
	new MaxCount = MaxClients;
	for(new i=1; i<=MaxCount; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && !IsPlayerIncapped(i))
		{
			GiveUpgrade(i, 12);
			UpgradeAloeVera(i);
		}
	}
}

public event_HealSuccess(Handle:event, const String:name[], bool:Broadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new subject = GetClientOfUserId(GetEventInt(event, "subject"));
	new health_restored = GetEventInt(event, "health_restored");

	new m_iMaxHealth = GetEntData(subject, FindDataMapInfo(subject, "m_iMaxHealth"), 4);
	new m_iCHealth = RoundFloat(float(m_iMaxHealth)-(250.0-(float(health_restored)/0.8)));
	new m_iHealth = RoundFloat((m_iMaxHealth-m_iCHealth)+m_iCHealth*0.8);
	SetEntData(subject, FindDataMapInfo(subject, "m_iHealth"), m_iHealth, 4, true);

	UpgradeOintment(client, subject, m_iMaxHealth);
	UpgradePrimaryItem(client);
	UpgradeMedicalChart(client, subject, m_iCHealth);
	
	iAutoinjectors[client] = 0;
}

public event_InfectedDeath(Handle:event, const String:name[], bool:Broadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "attacker"));
	new bool:headshot = GetEventBool(event, "headshot");

	if(client == 0)
		return;
	
	if(headshot == true)
	{
		event_AwardEarnedExtended(client, 102, 0);
	}
	if(GetConVarInt(g_PerkMode))
	{
		if(GetRandomInt(0, 1000) == 1 && GetConVarInt(PerkBonusSlots) > iPerkBonusSlots[client])
		{
			iPerkBonusSlots[client]++;
			PrintToChat(client, "You have unlocked a new \x04Perk Slot\x01.");
		}
		if(GetRandomInt(0, 2000) == 1 && GetConVarInt(BoosterSlots) > iBoosterSlots[client])
		{
			iBoosterSlots[client]++;
			PrintToChat(client, "You have unlocked a new \x04Booster Point\x01.");
		}
	}
}

public event_PillsUsed(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	UpgradeSteroids(client, 1);
	UpgradeSecondaryItems(client);
	UpgradePillsAddiction(client);
}

public event_AdrenalineUsed(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	UpgradeSteroids(client, 2);
	UpgradeSecondaryItems(client);
	UpgradeEndocrine(client);
	UpgradePillsAddiction(client);
}

public event_AdrenalineUsedPre(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	UpgradeEndocrine(client);
}

public event_DefibrillatorUsed(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new subject = GetClientOfUserId(GetEventInt(event, "subject"));
	UpgradeHeavyDutyBatteries(client, subject);
	UpgradePrimaryItem(client);
}
public event_UpgradePackUsed(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	UpgradePrimaryItem(client);
}

public event_ReceiveUpgrade(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new String:upgrade[32];
	GetEventString(event, "upgrade", upgrade, sizeof(upgrade));

	if(StrEqual(upgrade, "EXPLOSIVE_AMMO") || StrEqual(upgrade, "INCENDIARY_AMMO"))
	{
		new iWEAPON = GetPlayerWeaponSlot(client, 0);
		SetEntProp(iWEAPON, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", CheckWeaponUpgradeLimit(iWEAPON, client, true), 4);
	}
	UpgradeBarrelChamber(client);
}

public event_ReviveSuccess(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new subject = GetClientOfUserId(GetEventInt(event, "subject"));

	GiveUpgrade(subject, 10);
	UpgradeBandages(client, subject);
	UpgradeAutoinjectors(subject);
	iSecondWindReady = false;
}

public event_PlayerIncapacitated(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	UpgradeBetaBlockers(client);
	if(RegenerationTimer[client] != INVALID_HANDLE)
	{
		KillTimer(RegenerationTimer[client]);
		RegenerationTimer[client] = INVALID_HANDLE;
	}

	iSecondWindReady = true;
	if(iSecondWindReady > 0 && iSecondWindMaxUse[client] > 0 && IsPlayerAlive(client) && b_round_end == false)
	{
		PrintHintText(client, "Press E to revive yourself.");
		if(SecondWindCooldownTimer[client] == INVALID_HANDLE)
		{
			SecondWindCooldownTimer[client] = CreateTimer(0.8, timer_SecondWindCooldownTimer, client);
		}
	}

	else if(iSecondWindMaxUse[client] == 0)
	{
		PrintHintText(client, "You can use Second Wind only 2 times.");
	}
	event_AwardEarnedExtended(client, 106, 1);
}

public event_PlayerLedgeGrab(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	GiveUpgrade(client, 19);
	iSecondWindReady = true;
	if(iSecondWindReady > 0 && iSecondWindMaxUse[client] > 0)
	{
		PrintHintText(client, "Press E to help yourself.");
		if(SecondWindCooldownTimer[client] == INVALID_HANDLE)
		{
			SecondWindCooldownTimer[client] = CreateTimer(1.0, timer_SecondWindCooldownTimer, client);
		}
	}

	else if(iSecondWindMaxUse[client] == 0)
	{
		PrintHintText(client, "You can use Second Wind only 2 times.");
	}
}

public event_PlayerNowIt(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new bool:exploded = GetEventBool(event, "exploded");

	if(exploded == true)
		event_AwardEarnedExtended(client, 104, 1);
	else
		event_AwardEarnedExtended(client, 103, 1);
}


public event_EnteredSpit(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	event_AwardEarnedExtended(client, 105, 1);
}


public event_PlayerHurt(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new dmg_health = GetEventInt(event, "dmg_health");
	new health = GetEntData(client, FindDataMapInfo(client, "m_iHealth"), 4);	

	if(RegenerationTimer[client] != INVALID_HANDLE)
	{
		KillTimer(RegenerationTimer[client]);
		RegenerationTimer[client] = INVALID_HANDLE;
	}
	UpgradeHollowPointAmmunition(client, attacker, dmg_health, health, 1);
}

public event_InfectedHurt(Handle:event, const String:name[], bool:Broadcast)
{
	new entityid = (GetEventInt(event, "entityid"));
	new client = GetClientOfUserId(GetEventInt(event, "attacker"));
	new amount = GetEventInt(event, "amount");
	new health = GetEntProp(entityid, Prop_Data, "m_iHealth");	
	new type = GetEventInt(event, "type");

	if(type & 1 << 3 && client > 0)
	{
		event_AwardEarnedExtended(client, 100, 0);
	}
	UpgradeHollowPointAmmunition(entityid, client, amount, health, 2);
}

public event_HealBegin(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	UpgradeQuickHeal(client);
}

public event_ReviveBegin(Handle:event, const String:name[], bool:Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	UpgradeSmellingSalts(client);
}

public event_BreakProp(Handle:event, const String:name[], bool:Broadcast) 
{
	new entindex = GetEventInt(event, "entindex");
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	UpgradeKeroseneShot(client, entindex);
}

public event_BotPlayerReplace(Handle:event, const String:name[], bool:Broadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "player"));
	
	if(client > 0)
	{
		if(GetConVarInt(g_PerkMode) == 1 && IsClientInGame(client))
		{
			PrintToChat(client, "%s \x04[\x05%s\x04]", xUpgrade_message, PLUGIN_VERSION);
			PrintToChat(client, "%s \x01All survivors have been upgraded!", xUpgrade_tag);
			
		}

		else
		{
			PrintToChat(client, "%s \x04[\x05%s\x04]", xUpgrade_message, PLUGIN_VERSION);
			PrintToChat(client, "%s \x01All survivors have been upgraded!", xUpgrade_tag);
		}
	}
}

public UpgradeSteroids(client, type)
{
	if(type == 1)
	{
		new Float:m_iHealth = float(GetEntData(client, FindDataMapInfo(client, "m_iHealth"), 4));
		new Float:m_iMaxHealth = float(GetEntData(client, FindDataMapInfo(client, "m_iMaxHealth"), 4));
		new Float:m_iHealthBufferBits = GetConVarInt(FindConVar("pain_pills_health_value"))*(0.5+CheckBoosters(client, 7));
		new Float:m_iHealthBuffer = GetEntDataFloat(client, FindSendPropInfo("CTerrorPlayer","m_healthBuffer"));

		if(iUpgrade[client][7] > 0)
		{
			if(m_iHealth + m_iHealthBuffer + m_iHealthBufferBits > m_iMaxHealth)
			{
				m_iHealthBufferBits = m_iMaxHealth - m_iHealth;
				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", m_iHealthBufferBits);
			}
			else
			{
				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", m_iHealthBuffer + m_iHealthBufferBits);
			}
		}
	}
	if(type == 2)
	{
		new Float:m_iHealth = float(GetEntData(client, FindDataMapInfo(client, "m_iHealth"), 4));
		new Float:m_iMaxHealth = float(GetEntData(client, FindDataMapInfo(client, "m_iMaxHealth"), 4));
		new Float:m_iHealthBufferBits = GetConVarInt(FindConVar("adrenaline_health_buffer"))*(0.5+CheckBoosters(client, 7));
		new Float:m_iHealthBuffer = GetEntDataFloat(client, FindSendPropInfo("CTerrorPlayer","m_healthBuffer"));

		if(iUpgrade[client][7] > 0)
		{
			if(m_iHealth + m_iHealthBuffer + m_iHealthBufferBits > m_iMaxHealth)
			{
				m_iHealthBufferBits = m_iMaxHealth - m_iHealth;
				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", m_iHealthBufferBits);
			}
			else
			{
				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", m_iHealthBuffer + m_iHealthBufferBits);
			}
		}
	}
}

public Action:Timer_Healthcare(Handle:timer)
{
	UpgradeHealthCare();
}

public UpgradeHealthCare()
{
	if(GetConVarInt(UpgradeEnabled[22]) > 0)
	{
		new flags = GetCommandFlags("give");	
		SetCommandFlags("give", flags & ~FCVAR_CHEAT);	
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == 2)
			{
				FakeClientCommand(i, "give adrenaline");
				PrintToChat(i, "%s \x01All survivors got \x03Healthcare \x05[Free Adrenaline]", xUpgrade_tag);
				iKnifeMaxUse[i] = 2;
				iSecondWindMaxUse[i] = 2;
			}
		}
		SetCommandFlags("give", flags|FCVAR_CHEAT);
	}
}

public UpgradeHeavyDutyBatteries(client, subject)
{
	if(iUpgrade[client][9] > 0)
	{
		new Float:m_iHealth = float(GetEntData(subject, FindDataMapInfo(subject, "m_iHealth"), 4));
		SetEntData(subject, FindDataMapInfo(subject, "m_iHealth"), RoundFloat(m_iHealth*(1.5+CheckBoosters(client, 9))), 4, true);
	}
}

public UpgradeBarrelChamber(client)
{

	if(iUpgrade[client][8] > 0)
	{
		new iWEAPON = GetPlayerWeaponSlot(client, 0);
		SetEntProp(iWEAPON, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", RoundFloat(CheckWeaponUpgradeLimit(iWEAPON, client, true)*(1.5+CheckBoosters(client, 8))), 4);
	}
}

public UpgradeBandages(client, subject)
{
	if(iUpgrade[subject][10] > 0)
	{
		decl String:ClientUserName[MAX_TARGET_LENGTH];
		GetClientName(client, ClientUserName, sizeof(ClientUserName));

		decl String:SubjectUserName[MAX_TARGET_LENGTH];
		GetClientName(subject, SubjectUserName, sizeof(SubjectUserName));
		
		new Float:m_iHealthBuffer = float(GetConVarInt(FindConVar("survivor_revive_health")))*(1.5+CheckBoosters(client, 10));
		SetEntPropFloat(subject, Prop_Send, "m_healthBuffer", m_iHealthBuffer);
		if(subject != client)
		{
			PrintToChat(subject, "%s \x03%s \x01used \x03Bandages \x01on you \x05[50HP Revive]", xUpgrade_tag, ClientUserName);
			PrintToChat(client, "%s \x03You \x01used \x03Bandages \x01on \x03%s \x05[50HP Revive]", xUpgrade_tag, SubjectUserName);
		}	
	}
}

public UpgradeBetaBlockers(client)
{
	if(iUpgrade[client][11] > 0)
	{
		new m_iHealthBuffer = RoundFloat(GetConVarInt(FindConVar("survivor_incap_health"))*(1.5+CheckBoosters(client, 10)));
		SetEntProp(client, Prop_Send, "m_iHealth", m_iHealthBuffer);
	}
}

public UpgradeAloeVera(client)
{
	if(iUpgrade[client][12] > 0)
	{
		decl String:GameName[12];
		GetConVarString(FindConVar("mp_gamemode"), GameName, sizeof(GameName));
		new m_iHealth = GetEntProp(client, Prop_Send, "m_iHealth");
		new m_isIncapacitated = GetEntProp(client, Prop_Send, "m_isIncapacitated"); 

		if(AloeVeraCooldown[client] != INVALID_HANDLE)
			return;
		
		if(StrEqual(GameName, "survival", false) && m_isIncapacitated == 0)
			if(m_iHealth > 11)
				return;
		
		SetEntProp(client, Prop_Send, "m_iHealth", 100, 4);
		SetEntProp(client, Prop_Send, "m_isGoingToDie", 0, 4);
		PrintToChat(client, "%s \x01All survivors got \x03Aloe Vera \x05[100HP Safe-house]", xUpgrade_tag);
		
		if(GetConVarInt(g_PerkMode) == 0)
			iUpgrade[client][12] = 0;
		else if(AloeVeraCooldown[client] == INVALID_HANDLE)
			AloeVeraCooldown[client] = CreateTimer(120.0, event_AloeVeraCooldown, client);
	}
}

public Action:timer_RegenerationTimer(Handle:timer, any:client)
{
	if(IsClientInGame(client))
	{
		new m_iHealth = GetEntData(client, FindDataMapInfo(client, "m_iHealth"), 4);
		new m_iMaxHealth = GetEntData(client, FindDataMapInfo(client, "m_iMaxHealth"), 4);
		if(m_iHealth >= RoundFloat(m_iMaxHealth * (0.5+CheckBoosters(client, 12))))
		{
			RegenerationTimer[client] = INVALID_HANDLE;
			return Plugin_Stop;

		}
		SetEntData(client, FindDataMapInfo(client, "m_iHealth"), m_iHealth+1, 4, true);
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

public UpgradeBandoliers(client)
{
	if(iUpgrade[client][14] > 0)
	{
		new iWEAPON = GetPlayerWeaponSlot(client, 0);
		if(iWEAPON > 0)
		{
			decl String:WEAPON_NAME[64];
			GetEdictClassname(iWEAPON, WEAPON_NAME, 32);

			if(StrEqual(WEAPON_NAME, "weapon_rifle_m60"))
			{				
				if(iUpgrade[client][6] > 0)
				{
					SetEntProp(iWEAPON, Prop_Send, "m_iClip1", 225, 1);
				}
				else
				{
					SetEntProp(iWEAPON, Prop_Send, "m_iClip1", 150, 1);
				}
			}
			else if(StrEqual(WEAPON_NAME, "weapon_grenade_launcher"))
			{
				if(iUpgrade[client][6] > 0)
				{
					new m_iAmmo = FindDataMapInfo(client, "m_iAmmo");
					SetEntData(client, m_iAmmo+GRENADE_LAUNCHER_OFFSET_AMMO, RoundToNearest((GRENADE_LAUNCHER_AMMO * (1.5))) + (CheckWeaponUpgradeLimit(iWEAPON, client, true) - GetEntProp(iWEAPON, Prop_Send, "m_iClip1")));
				}
			}
		}
	}
}

UpgradeFastReload(client)
{
	if(iUpgrade[client][13] > 0)
	{
		if (GetClientTeam(client) == 2)
		{
			new iEntid = GetEntDataEnt2(client, g_iActiveWO);
			if (IsValidEntity(iEntid)==false) return;

			decl String:stClass[32];
			GetEntityNetClass(iEntid,stClass,32);

			//for non-shotguns
			if (StrContains(stClass,"shotgun",false) == -1)
			{
				MagStart(iEntid, client);
				return;
			}

			//shotguns are a bit trickier since the game
			//tracks per shell inserted - and there's TWO
			//different shotguns with different values...
			else if (StrContains(stClass,"autoshotgun",false) != -1)
			{
				//crate a pack to send clientid and gunid through to the timer
				new Handle:hPack = CreateDataPack();
				WritePackCell(hPack, client);
				WritePackCell(hPack, iEntid);

				CreateTimer(0.1,Timer_AutoshotgunStart,hPack);
				return;
			}

			else if (StrContains(stClass,"shotgun_spas",false) != -1)
			{
				//crate a pack to send clientid and gunid through to the timer
				new Handle:hPack = CreateDataPack();
				WritePackCell(hPack, client);
				WritePackCell(hPack, iEntid);

				CreateTimer(0.1,Timer_SpasShotgunStart,hPack);
				return;
			}

			else if (StrContains(stClass,"pumpshotgun",false) != -1
				|| StrContains(stClass,"shotgun_chrome",false) != -1)
			{
				//crate a pack to send clientid and gunid through to the timer
				new Handle:hPack = CreateDataPack();
				WritePackCell(hPack, client);
				WritePackCell(hPack, iEntid);

				CreateTimer(0.1,Timer_PumpshotgunStart,hPack);
				return;
			}
		}
	}
}

//called for mag loaders
MagStart (iEntid, client)
{

	new Float:flGameTime = GetGameTime();
	new Float:flNextTime_ret = GetEntDataFloat(iEntid,g_iNextPAttO);

	//this is a calculation of when the next primary attack
	//will be after applying reload values
	//NOTE: at this point, only calculate the interval itself,
	//without the actual game engine time factored in
	new Float:flNextTime_calc = ( flNextTime_ret - flGameTime ) * f_UpgradeFastReloadRate ;

	//we change the playback rate of the gun
	//just so the player can "see" the gun reloading faster
	SetEntDataFloat(iEntid, g_iPlayRateO, 1.0/f_UpgradeFastReloadRate, true);

	//create a timer to reset the playrate after
	//time equal to the modified attack interval
	CreateTimer( flNextTime_calc, Timer_MagEnd, iEntid);

	//experiment to remove double-playback bug
	new Handle:hPack = CreateDataPack();
	WritePackCell(hPack, client);
	//this calculates the equivalent time for the reload to end
	new Float:flStartTime_calc = flGameTime - ( flNextTime_ret - flGameTime ) * ( 1 - f_UpgradeFastReloadRate ) ;
	WritePackFloat(hPack, flStartTime_calc);
	//now we create the timer that will prevent the annoying double playback
	if ( (flNextTime_calc - 0.4) > 0 )
		CreateTimer( flNextTime_calc - 0.4 , Timer_MagEnd2, hPack);

	//and finally we set the end reload time into the gun
	//so the player can actually shoot with it at the end
	flNextTime_calc += flGameTime;
	SetEntDataFloat(iEntid, g_iTimeIdleO, flNextTime_calc, true);
	SetEntDataFloat(iEntid, g_iNextPAttO, flNextTime_calc, true);
	SetEntDataFloat(client, g_iNextAttO, flNextTime_calc, true);
}

//called for autoshotguns
public Action:Timer_AutoshotgunStart (Handle:timer, Handle:hPack)
{
	KillTimer(timer);
	if (IsServerProcessing()==false)
		return Plugin_Stop;

	ResetPack(hPack);
	new iCid = ReadPackCell(hPack);
	new iEntid = ReadPackCell(hPack);
	CloseHandle(hPack);
	hPack = CreateDataPack();
	WritePackCell(hPack, iCid);
	WritePackCell(hPack, iEntid);

	if (iCid <= 0
		|| iEntid <= 0
		|| IsValidEntity(iCid)==false
		|| IsValidEntity(iEntid)==false
		|| IsClientInGame(iCid)==false)
		return Plugin_Stop;
		
	//then we set the new times in the gun
	SetEntDataFloat(iEntid,	g_iShotStartDurO,	g_fl_AutoS*f_UpgradeFastReloadRate,	true);
	SetEntDataFloat(iEntid,	g_iShotInsertDurO,	g_fl_AutoI*f_UpgradeFastReloadRate,	true);
	SetEntDataFloat(iEntid,	g_iShotEndDurO,		g_fl_AutoE*f_UpgradeFastReloadRate,	true);

	//we change the playback rate of the gun
	//just so the player can "see" the gun reloading faster
	SetEntDataFloat(iEntid, g_iPlayRateO, 1.0/f_UpgradeFastReloadRate, true);

	//and then call a timer to periodically check whether the
	//gun is still reloading or not to reset the animation
	//but first check the reload state; if it's 2, then it
	//needs a pump/cock before it can shoot again, and thus
	//needs more time
	if (g_i_L4D_12 == 2)
		CreateTimer(0.3,Timer_ShotgunEnd,hPack,TIMER_REPEAT);
	else if (g_i_L4D_12 == 1)
	{
		if (GetEntData(iEntid,g_iShotRelStateO)==2)
			CreateTimer(0.3,Timer_ShotgunEndCock,hPack,TIMER_REPEAT);
		else
			CreateTimer(0.3,Timer_ShotgunEnd,hPack,TIMER_REPEAT);
	}

	return Plugin_Stop;
}

public Action:Timer_SpasShotgunStart (Handle:timer, Handle:hPack)
{
	KillTimer(timer);
	if (IsServerProcessing()==false)
		return Plugin_Stop;

	ResetPack(hPack);
	new iCid = ReadPackCell(hPack);
	new iEntid = ReadPackCell(hPack);
	CloseHandle(hPack);
	hPack = CreateDataPack();
	WritePackCell(hPack, iCid);
	WritePackCell(hPack, iEntid);

	if (iCid <= 0
		|| iEntid <= 0
		|| IsValidEntity(iCid)==false
		|| IsValidEntity(iEntid)==false
		|| IsClientInGame(iCid)==false)
		return Plugin_Stop;
		
	//then we set the new times in the gun
	SetEntDataFloat(iEntid,	g_iShotStartDurO,	g_fl_SpasS*f_UpgradeFastReloadRate,	true);
	SetEntDataFloat(iEntid,	g_iShotInsertDurO,	g_fl_SpasI*f_UpgradeFastReloadRate,	true);
	SetEntDataFloat(iEntid,	g_iShotEndDurO,		g_fl_SpasE*f_UpgradeFastReloadRate,	true);

	//we change the playback rate of the gun
	//just so the player can "see" the gun reloading faster
	SetEntDataFloat(iEntid, g_iPlayRateO, 1.0/f_UpgradeFastReloadRate, true);

	//and then call a timer to periodically check whether the
	//gun is still reloading or not to reset the animation
	//but first check the reload state; if it's 2, then it
	//needs a pump/cock before it can shoot again, and thus
	//needs more time
	CreateTimer(0.3,Timer_ShotgunEnd,hPack,TIMER_REPEAT);

	return Plugin_Stop;
}

//called for pump/chrome shotguns
public Action:Timer_PumpshotgunStart (Handle:timer, Handle:hPack)
{
	KillTimer(timer);
	if (IsServerProcessing()==false)
		return Plugin_Stop;

	ResetPack(hPack);
	new iCid = ReadPackCell(hPack);
	new iEntid = ReadPackCell(hPack);
	CloseHandle(hPack);
	hPack = CreateDataPack();
	WritePackCell(hPack, iCid);
	WritePackCell(hPack, iEntid);

	if (iCid <= 0
		|| iEntid <= 0
		|| IsValidEntity(iCid)==false
		|| IsValidEntity(iEntid)==false
		|| IsClientInGame(iCid)==false)
		return Plugin_Stop;

	//then we set the new times in the gun
	SetEntDataFloat(iEntid,	g_iShotStartDurO,	g_fl_PumpS*f_UpgradeFastReloadRate,	true);
	SetEntDataFloat(iEntid,	g_iShotInsertDurO,	g_fl_PumpI*f_UpgradeFastReloadRate,	true);
	SetEntDataFloat(iEntid,	g_iShotEndDurO,		g_fl_PumpE*f_UpgradeFastReloadRate,	true);

	//we change the playback rate of the gun
	//just so the player can "see" the gun reloading faster
	SetEntDataFloat(iEntid, g_iPlayRateO, 1.0/f_UpgradeFastReloadRate, true);

	//and then call a timer to periodically check whether the
	//gun is still reloading or not to reset the animation
	if (g_i_L4D_12 == 2)
		CreateTimer(0.3,Timer_ShotgunEnd,hPack,TIMER_REPEAT);
	else if (g_i_L4D_12 == 1)
	{
		if (GetEntData(iEntid,g_iShotRelStateO)==2)
			CreateTimer(0.3,Timer_ShotgunEndCock,hPack,TIMER_REPEAT);
		else
			CreateTimer(0.3,Timer_ShotgunEnd,hPack,TIMER_REPEAT);
	}

	return Plugin_Stop;
}

//this resets the playback rate on non-shotguns
public Action:Timer_MagEnd (Handle:timer, any:iEntid)
{
	KillTimer(timer);
	if (IsServerProcessing()==false)
		return Plugin_Stop;

	if (iEntid <= 0
		|| IsValidEntity(iEntid)==false)
		return Plugin_Stop;

	SetEntDataFloat(iEntid, g_iPlayRateO, 1.0, true);

	return Plugin_Stop;
}

public Action:Timer_MagEnd2 (Handle:timer, Handle:hPack)
{
	KillTimer(timer);
	if (IsServerProcessing()==false)
	{
		CloseHandle(hPack);
		return Plugin_Stop;
	}

	ResetPack(hPack);
	new iCid = ReadPackCell(hPack);
	new Float:flStartTime_calc = ReadPackFloat(hPack);
	CloseHandle(hPack);

	if (iCid <= 0
		|| IsValidEntity(iCid)==false
		|| IsClientInGame(iCid)==false)
		return Plugin_Stop;

	//experimental, remove annoying double-playback
	new iVMid = GetEntDataEnt2(iCid,g_iViewModelO);
	SetEntDataFloat(iVMid, g_iVMStartTimeO, flStartTime_calc, true);

	return Plugin_Stop;
}

public Action:Timer_ShotgunEnd (Handle:timer, Handle:hPack)
{
	ResetPack(hPack);
	new iCid = ReadPackCell(hPack);
	new iEntid = ReadPackCell(hPack);

	if (IsServerProcessing()==false
		|| iCid <= 0
		|| iEntid <= 0
		|| IsValidEntity(iCid)==false
		|| IsValidEntity(iEntid)==false
		|| IsClientInGame(iCid)==false)
	{
		KillTimer(timer);
		return Plugin_Stop;
	}

	if (GetEntData(iEntid,g_iShotRelStateO)==0)
	{
		SetEntDataFloat(iEntid, g_iPlayRateO, 1.0, true);

		//new iCid=GetEntPropEnt(iEntid,Prop_Data,"m_hOwner");
		new Float:flTime=GetGameTime()+0.2;
		SetEntDataFloat(iCid,	g_iNextAttO,	flTime,	true);
		SetEntDataFloat(iEntid,	g_iTimeIdleO,	flTime,	true);
		SetEntDataFloat(iEntid,	g_iNextPAttO,	flTime,	true);

		KillTimer(timer);
		CloseHandle(hPack);
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

//since cocking requires more time, this function does
//exactly as the above, except it adds slightly more time
public Action:Timer_ShotgunEndCock (Handle:timer, any:hPack)
{
	ResetPack(hPack);
	new iCid = ReadPackCell(hPack);
	new iEntid = ReadPackCell(hPack);

	if (IsServerProcessing()==false
		|| iCid <= 0
		|| iEntid <= 0
		|| IsValidEntity(iCid)==false
		|| IsValidEntity(iEntid)==false
		|| IsClientInGame(iCid)==false)
	{
		KillTimer(timer);
		return Plugin_Stop;
	}

	if (GetEntData(iEntid,g_iShotRelStateO)==0)
	{
		SetEntDataFloat(iEntid, g_iPlayRateO, 1.0, true);

		//new iCid=GetEntPropEnt(iEntid,Prop_Data,"m_hOwner");
		new Float:flTime= GetGameTime() + 1.0;
		SetEntDataFloat(iCid,	g_iNextAttO,	flTime,	true);
		SetEntDataFloat(iEntid,	g_iTimeIdleO,	flTime,	true);
		SetEntDataFloat(iEntid,	g_iNextPAttO,	flTime,	true);

		KillTimer(timer);
		CloseHandle(hPack);
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public UpgradeHollowPointAmmunition(client, attacker, dmg_health, health, type)
{
	if(iUpgrade[attacker][15] > 0)
	{
		new m_iHealth = health - RoundFloat(dmg_health * (0.5+CheckBoosters(attacker, 15)));
		if(m_iHealth < 1)
			return;

		if(GetClientTeam(attacker) == 2 && type == 1)
		{
			SetEntityHealth(client, m_iHealth);
		}

		if(GetClientTeam(attacker) == 2 && type == 2)
		{
			SetEntProp(client, Prop_Data, "m_iHealth", m_iHealth);
		}
	}
}

public UpgradeKnife(client)
{
	if(iUpgrade[client][16] == 0 && iKnifeMaxUse[client] > 0)
	{
		GiveUpgrade(client, 16);
	}

	if(iUpgrade[client][16] > 0)
	{
		decl String:ClientUserName[MAX_TARGET_LENGTH];
		GetClientName(client, ClientUserName, sizeof(ClientUserName));

		if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 && iKnifeReady == true && iKnifeMaxUse[client] > 0 && KnifeCooldownTimer[client] == INVALID_HANDLE)
		{
			//Hunter
			if(GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0)
			{
				ForcePlayerSuicide(GetEntPropEnt(client, Prop_Send, "m_pounceAttacker"));
				EmitSoundToClient(client, "weapons/knife/knife_hitwall1.wav");
				if(GetConVarInt(g_PerkMode) == 0)
					iKnifeMaxUse[client] -= 1;
				RemoveUpgrade(client, 16);
				PrintToChatAll("%s \x03%s \x01used \x03Knife \x05[Remaining: %d]", xUpgrade_tag, ClientUserName, iKnifeMaxUse[client]);
			}

			//Charger
			else if(GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0)
			{
				ForcePlayerSuicide(GetEntPropEnt(client, Prop_Send, "m_pummelAttacker"));
				EmitSoundToClient(client, "weapons/knife/knife_hitwall1.wav");
				if(GetConVarInt(g_PerkMode) == 0)
					iKnifeMaxUse[client] -= 1;
				RemoveUpgrade(client, 16);
				PrintToChatAll("%s \x03%s \x01used \x03Knife \x05[Remaining: %d]", xUpgrade_tag, ClientUserName, iKnifeMaxUse[client]);
			}

			//Charger
			else if(GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0)
			{
				ForcePlayerSuicide(GetEntPropEnt(client, Prop_Send, "m_carryAttacker"));
				EmitSoundToClient(client, "weapons/knife/knife_hitwall1.wav");
				if(GetConVarInt(g_PerkMode) == 0)
					iKnifeMaxUse[client] -= 1;
				RemoveUpgrade(client, 16);
				PrintToChatAll("%s \x03%s \x01used \x03Knife \x05[Remaining: %d]", xUpgrade_tag, ClientUserName, iKnifeMaxUse[client]);
			}

			//Smoker
			else if(GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0)
			{
				ForcePlayerSuicide(GetEntPropEnt(client, Prop_Send, "m_tongueOwner"));
				EmitSoundToClient(client, "weapons/knife/knife_hitwall1.wav");
				if(GetConVarInt(g_PerkMode) == 0)
					iKnifeMaxUse[client] -= 1;
				RemoveUpgrade(client, 16);
				PrintToChatAll("%s \x03%s \x01used \x03Knife \x05[Remaining: %d]", xUpgrade_tag, ClientUserName, iKnifeMaxUse[client]);
			}

			//Jockey
			else if(GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0)
			{
				ForcePlayerSuicide(GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker"));
				EmitSoundToClient(client, "weapons/knife/knife_hitwall1.wav");
				if(GetConVarInt(g_PerkMode) == 0)
					iKnifeMaxUse[client] -= 1;
				RemoveUpgrade(client, 16);
				PrintToChatAll("%s \x03%s \x01used \x03Knife \x05[Remaining: %d]", xUpgrade_tag, ClientUserName, iKnifeMaxUse[client]);
			}
			iKnifeReady = false;
		}
	}
}

stock bool:IsPlayerIncapped(client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)
	|| (GetEntProp(client, Prop_Send, "m_isHangingFromLedge") == 1))
	{
		return true;
	}
	
	return false;
}

stock bool:IsValidSurvivor(client)
{
	if (client < 1 || client > MaxClients) return false;
	if (!IsClientConnected( client)) return false;
	if (!IsClientInGame(client)) return false;
	if (!IsPlayerAlive(client)) return false;
	if (IsFakeClient(client)) return false;
	if (GetClientTeam(client) != 2) return false;
	return true;
}

public UpgradeSecondWind(client)
{
	if(iUpgrade[client][19] == 0 && iSecondWindMaxUse[client] > 0)
	{
		GiveUpgrade(client, 19);
	}

	if(iUpgrade[client][19] > 0)
	{
		decl String:ClientUserName[MAX_TARGET_LENGTH];
		GetClientName(client, ClientUserName, sizeof(ClientUserName));

		gSecondWindHealth = GetConVarFloat(UpgradeSecondWindHealth);

		new SecondWindMeds = GetPlayerWeaponSlot(client, PILLS_ADRENALINE_SLOT);

		if(IsPlayerIncapped(client))
		{
			if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 && iSecondWindReady == true && iSecondWindMaxUse[client] > 0 && SecondWindCooldownTimer[client] == INVALID_HANDLE && b_round_end == false)
			{
				if(SecondWindMeds == -1)
					PrintHintText(client, "You ain't got no Pills/Adrenaline");

				else
				{
					CheatCommand(client, "give", "health", "");
					SetEntProp(client, Prop_Send, "m_iHealth", 5, 4);
					SetEntPropFloat(client, Prop_Send, "m_healthBuffer", gSecondWindHealth);
					EmitSoundToClient(client, "player/items/pain_pills/pills_deploy_1.wav");				
					if(GetConVarInt(g_PerkMode) == 0)
						iSecondWindMaxUse[client] -= 1;
					RemoveUpgrade(client, 19);
					PrintToChatAll("%s \x03%s \x01used \x03Second Wind! \x05[Remaining: %d]", xUpgrade_tag, ClientUserName, iSecondWindMaxUse[client]);
					AcceptEntityInput(SecondWindMeds, "kill");
					SecondWindMeds = -1;
					iSecondWindReady = false;
				}
			}
		}
	}
}

public UpgradeQuickHeal(client)
{
	if(iUpgrade[client][17] > 0)
		SetConVarFloat(g_VarFirstAidDuration, FirstAidDuration * (0.5-CheckBoosters(client, 17)), false, false);
	else
		SetConVarFloat(g_VarFirstAidDuration, FirstAidDuration, false, false);
}

public UpgradeOintment(client, subject, m_iMaxHealth)
{
	if(iUpgrade[client][5] > 0)
	{
		SetEntProp(subject, Prop_Send, "m_iHealth", m_iMaxHealth, 4);
	}
}

public UpgradeSmellingSalts(client)
{
	if(iUpgrade[client][18] > 0)
		SetConVarFloat(g_VarReviveDuration, ReviveDuration * (0.5-CheckBoosters(client, 18)), false, false);
	else
		SetConVarFloat(g_VarReviveDuration, ReviveDuration, false, false);
}

public UpgradeHotMeal(client)
{
	if(iUpgrade[client][4] > 0)
	{
		new m_iHealth = GetEntProp(client, Prop_Send, "m_iHealth");
		new m_isIncapacitated = GetEntProp(client, Prop_Send, "m_isIncapacitated"); 

		if(HotMealCooldown[client] != INVALID_HANDLE)
			return;
		
		SetEntProp(client, Prop_Send, "m_iHealth", 150, 4);
		SetEntProp(client, Prop_Send, "m_isGoingToDie", 0, 4);
		
		if(GetConVarInt(g_PerkMode) == 0)
			iUpgrade[client][4] = 0;
		else if(HotMealCooldown[client] == INVALID_HANDLE)
			HotMealCooldown[client] = CreateTimer(120.0, event_HotMealCooldown, client);
	}
}

public UpgradePrimaryItem(client)
{
	CreateTimer(0.3, timer_UpgradePrimaryItems, client);
}

public UpgradeSecondaryItems(client)
{
	CreateTimer(0.3, timer_UpgradeSecondaryItems, client);
}

public UpgradeGrenadePouch(client)
{
	CreateTimer(1.5, timer_UpgradeGrenadeItems, client);
}

public UpgradeAutoinjectors(client)
{
	if(iUpgrade[client][0] > 0)
	{
		if(GetEntProp(client, Prop_Send, "m_currentReviveCount") == 1 && iAutoinjectors[client] == 0)
		{
			iAutoinjectors[client] = 1;
			SetEntProp(client, Prop_Send, "m_currentReviveCount", 0, 4);
			SetEntProp(client, Prop_Send, "m_isGoingToDie", 0);
		}
	}
}

public UpgradeOcularImplants(client, entityid)
{
	if(iUpgrade[client][28] > 0)
	{
		char itemSlot[][][] =
		{
			{"weapon_rifle", "weapon_autoshotgun", "weapon_hunting_rifle", "weapon_rifle_ak47", "weapon_rifle_desert", "weapon_rifle_m60", "weapon_shotgun_chrome", "weapon_shotgun_spas", "weapon_sniper_military"},
			{"weapon_pistol", "weapon_pistol_magnum", "", "", "", "", "", "", ""},
			{"weapon_molotov", "weapon_pipe_bomb", "weapon_vomitjar", "", "", "", "", "", ""},
			{"weapon_first_aid_kit", "weapon_defibrillator", "weapon_upgradepack_explosive", "weapon_upgradepack_incendiary", "", "", "", "", ""},
			{"weapon_pain_pills", "weapon_adrenaline", "", "", "", "", "", "", ""}
		};

		for(int slot = 0; slot < sizeof(itemSlot); slot++)
		{
			if(GetRandomInt(0, 100) > 10)
				continue;
			
			int items = 0;
			for(int item = 0; item < sizeof(itemSlot[]); item++)
				if(strlen(itemSlot[slot][item]) > 0)
					items++;
			
			int chosen = GetRandomInt(0, items-1);
			
			float fOrigin[3];
			GetEntPropVector(entityid, Prop_Data, "m_vecOrigin", fOrigin);
			new iDrop;

			fOrigin[2] += 40.0;
			float vel[3];
			vel[0] = GetRandomFloat(-200.0, 200.0);
			vel[1] = GetRandomFloat(-200.0, 200.0);
			vel[2] = GetRandomFloat(40.0, 80.0);

			iDrop = CreateEntityByName(itemSlot[slot][chosen]);

			DispatchSpawn(iDrop);
			ActivateEntity(iDrop);
			TeleportEntity(iDrop, fOrigin, NULL_VECTOR, vel);
			if(slot == 0)
				SetEntProp(iDrop, Prop_Send, "m_iExtraPrimaryAmmo", GetRandomInt(50, 128));
		}
	}
}

UpgradeHighCapacityMag(client)
{
	if(iUpgrade[client][21] > 0 && IsValidSurvivor(client))
	{
		new ActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		decl String:WEAPON_NAME[64];
		GetEdictClassname(ActiveWeapon, WEAPON_NAME, sizeof(WEAPON_NAME));
		
		if(StrContains(WEAPON_NAME, "shotgun", false) != -1)
		{
			CreateTimer(0.1, timer_SetNumShells, client);
		}
		SDKHook(client, SDKHook_PreThink, OnPreThink);
	}
}

public UpgradeKerosene(client)
{
	if(iUpgrade[client][1] > 0)
	{
		CreateTimer(0.4, CreateMolotovTimer);
	}
}

public UpgradeSafetyFuse(client)
{
	if(iUpgrade[client][24] > 0)
	{
		SetConVarFloat(FindConVar("pipe_bomb_timer_duration"), PipeBombDuration*(1.5+CheckBoosters(client, 24)), false, false);
	}
}

public UpgradeMedicalChart(client, subject, restored_health)
{
	if(iUpgrade[client][30] > 0)
	{
		restored_health = RoundFloat((float(restored_health)*0.8) / 2.0);
			
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientClose(i, subject) && i != subject)
			{
				new m_iHealth = GetEntData(i, FindDataMapInfo(i, "m_iHealth"), 4);
				new m_iMaxHealth = GetEntData(i, FindDataMapInfo(i, "m_iMaxHealth"), 4);
				
				new iEHealth = m_iHealth + restored_health;
				if((m_iHealth + restored_health) > m_iMaxHealth || iUpgrade[subject][5] > 0)
					 iEHealth = m_iMaxHealth;
				CheatCommand(i, "give", "health", "");
				SetEntData(i, FindDataMapInfo(i, "m_iHealth"), iEHealth, 4, true);
				SetEntProp(i, Prop_Send, "m_currentReviveCount", 0, 4);
				SetEntProp(i, Prop_Send, "m_isGoingToDie", 0);
			}
		}
	}
}

public UpgradeLaserSight(client)
{
	CreateTimer(0.1, timer_UpgradeLaserSight, client);
}

public Action:timer_UpgradeLaserSight(Handle:timer, any:client)
{
	if(iUpgrade[client][2] > 0)
	{
		if(IsClientInGame(client))
		{
			CheatCommand(client, "upgrade_add", "laser_sight", "");
			new iWEAPON2 = GetPlayerWeaponSlot(client, 1);
			if(iWEAPON2 > 0)
			{
				decl String:WEAPON_NAME2[64];
				GetEdictClassname(iWEAPON2, WEAPON_NAME2, 32);
				if(!StrEqual(WEAPON_NAME2, "weapon_melee") && !StrEqual(WEAPON_NAME2, "weapon_chainsaw"))
				{
					new userbits = GetEntProp(iWEAPON2, Prop_Send, "m_upgradeBitVec");
					if(userbits & 1 << 2 != 1 << 2)
					{
						SetEntProp(iWEAPON2, Prop_Send, "m_upgradeBitVec", userbits |= (1 << 2), 4);
					}
				}
			}
		}

	}
}

public UpgradeCombatGloves(client)
{
	if(iUpgrade[client][31] > 0)
	{
		new iShovePenalty = GetEntProp(client, Prop_Send, "m_iShovePenalty");
		if(iShovePenalty >= 1 && iCombatGloves[client] < 4)
		{
			iCombatGloves[client]++;
			SetEntProp(client, Prop_Send, "m_iShovePenalty", iShovePenalty-1, 1);
		}
		if(CombatGlovesCooldownTimer[client] == INVALID_HANDLE)
		{
			CombatGlovesCooldownTimer[client] = CreateTimer(2.0, timer_UpgradeCombatGloves, client, TIMER_REPEAT);
		}
	}
}

public Action:timer_UpgradeCombatGloves(Handle:timer, any:client)
{
	if(iCombatGloves[client] > 0)
	{
		iCombatGloves[client]--;
	}
	else
	{
		CombatGlovesCooldownTimer[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public UpgradeEndocrine(client)
{
	if(iUpgrade[client][32] > 0)
	{
		SetConVarFloat(g_VarAdrenalineDuration, AdrenalineDuration*(1.7+CheckBoosters(client, 32)), false, false);
	}	
	else
	{
		SetConVarFloat(g_VarAdrenalineDuration, AdrenalineDuration, false, false);
	}
		
}

public bool:IsClientClose(client, subject)
{ 
	new Float:clientPosition[3];
	new Float:otherPosition[3];
	new Float:m_flDistance;
	
	GetClientEyePosition(subject, clientPosition);	

	if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2)
	{
		GetClientEyePosition(client, otherPosition);
		m_flDistance = GetVectorDistance(clientPosition, otherPosition);
		
		if(m_flDistance < 200)
		{			
			return true;
		}
	}
	return false;
}

public Action:timer_SafetyFuseStop(Handle:timer, any:client)
{
	SetConVarFloat(FindConVar("pipe_bomb_timer_duration"), PipeBombDuration, false, false);
	return Plugin_Handled;
}

public Action:timer_KnifeCooldownTimer(Handle:timer, any:client)
{
	KnifeCooldownTimer[client] = INVALID_HANDLE;
}

public Action:timer_SecondWindCooldownTimer(Handle:timer, any:client)
{
	SecondWindCooldownTimer[client] = INVALID_HANDLE;
}
	
public Action:CreateMolotovTimer(Handle:hTimer, any:type)
{
	new iEntity = INVALID_ENT_REFERENCE;
	while ((iEntity = FindEntityByClassname(iEntity, "molotov_projectile")) != INVALID_ENT_REFERENCE)
	{
		HookSingleEntityOutput(iEntity, "OnKilled", MolotovBreak);
	}
}

public MolotovBreak(const String:output[], caller, activator, Float:delay)
{
	decl Float:fOrigin[3];
	GetEntPropVector(caller, Prop_Data, "m_vecOrigin", fOrigin);

	new Handle:pack = CreateDataPack();
	WritePackFloat(pack, fOrigin[0]);
	WritePackFloat(pack, fOrigin[1]);
	WritePackFloat(pack, fOrigin[2]);
	WritePackCell(pack, activator);
	CreateTimer(10.0, timer_PyroPouchGasCan, pack);
}

public UpgradeKeroseneShot(client, entindex)
{
	if(iUpgrade[client][1] > 0)
	{
		decl String:sModelFile[256];
		GetEntPropString(entindex, Prop_Data, "m_ModelName", sModelFile, sizeof(sModelFile));

		if(StrEqual(sModelFile, ENTITY_GASCAN, false))
		{
			decl Float:fOrigin[3];
			GetEntPropVector(entindex, Prop_Data, "m_vecOrigin", fOrigin);

			new Handle:pack = CreateDataPack();
			WritePackFloat(pack, fOrigin[0]);
			WritePackFloat(pack, fOrigin[1]);
			WritePackFloat(pack, fOrigin[2]);
			WritePackCell(pack, client);
			CreateTimer(10.0, timer_PyroPouchGasCan, pack);
		}
		if(StrEqual(sModelFile, ENTITY_PROPANE, false))
		{
			decl Float:fOrigin[3];
			GetEntPropVector(entindex, Prop_Data, "m_vecOrigin", fOrigin);

			new Handle:pack = CreateDataPack();
			WritePackFloat(pack, fOrigin[0]);
			WritePackFloat(pack, fOrigin[1]);
			WritePackFloat(pack, fOrigin[2]);
			WritePackCell(pack, client);
			CreateTimer(0.8, timer_PyroPouchPropane, pack, TIMER_REPEAT);
		}
	}
}

public UpgradePillsAddiction(client)
{
	if(iUpgrade[client][33] > 0)
	{
		new Float:m_iHealthBufferBits = float(GetConVarInt(FindConVar("pain_pills_health_value")));
		new Float:im_iHealthBufferBits = 0.0;
		
		if(iUpgrade[client][7] > 0)
			m_iHealthBufferBits = m_iHealthBufferBits*1.5;
			
		m_iHealthBufferBits = m_iHealthBufferBits*0.5;
			
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientClose(i, client) && i != client)
			{
				new Float:im_iHealth = float(GetEntData(i, FindDataMapInfo(i, "m_iHealth"), 4));
				new Float:im_iMaxHealth = float(GetEntData(i, FindDataMapInfo(i, "m_iMaxHealth"), 4));
				new Float:im_iHealthBuffer = GetEntDataFloat(i, FindSendPropInfo("CTerrorPlayer","m_healthBuffer"));
				im_iHealthBufferBits = m_iHealthBufferBits;
				if(im_iHealth + im_iHealthBuffer + m_iHealthBufferBits > im_iMaxHealth)
				{
					im_iHealthBufferBits = im_iMaxHealth - im_iHealth;
					SetEntPropFloat(i, Prop_Send, "m_healthBuffer", im_iHealthBufferBits);
				}
				else
				{
					SetEntPropFloat(i, Prop_Send, "m_healthBuffer", im_iHealthBuffer + im_iHealthBufferBits);
				}
				SetEntPropFloat(i, Prop_Send, "m_healthBufferTime", GetGameTime());
			}
		}
	}
}

public Action:timer_PyroPouchGasCan(Handle:timer, any:pack)
{
	decl Float:fOrigin[3];

	ResetPack(pack);
	fOrigin[0] = ReadPackFloat(pack);
	fOrigin[1] = ReadPackFloat(pack);
	fOrigin[2] = ReadPackFloat(pack);
	//new client = ReadPackCell(pack);

	new entity = CreateEntityByName("prop_physics");
	if(IsValidEntity(entity))
	{
		fOrigin[2] += 30.0;
		DispatchKeyValue(entity, "model", ENTITY_GASCAN);
		DispatchSpawn(entity);
		SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
		TeleportEntity(entity, fOrigin, NULL_VECTOR, NULL_VECTOR);
		ActivateEntity(entity);
		//AcceptEntityInput(entity, "break");
	}
}

public Action:timer_PyroPouchPropane(Handle:timer, any:pack)
{
	decl Float:fOrigin[3];

	ResetPack(pack);
	fOrigin[0] = ReadPackFloat(pack);
	fOrigin[1] = ReadPackFloat(pack);
	fOrigin[2] = ReadPackFloat(pack);
	new client = ReadPackCell(pack);

	new entity = CreateEntityByName("prop_physics");
	if(IsValidEntity(entity))
	{
		fOrigin[2] += 30.0;
		DispatchKeyValue(entity, "model", ENTITY_PROPANE);
		DispatchSpawn(entity);
		SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
		//SetEntPropEnt(entity, Prop_Data, "m_hPhysicsAttacker", client);
		//SetEntPropEnt(entity, Prop_Data, "m_hLastAttacker", client);
		//SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", client);
		TeleportEntity(entity, fOrigin, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(entity, "break");
	}

	iCountTimer[client] += 1;

	if(iCountTimer[client] > 2)
	{
		iCountTimer[client] = 0;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action:timer_UpgradeGrenadeItems(Handle:timer, any:client)
{
    for(new slot = 0; slot < 2; slot++)
    {
		if(!StrEqual(iGrenadeItems[client][slot], ""))
		{				
			new item = GivePlayerItem(client, iGrenadeItems[client][slot]);
			EquipPlayerWeapon(client, item);
			iGrenadeItems[client][slot] = "";
			return;
		}
	}
}

public Action:timer_UpgradePrimaryItems(Handle:timer, any:client)
{
	new maxslots = 0;
	if(iUpgrade[client][27] > 0)
		maxslots++;
	
	if(iUpgrade[client][27] > 0)
	{
		for(new slot = 0; slot < maxslots; slot++)
		{
			if(!StrEqual(iPrimaryItems[client][slot], ""))
			{
				new item = GivePlayerItem(client, iPrimaryItems[client][slot]);
				EquipPlayerWeapon(client, item);
				iPrimaryItems[client][slot] = "";
				return;
			}
		}
	}
}

public Action:timer_UpgradeSecondaryItems(Handle:timer, any:client)
{
	new maxslots = 0;
	if(iUpgrade[client][20] > 0)
		maxslots++;
	if(iUpgrade[client][25] > 0)
		maxslots++;
	
	if(iUpgrade[client][20] > 0 || iUpgrade[client][25] > 0)
	{		
		for(new slot = 0; slot < maxslots; slot++)
		{
			if(!StrEqual(iSecondaryItems[client][slot], ""))
			{				
				new item = GivePlayerItem(client, iSecondaryItems[client][slot]);
				EquipPlayerWeapon(client, item);
				iSecondaryItems[client][slot] = "";
				return;
			}
		}
	}
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(client == 0)
		return Plugin_Handled;
	
	if(buttons & IN_ATTACK2)
	{
		UpgradeKnife(client);
		UpgradeCombatGloves(client);
	}

	if(IsPlayerIncapped(client) && buttons & IN_USE)
	{
		UpgradeSecondWind(client);
	}

	if(IsFakeClient(client) || GetClientTeam(client) != 2)
		return Plugin_Stop;

	new ActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if(iUpgrade[client][21] > 0 && (buttons & IN_RELOAD) && ReloadCooldown[client] == INVALID_HANDLE && ActiveWeapon > 0)
	{
		decl String:WEAPON_NAME[64];
		GetEdictClassname(ActiveWeapon, WEAPON_NAME, sizeof(WEAPON_NAME));
	
		if(StrContains(WEAPON_NAME, "shotgun", false) != -1 && GetEntProp(ActiveWeapon, Prop_Send, "m_bInReload") == 0)
		{
			new m_iClip1 = GetEntProp(ActiveWeapon, Prop_Send, "m_iClip1");
			if(CheckWeaponUpgradeLimit(ActiveWeapon, client, true) > m_iClip1 >= CheckWeaponUpgradeLimit(ActiveWeapon, client, false))
			{
				SetEntProp(ActiveWeapon, Prop_Send, "m_iClip1", CheckWeaponUpgradeLimit(ActiveWeapon, client, false)-1, 4);				

				new Handle:pack;
				CreateDataTimer(0.1, timer_RestoreShotgun, pack);
				WritePackCell(pack, ActiveWeapon);
				WritePackCell(pack, m_iClip1);
				WritePackCell(pack, client);
			}
		}
		if(StrEqual(WEAPON_NAME, "weapon_pistol_magnum") || StrEqual(WEAPON_NAME, "weapon_pistol") || StrEqual(WEAPON_NAME, "weapon_grenade_launcher") || StrEqual(WEAPON_NAME, "weapon_sniper_military") || StrEqual(WEAPON_NAME, "weapon_hunting_rifle") || StrEqual(WEAPON_NAME, "weapon_rifle_ak47") || StrEqual(WEAPON_NAME, "weapon_rifle_desert") || StrEqual(WEAPON_NAME, "weapon_rifle") || StrEqual(WEAPON_NAME, "weapon_smg") || StrEqual(WEAPON_NAME, "weapon_smg_silenced") || StrEqual(WEAPON_NAME, "weapon_smg_mp5"))
		{
			new m_iClip1 = GetEntProp(ActiveWeapon, Prop_Send, "m_iClip1");
			if(CheckWeaponUpgradeLimit(ActiveWeapon, client, false) == m_iClip1)
			{
				new m_iAmmo = GetEntData(client, (FindDataMapInfo(client, "m_iAmmo") + CheckWeaponAmmoType(ActiveWeapon))); 
				SetEntProp(ActiveWeapon, Prop_Send, "m_iClip1", 0, 4);
				SetEntData(client, (FindDataMapInfo(client, "m_iAmmo") + CheckWeaponAmmoType(ActiveWeapon)), m_iAmmo + CheckWeaponUpgradeLimit(ActiveWeapon, client, false), 4, true);
			}
		}
	}
	ReloadCooldown[client] = CreateTimer(1.0, timer_ReloadCooldown, client);
	return Plugin_Continue;
}

public Action:timer_ReloadCooldown(Handle:timer, any:client)
{
	ReloadCooldown[client] = INVALID_HANDLE;
}

public Action:timer_RestoreShotgun(Handle:timer, any:pack)
{
	ResetPack(pack);
	new ActiveWeapon = ReadPackCell(pack);
	new m_iClip1 = ReadPackCell(pack);
	new client = ReadPackCell(pack);

	SetEntProp(ActiveWeapon, Prop_Send, "m_iClip1", m_iClip1, 4);
	SetEntProp(ActiveWeapon, Prop_Send, "m_reloadNumShells", (CheckWeaponUpgradeLimit(ActiveWeapon, client, true) - m_iClip1), 4);
}

public Action:timer_SetNumShells(Handle:timer, any:client)
{
	new ActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	decl String:WEAPON_NAME[64];
	GetEdictClassname(ActiveWeapon, WEAPON_NAME, sizeof(WEAPON_NAME));
	
	if(StrContains(WEAPON_NAME, "shotgun", false) != -1)
	{
		new m_iClip1 = GetEntProp(ActiveWeapon, Prop_Send, "m_iClip1");
		SetEntProp(ActiveWeapon, Prop_Send, "m_reloadNumShells", CheckWeaponUpgradeLimit(ActiveWeapon, client, true) - m_iClip1, 4);
	}
}

Float:CheckBoosters(client, upgradeid)
{
	if(iBooster[client][upgradeid] > 0)
		return 0.25;
	return 0.0;
}

bool:CanUseBooster(client)
{
	if(iBoosterSlots[client] > 0 && iBoosterSlots[client] - TotalBoostersUsed(client) > 0)
		return true;
	return false;
}

TotalBoostersUsed(client)
{
	new boostersUsed = 0;
	for(new upgradeID = 0; upgradeID <= MAX_UPGRADES; upgradeID++)
    {
		if(iBooster[client][upgradeID] > 0)
			boostersUsed++;
	}
	return boostersUsed;
}

stock bool:HasIdlePlayer(bot)
{
    new userid = GetEntData(bot, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID"));
    new client = GetClientOfUserId(userid);
    
    if(client > 0)
    {
        if(IsClientConnected(client) && !IsFakeClient(client))
            return true;
    }    
    return false;
}

stock bool:IsClientIdle(client)
{
    for(new i = 1; i <= MaxClients; i++)
    {
        if(!IsClientConnected(i))
            continue;
        if(!IsClientInGame(i))
            continue;
        if(GetClientTeam(i) != 2)
            continue;
        if(!IsFakeClient(i))
            continue;
        if(!HasIdlePlayer(i))
            continue;
        
        new spectator_userid = GetEntData(i, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID"));
        new spectator_client = GetClientOfUserId(spectator_userid);
        
        if(spectator_client == client)
            return true;
    }
    return false;
}

stock GetAnyValidClient()
{
    for (new target = 1; target <= MaxClients; target++)
    {
        if (IsClientInGame(target)) return target;
    }
    return -1;
}

stock GetClientUsedUpgrade(upgrade)
{
	for(new client = 1; client <= MaxClients; client++)
	{
		if(!IsClientConnected(client))
			continue;
		if(!IsClientInGame(client))
			continue;

		if(iUpgrade[client][upgrade] > 0 && (iBitsUpgrades[client] - iUpgrade[client][upgrade]) == GetEntProp(client, Prop_Send, "m_upgradeBitVec"))
		{
			RemoveUpgrade(client, upgrade);
			return client;
		}
	}
	return 0;
}

stock CheatCommand(client, String:command[], String:argument1[], String:argument2[])
{
	new userFlags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s %s", command, argument1, argument2);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userFlags);
}