using Godot;
using System;

[GlobalClass]
public partial class Ability : Resource
{
    public Ability(float min, float max)
    {
        MinModifier = min;
        MaxModifier = max;
    }

    public Ability()
    {
        
    }
    
    private float MinModifier = 0.0f;
    private float MaxModifier = 100.0f;

    [Export(PropertyHint.Range, "0,100")]
    public int AbilityScore = 25;

    public float GetValue()
    {
        return Mathf.Lerp(MinModifier, MaxModifier, AbilityScore / 100.0f);
    }
}
