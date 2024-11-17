namespace GiveToPlayer
{
	void GiveItem( CBasePlayer@ pPlayer, string szItem )
	{
		if ( pPlayer is null ) return;
		CBaseEntity@ pEntity = g_EntityFuncs.Create( szItem, pPlayer.pev.origin, Vector(0, pPlayer.pev.angles.y, 0), true );
		if ( pEntity is null ) return;
		pEntity.pev.spawnflags = 1024;	// Disable Respawn
		g_EntityFuncs.DispatchSpawn( pEntity.edict() );
	}

	void GivePrestiges( CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( pPlayer is null ) return;
		if ( data is null ) return;

		if ( data.iWaitTimer_UseModel < 0 )

			//Prestige Rewards for Vanilla - Rewards are given upon spawning, will always have these weapons on every map
			//1st 
			GivePrestige( 1, "item_longjump", pPlayer, data );
			GivePrestige( 1, "weapon_crowbar", pPlayer, data );
			GivePrestige( 1, "weapon_medkit", pPlayer, data );
			GivePrestige( 1, "weapon_grapple", pPlayer, data );
			GivePrestige( 1, "weapon_glock", pPlayer, data );
			GivePrestige( 1, "weapon_mp5", pPlayer, data );
			GivePrestige( 2, "weapon_shotgun", pPlayer, data );
			GivePrestige( 1, "weapon_hornetgun", pPlayer, data );

			//2nd
			GivePrestige( 2, "weapon_uziakimbo", pPlayer, data );
			GivePrestige( 2, "weapon_m16", pPlayer, data );

			//3rd
			GivePrestige( 3, "weapon_eagle", pPlayer, data );
			GivePrestige( 4, "weapon_357", pPlayer, data );
			
			//4th
			GivePrestige( 3, "weapon_m249", pPlayer, data );

			//5th
			GivePrestige( 5, "weapon_sniperrifle", pPlayer, data );
			GivePrestige( 5, "weapon_crossbow", pPlayer, data );
			

			//6th
			GivePrestige( 6, "weapon_gauss", pPlayer, data );

			//7th
			GivePrestige( 7, "weapon_rpg", pPlayer, data );

			//8th
			GivePrestige( 8, "weapon_sporelauncher", pPlayer, data );

			//9th
			GivePrestige( 9, "weapon_egon", pPlayer, data );

			//10th
			GivePrestige( 10, "weapon_displacer", pPlayer, data );
			
	}

	void GivePrestige( int &in level, string &in szWeapon, CBasePlayer@ pPlayer, PlayerData@ data )
	{
		if ( data.iPrestige >= level )
			GiveWeapon( pPlayer, szWeapon );
	}
}