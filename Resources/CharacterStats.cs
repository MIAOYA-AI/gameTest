using Godot;
using System;

[GlobalClass]
public partial class CharacterStats : Resource
{
    [Export] public Ability Level = new() { MinModifier = 0.0f, MaxModifier = 100.0f };
    [Export] public Ability Xp = new();

    [Export] public Ability Strength = new();
    [Export] public Ability Speed = new() { MinModifier = 3.0f, MaxModifier = 7.0f };
    [Export] public Ability Endurance = new();
    [Export] public Ability Agility = new();
}