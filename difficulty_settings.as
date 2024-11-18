CCVar@ g_difficultysettings_debug;

final class DifficultySettings
{
	private array<float> weapon_damage_values = {
		10.0, //Medkit - Default 10
		30.0, //Crowbar - Default 15
		50.0, //Wrench - Default 22
		80.0, //Grapple (Barnacle) - Default 40
		25.0, //Handgun (9mm Handgun) - Default 12
		150.0, //357 (Deagle is 2/3 of this) - Default 66
		25.0, //Uzi (Also Akimbo, Gold do +1 extra damage) - Default 10
		25.0, //MP5 (9mm AR) - Default 8
		15.0, //Buckshot (7 pellets primary, 6 pellets secondary) - Default 10
		200.0, //Crossbow (Alt weapon mode is explosive on impact) - Default 60
		30.0, //556 (M16/SAW/Minigun, also effects enemies damage!) - Default 12
		150.0, //M203 (ARgrenades) - Default 100
		300.0, //RPG - Default 150
		50.0, //Gauss (No charge) - Default 19
		500.0, //Secondary Guass (Max Charge) - Default 190
		40.0, //Gluon (Egon) Gun - Default 12
		30.0, //Hornet Gun - Default 12
		200.0, //Hand Grenade - Default 100
		320.0, //Satchel - Default 160
		300.0, //Tripmine - Default 150
		220.0, //762 (Sniper Rifle) - Default 110
		200.0, //Spore Launcher - Default 100
		600.0, //Displacer (Primary) - Default 250
		300.0, //Displacer Radius - Default 300
		50.0, //Shockrifle (Primary) - Default 15
		12.0, //Shockrifle (Beam) - Default 2
		0.0, //Shockrifle Touch damage (on self on detonate?) - Default 350
		0.0 //Shockroach Splash damage (on self when detonate?) - Default 150
	};

	private array<string> weapon_damage_strings = {
		"sk_plr_HpMedic",
		"sk_plr_crowbar",
		"sk_plr_wrench",
		"sk_plr_grapple",
		"sk_plr_9mm_bullet",
		"sk_plr_357_bullet",
		"sk_plr_uzi",
		"sk_plr_9mmAR_bullet",
		"sk_plr_buckshot",
		"sk_plr_xbow_bolt_monster",
		"sk_556_bullet",
		"sk_plr_9mmAR_grenade",
		"sk_plr_rpg",
		"sk_plr_gauss",
		"sk_plr_secondarygauss",
		"sk_plr_egon_wide",
		"sk_hornet_pdmg",
		"sk_plr_hand_grenade",
		"sk_plr_satchel",
		"sk_plr_tripmine",
		"sk_plr_762_bullet",
		"sk_plr_spore",
		"sk_plr_displacer_other",
		"sk_plr_displacer_radius",
		"sk_plr_shockrifle",
		"sk_plr_shockrifle_beam",
		"sk_shockroach_dmg_xpl_touch",
		"sk_shockroach_dmg_xpl_splash"
	};

	private array<float> monster_damage_values = {
		150.0, // sk_agrunt_health
		15.0, // sk_agrunt_dmg_punch
		256.0, // sk_agrunt_melee_engage_distance
		20.0, // sk_agrunt_berserker_dmg_punch
		500.0, // sk_apache_health
		50.0, // sk_barnacle_health
		15.0, // sk_barnacle_bite
		65.0, // sk_barney_health
		110.0, // sk_bullsquid_health
		10.0, // sk_bullsquid_dmg_bite
		25.0, // sk_bullsquid_dmg_whip
		10.0, // sk_bullsquid_dmg_spit
		1.0, // sk_bigmomma_health_factor
		50.0, // sk_bigmomma_dmg_slash
		100.0, // sk_bigmomma_dmg_blast
		260.0, // sk_bigmomma_radius_blast
		1000.0, // sk_gargantua_health
		30.0, // sk_gargantua_dmg_slash
		8.0, // sk_gargantua_dmg_fire
		100.0, // sk_gargantua_dmg_stomp
		50.0, // sk_hassassin_health
		20.0, // sk_headcrab_health
		20.0, // sk_headcrab_dmg_bite
		100.0, // sk_hgrunt_health
		12.0, // sk_hgrunt_kick
		500.0, // sk_hgrunt_gspeed
		60.0, // sk_houndeye_health
		15.0, // sk_houndeye_dmg_blast
		80.0, // sk_islave_health
		10.0, // sk_islave_dmg_claw
		10.0, // sk_islave_dmg_clawrake
		10.0, // sk_islave_dmg_zap
		350.0, // sk_ichthyosaur_health
		30.0, // sk_ichthyosaur_shake
		3.0, // sk_leech_health
		5.0, // sk_leech_dmg_bite
		90.0, // sk_controller_health
		10.0, // sk_controller_dmgzap
		900.0, // sk_controller_speedball
		5.0, // sk_controller_dmgball
		900.0, // sk_nihilanth_health
		30.0, // sk_nihilanth_zap
		50.0, // sk_scientist_health
		2.0, // sk_snark_health
		10.0, // sk_snark_dmg_bite
		10.0, // sk_snark_dmg_pop
		100.0, // sk_zombie_health
		20.0, // sk_zombie_dmg_one_slash
		40.0, // sk_zombie_dmg_both_slash
		200.0, // sk_turret_health
		80.0, // sk_miniturret_health
		80.0, // sk_sentry_health
		600.0, // sk_babygargantua_health
		15.0, // sk_babygargantua_dmg_slash
		4.0, // sk_babygargantua_dmg_fire
		50.0, // sk_babygargantua_dmg_stomp
		200.0, // sk_hwgrunt_health
		100.0, // sk_rgrunt_explode
		50.0, // sk_massassin_sniper
		65.0, // sk_otis_health
		110.0, // sk_zombie_barney_health
		20.0, // sk_zombie_barney_dmg_one_slash
		40.0, // sk_zombie_barney_dmg_both_slash
		150.0, // sk_zombie_soldier_health
		30.0, // sk_zombie_soldier_dmg_one_slash
		60.0, // sk_zombie_soldier_dmg_both_slash
		200.0, // sk_gonome_health
		10.0, // sk_gonome_dmg_one_slash
		15.0, // sk_gonome_dmg_guts
		15.0, // sk_gonome_dmg_one_bite
		60.0, // sk_pitdrone_health
		15.0, // sk_pitdrone_dmg_bite
		30.0, // sk_pitdrone_dmg_whip
		15.0, // sk_pitdrone_dmg_spit
		200.0, // sk_shocktrooper_health
		10.0, // sk_shocktrooper_kick
		12.0, // sk_shocktrooper_maxcharge
		800.0, // sk_tor_health
		30.0, // sk_tor_punch
		3.0, // sk_tor_energybeam
		15.0, // sk_tor_sonicblast
		350.0, // sk_voltigore_health
		30.0, // sk_voltigore_dmg_punch
		40.0, // sk_voltigore_dmg_beam
		750.0, // sk_tentacle
		600.0, // sk_blkopsosprey
		600.0, // sk_osprey
		125.0, // sk_stukabat
		20.0, // sk_stukabat_dmg_bite
		50.0, // sk_sqknest_health
		450.0, // sk_kingpin_health
		20.0, // sk_kingpin_lightning
		15.0, // sk_kingpin_tele_blast
		50.0, // sk_kingpin_plasma_blast
		30.0, // sk_kingpin_melee
		500.0 // sk_kingpin_telefrag
	};

    	private array<string> monster_damage_strings = {
		"sk_agrunt_health",
		"sk_agrunt_dmg_punch",
		"sk_agrunt_melee_engage_distance",
		"sk_agrunt_berserker_dmg_punch",
		"sk_apache_health",
		"sk_barnacle_health",
		"sk_barnacle_bite",
		"sk_barney_health",
		"sk_bullsquid_health",
		"sk_bullsquid_dmg_bite",
		"sk_bullsquid_dmg_whip",
		"sk_bullsquid_dmg_spit",
		"sk_bigmomma_health_factor",
		"sk_bigmomma_dmg_slash",
		"sk_bigmomma_dmg_blast",
		"sk_bigmomma_radius_blast",
		"sk_gargantua_health",
		"sk_gargantua_dmg_slash",
		"sk_gargantua_dmg_fire",
		"sk_gargantua_dmg_stomp",
		"sk_hassassin_health",
		"sk_headcrab_health",
		"sk_headcrab_dmg_bite",
		"sk_hgrunt_health",
		"sk_hgrunt_kick",
		"sk_hgrunt_gspeed",
		"sk_houndeye_health",
		"sk_houndeye_dmg_blast",
		"sk_islave_health",
		"sk_islave_dmg_claw",
		"sk_islave_dmg_clawrake",
		"sk_islave_dmg_zap",
		"sk_ichthyosaur_health",
		"sk_ichthyosaur_shake",
		"sk_leech_health",
		"sk_leech_dmg_bite",
		"sk_controller_health",
		"sk_controller_dmgzap",
		"sk_controller_speedball",
		"sk_controller_dmgball",
		"sk_nihilanth_health",
		"sk_nihilanth_zap",
		"sk_scientist_health",
		"sk_snark_health",
		"sk_snark_dmg_bite",
		"sk_snark_dmg_pop",
		"sk_zombie_health",
		"sk_zombie_dmg_one_slash",
		"sk_zombie_dmg_both_slash",
		"sk_turret_health",
		"sk_miniturret_health",
		"sk_sentry_health",
		"sk_babygargantua_health",
		"sk_babygargantua_dmg_slash",
		"sk_babygargantua_dmg_fire",
		"sk_babygargantua_dmg_stomp",
		"sk_hwgrunt_health",
		"sk_rgrunt_explode",
		"sk_massassin_sniper",
		"sk_otis_health",
		"sk_zombie_barney_health",
		"sk_zombie_barney_dmg_one_slash",
		"sk_zombie_barney_dmg_both_slash",
		"sk_zombie_soldier_health",
		"sk_zombie_soldier_dmg_one_slash",
		"sk_zombie_soldier_dmg_both_slash",
		"sk_gonome_health",
		"sk_gonome_dmg_one_slash",
		"sk_gonome_dmg_guts",
		"sk_gonome_dmg_one_bite",
		"sk_pitdrone_health",
		"sk_pitdrone_dmg_bite",
		"sk_pitdrone_dmg_whip",
		"sk_pitdrone_dmg_spit",
		"sk_shocktrooper_health",
		"sk_shocktrooper_kick",
		"sk_shocktrooper_maxcharge",
		"sk_tor_health",
		"sk_tor_punch",
		"sk_tor_energybeam",
		"sk_tor_sonicblast",
		"sk_voltigore_health",
		"sk_voltigore_dmg_punch",
		"sk_voltigore_dmg_beam",
		"sk_tentacle",
		"sk_blkopsosprey",
		"sk_osprey",
		"sk_stukabat",
		"sk_stukabat_dmg_bite",
		"sk_sqknest_health",
		"sk_kingpin_health",
		"sk_kingpin_lightning",
		"sk_kingpin_tele_blast",
		"sk_kingpin_plasma_blast",
		"sk_kingpin_melee",
		"sk_kingpin_telefrag"
	};

	private array<float> monster_damage_values_bullet = {
		8, // sk_12mm_bullet
		3, // sk_9mmAR_bullet
		4, // sk_9mm_bullet
		8, // sk_hornet_dmg
		34, // sk_otis_bullet
		3, // sk_grunt_buckshot
		32 // sk_556_bullet
	};

	private array<string> monster_damage_strings_bullet = {
		"sk_12mm_bullet",
		"sk_9mmAR_bullet",
		"sk_9mm_bullet",
		"sk_hornet_dmg",
		"sk_otis_bullet",
		"sk_grunt_buckshot",
		"sk_556_bullet"
	};

    private array<float> player_location_values = {
		1.0, //sk_player_head
		1.0, //sk_player_chest
		1.0, //sk_player_stomach
		0.5, //sk_player_arm
		0.5 //sk_player_leg
	};
	
	private array<string> player_location_strings = {
		"sk_player_head",
		"sk_player_chest",
		"sk_player_stomach",
		"sk_player_arm",
		"sk_player_leg"
	};

    	private array<float> monster_location_values = {
		3.0, //sk_monster_head
		1.0, //sk_monster_chest
		1.0, //sk_monster_stomach
		1.0, //sk_monster_arm
		1.0  //sk_monster_leg
	};
	
	private array<string> monster_location_strings = {
		"sk_monster_head",
		"sk_monster_chest",
		"sk_monster_stomach",
		"sk_monster_arm",
		"sk_monster_leg"
	};
	
	DifficultySettings()
	{
		Clear();
	}
	
	void Clear()
	{
		PushDifficultySettings();
	}
	
	void PushDifficultySettings()
	{   

		//Player Damage
		int iMax = weapon_damage_values.size();
		for( int i = 0; i < iMax; ++i )
		{
			float flValue = weapon_damage_values[i];
			string strStrings = weapon_damage_strings[i] + " " + flValue + "\n";
			g_EngineFuncs.ServerCommand( strStrings );
			Debug( strStrings );
		}
        //Monster Damage
		iMax = monster_damage_values.size();
		for( int i = 0; i < iMax; ++i )
		{
			float flValue = monster_damage_values[i];
			string strStrings = monster_damage_strings[i] + " " + flValue + "\n";
			g_EngineFuncs.ServerCommand( strStrings );
			Debug( strStrings );
		}

		//Monster Damage Bullet
		iMax = monster_damage_values_bullet.size();
		for( int i = 0; i < iMax; ++i )
		{
			float flValue = monster_damage_values_bullet[i];
			string strStrings = monster_damage_strings_bullet[i] + " " + flValue + "\n";
			g_EngineFuncs.ServerCommand( strStrings );
			Debug( strStrings );
		}
		
		//Player location damage
		iMax = player_location_values.size();
		for( int i = 0; i < iMax; ++i )
		{
			float flValue = player_location_values[i];
			string strStrings = player_location_strings[i] + " " + flValue + "\n";
			g_EngineFuncs.ServerCommand( strStrings );
			Debug( strStrings );
		}
		
		//Monster location damage
		iMax = monster_location_values.size();
		for( int i = 0; i < iMax; ++i )
		{
			float flValue = monster_location_values[i];
			string strStrings = monster_location_strings[i] + " " + flValue + "\n";
			g_EngineFuncs.ServerCommand( strStrings );
			Debug( strStrings );
		}
	}
	
	void Debug( string strMsg )
	{
		if ( g_difficultysettings_debug is null ) return;
		if ( g_difficultysettings_debug.GetInt() < 1 ) return;
		g_EngineFuncs.ServerCommand( "echo \"" + strMsg + "\"" );
	}
	
	void DifficultySettingsCheck()
	{
		PushDifficultySettings();
		g_Scheduler.SetTimeout( @this, "DifficultySettingsCheck", 1.0 );
	}
}
DifficultySettings@ g_DifficultySettings;

void DifficultySettings_RegisterHooks()
{
	@g_difficultysettings_debug = CCVar("difficultysettings_debug", 0, "Debug Values", ConCommandFlag::AdminOnly);
}