extends Control

signal player_message_submitted(text: String)
signal conversation_ended

@onready var chat_log: RichTextLabel = $VBoxContainer/ScrollContainer/ChatLog
@onready var user_input: LineEdit      = $VBoxContainer/InputRow/UserInput
@onready var scroll_container: ScrollContainer   = $VBoxContainer/ScrollContainer

var lines: Array[String] = []  # keeps history, rendered as one big block

# Call this when an NPC interaction starts
func start_conversation(initial_npc_line: String) -> void:
	lines.clear()
	_add_npc_line(initial_npc_line)
	_update_log()
	user_input.text = ""
	user_input.grab_focus()

## Player pressed Enter in the LineEdit (hook up via signal in the editor)
func _on_user_input_text_submitted(text: String) -> void:
	# Empty line => end conversation
	if text.strip_edges() == "":
		emit_signal("conversation_ended")
		return

	_add_player_line(text)
	user_input.text = ""

	_update_log()
	_scroll_to_bottom()

	# Tell parent (DialogBox) to get an AI response
	emit_signal("player_message_submitted", text)

## Public method for parent to append NPC/AI responses
func add_npc_response(text: String) -> void:
	_add_npc_line(text)
	_update_log()
	_scroll_to_bottom()

# --- Internal helpers ---

func _add_npc_line(text: String) -> void:
	lines.append(text)

func _add_player_line(text: String) -> void:
	# Two spaces + "> " to get the retro indented look
	lines.append("  > " + text)

func _update_log() -> void:
	chat_log.text = "\n".join(lines)

func _scroll_to_bottom() -> void:
	# small deferred call so layout has updated
	await get_tree().process_frame
	scroll_container.scroll_vertical = ceil(scroll_container.get_v_scroll_bar().max_value)
