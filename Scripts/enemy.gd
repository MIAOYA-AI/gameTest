extends CharacterBody3D

## todo：解决Enemy的动画无法循环的问题
class_name Enemy

@onready var animation_tree:AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
