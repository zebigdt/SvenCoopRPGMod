#include "include_rpg"
#include "scrpg_core"
#include "difficulty_settings"

CClientCommand c_rpgmod_medic( "shockrifle", "", @CVAR_MedicSound );
CClientCommand c_rpgmod_grenade( "firstaid", "", @CVAR_GrenadeSound );
CClientCommand c_rpgmod_give_weapon( "give_weapon", "<classname>", @CVAR_GiveWeapon );

void CVAR_MedicSound( const CCommand@ args )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	if ( pPlayer is null ) return;
	g_SCRPGCore.DoSoundEffect( pPlayer, true );
}

void CVAR_GrenadeSound( const CCommand@ args )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	if ( pPlayer is null ) return;
	g_SCRPGCore.DoSoundEffect( pPlayer, false );
}

void CVAR_GiveWeapon( const CCommand@ args )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	if ( pPlayer is null ) return;
	g_SCRPGCore.AdminGiveWeapon( pPlayer, args[ 1 ] );
}

void LoadImportantStuff()
{
	LoadRPGCore();
	
	if ( g_DifficultySettings !is null )
	{
		g_DifficultySettings.Clear();
		@g_DifficultySettings = null;
	}
	
	DifficultySettings DifficultySettings();
	@g_DifficultySettings = @DifficultySettings;
	g_Scheduler.SetTimeout( @g_DifficultySettings, "DifficultySettingsCheck", 5.0 );
}

void MapInit()
{
	LoadImportantStuff();
	RegisterAllWeapons();
	g_DifficultySettings.Clear();
	g_SCRPGCore.Reset();
	g_SCRPGCore.CheckMapDefines();
	g_SCRPGCore.CreateThinker();



	// Precache explosion sprites and sounds - Needs to be done in a function seperately.
    g_Game.PrecacheModel("sprites/zerogxplode.spr");
    g_SoundSystem.PrecacheSound("weapons/explode3.wav");
    g_SoundSystem.PrecacheSound("buttons/lightswitch2.wav");
    
    // Gib-related precaches
    g_Game.PrecacheModel("models/hgibs.mdl");
    g_SoundSystem.PrecacheSound("common/bodysplat.wav");
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "JonnyBoy0719" );
	g_Module.ScriptInfo.SetContactInfo( "https://twitter.com/JohanEhrendahl" );
	
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
	g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage );
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
	g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );

	g_Hooks.RegisterHook(Hooks::Weapon::WeaponPrimaryAttack, @OnWeaponPrimaryAttack);
	//g_Hooks.RegisterHook(Hooks::Weapon::WeaponSecondaryAttack, @OnWeaponSecondaryAttack);
	g_Hooks.RegisterHook(Hooks::Weapon::WeaponTertiaryAttack, @OnWeaponTertiaryAttack);
	
	//DifficultySettings_RegisterHooks();
	
	//Disable survival mode
	//g_EngineFuncs.ServerCommand( "mp_survival_mode 0\n" );
	//g_EngineFuncs.ServerCommand( "mp_survival_voteallow 0\n" );
	//g_EngineFuncs.ServerCommand( "mp_survival_minplayers 90\n" );
}

HookReturnCode OnWeaponTertiaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon) 
{
    if (pWeapon is null || pPlayer is null)
        return HOOK_CONTINUE;

	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if( g_PlayerCoreData.exists( szSteamId ) )
	{
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if(data !is null)
		{
			if(data.iPrestige == 1)
			{
				// Only handle shotgun tertiary attack
				if (pWeapon.GetClassname() == "weapon_shotgun" ) 
				{
					string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
					
					// Toggle mode
					data.bExplosiveRounds = !data.bExplosiveRounds;
					
					// Notify player of mode change																		//true      //false
					g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "Explosive rounds: " + (data.bExplosiveRounds ? "ENABLED" : "DISABLED") + "\n");
						
					// Play toggle sound
					g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_WEAPON, "buttons/lightswitch2.wav", 1.0f, ATTN_NORM, 0, 100);
				}
			}
		}
	}
    
    return HOOK_CONTINUE;
}

HookReturnCode OnWeaponPrimaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon) 
{
    if (pWeapon is null || pPlayer is null)
        return HOOK_CONTINUE;

	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if( g_PlayerCoreData.exists( szSteamId ) )
	{
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if(data !is null)
		{
			// Check if weapon is shotgun
			if (pWeapon.GetClassname() == "weapon_shotgun" )  
			{
				string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
				
				// Only create explosion if explosive mode is enabled for this player
				if (data.bExplosiveRounds) 
				{
					// Get player's view angles and position
					Vector vecSrc = pPlayer.GetGunPosition();
					Vector vecAiming = pPlayer.GetAutoaimVector(0.0f);
					
					// Create tracer effect for visual feedback
					NetworkMessage tracers(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY);
					tracers.WriteByte(TE_TRACER);
					tracers.WriteCoord(vecSrc.x);
					tracers.WriteCoord(vecSrc.y);
					tracers.WriteCoord(vecSrc.z);
					tracers.WriteCoord(vecSrc.x + vecAiming.x * 4096);
					tracers.WriteCoord(vecSrc.y + vecAiming.y * 4096);
					tracers.WriteCoord(vecSrc.z + vecAiming.z * 4096);
					tracers.End();
					
					// Create explosion at impact point
					TraceResult tr;
					g_Utility.TraceLine(vecSrc, vecSrc + vecAiming * 4096, dont_ignore_monsters, pPlayer.edict(), tr);
					
					// Create explosion with enhanced visual effect
					g_EntityFuncs.CreateExplosion(tr.vecEndPos, Vector(0, 0, 0), null, 100, true);
					
					// Apply radius damage with combined damage flags for guaranteed gibbing
					// DMG_ALWAYSGIB ensures gibbing regardless of damage
					// DMG_BLAST | DMG_NEVERGIB removed as they could interfere with gibbing
					g_WeaponFuncs.RadiusDamage(
						tr.vecEndPos,   //damage position
						pWeapon.pev,    //inflictor
						pPlayer.pev,    //attacker
						2.0f,       //damage amount
						100.0f,     //radius
						CLASS_NONE, //classification
						DMG_ACID //damage type
					);
				}
			}
		}
	}

	
    
    return HOOK_CONTINUE;
}


HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{
	g_SCRPGCore.PlayerSpawned( pPlayer );
	return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
	g_Achivements.GiveAchievement( pPlayer, "endyourlife", true );
	return HOOK_CONTINUE;
}

HookReturnCode PlayerTakeDamage( DamageInfo@ pDamageInfo )
{
	if ( pDamageInfo.pVictim !is null )
	{
		CBasePlayer@ pPlayer = cast<CBasePlayer@>(pDamageInfo.pVictim);
		if ( pPlayer !is null && pPlayer.IsAlive() )
			g_SCRPGCore.PlayerIsHurt( pPlayer );
	}
	return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
{
	g_SCRPGCore.LoadClientData( pPlayer );
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer)
{
	g_SCRPGCore.SaveClientData( pPlayer );
	return HOOK_CONTINUE;
}

HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer )
{
	if ( pPlayer is null ) return HOOK_CONTINUE;
	if ( !pPlayer.IsAlive() ) return HOOK_CONTINUE;
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if( g_PlayerCoreData.exists( szSteamId ) )
	{
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if ( data.flWaitTimer_SndEffect_Delay <= 0.0 && data.bSndEffect )
		{
			data.bSndEffect = false;
		}
		else
			data.flWaitTimer_SndEffect_Delay -= 0.01;
		
		if ( data.bReopenSkills )
		{
			g_SCRPGCore.ShowMenu( pPlayer, MENU_SKILLS );
			data.bReopenSkills = false;
		}
		
		string output;
		// Are we jumping? (Make sure we are not on the ground first)
		if ( pPlayer.pev.flags & FL_ONGROUND == 0 )
		{
			if ( pPlayer.pev.button & IN_JUMP != 0 )
			{
				// Don't spam this
				if ( !data.bHasJumped )
				{
					data.bHasJumped = true;
					data.bOldButtonJump = true;
				}
				else
					g_SCRPGCore.DoPlayerJump( pPlayer, data );
			}
			else
			{
				if ( data.bOldButtonJump )
					data.bOldButtonJump = false;
			}
		}
		else
		{
			if ( data.iDoubleJump > 0 )
			{
				g_SCRPGCore.ClientSidedSound( pPlayer, SND_JUMP_LAND );
				data.iDoubleJump = 0;
			}
			if ( data.bHasJumped )
				data.bHasJumped = false;
		}
	}
	return HOOK_CONTINUE;
}

bool IsValidMenu( string input, string val )
{
	string szTmp = "!" + val;
	if ( input == szTmp ) return true;
	szTmp = "/" + val;
	if ( input == szTmp ) return true;
	return false;
}

bool IsValidChatCommand( string input, string val )
{
	if ( input == val ) return true;
	string szTmp = "!" + val;
	if ( input == szTmp ) return true;
	szTmp = "/" + val;
	if ( input == szTmp ) return true;
	return false;
}

bool IsValidRewards( string input )
{
	if ( IsValidMenu( input, "challenges" ) ) return true;
	if ( IsValidMenu( input, "rewards" ) ) return true;
	if ( IsValidMenu( input, "progress" ) ) return true;
	if ( IsValidMenu( input, "achievements" ) ) return true;
	return false;
}

bool IsValidPraise( string input, string val )
{
	if ( input == val ) return true;
	return false;
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	if ( pPlayer is null ) return HOOK_CONTINUE;
	const CCommand@ args = pParams.GetArguments();
	
	// Menu
	if ( IsValidMenu( args.Arg(0), "skills" ) )
		g_SCRPGCore.ShowMenu( pPlayer, MENU_SKILLS );
	else if ( IsValidMenu( args.Arg(0), "shop" ) )
		g_SCRPGCore.ShowMenu( pPlayer, MENU_SHOP );
	
	// stuff
	if ( IsValidMenu( args.Arg(0), "reset" ) )
		g_SCRPGCore.ResetSkills( pPlayer );
	else if ( IsValidMenu( args.Arg(0), "prestige" ) )
		g_SCRPGCore.TryPrestige( pPlayer );
	else if ( IsValidMenu( args.Arg(0), "community" ) )
		g_SCRPGCore.AddToCommunity( pPlayer );
	else if ( IsValidMenu( args.Arg(0), "rpg" ) )
		g_SCRPGCore.ShowCommands( pPlayer );
	else if ( IsValidRewards( args.Arg(0) ) )
		g_SCRPGCore.ShowAchievements( pPlayer );
	else if ( IsValidChatCommand( args.Arg(0), "shockrifle" ) )
	{
		g_SCRPGCore.DoSoundEffect( pPlayer, true );
		return HOOK_HANDLED;
	}
	else if ( IsValidChatCommand( args.Arg(0), "firstaid" ) )
	{
		g_SCRPGCore.DoSoundEffect( pPlayer, false );
		return HOOK_HANDLED;
	}

	return HOOK_CONTINUE;
}
