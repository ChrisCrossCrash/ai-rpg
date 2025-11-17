# openai_api_stateful_structured.py
import os
import requests
from typing import Optional, Any

API_KEY = os.environ["OPENAI_API_KEY"]
url = "https://api.openai.com/v1/responses"
headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json",
}


def get_output_text(result: dict[str, Any]) -> str:
    """
    Extracts the assistant's output_text from a Responses API JSON result.
    """
    outputs = result.get("output", [])
    for item in outputs:
        if item.get("type") == "message":
            for c in item.get("content", []):
                if c.get("type") == "output_text":
                    return c.get("text", "")
    return ""


class BuddyConversationStructured:
    """
    A stateful conversation wrapper that uses previous_response_id
    and structured role-based messages for Buddy the blacksmith.
    """

    def __init__(self) -> None:
        self.previous_response_id: Optional[str] = None
        self.initialized: bool = False

    def _initial_messages(self, first_player_text: str) -> list[dict[str, str]]:
        """
        Build the initial structured message list for the very first turn.
        """
        return [
            {
                "role": "system",
                "content": (
                    "You are Buddy, a humble blacksmith NPC in a fantasy RPG. "
                    "You are speaking to the player, whose name is Chris. "
                    "Speak concisely, like classic SNES RPG dialog."
                ),
            },
            {
                "role": "system",
                "content": "NPC Personality: grumpy, terse blacksmith.",
            },
            {
                "role": "system",
                "content": "Faction: Iron Ring Guild. They distrust outsiders.",
            },
            {
                "role": "system",
                "content": "Town Lore: Brimstone Hollow mines ruinsstone.",
            },
            {
                "role": "system",
                "content": "Player Reputation: Chris defeated the mountain dragon.",
            },
            {
                "role": "assistant",
                "content": "Welcome, traveler. What can I do for you today?",
            },
            {
                "role": "user",
                "content": first_player_text,
            },
        ]

    def send_turn(self, player_text: str) -> str:
        """
        Sends one user turn to the model, returning Buddy's reply.
        Uses previous_response_id so the API remembers prior turns.
        """

        # First message: include all system/context messages plus the first user message
        if not self.initialized:
            input_messages = self._initial_messages(player_text)
            data: dict[str, Any] = {
                "model": "gpt-5-nano",
                "input": input_messages,
            }
            self.initialized = True
        else:
            # Subsequent messages: rely on previous_response_id for context,
            # only send the new user message.
            data = {
                "model": "gpt-5-nano",
                "previous_response_id": self.previous_response_id,
                "input": [
                    {
                        "role": "user",
                        "content": player_text,
                    }
                ],
            }

        resp = requests.post(url, headers=headers, json=data)
        resp.raise_for_status()
        result = resp.json()

        # Store response id for the next turn
        self.previous_response_id = result.get("id")

        buddy_reply = get_output_text(result).strip()
        return buddy_reply


if __name__ == "__main__":
    convo = BuddyConversationStructured()

    player_lines = [
        "Hello Buddy! Can you tell me about this town?",
        "Do you have any special items for sale?",
        "Thanks, I'll be back later!",
    ]

    # Mirror the opening assistant line we put in _initial_messages
    print("Buddy: Welcome, traveler. What can I do for you today?")

    for line in player_lines:
        print(f"User: {line}")
        reply = convo.send_turn(line)
        print(f"Buddy: {reply}")
