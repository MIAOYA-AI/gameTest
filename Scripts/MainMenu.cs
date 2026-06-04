using Godot;
using System;

public partial class MainMenu : Node3D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	public void StartGame()
	{
		GetTree().ChangeSceneToFile("res://Scenes/game_scene.tscn");
	}

	public void ExitGame()
	{
		GetTree().Quit();
	}
}
