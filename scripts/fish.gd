class_name Fish
extends Resource

enum Type { GENTLE, HEAVY }
enum Outcome { ESCAPED, RAN_AWAY, FREED, PASSED_OUT }

@export var fish_id: String = ""; # unique key e.g. "kid_fish", "waiting_lady"
@export var fish_name: String = ""; # display name
@export var portraits: Dictionary = {}
# e.g. { "default": <Texture>, "angry": <Texture>, "satisfied": <Texture> }

# for heavy hearted souls
@export var has_minigame: bool = false;
@export var minigame_id: String = ""; # "cake_dodge", etc — minigame router uses this


# Each step is a Dictionary:
# {
#   "speaker": "fish" | "player" | "monologue",
#   "text": String,
#   "choices": [{ "label": String, "next": int }]  -- optional
# }
# "next": -1 means the fish escapes (good end).
# "next": -2 means the fish runs away (bad end).
@export var dialogue: Array = []
