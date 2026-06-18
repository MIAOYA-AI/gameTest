extends TextureButton
class_name ItemIcon

signal interact(item)

@onready var name_label: Label = %NameLabel
@onready var num_label: Label = %NumLabel


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action("click"):
		interact.emit(self)
