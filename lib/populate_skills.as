namespace Populate
{
	void PopulateSkills()
	{
		if ( !g_SkillMenu.ShouldAddItems() ) return;
		if ( !g_SkillMenuEx.ShouldAddItems() ) return;
		
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Max Health", Menu::SKILL_HEALTH, AB_HEALTH_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Max Armor", Menu::SKILL_ARMOR, AB_ARMOR_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Health Regen", Menu::SKILL_HEALTH_REGEN, AB_HEALTH_REGEN_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Armor Regen", Menu::SKILL_ARMOR_REGEN, AB_ARMOR_REGEN_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Ammo Regen", Menu::SKILL_AMMOREGEN, AB_AMMO_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Explosive Regen", Menu::SKILL_EXPLOSIVEREGEN, AB_WEAPON_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Double Jump", Menu::SKILL_DOUBLEJUMP, AB_DOUBLEJUMP_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "First Aid (Skill)", Menu::SKILL_FIRSTAID, AB_AURA_MAX ) );
		g_SkillMenu.AddItem( Menu::CPlayerSkill( "Shock Rifle (Skill)", Menu::SKILL_SHOCKRIFLE, AB_HOLYGUARD_MAX ) );
		
		// Point increase menu
		g_SkillMenuEx.AddItem( Menu::CPointChoice( 1 ) );
		g_SkillMenuEx.AddItem( Menu::CPointChoice( 5 ) );
		g_SkillMenuEx.AddItem( Menu::CPointChoice( 10 ) );
		//g_SkillMenuEx.AddItem( Menu::CPointChoice( 15 ) );
		//g_SkillMenuEx.AddItem( Menu::CPointChoice( 20 ) );
		//g_SkillMenuEx.AddItem( Menu::CPointChoice( 25 ) );
		//g_SkillMenuEx.AddItem( Menu::CPointChoice( 50 ) );
		//g_SkillMenuEx.AddItem( Menu::CPointChoice( 100 ) );
	}
}