extends Node

# ---------------------------------------------------------------------------
# FishData — single source of truth for all fish in the game.
# Add new fish here. main.gd pulls from this pool randomly.
# ---------------------------------------------------------------------------

static func getFirstFish() -> Fish:
	return firstFish();

static func getGentlePool() -> Array:
	var pool = [];
	
	if not GameState.tutorial_complete:
		pool.append(grumpyOldMan())  # tutorial only
	else:
		if GameState.soul_tier == 2:
			pool.append(kidFish());
			pool.append(loverFish());
		elif GameState.soul_tier == 3:
			pass # add more gentle fish here
		
	return filterPool(pool);
	
static func getHeavyPool() -> Array:
	var pool = [];
	
	if not GameState.tutorial_complete:
		pool.append(waitingLady());
	else:
		if GameState.soul_tier == 2:
			pass; # add more heavy hearted fish here
		#else:
			#pass
		
	return filterPool(pool);

static func filterPool(pool: Array) -> Array:
	return pool.filter(func(f): return not GameState.freed_souls.has(f.fish_id))

# ---------------------------------------------------------------------------
# How the dialogue per fish works: 
# Fish -> Player (always next line or element)
# Player element includes a "label" key with text and a "next" key with jump to line
# 		-1 : fish resolved / good end
#		-2 : fish escapes  / bad end
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# COMMON SOUL  (gentle — linear, no choices)
# ---------------------------------------------------------------------------
static func firstFish() -> Fish:
	var f = Fish.new()
	f.fish_name = "???";
	f.fish_id = "first_fish";
	f.portraits = {
		"default": preload("res://assets/fish portrait/first/plain.PNG"),
	}
	f.dialogue = [
		{
			"speaker": "fish",
			"text": "...Oh. You can see me? That's new. It has been ages since I saw a person."
		},
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "...",        "next": 2 },
				{ "label": "Who are you?", "next": 2 }
			]
		},
		{
			"speaker": "fish",
			"text": "I was... No. That part isn't important. But I will give you advice, kiddo. You shouldn't hold on too tight. It hurts more when you do that.",
			"next": -1  # escape (good end)
		}
	]
	return f

# ---------------------------------------------------------------------------
# GRUMPY OLD MAN  (heavy — branches, one bad end)
# ---------------------------------------------------------------------------
static func grumpyOldMan() -> Fish:
	var f = Fish.new()
	f.fish_name = "Grumpy Man"
	f.fish_id = "grumpy_old_man";
	f.portraits = {
		"default": preload("res://assets/fish portrait/grumpy-man/man.PNG"),
		"angry": preload("res://assets/fish portrait/grumpy-man/man_angry.PNG"),
	}

	f.dialogue = [
		# 0
		{
			"speaker": "fish",
			"text": "Humph! Careful with that line! Kids these days have no respect at all. Where are your parents? I need to talk to them!",
		},
		# 1 — first choice
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "Sorry...",       "next": 2 },
				{ "label": "You seem upset.", "next": 6 }
			]
		},
		# --- BRANCH A: apologize ---
		# 2
		{
			"speaker": "fish",
			"text": "At least you know when to apologize. That's rare, these days.",
		},
		# 3
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "I didn't mean to hurt you.", "next": 4 },
				{ "label": "I'll be more careful.",      "next": 5 }
			]
		},
		# 4
		{
			"speaker": "fish",
			"text": "Hmph. Well. Intentions matter, I suppose.",
			"next": -1,
		},
		# 5
		{
			"speaker": "fish",
			"text": "Good. That's all I ever asked of anyone.",
			"next": -1
		},
		# --- BRANCH B: you seem upset ---
		# 6
		{
			"speaker": "fish",
			"text": "OF COURSE I AM UPSET! You yanked me out like I was nothing!",
			"emotion": "angry",
		},
		# 7
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "You're not nothing.",          "next": 8 },
				{ "label": "You talk a lot for a fish.", "next": 9 }
			]
		},
		# 8 — good end from branch B
		{
			"speaker": "fish",
			"text": "Hah. Well, that's better than most. Maybe you're not as careless as you look. Very well. Just this once. And your grip needs to be better.",
			"next": -1
		},
		# 9 — bad end
		{
			"speaker": "fish",
			"text": "THIS CHILD— no manners, no patience, no— ugh. I don't have time for this.",
			"emotion": "angry",
			"next": -2  # fish runs away
		}
	]
	return f

# ---------------------------------------------------------------------------
# THE WAITING LADY  (heavy — cake gag + flower minigame)
# Phase 1: conversation. Cake path = blackout. Flower path = minigame signal.
# ---------------------------------------------------------------------------
static func waitingLady() -> Fish:
	var f = Fish.new()
	f.fish_name = "A Lady"
	f.fish_id = "waiting_lady"
	f.portraits = {
			"default": preload("res://assets/waiting-lady-assets/lady.png"),
		}
	f.dialogue = [
		# 0
		{
			"speaker": "fish",
			"text": "...Ah. There you are. I was starting to think no one would come and the invitation had dissolved in the water."
		},
		# 1 — first choice
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "I hope you have some cake.",  "next": 2 },
				{ "label": "Who are you waiting for?",   "next": 4 }
			]
		},
		# --- CAKE PATH A (instant blackout) ---
		# 2
		{
			"speaker": "fish",
			"text": "Of course, silly. A tea party without cake is just a meeting, isn't it? I have a slice right here... saved just for the first person kind enough to sit with me."
		},
		# 3 — eating the cake triggers a blackout, signalled by "next": "blackout"
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "Eat the cake.", "next": "blackout"}
			],
			"next": -3 # TODO: blackout is saying the fish got freed ? or away. i think something is wrong with the emit signal when blackout
		},
		# --- PATH B: who are you waiting for ---
		# 4
		{
			"speaker": "fish",
			"text": "It was silly, really. I set the table too early. The tea went cold... I thought if I waited properly, they would arrive properly too. But anyway — you should have some cake."
		},
		# 5
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "Eat the cake.",          "next": "blackout" },
				{ "label": "No, thank you. I'm not hungry.", "next": 6 }
			]
		},
		# 6 — refusal leads to emotional reveal
		{
			"speaker": "fish",
			"text": "...Why not? You think I'm strange, don't you. Just like the others. You all leave eventually. You smile, you sit, you say nothing is wrong — and then you go. I made all of this for you. I am ALWAYS waiting for you."
		},
		# 7 — triggers flower minigame, signalled by "next": "minigame"
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "Back away slowly.", "next": "minigame" }
			]
		}
	]
	return f
	
static func kidFish():
	var f = Fish.new()
	f.fish_name = "Kid"
	f.fish_id = "kid_fish"
	
	# for when the kid fish is freed:
	# GameState.collected_items["kid_soundtrack"] = true
	# GameState.freed_souls.append("kid_fish")
	pass

static func loverFish() -> Fish:
	var f = Fish.new()
	f.fish_name = "Lover Fish";
	f.fish_id = "lover_fish";
	
	# dialogue changes based on world state
	if GameState.collected_items.get("kid_soundtrack", false):
		#f.dialogue = loverDialogue_withSong()
		f.fish_id = "lover_fish_return";
		pass
	else:
		#f.dialogue = loverDialogue_default()
		pass
	
	return f
