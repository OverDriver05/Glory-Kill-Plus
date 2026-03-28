class GKCode1 : GKCode
{
    States
    {
    Use:
        // When GKCore tells the player to "Use" this item, it triggers this state.
        TNT1 A 0 
        {
            // Draw the punch animation on layer 10 (on top of the current weapon)
            A_Overlay(10, "ExecuteAnim");
        }
        Fail; // "Fail" just means the item isn't consumed/deleted from inventory

    ExecuteAnim:
        // Frame A: The wind-up
        PUNG A 2 A_OverlayOffset(10, 0, 0); 
        
        // Frame B: Extending the arm
        PUNG B 2 A_OverlayOffset(10, 0, 0); 
        
        // Frame C: The Impact!
        PUNG C 2 
        {
            A_OverlayOffset(10, 0, 0);
            
            // A_CustomPunch(Damage, true = use puff, flags, "PuffClass", Range)
            // 999 damage + GKPuff's EXTREMEDEATH ensures a messy gib.
            // Massive damage in DOOM naturally propels enemies backward!
            A_CustomPunch(999, true, CPF_NOTURN, "GKPuff", 128); 
            
            // Play a meaty sound effect
            A_StartSound("weapons/punch", CHAN_WEAPON);
        }
        
        // Hold the punch out for a split second for impact frame
        PUNG C 5 A_OverlayOffset(10, 0, 0); 
        
        // Frame B & A: Retracting the arm back to the resting position
        PUNG B 3 A_OverlayOffset(10, 0, 0); 
        PUNG A 3 A_OverlayOffset(10, 0, 0); 
        
        Stop; // Clears the overlay, returning to normal view
    }
}
