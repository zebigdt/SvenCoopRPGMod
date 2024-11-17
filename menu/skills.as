namespace Menu
{
	enum SkillEnums
	{
		SKILL_HEALTH = 0,
		SKILL_ARMOR,
		SKILL_HEALTH_REGEN,
		SKILL_ARMOR_REGEN,
		SKILL_AMMOREGEN,
		SKILL_EXPLOSIVEREGEN,
		SKILL_DOUBLEJUMP,
		SKILL_FIRSTAID,
		SKILL_SHOCKRIFLE
	};
	
	final class CPlayerSkill
	{
		private string m_szName;
		private SkillEnums m_iSkill;
		private int m_iMaxValue;
		
		CPlayerSkill( const string& in szSkillName, SkillEnums eSkill, const uint uiMax )
		{
			m_szName = szSkillName;
			m_iSkill = eSkill;
			m_iMaxValue = uiMax;
		}
		
		string GetDescription( PlayerData@ data )
		{
			int iPoints = 0;
			switch( m_iSkill )
			{
				case SKILL_HEALTH: iPoints = data.iStat_health; break;
				case SKILL_ARMOR: iPoints = data.iStat_armor; break;
				case SKILL_HEALTH_REGEN: iPoints = data.iStat_health_regen; break;
				case SKILL_ARMOR_REGEN: iPoints = data.iStat_armor_regen; break;
				case SKILL_AMMOREGEN: iPoints = data.iStat_ammoregen; break;
				case SKILL_EXPLOSIVEREGEN: iPoints = data.iStat_explosiveregen; break;
				case SKILL_DOUBLEJUMP: iPoints = data.iStat_doublejump; break;
				case SKILL_FIRSTAID: iPoints = data.iStat_firstaid; break;
				case SKILL_SHOCKRIFLE: iPoints = data.iStat_shockrifle; break;
			}
			return m_szName + " - [" + iPoints + "/" + m_iMaxValue + "]";
		}
		
		private int GetSpentAmount( int input, int value )
		{
			if ( value + input >= m_iMaxValue )
				value = m_iMaxValue - input;
			return value;
		}
		
		void ObtainSkill( CBasePlayer@ pPlayer, int iSpendAmount )
		{
			if( pPlayer is null ) return;
			
			PlayerData@ data;
			string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
			if ( g_PlayerCoreData.exists(szSteamId) )
				@data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			if ( data is null ) return;
			
			int iPoints = 0;
			switch( m_iSkill )
			{
				case SKILL_HEALTH: iPoints = data.iStat_health; break;
				case SKILL_ARMOR: iPoints = data.iStat_armor; break;
				case SKILL_HEALTH_REGEN: iPoints = data.iStat_health_regen; break;
				case SKILL_ARMOR_REGEN: iPoints = data.iStat_armor_regen; break;
				case SKILL_AMMOREGEN: iPoints = data.iStat_ammoregen; break;
				case SKILL_EXPLOSIVEREGEN: iPoints = data.iStat_explosiveregen; break;
				case SKILL_DOUBLEJUMP: iPoints = data.iStat_doublejump; break;
				case SKILL_FIRSTAID: iPoints = data.iStat_firstaid; break;
				case SKILL_SHOCKRIFLE: iPoints = data.iStat_shockrifle; break;
			}
			
			if ( data.iPoints <= 0 )
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[RPG MOD] Not enough skillpoints to increase " + m_szName + "!\n");
				return;
			}
			
			if( iPoints >= m_iMaxValue )
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[RPG MOD] " + m_szName + "Is already at max!\n");
				if ( data.iPoints > 0 )
					data.bReopenSkills = true;
			}
			else
			{
				if ( iSpendAmount > 1 )
				{
					// Make sure to only remove the required value
					int iResult = GetSpentAmount( iPoints, iSpendAmount );
					iPoints += iResult;
					data.iPoints -= iResult;
				}
				else
				{
					data.iPoints--;
					iPoints++;
				}
				
				switch( m_iSkill )
				{
					case SKILL_HEALTH: data.iStat_health = iPoints; break;
					case SKILL_ARMOR: data.iStat_armor = iPoints; break;
					case SKILL_HEALTH_REGEN: data.iStat_health_regen = iPoints; break;
					case SKILL_ARMOR_REGEN: data.iStat_armor_regen = iPoints; break;
					case SKILL_AMMOREGEN: data.iStat_ammoregen = iPoints; break;
					case SKILL_EXPLOSIVEREGEN: data.iStat_explosiveregen = iPoints; break;
					case SKILL_DOUBLEJUMP: data.iStat_doublejump = iPoints; break;
					case SKILL_FIRSTAID: data.iStat_firstaid = iPoints; break;
					case SKILL_SHOCKRIFLE: data.iStat_shockrifle = iPoints; break;
				}
				
				// Make sure to update it
				g_SCRPGCore.SetMaxArmorHealth( pPlayer, data );
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[RPG MOD] Increased " + m_szName + " to Level " + iPoints + "\n");
				if ( data.iPoints > 0 )
					data.bReopenSkills = true;
			}
		}
	}

	final class SkillMenu
	{
		array<CPlayerSkill@> m_Items;
		
		private CTextMenu@ m_pMenu = null;
		private int iSpendChoice = 0;
		
		bool ShouldAddItems()
		{
			if ( m_Items.length() <= 0 ) return true;
			return false;
		}
		
		void AddItem( CPlayerSkill@ pItem )
		{
			if ( pItem is null )
				return;
				
			if ( m_Items.findByRef( @pItem ) != -1 )
				return;
				
			m_Items.insertLast( pItem );
			
			if ( m_pMenu !is null )
				@m_pMenu = null;
		}
		
		void Show( CBasePlayer@ pPlayer, int iAvailablePoints, bool bDoSpendChoice = false )
		{
			if ( pPlayer is null ) return;
			if ( m_pMenu !is null )
				@m_pMenu = null;
			iSpendChoice = bDoSpendChoice ? iAvailablePoints : 0;
			CreateMenu( pPlayer, iAvailablePoints );
			// Check again, if our data is invalid
			if ( m_pMenu is null ) return;
			m_pMenu.Open( 0, 0, pPlayer );
		}
		
		private void CreateMenu( CBasePlayer@ pPlayer, int iAvailablePoints )
		{
			PlayerData@ data;
			string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
			if ( g_PlayerCoreData.exists(szSteamId) )
				@data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			if ( data is null ) return;
			
			@m_pMenu = CTextMenu( TextMenuPlayerSlotCallback( this.Callback ) );
			
			if ( iSpendChoice > 1 )
				m_pMenu.SetTitle( "Select Skills - Increase amount (" + iAvailablePoints + "):" );
			else
				m_pMenu.SetTitle( "Select Skills - Skillpoints: " + iAvailablePoints );
			
			for( uint uiIndex = 0; uiIndex < m_Items.length(); ++uiIndex )
			{
				CPlayerSkill@ pItem = m_Items[ uiIndex ];
				m_pMenu.AddItem( pItem.GetDescription( data ), any( @pItem ) );
			}
			
			m_pMenu.Register();
		}
		
		private void Callback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
		{
			if ( pItem !is null )
			{
				CPlayerSkill@ pSkillItem = null;
				
				pItem.m_pUserData.retrieve( @pSkillItem );
				
				if ( pSkillItem !is null )
					pSkillItem.ObtainSkill( pPlayer, iSpendChoice );
			}
		}
	}
	
	final class CPointChoice
	{
		private int iSpendChoice = 0;
		CPointChoice( int iSpend )
		{
			iSpendChoice = iSpend;
		}
		
		int GetPointSpending() { return iSpendChoice; }
		
		string GetDescription()
		{
			string szPoints = iSpendChoice > 1 ? "points" : "point";
			return "" + iSpendChoice + "  " + szPoints;
		}
		
		void DisplayMenu( CBasePlayer@ pPlayer )
		{
			g_SkillMenu.Show( pPlayer, GetPointSpending(), true );
		}
	}
	
	final class SkillMenuEx
	{
		array<CPointChoice@> m_Items;
		
		private CTextMenu@ m_pMenu = null;
		
		bool ShouldAddItems()
		{
			if ( m_Items.length() <= 0 ) return true;
			return false;
		}
		
		void AddItem( CPointChoice@ pItem )
		{
			if ( pItem is null )
				return;
				
			if ( m_Items.findByRef( @pItem ) != -1 )
				return;
				
			m_Items.insertLast( pItem );
			
			if ( m_pMenu !is null )
				@m_pMenu = null;
		}
		
		void Show( CBasePlayer@ pPlayer, int iAvailablePoints )
		{
			if ( pPlayer is null ) return;
			if ( m_pMenu !is null )
				@m_pMenu = null;
			CreateMenu( pPlayer, iAvailablePoints );
			// Check again, if our data is invalid
			if ( m_pMenu is null ) return;
			m_pMenu.Open( 0, 0, pPlayer );
		}
		
		private void CreateMenu( CBasePlayer@ pPlayer, int iAvailablePoints )
		{
			PlayerData@ data;
			string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
			if ( g_PlayerCoreData.exists(szSteamId) )
				@data = cast<PlayerData@>(g_PlayerCoreData[szSteamId]);
			if ( data is null ) return;
			
			@m_pMenu = CTextMenu( TextMenuPlayerSlotCallback( this.Callback ) );
			
			m_pMenu.SetTitle( "Increase skill by" );
			
			for( uint uiIndex = 0; uiIndex < m_Items.length(); ++uiIndex )
			{
				CPointChoice@ pItem = m_Items[ uiIndex ];
				if ( pItem.GetPointSpending() > iAvailablePoints ) continue;
				m_pMenu.AddItem( pItem.GetDescription(), any( @pItem ) );
			}
			
			m_pMenu.Register();
		}
		
		private void Callback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
		{
			if ( pItem !is null )
			{
				CPointChoice@ pMenuItem = null;
				
				pItem.m_pUserData.retrieve( @pMenuItem );
				
				if ( pMenuItem !is null )
					pMenuItem.DisplayMenu( pPlayer );
			}
		}
	}
}