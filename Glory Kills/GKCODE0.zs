class GKPuff : BulletPuff
{
    Default
    {
        +PUFFONACTORS;   // Ensures it works when hitting monsters
        +ALWAYSPUFF;     // Spawns even if it hits the sky/nothing
        +EXTREMEDEATH;   // THE MAGIC FLAG: This forces the enemy into their "Gib" state!
        DamageType "GloryKill"; // Custom damage type, useful for boss resistances later
    }
}

class GKCode : CustomInventory
{
    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE;
    }
    // We leave the 'States' empty here. 
    // This acts purely as a foundation for the variants below.
}
