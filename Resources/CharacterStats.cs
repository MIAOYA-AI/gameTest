using Godot;
using System;

[GlobalClass]
public partial class CharacterStats : Resource
{
    [Export] public int Level = 1;
    [Export] public int Xp = 0;
    [Export] public int CurHealth = 0;

    [Export] public Ability Strength = new(80.0f,240.0f);//造成的伤害
    [Export] public Ability Speed = new(3.0f,7.0f);//m/s
    [Export] public Ability Endurance = new(50f,100f) ;//血量
    [Export] public Ability Agility = new(0.00f,1f);//暴击机率

    public void IncreaseXp(int value)
    {
        Xp += value;
        while (Xp > PercentageLevelUpBoundary())
        {
            Xp -= PercentageLevelUpBoundary();
            _levelUp();
        }
    }
    
    [Signal]
    public delegate void LevelUpEventHandler();
    
    public void _levelUp()
    {
        Level++;
        GD.Print("Level Up:"+Level);
        Strength.Increase(10);
        Speed.Increase(10);
        Endurance.Increase(10);
        Agility.Increase(10);
        GD.Print(Strength.GetValue());
        GD.Print(Speed.GetValue());
        GD.Print(Endurance.GetValue());
        GD.Print(Agility.GetValue());
        GD.Print(GetMaxHp());
        GD.Print(GetDashCooldown());

        EmitSignal(SignalName.LevelUp);
    }

    public int PercentageLevelUpBoundary()
    {
        return (int)(50*Math.Pow(1.2,Level));
    }

    public int GetMaxHp()
    {
        return 20 + (int)(Level * Endurance.GetValue());
    }

    public float GetDashCooldown()
    {
        return (float)Mathf.Max(0.5,1.5f-Agility.GetValue());
    }
}