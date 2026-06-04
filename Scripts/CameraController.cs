using Godot;
using System;

public partial class CameraController : SpringArm3D
{
	[Export]
	public float MouseSensitivity = 0.1f;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		Input.MouseMode = Input.MouseModeEnum.Captured;
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	public override void _Input(InputEvent @event)
	{
		base._Input(@event);

		if (@event is InputEventMouseMotion mouseMotion)
		{
			var mouseDelta=mouseMotion.Relative;
			Rotation = Rotation with { Y = Rotation.Y - mouseDelta.X * MouseSensitivity ,X =Mathf.Clamp(Rotation.X - mouseDelta.Y * MouseSensitivity,-Single.Pi/2,Single.Pi/4)};
		}

		if (@event is InputEventKey key)
		{
			if (key.Keycode == Key.Tab && key.Pressed)
			{
				if (Input.MouseMode == Input.MouseModeEnum.Captured)
					Input.MouseMode = Input.MouseModeEnum.Visible;
				else if(Input.MouseMode == Input.MouseModeEnum.Visible)
					Input.MouseMode = Input.MouseModeEnum.Captured;
			}
		}
	}
}
