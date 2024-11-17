namespace Populate
{
	void PopulateWeaponDrop()
	{
		if ( !g_WeaponDrop.ShouldAddItems() ) return;
		
		//For now, all is unused Weapondrop functionality changed to give explosives instead

		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_crowbar", "Crowbar", GiftFromTheGods::Rarity_Common, 1, true ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_pipewrench", "Pipe Wrench", GiftFromTheGods::Rarity_Common, 1, true ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_grapple", "Barnacle Grapple", GiftFromTheGods::Rarity_Common, 1, true ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_glock", "Glock", GiftFromTheGods::Rarity_Common, 1 ) ); - Default spawn weapon on most maps
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_uzi", "Uzi", GiftFromTheGods::Rarity_Common, 2 ) ); - Better to get two at once
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_uziakimbo", "Akimbo Uzi", GiftFromTheGods::Rarity_Common, 2 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_shotgun", "Shotgun", GiftFromTheGods::Rarity_Common, 1 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_mp5", "MP5", GiftFromTheGods::Rarity_Common, 1 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_357", "Revolver", GiftFromTheGods::Rarity_UnCommon, 3 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_eagle", "Desert Eagle", GiftFromTheGods::Rarity_UnCommon, 3 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_m16", "M16 w/ M203", GiftFromTheGods::Rarity_UnCommon, 2 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_sniperrifle", "Sniper Rifle", GiftFromTheGods::Rarity_UnCommon, 5 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_crossbow", "Crossbow", GiftFromTheGods::Rarity_UnCommon, 5 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_snark", "Some Suicidal Aliens", GiftFromTheGods::Rarity_UnCommon, 4 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_handgrenade", "Hand Grenades", GiftFromTheGods::Rarity_UnCommon, 3 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_tripmine", "HECU Laser Tripmine", GiftFromTheGods::Rarity_UnCommon, 4 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_satchel", "Satchel Charges", GiftFromTheGods::Rarity_UnCommon, 5 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_gauss", "Gauss Cannon", GiftFromTheGods::Rarity_UnCommon, 6 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_hornetgun", "Hornet Gun", GiftFromTheGods::Rarity_UnCommon, 3 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_m249", "M249 SAW", GiftFromTheGods::Rarity_Rare, 6 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_rpg", "Rocket Launcher", GiftFromTheGods::Rarity_Rare, 7 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_displacer", "Displacer", GiftFromTheGods::Rarity_Rare, 9 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_egon", "Experimental Gluon Gun", GiftFromTheGods::Rarity_Rare, 9 ) );
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "weapon_sporelauncher", "Spore Launcher", GiftFromTheGods::Rarity_Rare, 8 ) );
		
		//g_WeaponDrop.AddItem( GiftFromTheGods::CWeaponDrop( "______________", "______________", GiftFromTheGods::Rarity_Common, 000000000000 ) );
		
		// Populate this afterwards
		PopulateAmmoDrop();
	}
	
	void PopulateAmmoDrop()
	{
		if ( !g_AmmoDrop.ShouldAddItems() ) return;
		// Supported weapons that will allow ammo drops if holding
		// Vanilla Weapons
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_9mmhandgun", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_glock", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_9mmAR", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_mp5", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_uzi", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_uziakimbo", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_shotgun", "buckshot" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_eagle", "357" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_357", "357" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_m16", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_m249", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_minigun", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_sniperrifle", "m40a1" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_crossbow", "bolts" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_handgrenade", "hand grenade" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_tripmine", "trip mine" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_satchel", "satchel charge" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_rpg", "rockets" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_snark", "snarks" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_gauss", "uranium" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_egon", "uranium" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_displacer", "uranium" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_sporelauncher", "sporeclip" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_hornetgun", "hornets" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_shockrifle", "shock charges" ) );
		
		// Insurgency Weapons Support
		//Handguns
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2usp", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2beretta", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2c96", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m29", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2deagle", "357" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m1911", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2glock17", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2makarov", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2webley", "357" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2python", "357" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2vp70", "9mm" ) );

		//SMGs
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2mp5k", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2ump45", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2mp40", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2ppsh41", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2l2a3", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m1928", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2mp7", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2mp18", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2greasegun", "9mm" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2mp5sd", "9mm" ) );

		//Shotguns
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m590", "buckshot" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m1014", "buckshot" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2coach", "buckshot" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2ithaca", "buckshot" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2saiga12", "buckshot" ) );

		//Carbines
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2sks", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m4a1", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2mk18", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2aks74u", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2c96carb", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m1a1para", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2g36c", "556" ) );

		//Assault Rifles
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2akm", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m16a4", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2stg44", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2galil", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2asval", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2ak12", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2f2000", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2l85a2", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2ak74", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2an94", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2groza", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m16a1", "556" ) );

		//Battle Rifles
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2fnfal", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2g3a3", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m14ebr", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2fg42", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2scarh", "556" ) );

		//Rifles
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2garand", "m40a1" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2kar98k", "m40a1" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2enfield", "m40a1" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2svt40", "m40a1" ) );

		//LMGs
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2rpk", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m249", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2mg42", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2lewis", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m60", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2pkm", "556" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2mg34", "556" ) );

		//Explosives/Launchers
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2mk2", "hand grenade" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2rpg7", "rockets" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2law", "rockets" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m2", "hand grenade" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2stick", "hand grenade" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2pzfaust", "rockets" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m79", "ARgrenades" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2pzschreck", "rockets" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2at4", "rockets" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2rgo", "hand grenade" ) );

		//Sniper Rifles
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2dragunov", "m40a1" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2mosin", "m40a1" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m40a1", "m40a1" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2g43", "m40a1" ) );
		g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_ins2m21", "m40a1" ) );

		// Afterlife Weapons Support
		//g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_af_ethereal", "afterlife_crystals" ) );
		//g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_af_ethereal_mk2", "afterlife_crystals" ) );
		//g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_buffsg552", "556" ) );
		//g_AmmoDrop.AddItem( GiftFromTheGods::CAmmoDrop( "weapon_skull11", "buckshot" ) );
	}
}