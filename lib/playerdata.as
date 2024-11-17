// PlayerData
dictionary g_PlayerCoreData;
class PlayerData
{
	array<CAchievement@> hAchievements;	// Our achievements
	array<CPlayerModelBase@> hAvailableModels;	// Our models
	
	// Our saved SteamID
	string szSteamID;
	
	// Player stats
	int iLevel = 0;						// Level
	int iPoints = 0;					// Skill Points
	int iPrestige = 0;					// Prestige
	int iSouls = 0;						// Money (Unused)
	int iStat_health = 0;				// Vitality (Max Health)
	int iStat_health_regen = 0;			// Health Regeneration
	int iStat_armor = 0;				// Superior Armor (Max Armor)
	int iStat_armor_regen = 0;			// Nano Armor (Armor Regeneration)
	int iStat_ammoregen = 0;			// The Magic Pocket (Ammo Resupply)
	int iStat_explosiveregen = 0;			// A Gift From The Gods (Explosives Resupply)
	int iStat_doublejump = 0;			// Icarus Potion (Extra Jumps)
	int iStat_firstaid = 0;			// The Warrior's Battlecry (Heal Aura)
	int iStat_shockrifle = 0;			// Holy Armor (Shock Roach)
	
	int iDoubleJump = 0;				// Extra Jumps value
	
	int iScore = 0;						// Score
	int iExp = 0;						// EXP
	int iExpMax = 0;					// Max EXP
	
	int iMedals = 0;					// Medals - Unused
	
	string szModel = "null";			// Our model
	string szModelSpecial = "null";		// Special model (only the player can pick this)
	
	// Weekly stuff
	int iWeekly_Exp = 0;				// Special Weekly EXP bonus
	int iWeekly_Exp_Max = 0;			// Max CAP for Special Weekly EXP bonus

	//Community Member Bonus XP
	int iCommunityEXP = 0;
	
	//First Load Initialise
	int iWaitTimer_FreeEXP = 600;		// Free XP Timer
	int iWaitTimer_Hurt = 0;
	int iWaitTimer_Hurt_Snd = 0;		// We don't want to spam this
	int iWaitTimer_SndEffect = 0;		// We don't want to spam this
	int iWaitTimer_UseModel = 3;
	int iWaitTimer_AmmoDrop = 5;		// First Ammo Resupply
	int iWaitTimer_WeaponDrop = 10;	// First Explosive Drop

	int iWaitTimer_HolyArmor = 0;
	int iWaitTimer_HolyArmor_Max = 10;	// Super Weapon Cooldown
	int iWaitTimer_HolyArmor_Reset = -1;
	int iWaitTimer_BattleCry = 0;
	int iWaitTimer_BattleCry_Max = 5;	// Heal Aura Cooldown
	int iWaitTimer_BattleCry_Reset = -1;

	int iDisplayTimer_Aura = iWaitTimer_BattleCry_Max;
	int iDisplayTimer_SuperWeapon = iWaitTimer_HolyArmor_Max;
	int iDisplayTimer_AmmoDrop = iWaitTimer_AmmoDrop;
	int iDisplayTimer_WeaponDrop = iWaitTimer_WeaponDrop;
	
	float flWaitTimer_SndEffect_Delay = 0;
	
	// Misc
	bool bIsHurt = false;
	bool bSndEffect = false;
	bool bSndEffectMedic = false;
	bool bReopenSkills = false;
	bool bHasJumped = false;
	bool bOldButtonJump = false;
	
	// Community stuff
	bool bIsCommunity = false;
	bool bIsDonator = false;
	
	//These timers will be used if reconnected.
	void ResetOnJoin()
	{
		bIsHurt = false;
		bSndEffect = false;
		bSndEffectMedic = false;
		bReopenSkills = false;
		bHasJumped = false;
		bOldButtonJump = false;
		bIsCommunity = false;
		bIsDonator = false;
		
		flWaitTimer_SndEffect_Delay = 0;
		
		iWaitTimer_FreeEXP = 300;
		iWaitTimer_Hurt = 0;
		iWaitTimer_Hurt_Snd = 0;
		iWaitTimer_SndEffect = 0;
		iWaitTimer_UseModel = 3;
		//iWaitTimer_AmmoDrop = 90;
		//iWaitTimer_WeaponDrop = 300;
		//iWaitTimer_HolyArmor = 0;
		//iWaitTimer_HolyArmor_Max = 300;
		//iWaitTimer_HolyArmor_Reset = -1;
		//iWaitTimer_BattleCry = 0;
		//iWaitTimer_BattleCry_Max = 120;
		//iWaitTimer_BattleCry_Reset = -1;
		
		iWeekly_Exp = 0;
		iWeekly_Exp_Max = 0;
	}
	
	bool FindAchievement( string szID )
	{
		for ( uint i = 0; i < hAchievements.length(); i++ )
		{
			CAchievement@ pAchievement = hAchievements[ i ];
			if ( pAchievement is null ) continue;
			if ( pAchievement.GetID() == szID ) return true;
		}
		return false;
	}
	
	int GetCurrentAchievementProgress( string szID )
	{
		for ( uint i = 0; i < hAchievements.length(); i++ )
		{
			CAchievement@ pAchievement = hAchievements[ i ];
			if ( pAchievement is null ) continue;
			if ( pAchievement.GetID() == szID ) return pAchievement.GetCurrent();
		}
		return 0;
	}
	
	bool CanGiveAchievement( string szID )
	{
		for ( uint i = 0; i < hAchievements.length(); i++ )
		{
			CAchievement@ pAchievement = hAchievements[ i ];
			if ( pAchievement is null ) continue;
			if ( pAchievement.GetID() == szID )
				return pAchievement.CanGiveAch();
		}
		return false;
	}
	
	bool AddAchievement( CAchievement@ pAchievement, string szID, int iCurrent )
	{
		if ( pAchievement is null ) return false;
		if ( !FindAchievement( szID ) )
		{
			CAchievement @pAch = CAchievement( pAchievement.GetID(), pAchievement.GetName(), pAchievement.GetDescription(), pAchievement.GetMedals(), pAchievement.GetEXP(), pAchievement.GetMoney(), pAchievement.GetMax(), pAchievement.IsSecret() );
			if ( iCurrent > 0 )
				pAch.SetCurrent( iCurrent );
			hAchievements.insertLast( @pAch );
		}
		return CanGiveAchievement( szID );
	}
	
	private int CanAddPlayerModel( CPlayerModelBase@ pModel )
	{
		if ( pModel is null ) return -1;
		if ( hAvailableModels.findByRef( @pModel ) != -1 ) return 0;
		hAvailableModels.insertLast( @pModel );
		return 1;
	}
	
	int AddPlayerModel( string szModel )
	{
		for ( uint i = 0; i < g_LoadedPlayerModels.length(); i++ )
		{
			CPlayerModelBase@ model = @g_LoadedPlayerModels[ i ];
			if ( model is null ) continue;
			if ( model.GetModel() == szModel ) return CanAddPlayerModel( model );
		}
		return -1;
	}
	
	bool RemovePlayerModel( string szModel )
	{
		for ( uint i = 0; i < hAvailableModels.length(); i++ )
		{
			CPlayerModelBase@ model = @hAvailableModels[ i ];
			if ( model is null ) continue;
			if ( model.GetModel() == szModel )
			{
				hAvailableModels.removeAt( i );
				return true;
			}
		}
		return false;
	}
}