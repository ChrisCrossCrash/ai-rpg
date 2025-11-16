extends Control

@onready var text_label: Label = $Background/Text


func _ready() -> void:
	visible = false  # start hidden


func show_dialog(text: String) -> void:
	text_label.text = text
	visible = true


func hide_dialog() -> void:
	visible = false
