// GKCORE.zc

// A simple token to mark an enemy as "Staggered"
class GKStaggerToken : Inventory {
    Default {
        Inventory.MaxAmount 1;
    }
}

// The core brain of the Glory Kill system
class GKEventHandler : EventHandler {
    
    // Check every time something takes damage
    override void WorldThingDamaged(WorldEvent e) {
        if (!e.Thing || !e.Thing.bIsMonster) return; // Ignore non-monsters
        if (e.Thing.Health <= 0) return; // Ignore dead things

        // Calculate 15% of the monster's maximum spawn health
        int staggerThreshold = e.Thing.SpawnHealth() * 0.15;

        // If health falls into stagger threshold, and they aren't staggered yet
        if (e.Thing.Health <= staggerThreshold && !e.Thing.CountInv("GKStaggerToken")) {
            
            // Give them the stagger token
            e.Thing.GiveInventory("GKStaggerToken", 1);
            
            // Make them glow red to signify they are staggered (Visual indicator)
            e.Thing.A_SetRenderStyle(0.8, STYLE_Add);
            
            // Note: Later we can add a custom stun animation state here!
        }
    }

    // Listen for the 'E' key being pressed
    override void NetworkProcess(ConsoleEvent e) {
        if (e.Name == "gk_execute") {
            PlayerInfo p = players[e.Player];
            if (!p || !p.mo) return;

            // Cast an invisible ray from the player's view
            FLineTraceData trace;
            double hitDistance = 128.0; // Glory Kill reach range (128 units)
            
            bool hit = p.mo.LineTrace(
                p.mo.angle, 
                hitDistance, 
                p.mo.pitch, 
                TRF_ALLACTORS, 
                p.mo.player.viewheight, 
                data: trace
            );

            // If the ray hits a monster with the stagger token
            if (hit && trace.HitActor && trace.HitActor.CountInv("GKStaggerToken")) {
                // Execute the Glory Kill!
                GKExecutor.PerformGloryKill(p.mo, trace.HitActor);
            }
        }
    }
}

// GKCODE.zc

class GKExecutor : Object {
    
    // Static function to handle the Glory Kill logic
    static void PerformGloryKill(Actor player, Actor victim) {
        
        // 1. Check for specific weapon/boss types here later!
        // For now, we perform the Universal Melee Glory Kill.

        // 2. Make the player temporarily invincible
        player.GiveInventory("PowerInvulnerable", 1);
        
        // 3. Optional: Thrust player toward the enemy to close the gap
        player.A_Face(victim);
        
        // 4. Play a meaty sound effect (We can define custom sounds later)
        player.A_StartSound("misc/teleport", CHAN_WEAPON);
        
        // 5. Spawn health drops as a reward
        Actor healthDrop = Actor.Spawn("HealthBonus", victim.Pos);
        if (healthDrop) {
            // Pop the health bonus up into the air dynamically
            healthDrop.Vel.Z = 5.0; 
            healthDrop.Vel.X = random(-2, 2);
            healthDrop.Vel.Y = random(-2, 2);
        }

        // 6. Brutally execute the monster!
        // We use 'Telefrag' damage type to bypass all armor and resistances
        victim.DamageMobj(player, player, victim.Health + 100, 'Telefrag');

        // 7. Remove the invulnerability shortly after (Requires a custom powerup or delay system later)
        player.TakeInventory("PowerInvulnerable", 1);
        
        // Console message for testing purposes
        Console.Printf(" ");
    }
}
