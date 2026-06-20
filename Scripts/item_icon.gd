extends TextureButton
class_name ItemIcon

signal item_interact(item)

@onready var name_label: Label = %NameLabel
@onready var num_label: Label = %NumLabel

func _on_pressed() -> void:
	item_interact.emit(self)
