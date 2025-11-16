extends Control

@onready var ai_chat := $Background/AiChat


func _ready() -> void:
	visible = false  # start hidden
	
	ai_chat.player_message_submitted.connect(_on_player_message_submitted)
	ai_chat.conversation_ended.connect(_on_conversation_ended)


func start_conversation(initial_text: String) -> void:
	ai_chat.start_conversation(initial_text)
	visible = true


func hide_dialog() -> void:
	visible = false

## Called when the player submits a non-empty message
func _on_player_message_submitted(_player_text: String) -> void:
	# TEMPORARY: Fake NPC response so we can test the UI loop.
	# Later, this will call the OpenAI API.
	var npc_response := "Me? I'm just a humble blacksmith. Stop by my shop!"
	ai_chat.add_npc_response(npc_response)

func _on_conversation_ended() -> void:
	hide_dialog()
