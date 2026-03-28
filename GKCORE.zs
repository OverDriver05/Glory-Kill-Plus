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

    override void NetworkProcess(ConsoleEvent e)
    {
        // Did the player just press the Glory Kill key?
        if (e.Name == "gk_execute_event")
        {
            // Find the physical body (mo) of the player who pressed it
            let player = players[e.Player].mo;
            
            // Safety check: Make sure the player exists and isn't dead
            if (!player || player.Health <= 0) return; 

            double maxGKRange = 96.0; // How close you need to be (96 units is a good melee range)
            Actor targetEnemy = null;
            double closestDist = maxGKRange;

            // Create an iterator to search the area around the player
            BlockThingsIterator it = BlockThingsIterator.Create(player, maxGKRange);
            
            while (it.Next())
            {
                Actor mo = it.thing;
                
                // Filter out junk: Ignore empty space, the player themselves, and non-monsters
                if (!mo || mo == player || !mo.bIsMonster) continue;
                
                // Is the monster staggered? (Checking for our custom token)
                if (mo.CountInv("GKStaggerToken") == 0) continue; 

                // Calculate the true 3D distance
                double dist = player.Distance3D(mo);
                
                // Check 1 & 2: Are they within range AND can the player actually see them?
                if (dist <= closestDist && player.CheckSight(mo))
                {
                    // Check 3: Are we actually looking at them? (Field of View check)
                    double angleTo = player.AngleTo(mo);
                    double angleDiff = deltaangle(player.angle, angleTo);
                    
                    // If the enemy is within a 90-degree cone in front of the player
                    if (abs(angleDiff) < 45.0) 
                    {
                        closestDist = dist; // Update the closest distance
                        targetEnemy = mo;   // We found our victim!
                    }
                }
            }

            if (targetEnemy)
            {
                Console.Printf(" ", targetEnemy.GetClassName());
                
                // 1. Take away the stagger token so the timer stops
                targetEnemy.TakeInventory("GKStaggerToken", 1);
                
                // 2. We need to hand this off to GKCODE.zs to handle the animation and death!
                // We will call your custom execution logic here in the next step.
            }
            else
            {
                // Optional: Play a "whiff" sound if they press E but nothing is in range
                // player.A_StartSound("misc/gk_fail", CHAN_BODY);
            }
        }
    }
