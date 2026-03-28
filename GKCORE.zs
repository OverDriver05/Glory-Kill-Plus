// We use an EventHandler because it runs in the background and listens to everything happening in the game.
class GKCore : EventHandler
{
    // This virtual function triggers every time something takes damage in the world.
    override void WorldThingDamaged(WorldEvent e)
    {
        // 1. Identify the participants
        Actor target = e.Thing; // The monster taking damage
        Actor inflictor = e.Inflictor; // What caused the damage (projectile, fist, etc.)
        Actor source = e.DamageSource; // Who caused the damage (the player)

        // Make sure the source is a player and the target is a monster
        if (!source || !source.player || !target || !target.bISMONSTER) return;

        // 2. Check the Enemy's Remaining Health
        // Assuming 'StaggerThreshold' is a custom value we set later (e.g., 10% of max health)
        if (target.Health <= target.SpawnHealth() * 0.10 && target.Health > 0)
        {
            // The enemy is eligible for a Glory Kill! 
            // Here we would force them into a "Stagger" state.
            // target.SetStateLabel("Stagger"); 
        }
    }

    // This custom function evaluates all your parameters when the player tries to initiate the kill
    void TryGloryKill(PlayerPawn player, Actor enemy)
    {
        // --- THE PARAMETER CHECKS ---
        
        // 1. Current Weapon Equipped
        Weapon currentWeapon = player.player.ReadyWeapon;
        
        // 2. Player's Health and Armor
        int pHealth = player.Health;
        int pArmor = player.CountInv("BasicArmor");

        // 3. Difficulty Selected (GameSkill)
        int currentDifficulty = G_SkillProperty(SKILLP_ACSReturn); 

        // 4. Enemy Class
        string enemyClass = enemy.GetClassName();

        // --- THE CATEGORY ROUTING ---
        
        // Check Boss Glory Kill first (Highest Priority)
        if (IsBossClass(enemyClass))
        {
            ExecuteBossGloryKill(player, enemy);
            return;
        }

        // Check Weapon Glory Kill next
        // (Requires specific weapon and checks remaining ammunition)
        if (currentWeapon && CheckWeaponAmmo(currentWeapon)) 
        {
            ExecuteWeaponGloryKill(player, enemy, currentWeapon);
            return;
        }

        // Default to Melee Glory Kill (Universal)
        ExecuteMeleeGloryKill(player, enemy);
    }

    // --- THE EXECUTION TRIGGERS ---

    void ExecuteMeleeGloryKill(PlayerPawn player, Actor enemy)
    {
        // Code to randomly select a GKCodeX from the Melee pool
        // e.g., Spawn("GKCode_Melee_01", player.Pos);
        Console.Printf("Executing Universal Melee Glory Kill!");
    }

    void ExecuteWeaponGloryKill(PlayerPawn player, Actor enemy, Weapon currentWeapon)
    {
        // Code to randomly select a GKCodeX from the Weapon pool based on currentWeapon
        // Deduct ammo here before executing
        Console.Printf("Executing Weapon Glory Kill with %s!", currentWeapon.GetClassName());
    }

    void ExecuteBossGloryKill(PlayerPawn player, Actor enemy)
    {
        // Code to execute the specific, cinematic boss kill
        Console.Printf("Executing Boss Glory Kill!");
    }

    // --- HELPER FUNCTIONS ---
    
    bool IsBossClass(string className)
    {
        // Check if the enemy is a Cyberdemon, Spider Mastermind, etc.
        if (className == "Cyberdemon" || className == "SpiderMastermind") return true;
        return false;
    }

    bool CheckWeaponAmmo(Weapon wep)
    {
        // Logic to check if the equipped weapon has enough ammo to perform the kill
        // Returns true if enough ammo, false if empty
        return true; 
    }
}
