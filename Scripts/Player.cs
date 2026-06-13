using Godot;
using System;

//TODO：解决玩家攻击过程中按移动键会反复攻击的问题
[GlobalClass]
public partial class Player : CharacterBody3D
{
    [Export] public float Speed = 5.0f;
    [Export] public float Damage = 5.0f;
    [Export] public float JumpVelocity = 4.5f;
    [Export] public Camera3D Camera;
    [Export] public Node3D Model;
    [Export] public AnimationTree AnimationTree;
    [Export] public Vector3 Direction;
    //为了方便与enemy的gbscript脚本使用通用组件，这里采用gbscript的命名方式
    [Export] public Node health_component;
    public Vector3 CurDirection=Vector3.Zero;

    [Export] public bool IsJumping=false;
    [Export] public bool IsAttacking=false;
    [Export] public bool IsHeavyAttacking=false;
    [Export] public bool IsDash=false;
    [Export] public bool IsDefeat = false;
    
    [ExportCategory("RPG Stats")]
    [Export] public CharacterStats MyStats;

    public Vector3 SpawnPosition;
    private float TargetAngle = Single.Pi;
    public static Player Instance { get; private set; }
    private AnimationNodeStateMachinePlayback _playback;

    public override void _Ready()
    {
        SpawnPosition = Position;
        if (Instance != null)
        {
            QueueFree(); // 如果已存在实例，销毁当前对象  
            return;
        }

        Instance = this;

        if (AnimationTree != null)
        {
            _playback = (AnimationNodeStateMachinePlayback)AnimationTree.Get("parameters/StateMachine/playback");
        }
        
        if(CurDirection == Vector3.Zero)
            CurDirection = Model.GlobalTransform.Basis.Z;
        
        //初始化所有属性值
        InitAttribute();
    }

    public override void _Process(double delta)
    {
        //将模型相对相机方向移动并插值 暂时停用
        // var cameraAngle = Camera.GlobalRotation.Y;
        // Vector2 inputDir = Input.GetVector("left", "right", "forward", "backward");
        // var inputAngle = Godot.Mathf.Atan2(inputDir.X, inputDir.Y);
        // if (inputDir != Vector2.Zero && !GameManager.Instance.GameOver)
        //     TargetAngle = cameraAngle + inputAngle;
        // Model.GlobalRotation = Model.GlobalRotation with { Y = Mathf.LerpAngle(Model.GlobalRotation.Y, TargetAngle, (float)delta * 10f) };
    }

    public void LookTowardDirection(Vector3 dir, double delta)
    {
        Transform3D targetTranform=Model.GlobalTransform.LookingAt(Model.GlobalPosition+dir,Vector3.Up,true);
        //Model.GlobalTransform = Model.GlobalTransform with{Basis = targetTranform.Basis};
        Model.GlobalTransform=Model.GlobalTransform.InterpolateWith(targetTranform,(float)delta * 10f);
    }

    public override void _ExitTree()
    {
        if (Instance == this)
            Instance = null;
    }

    public override void _PhysicsProcess(double delta)
    {
        HandInput();
        Move(delta);
    }

    private void InitAttribute()
    {
        Speed = MyStats.Speed.GetValue();
        Damage=MyStats.Strength.GetValue();
    }

    // Handle input.
    private void HandInput()
    {
        
        if (Input.IsActionJustPressed("jump") && IsOnFloor())
        {
            IsJumping = true;
        }
        if (Input.IsActionJustPressed("attack") && IsOnFloor())
        {
            IsAttacking = true;
        }
        if (Input.IsActionJustPressed("heavy_attack") && IsOnFloor())
        {
            IsHeavyAttacking = true;
        }
        if (Input.IsActionJustPressed("dash") && IsOnFloor())
        {
            IsDash = true;
        }
        
        //测试按钮
        if (Input.IsActionJustPressed("test"))
            MyStats._levelUp();
    }

    private void Move(double delta)
    {
        Vector3 velocity = Velocity;
        if (IsJumping)
        {
            velocity.Y = JumpVelocity;
            //跳完后将状态重置
            IsJumping = false;
        }
            
        // Add the gravity.
        if (!IsOnFloor())
        {
            velocity += GetGravity() * (float)delta;
        }

        // Get the input direction and handle the movement/deceleration.
        // As good practice, you should replace UI actions with custom gameplay actions.
        Vector2 inputDir = Input.GetVector("left", "right", "forward", "backward");
        Direction = (Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();
        Direction = Direction.Rotated(Vector3.Up, Camera.GlobalRotation.Y);//Camera.Rotation是与上一级节点的旋转角度，这里因为有旋转臂，所以为0
        
        if (Direction != Vector3.Zero && !GameManager.Instance.GameOver&&!IsAttacking&&!IsDefeat)
        {
            velocity.X = Direction.X * Speed;
            velocity.Z = Direction.Z * Speed;
            CurDirection = Direction;
            LookTowardDirection(Direction, delta);
        }
        else
        {
            velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
            velocity.Z = Mathf.MoveToward(Velocity.Z, 0, Speed);
        }

        Velocity = velocity;
        MoveAndSlide();
    }

    public void PlayAnimation(string animationName, bool blend = true)
    {
        if (_playback == null)
            return;

        if (blend)
            _playback.Travel(animationName);  // ✅ 带过渡
        else
            _playback.Start(animationName);   // ✅ 直接切换
    }

    public void PlayAttackOneShot()
    {
        AnimationTree.Set("parameters/Attack/request", (int)AnimationNodeOneShot.OneShotRequest.Fire);
    }

    public void HitSomething(Node3D body)
    {
        if (body is CharacterBody3D bodyNode)
        {
            GD.Print($"Hit: {bodyNode.Name}");
        }
    }
}
