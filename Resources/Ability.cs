using Godot;
using System;

[GlobalClass]
public partial class Ability : Resource
{
    public Ability(float min, float max)
    {
        _minModifier = min;
        _maxModifier = max;
    }

    public Ability()
    {
    }
    
    private float _minModifier = 0.0f;
    private float _maxModifier = 100.0f;
    
    private int _abilityScore = 25;

    public float GetValue()
    {
        return Mathf.Lerp(_minModifier, _maxModifier, _abilityScore / 100.0f);
    }

    public void Increase(int score)
    {
        _abilityScore += score;
    }
}
