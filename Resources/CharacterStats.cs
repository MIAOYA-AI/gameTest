using Godot;
using System;

public partial class CharacterStats : Resource
{
    public class Ability
    {
        private float minModifier;
        private float maxModifier;

        public Ability()
        {
            minModifier = 0.0f;
            maxModifier = 100.0f;
        }
        public Ability(float min, float max)
        {
            minModifier = min;
            maxModifier = max;
        }
        //abilityScore的范围是0到100
        //根据abilityScore与该属性的最大最小值得到最终的属性插值
        private int abilityScore = 25;
        public int AbilityScore
        {
            get => abilityScore;
            set => abilityScore = Math.Clamp(value, 0, 100);
        }
    }
    
    public Ability Level = new  Ability(0.0f,100.0f);
    public Ability Xp=new  Ability();
        
    public Ability Strength=new  Ability();
    public Ability Speed=new  Ability(3.0f,7.0f);
    public Ability Endurance=new  Ability();
    public Ability Agility=new  Ability();
}
