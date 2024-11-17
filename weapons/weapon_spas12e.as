#include "../base_weapon"

// For available ammotypes, or animation seqences
// Check WeaponInfo.txt under the root scrpg folder

enum Weapon_Spas12e_e
{
	sm_idle = 0,
	shoot_double,
	reload_start,
	reload_middle,
	reload_end,
	draw,
};

class weapon_spas12e : ScriptBasePlayerWeaponEntity, weapon_afterlife_base
{
	private CBasePlayer@ m_pPlayer
	{
		get const 	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}
	private int iDefault_MaxAmmo = 8;
	private int iDefault_MaxCarry = iDefault_MaxAmmo; //Was * 10

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= iDefault_MaxCarry;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= iDefault_MaxAmmo;
		info.iSlot			= 2;
		info.iPosition		= 5;
		info.iWeight		= 0;
		info.iId     		= g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iFlags 		= ITEM_FLAG_NOAUTORELOAD | ITEM_FLAG_NOAUTOSWITCHEMPTY | ITEM_FLAG_SELECTONEMPTY;
		return true;
	}

	void Spawn()
	{
		self.Precache();
		g_EntityFuncs.SetModel( self, self.GetW_Model( GetWeaponModel( 0 ) ) );
		self.m_iClip			= iDefault_MaxAmmo;
		self.m_flCustomDmg		= self.pev.dmg;

		self.FallInit();// get ready to fall down.
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		// Set the model
		SetWeaponModel( 0, "models/w_shotgun.mdl" );
		SetWeaponModel( 1, "models/v_shotgun.mdl" );
		SetWeaponModel( 2, "models/p_shotgun.mdl" );

		SetWeaponWorldScale( 1.0 );
		SetFireRate( 1.42 );
		SetWeaponDamage( 20 );
		SetWeaponAccuracy( VECTOR_CONE_2DEGREES );	// Vector( 2, 2, 2 )

		g_Game.PrecacheModel( GetWeaponModel( 0 ) );	// World model
		g_Game.PrecacheModel( GetWeaponModel( 1 ) );	// View model
		g_Game.PrecacheModel( GetWeaponModel( 2 ) );	// Player model
		g_Game.PrecacheModel( "sprites/explode1.spr" );	
		g_Game.PrecacheModel( "sprites/afterlife/sheet_skull11.spr" );

		// Precache the sprite sheet file
		g_Game.PrecacheGeneric( "sprites/afterlife/weapon_skull11.txt" );

		//Precache weapon sounds
		PrecacheSound( "afterlife/skull11/boltpull.wav" );
		PrecacheSound( "afterlife/skull11/fire.wav" );
		PrecacheSound( "afterlife/skull11/clipin.wav" );
		PrecacheSound( "afterlife/skull11/clipout.wav" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		return CommonAddToPlayer( pPlayer );
	}

	bool Deploy()
	{
		return SetDeploy( draw, "shotgun", 1.12f );
	}

	bool CanDeploy()
	{
		return true;
	}

	void Holster( int skipLocal = 0 )
	{
		self.m_fInReload = false;
		EffectsFOVOFF();
		SetThink( null );
		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		// Shoot
		// >> Sound
		// >> Bullet count
		// >> Distance
		// >> Multiply Damage
		if ( !Attack_Firearm( "weapons/dbarrel2.wav", 1, 9216, false ) )
			return;

		// Explosion shot
		// >> Sound
		// >> Sprite
		// >> Distance
		// >> Damage
		// >> Size
		// >> Range
		Attack_Explosion( "", "sprites/explode1.spr", 9216, 40, 64, 200 ); //Damage was GetWeaponDamage() * 2

		// Play animation
		switch( Math.RandomLong( 0, 1 ) )
		{
			case 0: self.SendWeaponAnim( shoot_double ); break;
		}

		// Set the new timer
		self.m_flNextPrimaryAttack = WeaponTimeBase() + GetFireRate();
	}

	void Reload()
	{
		if ( self.m_iClip == iDefault_MaxAmmo || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		// Reload the weapon
		// >> Clip amount
		// >> Animation
		// >> Timer
		// >> Bodygroup
		//Reload( 0, reload_start, 0.75, 0 );
		Reload( 1, reload_middle, 0.48, 0 );
		//Reload( 0, reload_end, 0.85, 0 );

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		self.SendWeaponAnim( sm_idle, 0, 0 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 3.1f;
	}
}

string WeaponName_spas12e()
{
	return "weapon_spas12e";
}

void RegisterWeapon_spas12e()
{
	g_CustomEntityFuncs.RegisterCustomEntity( WeaponName_spas12e(), WeaponName_spas12e() );
	g_ItemRegistry.RegisterWeapon( WeaponName_spas12e(), "afterlife", "buckshot", "" );
}