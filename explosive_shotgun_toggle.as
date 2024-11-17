// Explosive Shotgun Plugin with Toggle
// Modifies the default shotgun to toggle explosive shots with tertiary fire

// Dictionary to track which players have explosive mode enabled
dictionary g_ExplosiveMode;

void PluginInit() 
{
    g_Module.ScriptInfo.SetAuthor("Example");
    g_Module.ScriptInfo.SetContactInfo("Created for demonstration");
    
    // Register hooks
    g_Hooks.RegisterHook(Hooks::Weapon::WeaponPrimaryAttack, @OnWeaponPrimaryAttack);
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @OnClientPutInServer);
    g_Hooks.RegisterHook(Hooks::Weapon::WeaponTertiaryAttack, @OnWeaponTertiaryAttack);
}

HookReturnCode OnClientPutInServer(CBasePlayer@ pPlayer) 
{
    if (pPlayer is null)
        return HOOK_CONTINUE;
        
    // Initialize player's explosive mode to false
    string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    g_ExplosiveMode[steamId] = false;
    
    return HOOK_CONTINUE;
}

HookReturnCode OnWeaponTertiaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon) 
{
    if (pWeapon is null || pPlayer is null)
        return HOOK_CONTINUE;
        
    // Only handle shotgun tertiary attack
    if (pWeapon.GetClassname() == "weapon_shotgun") 
    {
        string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        bool currentMode = cast<bool>(g_ExplosiveMode[steamId]);
        
        // Toggle mode
        g_ExplosiveMode[steamId] = !currentMode;
        
        // Notify player of mode change
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, 
            "Explosive rounds: " + (cast<bool>(g_ExplosiveMode[steamId]) ? "ENABLED" : "DISABLED") + "\n");
            
        // Play toggle sound
        g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_WEAPON, "buttons/lightswitch2.wav", 1.0f, ATTN_NORM, 0, 100);
    }
    
    return HOOK_CONTINUE;
}

HookReturnCode OnWeaponPrimaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon) 
{
    if (pWeapon is null || pPlayer is null)
        return HOOK_CONTINUE;
        
    // Check if weapon is shotgun
    if (pWeapon.GetClassname() == "weapon_shotgun") 
    {
        string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        
        // Only create explosion if explosive mode is enabled for this player
        if (cast<bool>(g_ExplosiveMode[steamId])) 
        {
            // Get player's view angles and position
            Vector vecSrc = pPlayer.GetGunPosition();
            Vector vecAiming = pPlayer.GetAutoaimVector(0.0f);
            
            // Create tracer effect for visual feedback
            NetworkMessage tracers(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY);
            tracers.WriteByte(TE_TRACER);
            tracers.WriteCoord(vecSrc.x);
            tracers.WriteCoord(vecSrc.y);
            tracers.WriteCoord(vecSrc.z);
            tracers.WriteCoord(vecSrc.x + vecAiming.x * 4096);
            tracers.WriteCoord(vecSrc.y + vecAiming.y * 4096);
            tracers.WriteCoord(vecSrc.z + vecAiming.z * 4096);
            tracers.End();
            
            // Create explosion at impact point
            TraceResult tr;
            g_Utility.TraceLine(vecSrc, vecSrc + vecAiming * 4096, dont_ignore_monsters, pPlayer.edict(), tr);
            
            // Create explosion with enhanced visual effect
            g_EntityFuncs.CreateExplosion(tr.vecEndPos, Vector(0, 0, 0), null, 100, true);
            
            // Apply radius damage with gibbing
            g_WeaponFuncs.RadiusDamage(
                tr.vecEndPos,
                pWeapon.pev,
                pPlayer.pev,
                50.0f,
                150.0f,
                CLASS_NONE,
                DMG_ALWAYSGIB
            );
        }
    }
    
    return HOOK_CONTINUE;
}

void MapInit() 
{
    // Precache explosion sprites and sounds
    g_Game.PrecacheModel("sprites/zerogxplode.spr");
    g_Game.PrecacheSound("weapons/explode3.wav");
    g_Game.PrecacheSound("buttons/lightswitch2.wav");
    
    // Gib-related precaches
    g_Game.PrecacheModel("models/hgibs.mdl");
    g_Game.PrecacheSound("common/bodysplat.wav");
    
    // Clear the explosive mode dictionary on map change
    g_ExplosiveMode.deleteAll();
}
