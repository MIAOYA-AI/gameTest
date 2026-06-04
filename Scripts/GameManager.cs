using System;
using Godot;
using GDDictionary = Godot.Collections.Dictionary;
using GDArray = Godot.Collections.Array;
using System.Collections.Generic;

public partial class GameManager : Node3D
{
	public static GameManager Instance { get; private set; }

	public Dictionary<Collectible.CollectibleType, int> CollectedItems = new();

	[Export] public Label WinLabel;
	public bool GameOver = false;

	[Export] public GDDictionary NameToLabel = new GDDictionary
	{
		{ (int)Collectible.CollectibleType.DIAMOND, new NodePath() },
		{ (int)Collectible.CollectibleType.COIN,    new NodePath() },
		{ (int)Collectible.CollectibleType.CHERRY,  new NodePath() },
	};

	[Export] public GDArray ActivatedChaeckPoints = new GDArray();
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		if (Instance != null)
		{
			QueueFree(); // 如果已存在实例，销毁当前对象
			return;
		}
		Instance = this;

		foreach (Collectible.CollectibleType type in Enum.GetValues<Collectible.CollectibleType>())
			CollectedItems[type] = 0;
		if(WinLabel!=null)
			WinLabel.Visible = false;//$env:ANTHROPIC_AUTH_TOKEN="<你的 DeepSeek API Key>"
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	public void RespawnPlayer(Node3D body)
	{
		if (body is Player)
		{
			if (ActivatedChaeckPoints.Count == 0)
				Player.Instance.Position = Player.Instance.SpawnPosition;
			else
			{
				var closestCheckPoint = (CheckPoint)ActivatedChaeckPoints[0];
				var closestDistance=closestCheckPoint.Position.DistanceTo(Player.Instance.Position);

				foreach (CheckPoint checkPoint in ActivatedChaeckPoints)
				{
					var distance=checkPoint.Position.DistanceTo(Player.Instance.Position);
					if (distance < closestDistance)
					{
						closestCheckPoint = checkPoint;
						closestDistance = distance;
					}
				}
				
				Player.Instance.Position = closestCheckPoint.Position;
			}
				
		}

	}

	public void CollectItem(Collectible.CollectibleType type)
	{
		CollectedItems[type]++;

		var path = (NodePath)NameToLabel[(int)type];
		if (path.IsEmpty)
			return;

		GetNode<Label>(path).Text = CollectedItems[type].ToString();
	}

	public override void _ExitTree()
	{
		if (Instance == this)
			Instance = null;
	}

	public void ReloadScene()
	{
		GetTree().CallDeferred(SceneTree.MethodName.ReloadCurrentScene);
	}

	public void BackToMainMenu()
	{
		GetTree().ChangeSceneToFile("res://Scenes/main_menu.tscn");
	}
}
