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


class BuddyConversation:
    """
    A stateful conversation wrapper that uses previous_response_id
    to let the Responses API keep track of context.
    """

    def __init__(self) -> None:
        self.previous_response_id: Optional[str] = None

    def send_turn(self, player_text: str) -> str:
        """
        Sends one user turn to the model, returning Buddy's reply.
        Uses previous_response_id so the API remembers prior turns.
        """

        # First message: include instructions + first user message
        if self.previous_response_id is None:
            input_payload = (
                "You are Buddy, a humble blacksmith NPC in a fantasy RPG.\n"
                "Speak concisely, like classic SNES RPG dialog.\n\n"
                "Buddy: Welcome, traveler. What can I do for you today?\n"
                f"Player: {player_text}\n"
                "Buddy:"
            )

            data = {
                "model": "gpt-5-nano",
                "input": input_payload,
            }

        else:
            # After the first message, we can keep it simpler:
            # rely on previous_response_id to supply history
            data = {
                "model": "gpt-5-nano",
                "input": f"Player: {player_text}\nBuddy:",
                "previous_response_id": self.previous_response_id,
            }

        resp = requests.post(url, headers=headers, json=data)
        resp.raise_for_status()
        result = resp.json()

        # Store response id for next turn
        self.previous_response_id = result.get("id")

        buddy_reply = get_output_text(result).strip()
        return buddy_reply


if __name__ == "__main__":
    convo = BuddyConversation()

    player_lines = [
        "Hello Buddy! I'm Chris. Can you tell me about this town?",
        "Do you have any special items for sale?",
        "Thanks, Buddy! I'll be back later!",
    ]

    # Mirror the opening assistant line we put in _initial_messages
    print("Buddy: Welcome, traveler. What can I do for you today?")

    for line in player_lines:
        print(f"User: {line}")
        reply = convo.send_turn(line)
        print(f"Buddy: {reply}")
