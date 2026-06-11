using Godot;
using System;

[GlobalClass]
public partial class Ability : Resource
{
    [Export] public float MinModifier = 0.0f;
    [Export] public float MaxModifier = 100.0f;

    [Export(PropertyHint.Range, "0,100")]
    public int AbilityScore = 25;

    public float GetModifier()
    {
        return Mathf.Lerp(MinModifier, MaxModifier, AbilityScore / 100.0f);
    }
}
