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
    g_Game.PrecacheModel("sprites/fexplo1.spr");
    g_SoundSystem.PrecacheSound("weapons/explode3.wav");
    g_SoundSystem.PrecacheSound("common/wpn_hudon.wav");
    
    // Gib-related precaches
    g_Game.PrecacheModel("models/hgibs.mdl");
    g_SoundSystem.PrecacheSound("common/bodysplat.wav");
	g_Game.PrecacheModel("models/blkop_apache.mdl");
	g_Game.PrecacheModel("models/apache.mdl");
	g_Game.PrecacheModel("models/HVR.mdl");
	g_Game.PrecacheModel("sprites/white.spr");
	g_Game.PrecacheModel("sprites/fexplo.spr");
	g_Game.PrecacheModel("models/metalplategibs_green.mdl");
	g_Game.PrecacheMonster("monster_apache", true);
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


CBaseEntity@ SpawnNPC(CBasePlayer@ pPlayer, string npc_name, float size = 1.0f) {
    if(pPlayer is null)
        return null;
    
    // Get player's position and offset it further forward and up for larger entities
    Vector spawnPos = pPlayer.pev.origin;
    
    // Increase offset distances, especially for apache
    float forwardDist = (npc_name.ToLowercase() == "monster_apache") ? 100.0f : 50.0f;
    float upDist = (npc_name.ToLowercase() == "monster_apache") ? 100.0f : 30.0f;
    
    Vector forwardOffset = g_Engine.v_forward * forwardDist;
    Vector upOffset = Vector(0, 0, upDist);
    spawnPos = spawnPos + forwardOffset + upOffset;

    // Create npc with adjusted position
    dictionary keys;
    keys["origin"] = spawnPos.ToString();
    keys["angles"] = pPlayer.pev.angles.ToString();
    keys["spawnflags"] = "1"; // Start active
    keys["classname"] = npc_name;
    
    CBaseEntity@ npc = g_EntityFuncs.CreateEntity(npc_name, keys, true);
    
    if(npc !is null) {
       // Set visual size
        npc.pev.scale = size;
        
        // Apply size scaling to bounds
        npc.pev.mins = Vector(-2, -2, 0);
        npc.pev.maxs = Vector(2, 2, 3);
        
        // Set new collision bounds
        g_EntityFuncs.SetSize(npc.pev, npc.pev.mins, npc.pev.maxs);

        // Cast to monster for monster-specific settings
        CBaseMonster@ monster = cast<CBaseMonster@>(npc);
        if(monster !is null) {
            monster.SetClassification(CLASS_PLAYER_ALLY);
            monster.StartPlayerFollowing(pPlayer, false);
            monster.SetPlayerAlly(true);
        }
        
        npc.pev.targetname = "pet_npc_" + pPlayer.entindex();
    }
    
    return npc;
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
			if(data.iPrestige == 0)
			{
				if(!data.bIsUsingSpecialRounds)
				{
					CBaseEntity@ npc = SpawnNPC(pPlayer,"monster_apache",0.1);
					if(npc !is null) {
						g_Game.AlertMessage(at_console, "Spawned friendly npc for player\n");
					}
					//if(pWeapon.GetClassname() == "weapon_shotgun" || pWeapon.GetClassname() == "weapon_357" || pWeapon.GetClassname() == "weapon_m249")
					
					data.bIsUsingSpecialRounds = true;
					data.sSpecialWeapon = pWeapon.GetClassname(); // Only current weapon allowed to use special rounds
					data.iSpecialRoundsCount = pWeapon.iMaxClip(); // The max number of rounds in this weapon's magazine is the number of special rounds
					int currentAmmo = pWeapon.m_iClip;
					pWeapon.m_iClip = 0; // Set current magazine round count to zero
					pPlayer.m_rgAmmo(pWeapon.m_iPrimaryAmmoType, pPlayer.m_rgAmmo(pWeapon.m_iPrimaryAmmoType) + currentAmmo); // Return ammo to reserve
					
					// Force reload
					pWeapon.Reload(); 
					pWeapon.FinishReload(); 
					
					// Notify player of mode change
					g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "Special rounds activated\n"); 
						
					// // Play toggle sound
					g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_WEAPON, "common/wpn_hudon.wav", 1.0f, ATTN_NORM, 0, 100);
					
				}
			}
		}
	}
    
    return HOOK_CONTINUE;
}

HookReturnCode OnWeaponPrimaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon) 
{
    if (pWeapon is null || pPlayer is null) return HOOK_CONTINUE;
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if( g_PlayerCoreData.exists( szSteamId ) )
	{
		PlayerData@ data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
		if(data !is null)
		{
			// Check if the current weapon is holding special rounds
			if (pWeapon.GetClassname() == data.sSpecialWeapon)  
			{
				if(data.iSpecialRoundsCount > 0)
				{
					int roundsCount = data.iSpecialRoundsCount-1;
					g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "Special rounds count: "+ roundsCount +"\n");
					
					// Reduce amount of special rounds
					data.iSpecialRoundsCount--;
					
					// Special rounds for shotgun and revolver
					//if(pWeapon.GetClassname() == "weapon_shotgun" || pWeapon.GetClassname() == "weapon_357" || pWeapon.GetClassname() == "weapon_m249")
					
					// Get player's view angles and position
					Vector vecSrc = pPlayer.GetGunPosition();
					Vector vecAiming = pPlayer.GetAutoaimVector(0.0f);
					
					// Create tracer effect for visual feedback
					NetworkMessage tracers(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY);
					tracers.WriteByte(TE_TRACER); //entity effect used?
					tracers.WriteCoord(vecSrc.x); //X vel
					tracers.WriteCoord(vecSrc.y); //Y vel
					tracers.WriteCoord(vecSrc.z); //Z vel
					tracers.WriteCoord(vecSrc.x + vecAiming.x * 4096);
					tracers.WriteCoord(vecSrc.y + vecAiming.y * 4096);
					tracers.WriteCoord(vecSrc.z + vecAiming.z * 4096);
					tracers.End();
					
					// Trace line at 
					TraceResult tr;
					g_Utility.TraceLine(vecSrc, vecSrc + vecAiming * 4096, dont_ignore_monsters, pPlayer.edict(), tr);
						
					//Add | DMG_ALWAYSGIB | DMG_NEVERGIB after damage type to enable/disable gibbing
					//RadiusDamage(const Vector& in vecSrc, entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, float flRadius, int iClassIgnore, int bitsDamageType)
					//g_EntityFuncs.CreateExplosion(tr.vecEndPos, Vector(0, 0, 0), null, 100, false);
					g_WeaponFuncs.RadiusDamage(tr.vecEndPos, pWeapon.pev, pPlayer.pev, 100.0f, 200.0f, CLASS_NONE, DMG_BLAST | DMG_ALWAYSGIB);

				}
				else
				{
					data.bIsUsingSpecialRounds = !data.bIsUsingSpecialRounds;
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
