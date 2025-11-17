extends Control

@onready var ai_chat := $Background/AiChat
@onready var quote_request: HTTPRequest = $QuoteRequest


func _ready() -> void:
	visible = false  # start hidden
	
	ai_chat.player_message_submitted.connect(_on_player_message_submitted)
	ai_chat.conversation_ended.connect(_on_conversation_ended)
	quote_request.request_completed.connect(_on_quote_request_completed)


func start_conversation(initial_text: String) -> void:
	ai_chat.start_conversation(initial_text)
	visible = true


func hide_dialog() -> void:
	visible = false

## Called when the player submits a non-empty message
func _on_player_message_submitted(_player_text: String) -> void:
	# Here we will later build an AI prompt. For now we just call the quote API.
	var err := quote_request.request("https://zenquotes.io/api/random")
	if err != OK:
		push_error(err)
		ai_chat.add_npc_response("Hmm, I can't think of anything to say right now…")

func _on_quote_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		ai_chat.add_npc_response("Something went wrong while I was thinking…")
		return

	var text := body.get_string_from_utf8()
	var data = JSON.parse_string(text)

	# Expect: [ { "q": "...", "a": "...", "h": "..." } ]
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
		var item = data[0]
		if typeof(item) == TYPE_DICTIONARY and item.has("q"):
			var quote: String  = str(item["q"])
			var author: String = str(item.get("a", ""))

			var reply := quote
			if author != "":
				reply += "\n— " + author

			ai_chat.add_npc_response(reply)
			return

	# Fallback if format isn’t as expected
	ai_chat.add_npc_response("I'm speechless right now.")


func _on_conversation_ended() -> void:
	hide_dialog()
