using Godot;

public partial class CheckPoint : Area3D
{
	[Export] public AnimationPlayer AnimationPlayer;
	[Export] public bool FinalCheck=false;

	private bool _activated=false;

	private void OnBodyEntered(Node3D body)
	{
		if (_activated || body is not Player)
			return;

		_activated = true;
		AnimationPlayer.Play("Activate");
		
		GameManager.Instance.ActivatedChaeckPoints.Add(this);
		if (FinalCheck)
		{
			GameManager.Instance.WinLabel.Visible = true;
			Input.MouseMode = Input.MouseModeEnum.Visible;
			GameManager.Instance.GameOver = true;
		}
	}
}
