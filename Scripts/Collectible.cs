using Godot;
using System;

public partial class Collectible : Area3D
{
	public enum CollectibleType
	{
		DIAMOND,
		COIN,
		CHERRY
	}

	[Export] public CollectibleType Type;
	[Export] public PackedScene DiamondModel;
	[Export] public PackedScene CoinModel;
	[Export] public PackedScene CherryModel;
	
	[Export] public float RotationSpeed = 0.5f;
	[Export] public float FloatingSpeed = 0.001f;
	[Export] public float FloatingMagnitude = 0.5f;

	private float OriginalY;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		OriginalY = Position.Y;

		Type=(CollectibleType)GD.RandRange(0,2);
		PackedScene model=null;
		switch (Type)
		{
			case CollectibleType.DIAMOND:
				model = DiamondModel;
				break;
			case CollectibleType.COIN:
				model = CoinModel;
				break;
			case CollectibleType.CHERRY:
				model = CherryModel;
				break;
			default:
				break;
		}

		if (model != null)
		{
			Node node = model.Instantiate();
			AddChild(node);
		}
		
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		//RotateY((float)delta*RotationSpeed);
		Rotation=Rotation with {Y=Rotation.Y+(float)delta*RotationSpeed};
		Position=Position with {Y=OriginalY+float.Sin((float)Time.GetTicksMsec()*FloatingSpeed)*0.5f};
	}

	private void OnBodyEntered(Node3D body)
	{
		if (body is CharacterBody3D bodyNode)
		{
			GameManager.Instance?.CollectItem(Type);
			CallDeferred(Node.MethodName.QueueFree);
		}
	}
}
