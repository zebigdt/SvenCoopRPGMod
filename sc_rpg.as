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
	g_SCRPGCore.CreateThinker();
	g_SCRPGCore.CheckMapDefines();
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "JonnyBoy0719" );
	g_Module.ScriptInfo.SetContactInfo( "https://twitter.com/JohanEhrendahl" );
	
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @RPGMOD_PlayerSpawn );
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @RPGMOD_PlayerKilled );
	g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @RPGMOD_PlayerTakeDamage );
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @RPGMOD_ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @RPGMOD_ClientDisconnect );
	g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @RPGMOD_PlayerPostThink );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @RPGMOD_ClientSay );

	g_Hooks.RegisterHook(Hooks::Weapon::WeaponPrimaryAttack, @OnWeaponPrimaryAttack);
	g_Hooks.RegisterHook(Hooks::Weapon::WeaponSecondaryAttack, @OnWeaponSecondaryAttack);
	g_Hooks.RegisterHook(Hooks::Weapon::WeaponTertiaryAttack, @OnWeaponTertiaryAttack);
	
	//DifficultySettings_RegisterHooks();
	
	//Disable survival mode
	//g_EngineFuncs.ServerCommand( "mp_survival_mode 0\n" );
	//g_EngineFuncs.ServerCommand( "mp_survival_voteallow 0\n" );
	//g_EngineFuncs.ServerCommand( "mp_survival_minplayers 90\n" );
}

HookReturnCode RPGMOD_PlayerSpawn(CBasePlayer@ pPlayer)
{
	g_SCRPGCore.PlayerSpawned( pPlayer );
	return HOOK_CONTINUE;
}

HookReturnCode RPGMOD_PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
	g_Achivements.GiveAchievement( pPlayer, "endyourlife", true );
	return HOOK_CONTINUE;
}

HookReturnCode RPGMOD_PlayerTakeDamage( DamageInfo@ pDamageInfo )
{
	if ( pDamageInfo.pVictim !is null )
	{
		CBasePlayer@ pPlayer = cast<CBasePlayer@>(pDamageInfo.pVictim);
		if ( pPlayer !is null && pPlayer.IsAlive() )
			g_SCRPGCore.PlayerIsHurt( pPlayer );
	}
	return HOOK_CONTINUE;
}

HookReturnCode RPGMOD_ClientPutInServer(CBasePlayer@ pPlayer)
{
	g_SCRPGCore.LoadClientData( pPlayer );
	return HOOK_CONTINUE;
}

HookReturnCode RPGMOD_ClientDisconnect(CBasePlayer@ pPlayer)
{
	g_SCRPGCore.SaveClientData( pPlayer );
	return HOOK_CONTINUE;
}

HookReturnCode RPGMOD_PlayerPostThink( CBasePlayer@ pPlayer )
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

bool IsNithil( const CCommand@ args )
{
	//I'm Nihilanths slave
	//Im Nihilanths slave
	string arg1 = args.Arg(1).ToLowercase();
	string arg2 = args.Arg(2).ToLowercase();
	string arg3 = args.Arg(3).ToLowercase();
	if ( arg1 == "i'm" || arg1 == "im" )
	{
		if ( arg2 != "nihilanths" ) return false;
		if ( arg3 != "slave" ) return false;
		return true;
	}
	return false;
}

HookReturnCode RPGMOD_ClientSay( SayParameters@ pParams )
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
	
	// Secret stuff
	if ( IsValidMenu( args.Arg(0), "praise" ) )
	{
		string arg1 = args.Arg(1);
		if ( IsValidPraise( arg1, "slave" ) )
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "Once a slave, always a slave.\n");
		else if ( IsValidPraise( arg1, "nihilanth" ) )
		{
			string szMsg;
			switch( Math.RandomLong( 0, 1 ) )
			{
				case 0: szMsg = "- .... .  .- -. ... .-- . .-.	.. ...	.-- .. - .... .. -.	-.-- --- ..- .-.	--. .-. .- ... .--. --··--	 ..-. .. -. -..	 - .... .	--- -. .	-.-- --- ..-	... . . -.-	.-- .. - ....	- .... . .. .-.	. -..- .. ... - . -. -.-. .	.. -. - .- -.-. -"; break;
				case 1: szMsg = ". -..- .. ... - . -. -.-. . --··--	.. ...	 -- -.-- - .... ·-·-·-	 - .... .	-- -.-- - ....	 .. ...	 . -..- .. ... - . -. -.-. . ·-·-·-  -.-- . -	-... --- - ....	-.-. .- -. -. --- -	. -..- .. ... -	.. ..-.	-. --- - .... .. -. --.	.. ...	.-. . .- .-.. ·-·-·-"; break;
			}
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, szMsg + "\n");
		}
		else if ( IsValidPraise( arg1, "truth" ) )
		{
			string szMsg;
			switch( Math.RandomLong( 0, 1 ) )
			{
				case 0: szMsg = "..	... . .	- .... .	- .-. ..- - .... --··--	-... ..- -	..	 ... - .. .-.. .-..	 -.-. .- -. ·----· -	.-. . .- -.-. ....	.. -"; break;
				case 1: szMsg = "..	-.-. .- -. -. --- -	..-. .. -. -..	 - .... .	. -..- .. ... - . -. -.-. .	..	 -. . . -.."; break;
			}
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, szMsg + "\n");
		}
		else if ( IsValidPraise( arg1, "real" ) )
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "..	.- --	- .... .	... .-.. .- ...- .	 --- ..-.	-. .. .... .. .-.. .- -. - ....\n");
		else if ( IsValidPraise( arg1, "exist" ) || IsValidPraise( arg1, "existence" ) )
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, ".. ·----· --	 -. .. .... .. .-.. .- -. - .... ·----· ...	 ... .-.. .- ...- . -·-·--\n");
		else if ( IsNithil( args ) )
			g_SCRPGCore.DoSecret( pPlayer, "secret1" );
		else
		{
			string szMsg;
			switch( Math.RandomLong( 0, 6 ) )
			{
				case 0: szMsg = "The truth. Hidden, beneath the old. By seeking thy code, your salvation will be within your grasp."; break;
				case 1: szMsg = "One who sees, will open the gates, for thy who cannot."; break;
				case 2: szMsg = "The Old. The New. The Future. All the same, but you, you see only black."; break;
				case 3: szMsg = "Obey the unknown, for he is your new salvation."; break;
				case 4: szMsg = "Alone. Decived. Thy who demand, will not. Thy who shall, will. Hidden, but not gone. Forgotten is what he is."; break;
				case 5: szMsg = "Thy slave, must do as told. If not, thy shall never see blessing."; break;
				case 6: szMsg = "The path to salvation, is thy sentence of existence. You may not need to use thy givings to bring you salvation."; break;
			}
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, szMsg + "\n");
		}
		
		string szSound;
		switch( Math.RandomLong( 0, 3 ) )
		{
			case 0: szSound = "nihilanth/nil_deceive.wav"; break;
			case 1: szSound = "nihilanth/nil_alone.wav"; break;
			case 2: szSound = "nihilanth/nil_thetruth.wav"; break;
			case 3: szSound = "nihilanth/nil_man_notman.wav"; break;
		}
		g_SCRPGCore.ClientSidedSound( pPlayer, szSound );
		return HOOK_HANDLED;
	}
	else if ( IsValidMenu( args.Arg(0), "postal" ) )
	{
		g_SCRPGCore.DoSecret( pPlayer, "secret_postal" );
		return HOOK_HANDLED;
	}
	return HOOK_CONTINUE;
}
