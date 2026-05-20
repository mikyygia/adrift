# fish_data.gd
extends Node

# ---------------------------------------------------------------------------
# FishData — single source of truth for all fish in the game.
# Add new fish here. main.gd pulls from this pool randomly.
# ---------------------------------------------------------------------------

static func getFirstFish() -> Fish:
	return firstFish();

#static func getGentlePool() -> Array:
	#var pool = [];
	#
	#if not GameState.tutorial_complete:
		#pool.append(grumpyOldMan())  # tutorial only
	#else:
		#if GameState.soul_tier == 2:
			#pool.append(kidFish());
			#pool.append(samuraiFish());
		#elif GameState.soul_tier == 3:
			#pass # add more gentle fish here
		#
	#return filterPool(pool);
	#
#static func getHeavyPool() -> Array:
	#var pool = [];
	#
	#if not GameState.tutorial_complete:
		#pool.append(waitingLady());
	#else:
		#if GameState.soul_tier == 2:
			#pass; # add more heavy hearted fish here
		##else:
			##pass
		#
	#return filterPool(pool);
#
#static func filterPool(pool: Array) -> Array:
	#return pool.filter(func(f): return not GameState.freed_souls.has(f.fish_id))

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
			"default": preload("res://assets/fish portrait/waiting-lady/lady.png"),
		}
	f.dialogue = [
		# 0
		{
			"speaker": "fish",
			"text": "...Ah. There you are.",
			"delay": 1.8
		},
		# 1 
		{
			"speaker": "fish",
			"text": "I was starting to think no one would come and the invitation had dissolved in the water.",
			"delay": 2.2
		},
		# 2 - player first choice
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "Oh a tea party.. do you have cake?", "next": 3 },
				{"label": "Who are you waiting for?", "next": 6 }
			]
		},
		# --- CAKE PATH A (instant blackout) ---
		# 3
		{
			"speaker": "fish",
			"text": "Of course, silly. A tea party without cake is just a meeting, isn't it?",
			"delay": 1.6
		},
		# 4
		{
			"speaker": "fish",
			"text": "I have a slice right here... saved just for the first person kind enough to sit with me.",
			"delay": 2.0
		},
		# 5 — eating the cake triggers a blackout, signalled by "next": "blackout"
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "Eat the cake.", "next": "blackout"}
			],
			"next": -3 # TODO: blackout is saying the fish got freed ? or away. i think something is wrong with the emit signal when blackout
		},
		# --- PATH B: who are you waiting for ---
		# 6
		{
			"speaker": "fish",
			"text": "...It was silly, really.",
			"delay": 1.5
		},
		# 7
		{
			"speaker": "fish",
			"text": "I set the table too early. The tea went cold. I kept thinking — if I waited properly, they would arrive properly too.",
			"delay": 2.4
		},
		# 8
		{
			"speaker": "fish",
			"text": "But anyway. You should have some cake.",
			"delay": 1.4
		},
		#9 - second choice
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "Eat the cake.",          "next": "blackout" },
				{ "label": "No, thank you. I'm not hungry.", "next": 10 }
			]
		},
		# 10 — refusal leads to emotional reveal
		{
			"speaker": "fish",
			"text": "...Why not?",
			"delay": 2.0
		},
		# 11
		{
			"speaker": "fish",
			"text": "You think I'm strange, don't you. Just like the others.",
			"delay": 1.8
		},
		# 12
		{
			"speaker": "fish",
			"text": "You all leave eventually. You smile, you sit, you say nothing is wrong — and then you go.",
			"delay": 2.2
		},
		# 13
		{
			"speaker": "fish",
			"text": "And then you talk. Don't think I don't know.",
			"delay": 1.6
		},
		# 14
		{
			"speaker": "fish",
			"text": "I made all of this... for you. I am ALWAYS waiting for you.",
			"delay": 2.5
		},
		# 15 — triggers flower minigame, signalled by "next": "minigame"
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "Back away slowly.", "next": "minigame" }
			]
		},# === POST-MINIGAME DIALOGUE ===
		# (These are only reached after minigame signals "minigame_won" or "minigame_lost")

		# 16 — STAGE 1 mid-minigame: collect PRESENTS
		{
			"speaker": "fish",
			"text": "...You know, perhaps it would be easier if you simply stayed.",
			"delay": 1.4,
			"minigame_stage": 1
		},
		# 17
		{
			"speaker": "fish",
			"text": "My dolls would be so happy to have a new friend.",
			"delay": 1.8,
			"minigame_stage": 1
		},

		# 18 — STAGE 2 mid-minigame: collect flowers
		{
			"speaker": "fish",
			"text": "What is so wrong with that?",
			"delay": 1.6,
			"minigame_stage": 2
		},
		# 19
		{
			"speaker": "fish",
			"text": "What is so wrong with... me?",
			"delay": 2.2,
			"minigame_stage": 2
		},

		# 20 — STAGE 3 / WIN: fish breaks down
		{
			"speaker": "fish",
			"text": "I... I'm sorry.",
			"delay": 2.5,
			"minigame_stage": 3
		},
		# 21
		{
			"speaker": "fish",
			"text": "I am a lady. I shouldn't have... I shouldn't have done that.",
			"delay": 2.0,
			"minigame_stage": 3
		},
		# 22
		{
			"speaker": "fish",
			"text": "I just... I only ever wanted a friend.",
			"delay": 2.8,
			"minigame_stage": 3
		},
		# 23
		{
			"speaker": "player",
			"text": "You shouldn't have had to wait that long. But... you don't have to be alone anymore. I'll be your friend.",
			"delay": 2.0,
			"minigame_stage": 3,
			"portrait": "player"
		},
		# 24
		{
			"speaker": "fish",
			"text": "You are a strange little thing, you know that?",
			"delay": 1.6,
			"minigame_stage": 3
		},
		# 25
		{
			"speaker": "fish",
			"text": "Coming all the way down here. Sitting with someone like me.",
			"delay": 2.0,
			"minigame_stage": 3
		},
		# 26
		{
			"speaker": "fish",
			"text": "I cannot promise I will always be easy to be around. But I can promise...",
			"delay": 2.4,
			"minigame_stage": 3
		},
		# 27
		{
			"speaker": "fish",
			"text": "...the next cake will be much better.",
			"delay": 1.8,
			"minigame_stage": 3
		},
		# 28 — final line, triggers music/free signal
		{
			"speaker": "fish",
			"text": "Thank you. For staying. And for being my first friend.",
			"delay": 3.0,
			"minigame_stage": 3,
			"next": -1
		},
	]
	return f
	
static func kidFish():
	var f = Fish.new()
	f.fish_name = "Kid"
	f.fish_id = "kid_fish"
	f.portraits = {
			"default": preload("res://assets/fish portrait/kid/kid.png"),
		}
	f.dialogue = [
		# 0
		{
			"speaker": "fish",
			"text": "...Oh. You're not carrying a folder.",
			"delay": 1.2
		},
		# 1
		{
			"speaker": "fish",
			"text": "You look tired though. Are you one of my tutors?",
			"delay": 1.0
		},
		# 2 - first choice
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{"label": "No, I am not.", "next": 3},
				{"label": "Do I look like I would grade you?", "next": 4}
			]
		},
		# ---OP1---
		# 3
		{
			"speaker": "fish",
			"text": "You're NOT my tutor?",
			"delay": 0.5
		},
		{
			"speaker": "fish",
			"text": "Are you here to play with me instead???",
			"delay": 0.4
		},
		{
			"speaker": "fish",
			"text": "Because I can play. And I always win. Hehe.",
			"delay": 0.6,
			"next": 6
		},
		# ---OP2---
		# 4
		{
			"speaker": "fish",
			"text": "...Hahaha. probably not, honestly.",
			"delay": 0.8
		}, 
		# 5
		{
			"speaker": "fish",
			"text": "My papers are like... a hundred pages long. And they keep adding more. It's fine though - you don't have to. We should play instead. That sounds way more fun than grading anyway.",
			"delay": 1.0,
			"next": 6
		},
		# ---BOTH PATHS MEET HERE---
		# 6
		{
			"speaker": "fish",
			"text": "Okay. But if we are playing - there are rules.",
			"delay": 1.0
		},
		# 7
		{
			"speaker": "fish",
			"text": "No stopping halfway. No giving up. And no pretending you understand when you dont.",
			"delay": 1.2
		},
		# 8
		{
			"speaker": "fish",
			"text": "I called it... the MEGA ULTRA SUPREME FUN AND FRIENDLY TRIVIA QUESTIONS TO REDEEM YOUR WORTHY OR NOT.",
			"delay": 0.6
		},
		# 9
		{
			"speaker": "fish",
			"text": "There's a prize at the end. So you'd better stay. And get them all right.",
			"delay": 0.6
		},
		# 10 - second choice
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "...the what. you take games really seriouasly, huh.", "next": 11 },
				{"label": "Okay. I'm in. Show me what you got.",                  "next": 11}
			]
		},
		# 11 - both lead to game start
		{
			"speaker": "fish",
			"text": "Good. Then let's begin.",
			"delay": 1.5,
			"next": "minigame_trivia"
		},

		# =============================================
		# POST-TRIVIA: WIN PATH
		# (resume here after minigame_won, step 15)
		# =============================================

		# 12
		{
			"speaker": "fish",
			"text": "Amazing...",
			"delay": 2.0
		},
		# 13
		{
			"speaker": "fish",
			"text": "No one ever got all my questions right. Not ever. Except... him. But this — this is the first time I've actually had a real challenge.",
			"delay": 2.5
		},
		# 14
		{
			"speaker": "fish",
			"text": "You know... it was actually fun. Playing with you.",
			"delay": 2.0
		},
		# 15
		{
			"speaker": "fish",
			"text": "I'm sorry if the questions were hard. I know it's not always fun playing with me.",
			"delay": 1.8
		},
		# 16 — third choice
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "Yeah, I had to use ChatGPT.", "next": 17 },
				{ "label": "I had a lot of fun. And I learned a lot from you.", "next": 19 }
			]
		},

		# --- CHEATING PATH ---
		# 17
		{
			"speaker": "fish",
			"text": "...You WHAT.",
			"delay": 1.5
		},
		# 18
		{
			"speaker": "fish",
			"text": "THAT'S CHEATING. I have been saving those questions. Those are MY questions — I worked hard for them. I can't believe this. I don't want to play with a cheater.",
			"delay": 2.5,
			"next": "ran_away"
		},

		# --- HONEST PATH ---
		# 19
		{
			"speaker": "fish",
			"text": "You mean it...",
			"delay": 1.8
		},
		# 20
		{
			"speaker": "fish",
			"text": "Usually people just get annoyed. Or quit.",
			"delay": 1.4
		},
		# 21
		{
			"speaker": "fish",
			"text": "But that's all I know how to do. I always had to center myself around studying. Thinking that would finally get my parents' love.",
			"delay": 2.2
		},
		# 22
		{
			"speaker": "fish",
			"text": "My brother is good at studying. Good at talking. Everyone loves him. I thought if I were just like him... I wouldn't have to be lonely.",
			"delay": 2.5
		},
		# 23
		{
			"speaker": "fish",
			"text": "I thought my parents would finally love me too.",
			"delay": 2.8
		},
		# 24 — fourth choice
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "You don't need to be your brother. Would you want to be my friend?", "next": 25 },
				{ "label": "Those were incredible questions. You should be proud of the mind that made them.", "next": 29 }
			]
		},

		# --- OP1: FRIENDSHIP ---
		# 25
		{
			"speaker": "fish",
			"text": "...Yes.",
			"delay": 2.0
		},
		# 26
		{
			"speaker": "fish",
			"text": "I'd like that. Very much.",
			"delay": 1.6
		},
		# 27
		{
			"speaker": "fish",
			"text": "Thank you. For accepting me for who I am.",
			"delay": 1.8
		},
		# 28
		{
			"speaker": "fish",
			"text": "This isn't much... but I hope you'll take it.",
			"delay": 1.4,
			"next": "give_item_friendship"
		},

		# --- OP2: PRIDE ---
		# 29
		{
			"speaker": "fish",
			"text": "I do try my best. I want to give it everything I have, while I still can.",
			"delay": 2.0
		},
		# 30
		{
			"speaker": "fish",
			"text": "This isn't much. But I hope you'll take it as my thank you.",
			"delay": 1.6
		},
		# 31
		{
			"speaker": "fish",
			"text": "Thank you. For playing with me.",
			"delay": 2.0,
			"next": "give_item_pride"
		},

		# =============================================
		# INTERNAL MONOLOGUE — after item received
		# (both paths lead here, step 35)
		# =============================================
		# 32
		{
			"speaker": "monologue",
			"text": "It's heavy and cold.",
			"delay": 1.6
		},
		# 33
		{
			"speaker": "monologue",
			"text": "As you wind it, the gears click with a rhythm that sounds like a heart trying to remember how to beat.",
			"delay": 2.5,
			"next": "freed"
		}
	]

	return f

static func samuraiFish() -> Fish:
	var f = Fish.new()
	f.fish_id = "samurai_fish"
	f.fish_name = "Teru"
	f.portraits = {
		"default": preload("res://assets/fish portrait/samurai/teru.png"),
	}
	f.dialogue = _teruDialogue()
	return f


static func _teruDialogue() -> Array:
	var has_sheet  = GameState.collected_items.get("kid_soundtrack", false)
	var has_stone  = GameState.collected_items.get("smooth_stone", false)
	var has_feather = GameState.collected_items.get("feather_charm", false)
	var has_card   = GameState.collected_items.get("blank_arcana", false)

	return [
		# 0
		{ "speaker": "fish", "text": "...", "delay": 2.0 },
		# 1
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "...",       "next": 2 },
				{ "label": "Hello..?",  "next": 2 }
			]
		},
		# 2
		{ "speaker": "fish", "text": "You're not supposed to be out here. This part of the water doesn't usually have visitors.", "delay": 2.2 },
		# 3
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "Are you waiting for someone?", "next": 4 },
				{ "label": "You seem used to this.",       "next": 4 }
			]
		},
		# 4
		{ "speaker": "fish", "text": "No. I stopped expecting people a long time ago.", "delay": 1.8 },
		# 5
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "What do you do instead?", "next": 6 }
			]
		},
		# 6
		{ "speaker": "fish", "text": "What needs doing.", "delay": 1.4 },
		# 7 — item prompt. choices built dynamically based on inventory
		{
			"speaker": "player", "text": "",
			"choices": _buildTeruItemChoices(has_sheet, has_stone, has_feather, has_card),
			"is_item_prompt": true
		},
		# 8 — no item / default close
		{ "speaker": "fish", "text": "...You remind me of someone, actually.", "delay": 2.0 },
		# 9
		{ "speaker": "fish", "text": "Never mind.", "delay": 1.2 },
		# 10
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "Does that make you happy?", "next": 11 },
				{ "label": "That sounds lonely.",       "next": 13 }
			]
		},
		# 11
		{ "speaker": "fish", "text": "Happy.", "delay": 1.5 },
		# 12
		{ "speaker": "fish", "text": "I'm not sure I've thought about it that way.", "delay": 1.8, "next": "tarot_begin" },
		# 13
		{ "speaker": "fish", "text": "...", "delay": 1.5 },
		# 14
		{ "speaker": "fish", "text": "Maybe.", "delay": 1.2 },
		# 15
		{ "speaker": "fish", "text": "But lonely is just what it is when you grow up fast.", "delay": 2.0, "next": "tarot_begin" },

		# ── MUSIC SHEET PATH (steps 16–27) ──────────────────────────────
		# 16
		{ "speaker": "fish", "text": "...", "delay": 2.5 },
		# 17
		{ "speaker": "fish", "text": "Where did you get this.", "delay": 1.6 },
		# 18
		{ "speaker": "fish", "text": "...", "delay": 3.0 },
		# 19
		{ "speaker": "fish", "text": "That melody.", "delay": 1.8 },
		# 20
		{ "speaker": "fish", "text": "I haven't heard it in a long time.", "delay": 1.8 },
		# 21
		{ "speaker": "fish", "text": "Someone used to hum it. Badly.", "delay": 2.0 },
		# 22
		{ "speaker": "fish", "text": "Every morning.", "delay": 1.4 },
		# 23
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "They were important to you?", "next": 24 }
			]
		},
		# 24
		{ "speaker": "fish", "text": "...", "delay": 1.5 },
		# 25
		{ "speaker": "fish", "text": "He was loud.", "delay": 1.2 },
		# 26
		{ "speaker": "fish", "text": "Always at the wrong times.", "delay": 1.4 },
		# 27
		{ "speaker": "fish", "text": "It used to annoy me.", "delay": 1.6 },
		# 28
		{ "speaker": "fish", "text": "I thought I preferred quiet.", "delay": 1.8 },
		# 29
		{ "speaker": "fish", "text": "...", "delay": 3.0 },
		# 30
		{ "speaker": "fish", "text": "Keep it.", "delay": 1.4 },
		# 31
		{ "speaker": "fish", "text": "It should be heard again.", "delay": 2.0, "next": "give_memory_fragment" },

		# ── STONE PATH (steps 32–39) ─────────────────────────────────────
		# 32
		{ "speaker": "fish", "text": "...", "delay": 1.5 },
		# 33
		{ "speaker": "fish", "text": "It's been in water a long time.", "delay": 1.8 },
		# 34
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "That's it?", "next": 35 }
			]
		},
		# 35
		{ "speaker": "fish", "text": "That's enough.", "delay": 1.2 },
		# 36
		{ "speaker": "fish", "text": "Things don't stay sharp in water.", "delay": 1.6 },
		# 37
		{ "speaker": "fish", "text": "They lose edges. Or they learn to stop resisting it.", "delay": 2.0 },
		# 38
		{ "speaker": "fish", "text": "...", "delay": 2.0 },
		# 39
		{ "speaker": "fish", "text": "You should put it back.", "delay": 1.4, "next": "tarot_begin" },

		# ── FEATHER PATH (steps 40–48) ───────────────────────────────────
		# 40
		{ "speaker": "fish", "text": "...", "delay": 1.5 },
		# 41
		{ "speaker": "fish", "text": "Someone tied this too tightly.", "delay": 1.8 },
		# 42
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "Does that matter?", "next": 43 }
			]
		},
		# 43
		{ "speaker": "fish", "text": "It does if it was meant to move.", "delay": 1.6 },
		# 44
		{ "speaker": "fish", "text": "Feathers aren't meant to stay still.", "delay": 1.6 },
		# 45
		{ "speaker": "fish", "text": "But this one won't forget the string.", "delay": 2.0 },
		# 46
		{ "speaker": "fish", "text": "...", "delay": 2.5 },
		# 47
		{ "speaker": "fish", "text": "Strange thing to keep.", "delay": 1.4 },
		# 48
		{ "speaker": "fish", "text": "Still.", "delay": 1.2, "next": "tarot_begin" },

		# ── BLANK CARD PATH (steps 49–56) ────────────────────────────────
		# 49
		{ "speaker": "fish", "text": "...", "delay": 1.5 },
		# 50
		{ "speaker": "fish", "text": "It doesn't have a name.", "delay": 1.6 },
		# 51
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "Does that mean anything?", "next": 52 }
			]
		},
		# 52
		{ "speaker": "fish", "text": "It means someone didn't decide what it was yet.", "delay": 2.0 },
		# 53
		{ "speaker": "fish", "text": "Or didn't want to.", "delay": 1.4 },
		# 54
		{ "speaker": "fish", "text": "Either way... it's waiting.", "delay": 2.0 },
		# 55
		{ "speaker": "fish", "text": "Like everything else out here.", "delay": 1.6, "next": "tarot_begin" },
	]

static func _buildTeruItemChoices(has_sheet: bool, has_stone: bool, has_feather: bool, has_card: bool) -> Array:
	return [
		{ "label": "Show Teru the music sheet.", "next": 16, "requires": "kid_soundtrack", "disabled": not has_sheet },
		{ "label": "Show Teru the stone.",        "next": 32, "requires": "smooth_stone",   "disabled": not has_stone },
		{ "label": "Show Teru the feather charm.","next": 40, "requires": "feather_charm",  "disabled": not has_feather },
		{ "label": "Show Teru the card.",         "next": 49, "requires": "blank_arcana",   "disabled": not has_card },
		{ "label": "...",                          "next": 8,  "requires": "",               "disabled": false },
	]
