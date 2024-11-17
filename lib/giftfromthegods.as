namespace GiftFromTheGods
{
	final class CAmmoDrop
	{
		private string m_szWeaponClass;
		private string m_szAmmoClass;
		
		string GetWeaponClassname() { return m_szWeaponClass; }
		string GetAmmoClassname() { return m_szAmmoClass; }
		
		CAmmoDrop( const string& in szWeaponClassname, const string& in szWeaponAmmoClassname )
		{
			m_szWeaponClass = szWeaponClassname;
			m_szAmmoClass = szWeaponAmmoClassname;
		}
	}
	
	// Just give the player some random ammo
	final class AmmoDrop
	{
		private array<string> m_BasicAmmoTypes = {
			"9mm",
			"buckshot",
			"357",
			"556",
			"m40a1",
			"bolts",
			"shock charges",
			"sporeclip",
			"hornets",
			"uranium",
			"snarks"
		};

		private array<string> m_ExplosiveAmmoTypes = {
			"rockets",
			"trip mine",
			"satchel charge",
			"hand grenade",
			"ARgrenades",
		};

		
		private array<CAmmoDrop@> m_Items;
		
		bool ShouldAddItems()
		{
			if ( m_Items.length() <= 0 ) return true;
			return false;
		}
		
		void AddItem( CAmmoDrop@ pItem )
		{
			if ( pItem is null )
				return;
			
			if ( m_Items.findByRef( @pItem ) != -1 )
				return;
			
			m_Items.insertLast( pItem );
		}

		private string GiveAmmoToActiveWeapon( string classname )
		{
			for ( uint i = 0; i < m_Items.length(); i++ )
			{
				CAmmoDrop@ ammo = m_Items[ i ];
				if ( ammo is null ) continue;
				if ( ammo.GetWeaponClassname() == classname )
					return ammo.GetAmmoClassname();
			}
			return "9mm";
		}

		void GiveDrop(CBasePlayer@ pPlayer, int iStat_ammoregen) 
		{
			if (pPlayer is null) return;

			dictionary givenAmmoTypeMap;

			// Initialize the map to track ammo types already given
			for (uint i = 0; i < m_BasicAmmoTypes.length(); i++)
			{
				givenAmmoTypeMap[m_BasicAmmoTypes[i]] = false;
			}

			// Iterate through the player's weapon inventory
			for (uint i = 0; i < MAX_ITEM_TYPES; i++) // MAX_ITEM_TYPES is the max number of weapon slots
			{
				CBasePlayerItem@ pItem = pPlayer.m_rgpPlayerItems(i); // Get the i-th slot

				// Loop through linked list of weapons in this slot
        		while(pItem !is null) 
				{
					string primaryAmmo = pItem.pszAmmo1(); //Weapon's primary ammo type.

					// Check whether the ammo type is normal and not explosive
					if(m_BasicAmmoTypes.find(primaryAmmo) != -1)
					{
						int maxPrimaryAmmo = pItem.iMaxAmmo1();  // Max ammo for primary ammo type.

						// Give primary ammo if not already given
						if (!bool(givenAmmoTypeMap[primaryAmmo]))
						{
							int amountToGive = int(Math.Ceil(iStat_ammoregen * 0.9));
							pPlayer.GiveAmmo(amountToGive, primaryAmmo, maxPrimaryAmmo);
							givenAmmoTypeMap[primaryAmmo] = true;
						}
					}
					
					@pItem = cast<CBasePlayerItem@>(pItem.m_hNextItem.GetEntity()); // Move to next weapon
        		}
			}
		}
	
		void GiveDropExplosive( CBasePlayer@ pPlayer, int iDropLevel ) //New void that I added to seperate explosive regen from normal
		{
			if ( pPlayer is null ) return;

			//Give ammo for Explosives.
			pPlayer.GiveAmmo( 2 ,"ARgrenades", 10 );
			pPlayer.GiveAmmo( 1 ,"hand grenade", 10, true );
			pPlayer.GiveAmmo( 1 ,"rockets", 10 );
			pPlayer.GiveAmmo( 1 ,"trip mine", 5, true );
			pPlayer.GiveAmmo( 1 ,"satchel charge", 5, true );

			//if ( pPlayer.HasPlayerItem( "weapon_tripmine", false ) )
			//	GiveToPlayer::GiveWeapon( pPlayer, "weapon_tripmine" );
		}
	}

	enum WeaponRarity
	{
		Rarity_Common = 0,
		Rarity_UnCommon,
		Rarity_Rare,
		Rarity_SuperRare,
		Rarity_Legendary,
		Rarity_Mythical
	};
	
	final class CWeaponDrop
	{
		private string m_szName;
		private string m_szClassname;
		private WeaponRarity m_iRarity;
		private int m_iDropLevelRequirement;
		private bool m_bIsMelee;
		
		string GetName() { return m_szName; }
		string GetClassname() { return m_szClassname; }
		
		bool IsMelee() { return m_bIsMelee; }
		
		int GetLevelRequirement() { return m_iDropLevelRequirement; }
		
		float GetPercentage()
		{
			float output;
			switch( m_iRarity )
			{
				case Rarity_Common: output = 1.0; break;
				case Rarity_UnCommon: output = 0.8; break;
				case Rarity_Rare: output = 0.25; break;
				case Rarity_SuperRare: output = 0.15; break;
				case Rarity_Legendary: output = 0.05; break; //Was 0.01
				case Rarity_Mythical: output = 0.02; break; //Was 0.001
			}
			return output;
		}
		
		CWeaponDrop( const string& in szWeaponClassname, const string& in szWeaponName, WeaponRarity eRarity, int iDropLevel, bool bMelee = false )
		{
			m_szClassname = szWeaponClassname;
			m_szName = szWeaponName;
			m_iRarity = eRarity;
			m_iDropLevelRequirement = iDropLevel;
			m_bIsMelee = bMelee;
		}
		
		void ObtainWeapon( CBasePlayer@ pPlayer )
		{
			if ( pPlayer is null ) return;
			
			bool bAnnounceAll = false;
			string szRarity = "";
			switch( m_iRarity )
			{
				case Rarity_Common: szRarity = "Common"; break;
				case Rarity_UnCommon: szRarity = "Un-Common"; break;
				case Rarity_Rare: szRarity = "Rare"; break;
				case Rarity_SuperRare: szRarity = "Super Rare"; break;
				case Rarity_Legendary:
				{
					bAnnounceAll = true;
					szRarity = "Legendary";
					break;
				}
				case Rarity_Mythical:
				{
					bAnnounceAll = true;
					szRarity = "Mythical";
					break;
				}
			}
			if ( bAnnounceAll )
			{
				string szNick = pPlayer.pev.netname;
				g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, szNick + " has been supplied with " + m_szName + ", with is " + szRarity + "!\n");
			}
			else
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "You have been supplied with " + m_szName + ", which is " + szRarity + "!\n");
			
			pPlayer.GiveNamedItem( m_szClassname );
			
			g_SCRPGCore.CheckForSpecificAchievement( pPlayer, m_szClassname );
		}
	}
	
	final class WeaponDrop
	{
		array<CWeaponDrop@> m_Items;
		
		bool ShouldAddItems()
		{
			if ( m_Items.length() <= 0 ) return true;
			return false;
		}
		
		void AddItem( CWeaponDrop@ pItem )
		{
			if ( pItem is null )
				return;
				
			if ( m_Items.findByRef( @pItem ) != -1 )
				return;
				
			m_Items.insertLast( pItem );
		}
		
		private bool CanGiveWeapon( CWeaponDrop@ weapon, int level, float percentage )
		{
			if ( weapon is null ) return false;
			if ( weapon.GetLevelRequirement() > level ) return false;
			// Common? Ignore
			if ( weapon.GetPercentage() != 1.0 )
			{
				if ( weapon.GetPercentage() > percentage ) return false;
			}
			if ( !weapon.IsMelee() && g_MapDefined_MeleeOnly ) return false;
			return true;
		}
		
		private CWeaponDrop@ GetRandomDrop( int iDropLevel )
		{
			array<CWeaponDrop@> mTemp = m_Items;
			while( mTemp.length() > 0 )
			{
				uint i = Math.RandomLong( 0, mTemp.length() - 1 );
				CWeaponDrop@ weapon = @mTemp[ i ];
				if ( !CanGiveWeapon( weapon, iDropLevel, Math.RandomFloat( 0.0, 1.0 ) ) )
				{
					mTemp.removeAt( i );
					continue;
				}
				return weapon;
			}
			return null;
		}
		
		void GiveDrop( CBasePlayer@ pPlayer, int iDropLevel )
		{
			CWeaponDrop@ weapon = GetRandomDrop( iDropLevel );
			if ( weapon is null ) return;

			weapon.ObtainWeapon( pPlayer );
		}
	}
}