import requests
import os

API_KEY = os.environ["OPENAI_API_KEY"]
url = "https://api.openai.com/v1/responses"
headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json",
}


def get_output_text(result: dict) -> str:
    outputs = result.get("output", [])
    for item in outputs:
        if item.get("type") == "message":
            for c in item.get("content", []):
                if c.get("type") == "output_text":
                    return c.get("text", "")
    return ""


# Start a conversation transcript
transcript = """You are Buddy, a humble blacksmith NPC in a fantasy RPG.
Speak concisely, like classic SNES RPG dialog.

Buddy: Welcome, traveler. What can I do for you today?
"""


def send_turn(player_text: str) -> str:
    global transcript

    # Append player line
    transcript += f"Player: {player_text}\nBuddy:"

    data = {
        "model": "gpt-5-nano",
        "input": transcript,
    }

    resp = requests.post(url, headers=headers, json=data)
    result = resp.json()

    buddy_reply = get_output_text(result).strip()

    # Append assistant reply back into transcript
    transcript += " " + buddy_reply + "\n"

    return buddy_reply


if __name__ == "__main__":
    player_lines = [
        "Hello Buddy! Can you tell me about this town?",
        "Do you have any special items for sale?",
        "Thanks, I'll be back later!",
    ]

    # Mirror the opening assistant line we put in _initial_messages
    print("Buddy: Welcome, traveler. What can I do for you today?")

    for line in player_lines:
        print(f"User: {line}")
        reply = send_turn(line)
        print(reply)
