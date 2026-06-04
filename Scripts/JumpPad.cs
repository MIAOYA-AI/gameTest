using Godot;
using System;

public partial class JumpPad : Area3D
{
	[Export] public float JumpVeloctity = 10.0f;
	[Export] public GpuParticles3D Particles;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	private void OnBodyEntered(Node3D body)
	{
		if (body is CharacterBody3D bodyNode)
		{
			bodyNode.Velocity=bodyNode.Velocity with {Y=JumpVeloctity};
			Particles.Restart();
		}
	}
}
