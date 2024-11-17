// Defines
bool g_MapDefined_MeleeOnly = false;
bool g_AuraIsActive = false;
int g_iWeeklyBonusEXP = 0;
int g_AllBonusEXP = 0;

// Load achievements
#include "lib/achievements"
// Load playerdata
#include "lib/playerdata"

// Menu stuff
enum MenuEnum
{
	MENU_SKILLS = 0,
	MENU_SHOP
};

#include "menu/skills"

// Give our garbage
#include "give_donator"
#include "give_prestiges"

Menu::SkillMenu g_SkillMenu;
Menu::SkillMenuEx g_SkillMenuEx;
// End

// Gift from the gods
GiftFromTheGods::AmmoDrop g_AmmoDrop;
GiftFromTheGods::WeaponDrop g_WeaponDrop;
// End

// Our max values
const int AB_HEALTH_MAX = 10; //Default 400
const int AB_ARMOR_MAX = 10; //Default 210
const int AB_HEALTH_REGEN_MAX = 10; //Default 50
const int AB_ARMOR_REGEN_MAX = 10; //Default 55
const int AB_AMMO_MAX = 10; //Default 30
const int AB_EXPLOSIVE_MAX = 5; //Default 10
const int AB_DOUBLEJUMP_MAX = 1; //Default 5
const int AB_FIRSTAID_MAX = 10; //Default 20
const int AB_SHOCKRIFLE_MAX = 10; //Default 20

const int MAX_LEVEL = AB_HEALTH_MAX + AB_ARMOR_MAX + AB_HEALTH_REGEN_MAX + AB_ARMOR_REGEN_MAX + AB_AMMO_MAX + AB_EXPLOSIVE_MAX + AB_DOUBLEJUMP_MAX + AB_FIRSTAID_MAX + AB_SHOCKRIFLE_MAX; //MUST ADD UP TO SKILL TOTAL
const int MAX_PRESTIGE = 10; //Default 10

//Unused
int SuperWeaponType = 0;

//For Max Ammos
int AMMO_SHOCKCHARGES;
int SHOCKCHARGES_BOOST;

const string SND_LVLUP = "items/r_item1.wav";
const string SND_LVLUP_800 = "items/r_item2.wav";
const string SND_PRESTIGE = "items/r_item2.wav";
const string SND_READY = "items/suitchargeok1.wav";
const string SND_AURA01 = "items/medshot5.wav";
const string SND_AURA02 = "items/medshot5.wav";
const string SND_AURA03 = "items/medshot5.wav";
const string SND_HOLYGUARD = "items/gunpickup4.wav";
const string SND_HOLYWEP = "items/ammopickup2.wav";
const string SND_JUMP = "player/pl_jump2.wav";
const string SND_JUMP_LAND = "player/pl_jumpland2.wav";
const string SND_NULL = "null.wav";

final class CSCRPGCore
{
	private CScheduledFunction@ hThinker = null;
	CSCRPGCore()
	{
		// Load our DB file
		LoadDB();
	}
	
	~CSCRPGCore()
	{
		// Unload it
		UnloadDB();
		Reset();
	}
	
	// SQL
	private bool m_bIsSQL = false;
	private string m_szSQL_Hostname = "";
	private string m_szSQL_User = "";
	private string m_szSQL_Password = "";
	private string m_szSQL_Database = "";
	private int m_iSQL_Port = 0;
	
	private bool m_bLoadedDB = false;
	private File@ player_data = null;
	
	private void PlaySoundEffect( CBasePlayer@ pPlayer, string snd )
	{
		if ( pPlayer is null ) return;
		g_SoundSystem.PlaySound( pPlayer.edict(), CHAN_AUTO, snd, 1.0f, ATTN_NORM, 0, 100 );
	}
	
	private void OnThink()
	{
		for ( int i = 1; i <= g_Engine.maxClients; i++ )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
			if ( (pPlayer !is null) && (pPlayer.IsConnected()) )
			{
				string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
				if ( g_PlayerCoreData.exists(szSteamId) )
				{
					PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
					if ( data is null ) continue;
					
					// Fix the model not showing
					if ( data.iWaitTimer_Prestige >= 0 )
					{
						if ( data.iWaitTimer_Prestige == 0 )
						{
							
						}
						data.iWaitTimer_Prestige--;
					}
					
					// Check our regen stuff
					RegenPlayer( pPlayer, data );
					
					// Check our timers
					PlayerTimers( pPlayer, data );
					
					// Playtime EXP bonus
					//PlayTimeEXP( pPlayer, data );
					
					// Draw our HUD info
					DrawHUDInfo( pPlayer, data );
					
					// AchievementsCheck
					CheckForAchievements( pPlayer, data );
					
					// Set our values and such
					int currentScore = int(pPlayer.pev.frags);
					data.iExp += currentScore - data.iScore;
					if(data.iExp <= 0) data.iExp = 0;
					data.iScore = currentScore;
					
					// Increase our EXP (bonus bullshit)
					//IncreaseEXP( data );
					
					// Give some cash
					//data.iSouls += Math.RandomLong( 0, 0 );
					
					// Calculate level up, and save our data
					CalculateLevelUp( pPlayer, data );
				}
			}
		}
	}
	
	private void CheckForAchievements( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		if ( data.iWaitTimer_Prestige > 0 ) return;
		
		// Prestige Achievements
		if ( data.iPrestige >= 1 )
			g_Achivements.GiveAchievement( pPlayer, "prestige_1", true );
		if ( data.iPrestige >= 2 )
			g_Achivements.GiveAchievement( pPlayer, "prestige_lj", true );
		if ( data.iPrestige >= 5 )
			g_Achivements.GiveAchievement( pPlayer, "prestige_5", true );
		
		// Map check
		if ( IsCurrentMap( "extreme_uboa_afterlife_v2" ) )
			g_Achivements.GiveAchievement( pPlayer, "extreme_uboa", true );
		if ( IsCurrentMap( "inv_dojo" ) )
			g_Achivements.GiveAchievement( pPlayer, "martialarts", true );
	}
			//Achievement Rewards
	void CheckForSpecificAchievement( CBasePlayer@ pPlayer, string szIDCheck )
	{
		if ( szIDCheck == "weapon_runeblade" )
			g_Achivements.GiveAchievement( pPlayer, "runeblade", true );
		if ( szIDCheck == "weapon_af_ethereal" )
			g_Achivements.GiveAchievement( pPlayer, "ethereal", true );
		if ( szIDCheck == "weapon_af_ethereal_mk2" )
			g_Achivements.GiveAchievement( pPlayer, "plasmarifle", true );
		if ( szIDCheck == "weapon_fotn" )
			g_Achivements.GiveAchievement( pPlayer, "fotn", true );
		if ( szIDCheck == "weapon_scinade" )
			g_Achivements.GiveAchievement( pPlayer, "scinade", true );
	}
	
		//HUD - Skill Cooldown Progress
	private string GetSkillProgress( float flProgress, float flProgressMAX )
	{
		float ratio = flProgress / flProgressMAX;
		float realpos = ratio * 10;
		string output = "[";
		
		// Our progress
		for ( int i = 0; i < 10; i++ )
		{
			if ( i <= realpos )
				output += "|";
			else
				output += ".";
		}
		
		output += "]";
		return output;
	}
		//Top-Right RPG HUD
	private void DrawHUDInfo( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;

		g_AllBonusEXP = (data.iPrestige * 1 + data.iCommunityEXP); //Display total bonus XP from Prestige Was g_AllBonusEXP = g_iWeeklyBonusEXP + data.iMedals + (data.iPrestige * 1);
		
		string szBonusEXP = "";
		if ( g_AllBonusEXP > 0 ) //Was if ( g_iWeeklyBonusEXP >= 0 )
			szBonusEXP = " (+" + g_AllBonusEXP + " XP Bonus)";
		string output = "";
		if ( data.iLevel < MAX_LEVEL )
			output = "XP: (" + data.iExp + " / " + data.iExpMax + ")" + szBonusEXP + "\n";
			output += "Level: " + data.iLevel + " / " + MAX_LEVEL + "\n";
			//output += "Achievements:  " + data.iMedals + " / " + g_Achivements.GetMaxMedals() + "\n";
			//output += "Souls:  " + data.iSouls + "\n"; Disabled
			output += "Prestige: " + data.iPrestige + " / " + MAX_PRESTIGE + "\n";
			//output += "Your SteamID:  " + data.szSteamID + "\n"; Disabled

			//Ammo/Explosive Timers on HUD
			output += "Ammo Regeneration - (" + data.iWaitTimer_AmmoDrop + "s)\n";
			output += "Explosives Regeneration - (" + data.iWaitTimer_WeaponDrop + "s)\n";
		
		if ( data.iPoints > 0 )
			output += "\nYou have " + data.iPoints + " skillpoints available!\nWrite /skills to spend them!\n\n";
		
		// Hud settings for RPG Display
		HUDTextParams params;
		
		params.channel = 16;	// We don't want to break other text channels, so lets put it here instead
		params.effect = 0;
		params.x = 0.75;
		params.y = 0.04;
		
		params.r1 = 255;
		params.g1 = 255;
		params.b1 = 0;
		params.a1 = 225;
		
		params.r2 = 127;
		params.g2 = 0;
		params.b2 = 255;
		params.a2 = 200;
		
		params.fadeinTime = 0.0;
		params.fadeoutTime = 0.0;
		params.holdTime = 255.0;
		params.fxTime = 6.0;
		
		g_PlayerFuncs.HudMessage(
			pPlayer,
			params,
			output
		);
		
		// Summon Shock Roach (Was Holy Armor)
		string buffer1 = "";
		string buffer2 = "";
		
		if ( data.iStat_shockrifle > 0 )
		{
			if ( data.iWaitTimer_HolyArmor >= data.iWaitTimer_HolyArmor_Max )
			{
				if ( pPlayer.IsAlive() )
					buffer1 = "Shock Rifle: [Type 'shockrifle' to use]\n";
				else
					buffer1 = "Shock Rifle: Cannot use whilst dead!\n";
			}
			else
				buffer1 = "Shock Rifle: On cooldown...  " + "(" + data.iDisplayTimer_SuperWeapon + "s)" + "\n"; //Display Time left on HUD
				//buffer1 = "Shock Rifle Cooldown: " + GetSkillProgress( data.iWaitTimer_HolyArmor, data.iWaitTimer_HolyArmor_Max ) + " (" + data.iDisplayTimer_SuperWeapon + "s)" + "\n"; //Changed to use skill timers in favour of skill progress bars 
		}
		
		if ( data.iStat_firstaid > 0 )
		{
			if ( data.iWaitTimer_BattleCry >= data.iWaitTimer_BattleCry_Max )
			{
				//if ( g_AuraIsActive )
				if ( pPlayer.IsAlive() )
					buffer2 = "First Aid (Heal): [Type 'firstaid' to use]\n";
				else
					buffer2 = "First Aid (Revive): [Type 'firstaid' to use]\n";
			}
			else
				buffer2 = "First Aid: On cooldown... " + "(" + data.iDisplayTimer_Aura + "s)" + "\n"; //Display bar and time left on HUD
				//buffer2 = "First Aid: " + GetSkillProgress( data.iWaitTimer_BattleCry, data.iWaitTimer_BattleCry_Max ) + " (" + iDisplayTimer_Aura + "s)" + "\n"; //Changed to use skill timers in favour of skill progress bars 
		}
		
		string output2 = buffer1 + buffer2;
		
		// Hud settings for Skill Progress Display
		HUDTextParams params2;
		
		params2.channel = 17;	// We don't want to break other text channels, so lets put it here instead
		params2.effect = 0;
		params2.x = 0.02;
		params2.y = 0.8;
		
		params2.r1 = 0;
		params2.g1 = 255;
		params2.b1 = 255;
		params2.a1 = 225;
		
		params2.r2 = 127;
		params2.g2 = 0;
		params2.b2 = 255;
		params2.a2 = 255;
		
		params2.fadeinTime = 0.0;
		params2.fadeoutTime = 0.0;
		params2.holdTime = 255.0;
		params2.fxTime = 6.0;
		
		g_PlayerFuncs.HudMessage(
			pPlayer,
			params2,
			output2
		);
	}
			//XP Over time
	private void PlayTimeEXP( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( data is null ) return;
		if ( data.iWaitTimer_FreeEXP <= 0 )
		{
			if ( data.iLevel < MAX_LEVEL )
			{
				data.iExp += 10; //Timed XP reward scales with level
				CalculateLevelUp( pPlayer, data );
			}
			data.iWaitTimer_FreeEXP = 600; //Give XP this many seconds (10 mins)
			data.iSouls += Math.RandomLong( 0, 0 ); //Disabled for now as souls has no current use
		}
		else
			data.iWaitTimer_FreeEXP--;
	}
		
		//Max Health & Armor Scaling
	void SetMaxArmorHealth( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		
		const int MAX_DEFAULT = 100;
		pPlayer.pev.max_health = MAX_DEFAULT + ( data.iStat_health + data.iPrestige ) * 10; //Scales health max
		pPlayer.pev.armortype = MAX_DEFAULT + ( data.iStat_armor + data.iPrestige ) * 10; //Scales armor max
	}
		//Max Health & Armor Setting
	private void SetArmorHealth( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		pPlayer.pev.health += ( data.iStat_health + data.iPrestige ) * 10;
		pPlayer.pev.armorvalue += ( data.iStat_armor + data.iPrestige ) * 10;
	}

			//First Aid (Was Battlecry)
	private void DoFirstAid( CBasePlayer@ pPlayer, PlayerData@ data )
	{	
		// Get % of max health
		int ihealskill = data.iStat_firstaid; //Get skill level
		float flhpvalue_self = pPlayer.pev.max_health / 100 * ( ihealskill * 10 ); //Self healing amount
		
		// Get % of target player max health
		float flhpvalue = pPlayer.pev.max_health / 100 * ( ihealskill * 8 ); //Target healing amount
		
		// Convert to floats to int
		int ihpvalue_self = int( flhpvalue_self ); //Healing value for self
		int ihpvalue = int( flhpvalue ); //Healing value for targets

		// Heal Mode - If not dead, heal full amount
		if ( pPlayer.pev.health > 0 )
			pPlayer.pev.health += ihpvalue_self;

		// Revive Mode - If dead, revive, only heal for half
			if ( pPlayer.pev.health < 1 )	
				pPlayer.Revive();

					if ( pPlayer.pev.health > 0 )
						pPlayer.pev.health += ihpvalue_self / 2; //Only heal half, to penalise revival, but to help not get rekt when surrounded.

		// If we ever overheal, remove it
		if ( pPlayer.pev.health > pPlayer.pev.max_health )
			pPlayer.pev.health = pPlayer.pev.max_health;
		
		// Within radius? then give them some boost!		//Doesn't seem to work, really needs fixing. I will alter this to heal a different amount to nearby players for when it is fixed.
		float distance = 300.0f;
		for ( int i = 1; i <= g_Engine.maxClients; i++ )
		{
			CBasePlayer@ pTarget = g_PlayerFuncs.FindPlayerByIndex( i );
			if ( (pTarget !is null) && (pTarget.IsConnected()) )
			{
				// Don't increase ourselves
				//if ( pTarget == pPlayer ) continue;
				Vector vEntOrigin = (pTarget.pev.absmin + pTarget.pev.absmax)/2;
				if ( (vEntOrigin - pPlayer.pev.origin).Length() < distance )
				{
					// Heal Mode - If not dead, heal full amount
					if ( pPlayer.pev.health > 0 )
						pPlayer.pev.health += ihpvalue;

					// Revive Mode - If dead, revive, only heal for half
						if ( pPlayer.pev.health < 1 )	
							pPlayer.Revive();

								if ( pPlayer.pev.health > 0 )
									pPlayer.pev.health += ihpvalue;

					// If we ever overheal, remove it
					if ( pPlayer.pev.health > pPlayer.pev.max_health )
						pPlayer.pev.health = pPlayer.pev.max_health;

					g_Achivements.GiveAchievement( pPlayer, "teamplayer", true );
				}
			}
		}
	}

	//Set any customised max ammo types
	private void SetMaxAmmo( CBasePlayer@ pPlayer )
	{	
		AMMO_SHOCKCHARGES = g_PlayerFuncs.GetAmmoIndex( "shock charges" ); //Get ammo index for type and store it
		if ( pPlayer is null ) return;
			pPlayer.m_rgAmmo( AMMO_SHOCKCHARGES, 100 + SHOCKCHARGES_BOOST ); //Boost shock rifle ammo with skill level
	}

		//Give a shock roach and increase shock rifle max charges
	private void GiveSuperWeapon( CBasePlayer@ pPlayer )
	{	
		AMMO_SHOCKCHARGES = g_PlayerFuncs.GetAmmoIndex( "shock charges" );

		if ( pPlayer is null ) return;
			GiveToPlayer::GiveWeapon( pPlayer, "weapon_shockrifle" ); //Give the player a shockroach
				pPlayer.m_rgAmmo( AMMO_SHOCKCHARGES, 100 + SHOCKCHARGES_BOOST ); //Boost shock rifle ammo with skill level

		//Give random super weapon - MINIGUN DOESN'T WORK
		//if ( pPlayer is null ) return;
		//	SuperWeaponType = Math.RandomLong( 0, 1 );
		//		if ( SuperWeaponType > 0 )	
		//			GiveToPlayer::GiveWeapon( pPlayer, "weapon_minigun" );
		//		if ( SuperWeaponType < 1 )
		//			GiveToPlayer::GiveWeapon( pPlayer, "weapon_shockrifle" );
	}

	private void FirstAidBuffMedkit( CBasePlayer@ pPlayer, PlayerData@ data )
	{	
		pPlayer.GiveAmmo( 1 + ( data.iStat_firstaid + data.iPrestige * 5 ),"health", 100 ); //Scale Medkit recharge with First Aid skill
	}

			//Player Timers
	private void PlayerTimers( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		if ( data.iWaitTimer_Hurt_Snd > 0 ) data.iWaitTimer_Hurt_Snd--;
		if ( data.iWaitTimer_SndEffect > 0 ) data.iWaitTimer_SndEffect--;
		
		if ( data.iWaitTimer_HolyArmor < data.iWaitTimer_HolyArmor_Max )
		{
			data.iWaitTimer_HolyArmor++; //Increase Timer
			data.iDisplayTimer_SuperWeapon--; //Reduce from Display Timer instead of add (count down)
			if ( data.iWaitTimer_HolyArmor == data.iWaitTimer_HolyArmor_Max )
				ClientSidedSound( pPlayer, SND_READY );
		}
		
		if ( data.iWaitTimer_HolyArmor_Reset > 0 )
		{
				SHOCKCHARGES_BOOST = ( data.iStat_shockrifle + data.iPrestige ) * 20; //Set Shock Rifle max charges to scale with Shock Roach skill
				GiveSuperWeapon( pPlayer ); //Give Shock Rifle, set max ammo
				data.iWaitTimer_HolyArmor_Reset--;
		}		
		else
		{
			if ( data.iWaitTimer_HolyArmor_Reset == 0 )
			{
				SetAuraGlow( false, pPlayer, 255, 255, 255 );
				data.iWaitTimer_HolyArmor_Reset = -1;
			}
		}
			//First Aid (Battlecry) Timers
		if ( data.iWaitTimer_BattleCry < data.iWaitTimer_BattleCry_Max )
		{
			data.iWaitTimer_BattleCry++; //Increase Timer
			data.iDisplayTimer_Aura--; //Reduce from Display Timer instead of add (count down)
			if ( data.iWaitTimer_BattleCry == data.iWaitTimer_BattleCry_Max )
				ClientSidedSound( pPlayer, SND_READY );
		}
		
		if ( data.iWaitTimer_BattleCry_Reset > 0 )
		{
			DoFirstAid( pPlayer, data );
			data.iWaitTimer_BattleCry_Reset--;
		}
		else
		{
			if ( data.iWaitTimer_BattleCry_Reset == 0 )
			{
				SetAuraGlow( false, pPlayer, 255, 255, 255 );
				g_AuraIsActive = false;
				data.iWaitTimer_BattleCry_Reset = -1;
			}
		}
				//Gift of The Gods Timers - Ammo Regen/Explosive Drop
		if ( pPlayer.IsAlive() )
		{
			if ( data.iStat_ammoregen > 0 )
			{
				if ( data.iWaitTimer_AmmoDrop > 0 )
					data.iWaitTimer_AmmoDrop--;
				else
				{
					g_AmmoDrop.GiveDrop( pPlayer, data.iStat_ammoregen ); //Give ammo drops
					data.iWaitTimer_AmmoDrop = 10 - ( data.iStat_ammoregen + data.iPrestige ) * 3/10; //Reset timer based on level (starts at 10 and can get as low as 6)
				}
				
			}
			
			if ( data.iStat_explosiveregen > 0 )
			{
				if ( data.iWaitTimer_WeaponDrop > 0 )
					data.iWaitTimer_WeaponDrop--;
				else
				{
					g_AmmoDrop.GiveDropExplosive( pPlayer, data.iStat_explosiveregen ); //Give ammo for all explosives
					data.iWaitTimer_WeaponDrop = 120 - ( data.iStat_explosiveregen + data.iPrestige ) * 4; //Reset timer based on level
				}
			}
		}
		
		if ( data.iWaitTimer_Hurt > 0 )
		{
			data.iWaitTimer_Hurt--;
			if ( data.iWaitTimer_Hurt == 0 )
				data.bIsHurt = false;
		}
	}
	
	private void CalculatePoints( PlayerData@ data )
	{
		if ( data is null ) return;
		
		// Read our unused levels from our level
		int iUnusedPoints = data.iLevel;
		
		// Now we remove points if we have some under the stat values
		iUnusedPoints -= data.iStat_health;
		iUnusedPoints -= data.iStat_health_regen;
		iUnusedPoints -= data.iStat_armor;
		iUnusedPoints -= data.iStat_armor_regen;
		iUnusedPoints -= data.iStat_ammoregen;
		iUnusedPoints -= data.iStat_explosiveregen;
		iUnusedPoints -= data.iStat_doublejump;
		iUnusedPoints -= data.iStat_firstaid;
		iUnusedPoints -= data.iStat_shockrifle;
		
		// Our unused points
		data.iPoints = iUnusedPoints;
	}
			//Health & Armor Regen Scaling
	private void RegenPlayer( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		if ( data.bIsHurt ) return;
		
		if ( pPlayer.IsAlive() )
		{
			FirstAidBuffMedkit( pPlayer, data ); //Regen extra Medkit charge
			SetMaxArmorHealth( pPlayer, data ); //Setting max health here again to override max limits on maps
			if ( data.iStat_health_regen > 0 )
			{
				// Restore for % of max health
				float flregenvalue_hp = pPlayer.pev.max_health / 100 * data.iStat_health_regen + data.iPrestige / 2; //Get % of max health based on skill level as float, then convert to int
						
				// Change to floats to int so they are usable (ingame health is an integer)
				int iregenvalue_hp = int( flregenvalue_hp );

				//If health is not full, regenerate
				if ( pPlayer.pev.health < pPlayer.pev.max_health )
					pPlayer.pev.health += iregenvalue_hp; //Add % of health to total health

					//If we heal over our maximum health, set it back to stop overheal
					if ( pPlayer.pev.health > pPlayer.pev.max_health )
						pPlayer.pev.health = pPlayer.pev.max_health;
			}
			
			if ( data.iStat_armor_regen > 0 )
			{

				// Restore for % of max armor
				float flregenvalue_ap = pPlayer.pev.armortype / 100 * data.iStat_armor_regen + data.iPrestige / 2; //Get % of max armor based on skill level as float, then convert to int
						
				// Change to floats to int so they are usable (ingame armor is an integer)
				int iregenvalue_ap = int( flregenvalue_ap );

				//If armor is not full, regenerate
				if ( pPlayer.pev.armorvalue < pPlayer.pev.max_health )
					pPlayer.pev.armorvalue += iregenvalue_ap; //Add % of armor to total armor

					//If we restore over our maximum armor, set it back to stop overheal
					if ( pPlayer.pev.armorvalue > pPlayer.pev.armortype )
						pPlayer.pev.armorvalue = pPlayer.pev.armortype;
			}
		}
	}
	
	private void LevelUp( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		
		// Increase our level
		data.iLevel++;
		
		// Increase our points
		data.iPoints++;
		
		// Reset exp
		data.iExp = 0;
		
		// Play sound effect
		if ( data.iLevel >= MAX_LEVEL )
		{
			PlaySoundEffect( pPlayer, SND_LVLUP_800 );
			string szNick = pPlayer.pev.netname;
			g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[RPG MOD] \"Congratulations!\" to " + szNick + ", for reaching Level " + MAX_LEVEL + "!\n");
		}
		else
			ClientSidedSound( pPlayer, SND_LVLUP );
		
		// Calculate new required EXP
		RequiredEXP( data );
	}
	
	private bool InsertData_Begin( string SteamID )
	{
		// We already exist, ignore...
		if ( g_PlayerCoreData.exists( SteamID ) )
			return false;
		
		PlayerData data;
		data.szSteamID = SteamID;
		//data.iMedals = 0;
		g_PlayerCoreData[data.szSteamID] = data;
		
		return true;
	}
	
	private void InsertData( string szFullLine, string SteamID, int iVal, string szLine )
	{
		// Just makin sure linux wont fuck
		szFullLine = szLine.SubString( szLine.Length() - 1, 1 );
		if ( szFullLine == " " || szFullLine == "\n" || szFullLine == "\r" || szFullLine == "\t" )
			szLine = szLine.SubString( 0, szLine.Length() - 1 );
		
		// We don't exist, ignore...
		if ( !g_PlayerCoreData.exists( SteamID ) )
			return;
		
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[SteamID]);
		
		int iOutput = atoi( szLine );
		switch( iVal )
		{
			case 1: data.iLevel = iOutput; break;
			case 2: data.iPrestige = iOutput; break;
			case 3: data.iSouls = iOutput; break;
			case 4: data.iExp = iOutput; break;
			case 5: data.iExpMax = iOutput; break;
			case 6: data.iStat_health = iOutput; break;
			case 7: data.iStat_armor = iOutput; break;
			case 8: data.iStat_health_regen = iOutput; break;
			case 9: data.iStat_armor_regen = iOutput; break;
			case 10: data.iStat_ammoregen = iOutput; break;
			case 11: data.iStat_explosiveregen = iOutput; break;
			case 12: data.iStat_doublejump = iOutput; break;
			case 13: data.iStat_firstaid = iOutput; break;
			case 14: data.iStat_shockrifle = iOutput; break;
			case 15: data.bIsCommunity = iOutput > 0 ? true : false; break;
			case 16: data.bIsDonator = iOutput > 0 ? true : false; break;
		}
		
		g_PlayerCoreData[SteamID] = data;
	}
	
	private void LoadDB()
	{
		g_PlayerCoreData.deleteAll();
		if ( !m_bIsSQL ) return;
		// TODO - SQL load
	}
	
	private void UnloadDB()
	{
		g_PlayerCoreData.deleteAll();
		if ( !m_bLoadedDB ) return;
		if ( !m_bIsSQL ) return;
		// TODO - We only continue if we use SQL
	}
	
	private int LoadFromDB( string SteamID, string szValue )
	{
		if ( !m_bLoadedDB ) return 0;
		// TODO
		return 0;
	}
	
	private string LoadFromDB_Model( string SteamID, string szValue )
	{
		if ( !m_bLoadedDB ) return "";
		// TODO
		return "";
	}
	
	private void LoadData( PlayerData@ data, string SteamID )
	{
		data.szSteamID = SteamID;
		data.bIsCommunity = LoadFromDB( SteamID, "member" ) > 0 ? true : false;
		data.bIsDonator = LoadFromDB( SteamID, "donator" ) > 0 ? true : false;
		data.iLevel = LoadFromDB( SteamID, "level" );
		data.iPrestige = LoadFromDB( SteamID, "prestige" );
		data.iSouls = LoadFromDB( SteamID, "money" );
		data.iExp = LoadFromDB( SteamID, "exp" );
		data.iExpMax = LoadFromDB( SteamID, "exp_max" );
		data.iStat_health = LoadFromDB( SteamID, "health" );
		data.iStat_health_regen = LoadFromDB( SteamID, "health_regen" );
		data.iStat_armor = LoadFromDB( SteamID, "armor" );
		data.iStat_armor_regen = LoadFromDB( SteamID, "armor_regen" );
		data.iStat_ammoregen = LoadFromDB( SteamID, "gotg_ammo" );
		data.iStat_explosiveregen = LoadFromDB( SteamID, "gotg_weapon" );
		data.iStat_doublejump = LoadFromDB( SteamID, "doublejump" );
		data.iStat_firstaid = LoadFromDB( SteamID, "battlecry" );
		data.iStat_shockrifle = LoadFromDB( SteamID, "holyarmor" );
	}
	
	// Only used by the local files
	private string ToSteamID64( string &in szSteamID )
	{
		if ( szSteamID.Length() < 11 )
			return "steamid_invalid";
		
		int iID_10 = atoi( szSteamID.SubString( 10, 1 ) );
		int iID_8 = atoi( szSteamID.SubString( 8, 1 ) );
		
		int iUpper = 765611979;
		int iFriendID = iID_10 * 2 + 60265728 + iID_8 - 48;
		
		int iDiv = iFriendID / 100000000;
		int tt = iDiv / 10 + 1;
		int iIdx = 9 - ( iDiv > 0 ? tt : 0 );
		iUpper += iDiv;
		
		string buffer = "" + iUpper + iIdx + iFriendID;
		return buffer;
	}
	
	private void LoadFromFile( CBasePlayer@ pPlayer, string SteamID )
	{
		if ( m_bIsSQL ) return;
		@player_data = g_FileSystem.OpenFile( "scripts/plugins/store/scrpg_" + ToSteamID64( SteamID ) + ".txt", OpenFile::READ );
		if ( player_data !is null && player_data.IsOpen() )
		{
			while( !player_data.EOFReached() )
			{
				string sLine;
				player_data.ReadLine( sLine );
				// Fix for linux
				string sFix = sLine.SubString( sLine.Length() - 1, 1 );
				if ( sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t" )
					sLine = sLine.SubString( 0, sLine.Length() - 1 );
				
				if ( sLine.SubString( 0, 1 ) == "#" || sLine.IsEmpty() )
					continue;
				
				array<string> parsed = sLine.Split(" ");
				if ( parsed.length() < 1 )
					continue;
				
				// SteamID compare
				if ( CheckConfigDefine( sFix, parsed[0], "stats" ) )
				{
					/*
						0 - stats
						1 - LEVEL
						2 - PRESTIGE
						3 - MONEY
						4 - EXP
						5 - EXPMAX
						6 - STAT_HEALTH
						7 - STAT_ARMOR
						8 - STAT_HEALTH_REGEN
						9 - STAT_ARMOMR_REGEN
						10 - STAT_AMMO
						11 - STAT_WEAPON
						12 - STAT_JUMP
						13 - STAT_AURA
						14 - STAT_HOLYARMOR
					*/
					if ( parsed.length() < 14 )
						continue;
					
					if ( InsertData_Begin( SteamID ) )
					{
						InsertData( sFix, SteamID, 1, parsed[1] );
						InsertData( sFix, SteamID, 2, parsed[2] );
						InsertData( sFix, SteamID, 3, parsed[3] );
						InsertData( sFix, SteamID, 4, parsed[4] );
						InsertData( sFix, SteamID, 5, parsed[5] );
						InsertData( sFix, SteamID, 6, parsed[6] );
						InsertData( sFix, SteamID, 7, parsed[7] );
						InsertData( sFix, SteamID, 8, parsed[8] );
						InsertData( sFix, SteamID, 9, parsed[9] );
						InsertData( sFix, SteamID, 10, parsed[10] );
						InsertData( sFix, SteamID, 11, parsed[11] );
						InsertData( sFix, SteamID, 12, parsed[12] );
						InsertData( sFix, SteamID, 13, parsed[13] );
						InsertData( sFix, SteamID, 14, parsed[14] );
					}
				}
				// Our achievement we have earned
				else if ( CheckConfigDefine( sFix, parsed[0], "achievement" ) )
					g_Achivements.GiveAchievement( pPlayer, parsed[ 1 ], false, atoi( parsed[ 2 ] ) );
			}
			m_bLoadedDB = true;
			player_data.Close();
		}
		else
			g_Game.AlertMessage(at_logged, "[SCRPG] Failed to load scrpg_" + ToSteamID64( SteamID ) + ".txt!\n");
	}
	
	private void SaveToFile( PlayerData@ data, bool backup = false )
	{
		if ( data is null ) return;
		string strBackup = "";
		if ( backup )
			strBackup = "-backup";
		string fileLoad = "scripts/plugins/store/scrpg_" + ToSteamID64( data.szSteamID ) + strBackup + ".txt";
		@player_data = g_FileSystem.OpenFile( fileLoad, OpenFile::WRITE );
		if ( player_data !is null && player_data.IsOpen() )
		{
			string output = "stats " + data.iLevel + " " + data.iPrestige + " "
			+ data.iSouls + " " + data.iExp + " " + data.iExpMax + " " + data.iStat_health
			+ " " + data.iStat_armor + " " + data.iStat_health_regen + " " + data.iStat_armor_regen + " "
			+ data.iStat_ammoregen + " " + data.iStat_explosiveregen + " " + data.iStat_doublejump + " "
			+ data.iStat_firstaid + " " + data.iStat_shockrifle + " " + data.bIsCommunity + " " + data.bIsDonator + "\n";
			
			// Add our achievements
			if ( data.hAchievements.length() > 0 )
			{
				output += "\n";
				for ( uint i = 0; i < data.hAchievements.length(); i++ )
				{
					CAchievement@ pAchievement = data.hAchievements[ i ];
					if ( pAchievement is null ) continue;
					output += "achievement " + pAchievement.GetID() + " " + pAchievement.GetCurrent() + "\n";
				}
			}
			
			player_data.Write( output );
			player_data.Close();
		}
		else
			g_Game.AlertMessage(at_logged, "[SCRPG] Failed to save " + fileLoad + "!\n");
	}
	
	private void SaveData( PlayerData@ data )
	{
		if ( data is null ) return;
		if ( m_bIsSQL )
		{
			// TODO
		}
		else
			SaveToFile( data );
	}
	
	private void CalculateLevelUp( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( data is null ) return;
		if ( data.iExp >= data.iExpMax )
			LevelUp( pPlayer, data );
		SaveData( data );
	}
		//Required XP / XP Needed
	private void RequiredEXP( PlayerData@ data )
	{
		if ( data is null ) return;
		float flLevelToEXPCalculation = float( data.iLevel ) * 5; //Was float( data.iLevel ) * 1500.0 * 8.5
		data.iExpMax = int( flLevelToEXPCalculation ) + data.iLevel;
	}
	
	private int CalculateBonusEXP( PlayerData@ data )
	{
		if ( data is null ) return 0;
		
		// Medal calculation - Medals made defunct, no longers scales stats or gives bonus XP
		//float flMedals = 0;
		//if ( data.iMedals > 0 )
		//	flMedals = data.iMedals; //Was 8, medals give +1 extra base XP per medal
		//int iMedalExp = 0; //Was int iMedalExp = int( flMedals );
		
		// Lets calculate
		if ( data.iPrestige > 0 )
		{
			float flPrestigeCalculate = float( data.iPrestige * 1 ); //Give bonus XP for each prestige | Was float( data.iPrestige / 0.1 ) * 500
			return int( flPrestigeCalculate ) + g_iWeeklyBonusEXP;
		}
		
		return g_iWeeklyBonusEXP;
	}
		//Give XP
	private void IncreaseEXP( PlayerData@ data )
	{
		if ( data is null ) return;
		float flLevelCalculate = 1; //Base XP
		int iCalculateEXP = int( flLevelCalculate ) + CalculateBonusEXP( data );
		
		// Set the calculated EXP.
		data.iExp += iCalculateEXP;
		if ( data.iWeekly_Exp_Max > 0 )
			data.iWeekly_Exp += iCalculateEXP;
	}
	
	private void DoPrestige( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		
		if ( data.iPrestige >= MAX_PRESTIGE )
		{
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[RPG MOD] You have hit the limit, you can no longer prestige!\n");
			return;
		}
		
		if ( data.iLevel < MAX_LEVEL )
		{
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[RPG MOD] You must be level " + MAX_LEVEL + " to prestige!\n");
			return;
		}
		
		// Reset level
		data.iLevel = 0;
		
		// Increase our prestige
		data.iPrestige++;
		
		// Reset skills
		ResetSkills( pPlayer );
		
		// Give 8k souls
		data.iSouls += 8000;
		
		// Calculate our EXP again
		RequiredEXP( data );
		
		// Play sound
		ClientSidedSound( pPlayer, SND_PRESTIGE );
		
		// Announce to everyone
		string szNick = pPlayer.pev.netname;
		string szVal = "st";
		if ( data.iPrestige > 1 )
			szVal = data.iPrestige > 2 ? "th" : "nd";
		g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[RPG MOD] " + szNick + " has prestiged for the " + data.iPrestige + szVal + " time!\n");
	}
	
	private void SetAuraGlow( bool state, CBasePlayer@ pPlayer, int red, int green, int blue )
	{
		if ( pPlayer is null ) return;
		pPlayer.pev.rendermode = kRenderNormal;
		pPlayer.pev.renderfx = state ? kRenderFxGlowShell : kRenderFxNone;
		pPlayer.pev.renderamt = state ? 4 : 255;
		pPlayer.pev.rendercolor = Vector( red, green, blue );
	}
	
	private void SetGodMode( CBasePlayer@ pPlayer, bool state )
	{
		if ( pPlayer is null ) return;
		if ( state )
		{
			if ( pPlayer.pev.flags & FL_GODMODE == 0 )
				pPlayer.pev.flags |= FL_GODMODE;
		}
		else
		{
			if ( pPlayer.pev.flags & FL_GODMODE > 0 )
				pPlayer.pev.flags &= ~FL_GODMODE;
		}
	}
	
	private bool IsGodMode( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return false;
		if ( pPlayer.pev.flags & FL_GODMODE > 0 ) return true;
		return false;
	}
	
	bool IsDonator( PlayerData@ data )
	{
		if ( data is null ) return false;
		return data.bIsDonator;
	}
	
	bool IsDonator( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return false;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			if ( data is null ) return false;
			return IsDonator( data );
		}
		return false;
	}
	
	void AddToCommunity( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			if ( data is null ) return;
			if ( data.bIsCommunity )
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "You are already a community member!\n");
				return;
			}
			data.bIsCommunity = true;
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "Welcome to the Server Community!\nCommunity bonus XP unlocked!\n");
			g_Achivements.GiveAchievement( pPlayer, "community", true );
			data.iCommunityEXP = 0; //Was 1
		}
	}
	
	//Admins
	bool IsAdministrators( CBasePlayer@ pPlayer, string SteamID )
	{

		//Chaotic Akantor
		//if ( SteamID == "STEAM_0:1:" )
		//	return true;
		// JonnyBoy0719 -- Creator of SCRPG
		if ( SteamID == "STEAM_0:1:24323838" )
			return true;
		// Dark4557
		if ( SteamID == "STEAM_0:1:8122893" )
			return true;
		AdminLevel_t adminLevel = g_PlayerFuncs.AdminLevel( pPlayer );
		if ( adminLevel >= ADMIN_YES )
			return true;
		return false;
	}
	
	private void GiveDonorWeapons( CBasePlayer@ pPlayer, string SteamID )
	{
		// Check donator
		if ( !IsDonator( pPlayer ) )
		{
			// Not donator, then check if we are an admin
			if ( !IsAdministrators( pPlayer, SteamID ) )
				return;
		}
		GiveToPlayer::GiveDonatorWeapons( pPlayer );
	}
	
	private void GiveSpecialWeapons( CBasePlayer@ pPlayer, string SteamID )
	{
		// Give Admin only weapons here
		if ( IsAdministrators( pPlayer, SteamID ) )
			//GiveToPlayer::GiveWeapon( pPlayer, "weapon_stormgiant" );
			//GiveToPlayer::GiveWeapon( pPlayer, "weapon_skull11" );
		
		// Give donor weapons
		GiveDonorWeapons( pPlayer, SteamID );
		
		// Prestige stuff
		if ( g_PlayerCoreData.exists( SteamID ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[SteamID]);
			GiveToPlayer::GivePrestiges( pPlayer, data );
		};
	}
	
	private void DisplaySkills( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			//if ( data.iPoints < 5 )					 //Commented out so that multiple skill spend menu is disabled
				g_SkillMenu.Show( pPlayer, data.iPoints );
			//else
			//	g_SkillMenuEx.Show( pPlayer, data.iPoints );
		}
	}
	
	private void DisplayShop( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		// TODO
	}
	
	private void ClearThinker()
	{
		if ( hThinker is null ) return;
		g_Scheduler.RemoveTimer( hThinker );
		@hThinker = @null;
	}
	
	private bool CheckConfigDefine( string szFullLine, string szLine, string szCompare )
	{
		// Just makin sure linux wont fuck
		szFullLine = szLine.SubString( szLine.Length() - 1, 1 );
		if ( szFullLine == " " || szFullLine == "\n" || szFullLine == "\r" || szFullLine == "\t" )
			szLine = szLine.SubString( 0, szLine.Length() - 1 );
		// Normal string compare
		if ( szLine == szCompare )
			return true;
		return false;
	}
	
	private void CheckCurrentDate()
	{
		DateTime date;
		/*
		g_Game.AlertMessage(at_logged, "[SCRPG] Current Day " + date.GetDayOfMonth() + "\n");
		string szCurrentDate = "" + date.GetYear() + "-" + date.GetMonth() + "-" + date.GetDayOfMonth();
		g_Game.AlertMessage(at_logged, "[SCRPG] Date: " + szCurrentDate + "\n");
		*/
		bool bNewWeek = false;
		@player_data = g_FileSystem.OpenFile( "scripts/plugins/store/scrpg_weekly.txt", OpenFile::READ );
		if ( player_data !is null && player_data.IsOpen() )
		{
			while( !player_data.EOFReached() )
			{
				string sLine;
				player_data.ReadLine( sLine );
				// Fix for linux
				string sFix = sLine.SubString( sLine.Length() - 1, 1 );
				if ( sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t" )
					sLine = sLine.SubString( 0, sLine.Length() - 1 );
				
				if ( sLine.SubString( 0, 1 ) == "#" || sLine.IsEmpty() )
					continue;
				
				array<string> parsed = sLine.Split(" ");
				if ( parsed.length() < 1 )
					continue;
				
				if ( CheckConfigDefine( sFix, parsed[0], "month" ) )
				{
					int SavedMonth = atoi( parsed[1] );
					int SavedDay = atoi( parsed[2] );
					if ( date.GetMonth() != SavedMonth )
						bNewWeek = true;
					if ( date.GetDayOfMonth() > SavedDay + 7 )
						bNewWeek = true;
				}
				
				if ( CheckConfigDefine( sFix, parsed[0], "bonusexp" ) )
					g_iWeeklyBonusEXP = atoi( parsed[1] );
			}
			player_data.Close();
		}
		else
			bNewWeek = true;
		
		if ( !bNewWeek ) return;
		
		g_iWeeklyBonusEXP = Math.RandomLong( 0, 0 ); //Was Math.RandomLong( 5500, 10650 ) Always Off for now
		
		@player_data = g_FileSystem.OpenFile( "scripts/plugins/store/scrpg_weekly.txt", OpenFile::WRITE );
		if ( player_data !is null && player_data.IsOpen() )
		{
			string output = "month " + date.GetMonth() + " " + date.GetDayOfMonth() + "\n";
			output += "bonusexp " + g_iWeeklyBonusEXP + "\n";
			player_data.Write( output );
			player_data.Close();
		}
	}
	
	string GetCurrentMap()
	{
		return string( g_Engine.mapname );
	}
	
	bool IsCurrentMap( string szMapName )
	{
		if ( szMapName.ToLowercase() == string(g_Engine.mapname).ToLowercase() )
			return true;
		return false;
	}
	
	void CheckMapDefines()
	{
		@player_data = g_FileSystem.OpenFile( "scripts/plugins/store/scrpg_mapdefines.txt", OpenFile::READ );
		if ( player_data !is null && player_data.IsOpen() )
		{
			bool bFounddefines = false;
			g_Game.AlertMessage(at_logged, "[SCRPG] Loading map defines for: " + GetCurrentMap() + "\n");
			while( !player_data.EOFReached() )
			{
				string sLine;
				player_data.ReadLine( sLine );
				// Fix for linux
				string sFix = sLine.SubString( sLine.Length() - 1, 1 );
				if ( sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t" )
					sLine = sLine.SubString( 0, sLine.Length() - 1 );
				
				if ( sLine.SubString( 0, 1 ) == "#" || sLine.IsEmpty() )
					continue;
				
				array<string> parsed = sLine.Split(" ");
				if ( parsed.length() < 1 )
					continue;
				
				if ( CheckConfigDefine( sFix, parsed[0], GetCurrentMap() ) )
				{
					bFounddefines = true;
					for ( uint i = 1; i < parsed.length(); i++ )
					{
						if ( CheckConfigDefine( sFix, parsed[ i ], "melee_only" ) )
						{
							g_Game.AlertMessage(at_logged, "\t>> melee_only has been applied!\n");
							g_MapDefined_MeleeOnly = true;
						}
					}
				}
			}
			if ( !bFounddefines )
				g_Game.AlertMessage(at_logged, "\t>> No defines found, skipping...\n");
			player_data.Close();
		}
		else
			g_Game.AlertMessage(at_logged, "[SCRPG] Failed to load scrpg_mapdefines.txt!\n");
		
		// After we checked map defines, check our date!
		CheckCurrentDate();
	}
	
	void CreateThinker()
	{
		@hThinker = @g_Scheduler.SetInterval( @this, "OnThink", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
	}
	
	void AdminGiveWeapon( CBasePlayer@ pPlayer, string szWeapon )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if ( IsAdministrators( pPlayer, szSteamId ) )
			pPlayer.GiveNamedItem( szWeapon );
	}
	
	void Reset()
	{
		g_PlayerCoreData.deleteAll();
		g_MapDefined_MeleeOnly = false;
		g_AuraIsActive = false;
		@player_data = null;
		ClearThinker();
	}
	
	void DoPlayerJump( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;
		if ( data.bOldButtonJump ) return;
		if ( data.iDoubleJump >= data.iStat_doublejump ) return;
		
		// If we are on the highest cap (or more)
		// Set our vel to 320 <~> 335
		if ( data.iStat_doublejump >= AB_DOUBLEJUMP_MAX )
			pPlayer.pev.velocity[2] = Math.RandomFloat( 320.0, 335.0 );
		else
			pPlayer.pev.velocity[2] = Math.RandomFloat( 265.0, 285.0 );
		
		data.bOldButtonJump = true;
		data.iDoubleJump++;
		ClientSidedSound( pPlayer, SND_JUMP );
	}
	
	void ShowAchievements( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if ( !g_PlayerCoreData.exists(szSteamId) ) return;
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if ( data is null ) return;
		
		// Show our challanges / achievements
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "Challenges:\n");
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "===================================================================\n");
		
		// Display them
		int iCompleted = g_Achivements.PrintList( pPlayer, data );
		
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\nYou have completed " + iCompleted + " out of " + g_Achivements.GetAmount() + " challenges.\n");
		
		// Print to chat
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "The challenges have been printed to the console!\n");
	}
	
	void ShowCommands( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		
		// Print to console
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "===================================================================\n");
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "RPG Mod Commands\n");
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "===================================================================\n\n");
		
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".shockrifle\n  Activates 'Shock Roach'\n");
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".firstaid\n  Activates 'First Aid'\n");
		
		if ( IsAdministrators( pPlayer, szSteamId ) )
		{
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n===================================================================\n\n");
			
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".give_weapon <classname>\n  Give yourself a weapon\n");
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".give_model <player> <model>\n  Give a player a model\n");
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".remove_model <player> <model>\n  Removes the model from the player\n");
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".set_model <player> <model> <special 0|1>\n  Sets the model of choice\n");
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, ".unset_model <player> <special 0|1>\n  Unsets the model of choice\n");
		}
		
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n===================================================================\n");
		
		// Print to chat
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "The commands have been printed to the console!\n");
	}
	
	void TryPrestige( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if ( !g_PlayerCoreData.exists(szSteamId) ) return;
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if ( data is null ) return;
		DoPrestige( pPlayer, data );
	}
	
	void LoadClientData( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		
		// Load from our File (Only loads if SQL is not enabled)
		LoadFromFile( pPlayer, szSteamId );
		
		// We exist!
		if ( !g_PlayerCoreData.exists(szSteamId) )
		{
			PlayerData data;
			data.szSteamID = szSteamId;
			g_PlayerCoreData[szSteamId] = data;
		}
		
		// Now load the data
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			RequiredEXP( data );
			SetMaxArmorHealth( pPlayer, data );
			SetArmorHealth( pPlayer, data );
			CalculatePoints( data );
			// Reset our specific values
			data.ResetOnJoin();
		}
	}
	
	void ResetSkills( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if ( !g_PlayerCoreData.exists(szSteamId) ) return;
		
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		
		// Reset everything
		data.iStat_health = data.iStat_health_regen = data.iStat_armor =
		data.iStat_armor_regen = data.iStat_ammoregen = data.iStat_explosiveregen =
		data.iStat_doublejump = data.iStat_firstaid = data.iStat_shockrifle = 0;
		SetMaxArmorHealth( pPlayer, data );
		
		// Recalculate our points
		CalculatePoints( data );
	}
	
	void PlayerSpawned( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			data.iWaitTimer_Hurt = 0;
			SetArmorHealth( pPlayer, data );
		}
		
		GiveSpecialWeapons( pPlayer, szSteamId );
	}
	
	void SaveClientData( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			SaveData( data );
		}
	}
	
	void PlayerIsHurt( CBasePlayer@ pPlayer )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			// We are in godmode
			if ( IsGodMode( pPlayer ) ) return;
			data.bIsHurt = true;
			data.iWaitTimer_Hurt = 5 - (data.iStat_health_regen + data.iStat_armor_regen) / 5; //Regen Delay Timer - Time to wait after taking damage before health and armor regen kicks in
			if ( data.iWaitTimer_Hurt_Snd == 0 )
			{
				data.iWaitTimer_Hurt_Snd = 1;
			}
		}
	}
	
	void DoSecret( CBasePlayer@ pPlayer, string szSecret )
	{
		if ( pPlayer is null ) return;
		if ( szSecret == "secret_postal" )
		{
			string szSound;
			switch( Math.RandomLong( 0, 3 ) )
			{
				case 0: szSound = "items/r_item1.wav"; break;
				case 1: szSound = "items/r_item1.wav"; break;
				case 2: szSound = "items/r_item1.wav"; break;
				case 3: szSound = "items/r_item1.wav"; break;
			}
			g_SCRPGCore.ClientSidedSound( pPlayer, szSound );
		}
		g_Achivements.GiveAchievement( pPlayer, szSecret, true );
	}
	
	void DoSoundEffect( CBasePlayer@ pPlayer, bool bIsMedicShout )
	{
		if ( pPlayer is null ) return;
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		
		if( g_PlayerCoreData.exists( szSteamId ) )
		{
			PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			if ( data.iWaitTimer_SndEffect == 0 )
			{
				SendClientCommand( pPlayer, bIsMedicShout ? "shockrifle\n" : "firstaid\n" );
				data.flWaitTimer_SndEffect_Delay = 0.07;	// Delay it
				data.bSndEffect = true;
				data.bSndEffectMedic = bIsMedicShout;
				data.iWaitTimer_SndEffect = 3;
			}
			
			// Shock Roach (Was Holy Armor) Skill cooldown and duration
			if ( bIsMedicShout && data.iStat_shockrifle > 0 )
			{
				if ( data.iWaitTimer_HolyArmor == data.iWaitTimer_HolyArmor_Max )
				{
					data.iWaitTimer_HolyArmor = 0;
					data.iWaitTimer_HolyArmor_Max = 240 - ( data.iStat_shockrifle + data.iPrestige * 1 ); //Shock Rifle Cooldown and reduction from skill
					data.iWaitTimer_HolyArmor_Reset = 1; //Duration till reset
					data.iDisplayTimer_SuperWeapon = data.iWaitTimer_HolyArmor_Max; //Set Display timer
					SetAuraGlow( true, pPlayer, 255, 0, 0 ); //Changed to RED
					ClientSidedSound( pPlayer, SND_HOLYGUARD );
					//string szNick = pPlayer.pev.netname;
					//g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[RPG MOD] " + szNick + " has equipped their Shock Rifle!\n");
						
					g_Achivements.GiveAchievement( pPlayer, "godsdoing", true );
				}
			}

			// First Aid (Was Battlecry) cooldown and duration
			else if ( data.iStat_firstaid > 0 )
			{
				if ( data.iWaitTimer_BattleCry == data.iWaitTimer_BattleCry_Max )
				{
					data.iWaitTimer_BattleCry = 0;
					data.iWaitTimer_BattleCry_Max = 60 - ( data.iStat_firstaid + data.iPrestige * 1 ); //Cooldown and reduction from skill
					data.iWaitTimer_BattleCry_Reset = 1; //Duration - Will constantly heal or revive if active
					data.iDisplayTimer_Aura = data.iWaitTimer_BattleCry_Max; //Set Display timer
					SetAuraGlow( true, pPlayer, 0, 255, 0 ); //Green
					string szSound;
					switch( Math.RandomLong( 0, 2 ) )
					{
						case 0: szSound = SND_AURA01; break;
						case 1: szSound = SND_AURA02; break;
						case 2: szSound = SND_AURA03; break;
					}
					g_AuraIsActive = true;
					ClientSidedSound( pPlayer, szSound );
					//string szNick = pPlayer.pev.netname;
					//g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[RPG MOD] " + szNick + " has activated their First Aid!\n");
					
					g_Achivements.GiveAchievement( pPlayer, "warriorinside", true );
				}
			}
		}
	}
	
	void SendClientCommand( CBasePlayer@ pPlayer, string szCommand )
	{
		if ( pPlayer is null ) return;
		NetworkMessage m( MSG_ONE, NetworkMessages::NetworkMessageType(9), pPlayer.edict() );
			m.WriteString( szCommand );
		m.End();
	}
	
	void ClientSidedSound( CBasePlayer@ pPlayer, string szSound )
	{
		if ( pPlayer is null ) return;
		SendClientCommand( pPlayer, "spk \"" + szSound + "\"\n" );
	}
	
	void ShowMenu( CBasePlayer@ pPlayer, MenuEnum eMenu )
	{
		switch( eMenu )
		{
			case MENU_SKILLS: DisplaySkills( pPlayer ); break;
			case MENU_SHOP: DisplayShop( pPlayer ); break;
		}
	}
}
CSCRPGCore@ g_SCRPGCore;

#include "lib/populate_skills"
#include "lib/populate_weapondrop"

void LoadRPGCore()
{
	if ( g_SCRPGCore !is null )
	{
		g_SCRPGCore.Reset();
		@g_SCRPGCore = null;
	}

	CSCRPGCore core();
	@g_SCRPGCore = @core;
	
	// Add stuff into our menu!
	Populate::PopulateSkills();
	
	// Add stuff into our weapon drop
	Populate::PopulateWeaponDrop();
	
	// Load our achievements
	Populate::PopulateAchievements();
}
