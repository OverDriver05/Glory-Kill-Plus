class GKStaggerToken : Inventory
{
    int staggerTimer; // Keeps track of how long they've been staggered

    Default
    {
        Inventory.MaxAmount 1;
    }

    override void DoEffect()
    {
        super.DoEffect();
        if (!Owner) return;

        // 1. Freeze the monster in place
        Owner.bNoPain = true;       // Stop them from flinching from other attacks
        Owner.bFriendly = true;     // Stop other monsters from targeting them
        Owner.A_SetTics(1);         // Freeze their animation frame

        // Optional: Spawn little blue/orange sparkles around the Owner here!

        // 2. Handle the Stagger Timer (35 tics = 1 second in DOOM)
        staggerTimer++;
        if (staggerTimer > 105) // 3 seconds total
        {
            // Time's up! The stagger ends, and the monster dies normally.
            Owner.bNoPain = false;
            Owner.bFriendly = false;
            Owner.DamageMobj(null, null, 999, "Normal"); // Finish them off
            Destroy(); // Remove the token
        }
    }
}

class GKCore : EventHandler
{
    // PART A: Intercept Damage
    override void WorldThingDamaged(WorldEvent e)
    {
        let victim = e.Thing;
        
        // Check: Is it a monster? Did its health drop to 0? Is it NOT already staggered?
        if (victim && victim.bIsMonster && victim.Health <= 0 && !victim.CountInv("GKStaggerToken"))
        {
            // PREVENT DEATH!
            victim.Health = 1; 
            
            // Give them the Stagger Token to freeze them
            victim.GiveInventory("GKStaggerToken", 1);
            
            // Force them into their "Pain" animation frame so they look hurt
            victim.SetStateLabel("Pain"); 
        }
    }

    // PART B: Listen for the Player Input
    override void NetworkProcess(ConsoleEvent e)
    {
        // Did the player just press 'E'?
        if (e.Name == "gk_execute_event")
        {
            // Find the player who pressed it
            let player = players[e.Player].mo;
            if (!player) return;

            // This is where we will check if a staggered enemy is in front of the player!
            Console.Printf("Glory Kill attempted by %s!", player.player.GetUserName());
            
            // TODO: Distance check, line-of-sight check, and trigger GKCodeX!
        }
    }
}
