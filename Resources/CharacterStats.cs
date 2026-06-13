using Godot;
using System; 

[GlobalClass]
public partial class CharacterStats : Resource
{
    [Export] public int Level = 1;
    [Export] public int Xp = 0;

    [Export] public Ability Strength = new(80.0f,100.0f);//造成的伤害
    [Export] public Ability Speed = new(3.0f,7.0f);//m/s
    [Export] public Ability Endurance = new(50f,100f) ;//血量
    [Export] public Ability Agility = new(0.05f,0.25f);//暴击机率
}