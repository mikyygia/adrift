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

static func firstFish() -> Fish:
	var f = Fish.new()
	f.fish_name = "???";
	f.fish_id = "first_fish";
	f.portraits = {
		"default": preload("res://assets/fish portrait/first/plainv2.png"),
		"blush": preload("res://assets/fish portrait/first/Firstfishv2-blush.png"),
		"doom": preload("res://assets/fish portrait/first/Firstfishv2-down.png")
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
				{ "label": "how does your hair dye stay intact underwater", "next": 2 },
				{ "label": "Who are you?", "next": 15 }
			]
		},
		{
			"speaker": "fish",
			"text": "Ah. Straight to the important questions.",
			"emotion": "blush"
		},
		{
			"speaker": "fish",
			"text": "You like it? Do you want the funny answer, or the real one?",
			"emotion": "default"
		},
		# 4
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "I didn't say i liked it", "next": 5 },
				{ "label": "Funny one", "next": 7 },
				{ "label": "I like a real response", "next": 11 }
			]
		},
		# hair route
		# i didn't say i liked it
		{
			"speaker": "fish",
			"text": "You didn't have to. Your eyes already did~ ",
			"emotion": "blush"
		},
		{
			"speaker": "fish",
			"text": "And besides... the ocean fears my commitment to color theory.",
			"emotion": "doom",
			"next": 17
			
		},
		# funny
		{
			"speaker": "fish",
			"text": "Ancient spirit conditioner!",
			"emotion": "blush"
		},
		{
			"speaker": "fish",
			"text": "Three in one. ",
			"emotion": "default"
		},
		{
			"speaker": "fish",
			"text": "Shampoo, conditioner, and existential preservation.",
			"emotion": "default"
		},
		{
			"speaker": "fish",
			"text": "Eternal loneliness leaves you with lots of time experimenting and trying new hobbies, new hair colors... and such of that medium.",
			"emotion": "default",
			"next": 17
		},
		# real
		{
			"speaker": "fish",
			"text": "I drowned before the dye could fade",
			"emotion": "doom",
		},
		{
			"speaker": "fish",
			"text": "...",
		},
		{
			"speaker": "fish",
			"text": "Haha~! Your expression was priceless~",
			"emotion": "default",
		},
		{
			"speaker": "fish",
			"text": "I'm only kidding. Mostly.",
			"emotion": "blush",
			"next": 17
		},
		
		# who are you route
		{
			"speaker": "fish",
			"text": "I was someone once",
			"emotion": "default",
		},
		{
			"speaker": "fish",
			"text": "But that part isn't too important",
			"emotion": "default",
			"next": 17
		},
		
		## everything ends here
		{
			"speaker": "fish",
			"text": "Anyways, enough about me ...",
			"emotion": "blush",
		},
		{
			"speaker": "fish",
			"text": "Switching to a slighter serious mode ... and this may be a bit heavy",
			"emotion": "doom",
		},
		{
			"speaker": "fish",
			"text": "There's going to be a long road (or water) ahead of you",
		},
		{
			"speaker": "fish",
			"text": "You're going to have to live with choices you make for the rest of your life",
		},
		{
			"speaker": "fish",
			"text": "I advice you to think very carefully about what it is you really want before it's too late",
		},
		{
			"speaker": "fish",
			"text": "Okay serious mode over~",
			"emotion": "blush",
		},
		{
			"speaker": "fish",
			"text": "Just one more thing before I go ...",
			"emotion": "default",
		},
		{
			"speaker": "fish",
			"text": "You do not have to carry every sentence someone hands you",
			"emotion": "default",
		},
		{
			"speaker": "fish",
			"text": "Accept what feels true to you, and let go of what doesn’t",
			"emotion": "default",
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
		"default": preload("res://assets/fish portrait/grumpy-man/Oldmanv2.png"),
		"angry": preload("res://assets/fish portrait/grumpy-man/Oldmanv2-angry.png"),
	}

	f.dialogue = [
		{ "speaker": "fish", "text": "GOOD LORD- HEY! WATCH IT! Nearly tore my shoulder clean off" },
		{ "speaker": "fish", "text": "Good grief. No warning, no manners... People these days treat reality like a revolving door" },
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "Sorry...",       "next": 3 },
				{ "label": "Are you ... upset?", "next": 10 }
			]
		},
		# apology route
		{ "speaker": "fish", "text": "Hm. At least you apologized. That's becoming rare" },
		{ "speaker": "fish", "text": "Most people just stare blankly and ruin my afternoon"},
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "I didn't mean to hurt you.", "next": 6 },
				{ "label": "I'll be more careful.",      "next": 15 }
			]
		},
		{ "speaker": "fish", "text": "Intentions matter, I suppose" },
		{ "speaker": "fish", "text": "People forget that when they're angry" },
		{ "speaker": "fish", "text": "Hmph. Good." }, 
		{ "speaker": "fish", "text": "Being careful costs nothing.", "next": -1 },
		
		# upset route
		{
			"speaker": "fish",
			"text": "UPSET?",
		},
		{
			"speaker": "fish",
			"text": "OF COURSE I AM UPSET!",
			"emotion": "angry",
		},
		{ "speaker": "fish", "text": "One moment I'm minding my own business..." },
		{ "speaker": "fish", "text": "The next moment some mysterious child decides gravity is optional!" },
		
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "First time for everything~",          "next": 15 },
				{ "label": "You talk a lot for a fish.", "next": 18 }
			]
		},
		
		{ "speaker": "fish", "text": "...Hmph." }, 
		{ "speaker": "fish", "text": "Well." }, 
		{ "speaker": "fish", "text": "That's more considerate than I expected from you.", "next": -1 },
		
		# 9 — bad end
		{ "speaker": "fish", "text": "THIS is why I avoid people." }, 
		{ "speaker": "fish", "text": "No patience. No respect. Terrible observational skills.", "next": -2 }, 
		
		# merge
		{ "speaker": "fish", "text": "Honestly..." }, 
		{ "speaker": "fish", "text": "Most people are too rough with things." },
		 { "speaker": "fish", "text": "Objects. Conversations. Each other." }, 
		{ "speaker": "fish", "text": "You'd be surprised how much gentler the world becomes once you stop treating everything like it owes you something." }, 
		{ "speaker": "fish", "text": "Now put me down properly before you dislocate my shoulder.", "next": -1 }
	]
	return f

# ---------------------------------------------------------------------------
# THE WAITING LADY  (dodge cake + collect flower minigame)
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
			"next": "free_fish"
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
				#{"label": "", "next": 6}
			]
		},
		# ---OP1---
		# 3
		{
			"speaker": "fish",
			"text": "You're NOT my tutor?",
			"delay": 0.5
		},
		# 4
		{
			"speaker": "fish",
			"text": "Are you here to play with me instead???",
			"delay": 0.4
		},
		# 5
		{
			"speaker": "fish",
			"text": "Because I can play. And I always win. Hehe.",
			"delay": 0.6,
			"next": 8
		},
		# ---OP2---
		# 6
		{
			"speaker": "fish",
			"text": "...Hahaha. probably not, honestly.",
			"delay": 0.8
		}, 
		# 7
		{
			"speaker": "fish",
			"text": "My papers are like... a hundred pages long. And they keep adding more. We should play instead! That sounds way more fun.",
			"delay": 1.0,
			"next": 8
		},
		# ---BOTH PATHS MEET HERE---
		# 8
		{
			"speaker": "fish",
			"text": "However, since we are playing ... there are rules.",
			"delay": 1.0
		},
		# 9
		{
			"speaker": "fish",
			"text": "No stopping halfway. No giving up. And no pretending you understand when you don't.",
			"delay": 1.2
		},
		# 10
		{
			"speaker": "fish",
			"text": "I call it... the MEGA ULTRA SUPREME FUN AND FRIENDLY TRIVIA QUESTIONS TO REDEEM YOUR WORTHY OR NOT.",
			"delay": 0.6
		},
		# 11
		{
			"speaker": "fish",
			"text": "There's a prize at the end. So you'd better stay. And get them all right.",
			"delay": 0.6
		},
		# 12 - second choice
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "...? No thanks-", "next": 13 },
				{"label": "Okay. I'm in. Show me what you got.", "next": 13}
			]
		},
		# 13 - both lead to game start
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

		# 14
		{
			"speaker": "fish",
			"text": "Amazing...",
			"delay": 2.0
		},
		# 15
		{
			"speaker": "fish",
			"text": "No one ever got all my questions right. Not ever. Except... him. But this — this is the first time I've actually had a real challenge.",
			"delay": 2.5
		},
		# 16
		{
			"speaker": "fish",
			"text": "You know... it was actually fun. Playing with you.",
			"delay": 2.0
		},
		# 17
		{
			"speaker": "fish",
			"text": "I'm sorry if the questions were hard. I know it's not always fun playing with me.",
			"delay": 1.8
		},
		# 18 — third choice
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "Yeah, I used ChatGPT", "next": 19 },
				{ "label": "I had a lot of fun. And I learned a lot from you.", "next": 21 }
			]
		},

		# --- CHEATING PATH ---
		# 19
		{
			"speaker": "fish",
			"text": "...You WHAT.",
			"delay": 1.5
		},
		# 20
		{
			"speaker": "fish",
			"text": "THAT'S CHEATING. I have been saving those questions. Those are MY questions — I worked hard for them. I can't believe this. I don't want to play with a cheater.",
			"delay": 2.5,
			"next": "ran_away"
		},

		# --- HONEST PATH ---
		# 21
		{
			"speaker": "fish",
			"text": "You mean it...",
			"delay": 1.8
		},
		# 22
		{
			"speaker": "fish",
			"text": "Usually people just get annoyed. Or quit.",
			"delay": 1.4
		},
		# 23
		{
			"speaker": "fish",
			"text": "But that's all I know how to do. I always had to center myself around studying. Thinking that would finally get my parents' love.",
			"delay": 2.2
		},
		# 24
		{
			"speaker": "fish",
			"text": "My brother is good at studying and talking. Everyone loves him. I thought if I were just like him... people would like me too",
			"delay": 2.5
		},
		# 25
		{
			"speaker": "fish",
			"text": "I thought my parents would finally love me too.",
			"delay": 2.8
		},
		# 26 — fourth choice
		{
			"speaker": "player",
			"text": "",
			"choices": [
				{ "label": "You don't need to be your brother. Would you want to be my friend?", "next": 27 },
				{ "label": "Those were incredible questions. You should be proud of the mind that made them.", "next": 31 }
			]
		},

		# --- OP1: FRIENDSHIP ---
		# 27
		{
			"speaker": "fish",
			"text": "...Yes.",
			"delay": 2.0
		},
		# 28
		{
			"speaker": "fish",
			"text": "I'd like that. Very much.",
			"delay": 1.6
		},
		# 29
		{
			"speaker": "fish",
			"text": "Thank you. For accepting me for who I am.",
			"delay": 1.8
		},
		# 30
		{
			"speaker": "fish",
			"text": "This isn't much... but I hope you'll take it.",
			"delay": 1.4,
			"next": "give_item_friendship"
		},

		# --- OP2: PRIDE ---
		# 31
		{
			"speaker": "fish",
			"text": "I do try my best. I want to give it everything I have, while I still can.",
			"delay": 2.0
		},
		# 32
		{
			"speaker": "fish",
			"text": "This isn't much. But I hope you'll take it as my thank you.",
			"delay": 1.6
		},
		# 33
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
		# 34
		{
			"speaker": "monologue",
			"text": "It's heavy and cold.",
			"delay": 1.6
		},
		# 35
		{
			"speaker": "monologue",
			"text": "As you wind it, the gears click with a rhythm that sounds like a heart trying to remember how to beat.",
			"delay": 2.5,
			"next": "freed"
		},
		
		# =============================================
		# POST-TRIVIA: LOSE PATH
		# (resume here after trivia_lost, step 36)
		# =============================================
		# 36
		{
			"speaker": "fish",
			"text": "Hmm... you didn't answer them all right.",
			"delay": 1.8
		},
		# 37
		{
			"speaker": "fish",
			"text": "But that's okay. You stayed till the end. That's more than most people do.",
			"delay": 2.2
		},
		# 38
		{
			"speaker": "fish",
			"text": "Here. You can pick one of my prizes anyway.",
			"delay": 1.6,
			"next": "choose_item"
		},
		
	]

	return f

static func samuraiFish() -> Fish:
	var f = Fish.new()
	f.fish_id = "samurai_fish"
	f.fish_name = "Teru"
	f.portraits = {
		"default": preload("res://assets/fish portrait/samurai/teru.png"),
		"blank":   preload("res://assets/fish portrait/samurai/teru_blank.png"),
	}
	f.dialogue = _teruDialogue()
	return f

static func _teruDialogue() -> Array:
	var has_sheet   = GameState.collected_items.get("kid_soundtrack", false)
	var has_card    = GameState.collected_items.get("blank_arcana", false)
	var has_stone   = GameState.collected_items.get("smooth_stone", false)
	var has_feather = GameState.collected_items.get("feather_charm", false)

	# track which items were offered — stored as flags so loop works
	# these get set via GameState.flags during dialogue

	return [
		# ── OPENING ─────────────────────────────────────────────────────
		# 0
		{ "speaker": "monologue", "text": "The wind moves over the water.", "delay": 2.0 },
		# 1
		{ "speaker": "monologue", "text": "A figure — one hand resting against the sheath of a sword.", "delay": 2.2 },
		# 2
		{ "speaker": "fish", "text": "...", "delay": 2.5, "emotion": "blank" },
		# 3
		{ "speaker": "monologue", "text": "He looks at you.", "delay": 1.5 },
		# 4
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "...",       "next": 5 },
				{ "label": "Hello..?",  "next": 5 }
			]
		},
		# 5
		{ "speaker": "fish", "text": "You're far from shore.", "delay": 1.6 },
		# 6
		{ "speaker": "fish", "text": "People don't usually come this far out.", "delay": 1.8 },
		# 7 — branch split
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "Are you like some guardian of these waters?", "next": 8 },
				{ "label": "You seem used to this.",                       "next": 16 }
			]
		},

		# ── BRANCH 1 OP1: Guardian ───────────────────────────────────────
		# 8
		{ "speaker": "fish", "text": "Guardian.", "delay": 1.2 },
		# 9
		{ "speaker": "monologue", "text": "He tilts his head slightly.", "delay": 1.0 },
		# 10
		{ "speaker": "fish", "text": "No.", "delay": 1.4 },
		# 11
		{ "speaker": "fish", "text": "Most things out here survive fine without being watched.", "delay": 2.0 },
		# 12
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "Watching? Is there something you're hoping to see?", "next": 13 }
			]
		},
		# 13
		{ "speaker": "monologue", "text": "The question lingers in the air between them.", "delay": 1.8 },
		# 14
		{ "speaker": "fish", "text": "...", "delay": 2.5, "emotion": "blank" },
		# 15
		{ "speaker": "fish", "text": "No.", "delay": 1.2 },
		# 15b
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "Then why stay out here?", "next": 23 }
			]
		},
		# ── will jump to 23 (water is quiet) then to item loop at 26

		# ── BRANCH 1 OP2: Duty ───────────────────────────────────────────
		# 16
		{ "speaker": "monologue", "text": "He glances briefly at his own hands.", "delay": 1.4 },
		# 17
		{ "speaker": "fish", "text": "... It is my duty.", "delay": 1.8, "emotion": "blank" },
		# 18
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "What do you do?", "next": 19 }
			]
		},
		# 19
		{ "speaker": "fish", "text": "What needs doing.", "delay": 1.4 },
		# 20
		{ "speaker": "fish", "text": "I have done this long enough that I don't have to think about it anymore.", "delay": 2.2 },
		# 21
		{ "speaker": "fish", "text": "I'm not sure if that's a good thing.", "delay": 2.0, "next": 26 },
		# skips 22-25, goes straight to item loop

		# ── SHARED: water is quiet ───────────────────────────────────────
		# 23 (reached from branch 1 op1)
		{ "speaker": "fish", "text": "The water is quiet.", "delay": 1.6 },
		# 24
		{ "speaker": "fish", "text": "Most places are not.", "delay": 1.8, "next": 26 },

		# ── TRANSITION TO ITEM LOOP ──────────────────────────────────────
		# 26
		{ "speaker": "monologue", "text": "He notices the objects on your boat.", "delay": 1.6 },
		# 27
		{ "speaker": "monologue", "text": "The wind shifts slightly.", "delay": 1.2 },
		# 28
		{ "speaker": "monologue", "text": "His attention drifts toward the things you've collected.", "delay": 1.8 },

		# ── ITEM LOOP (player returns here after each item) ───────────────
		# 29 — the loop anchor
		{ "speaker": "fish", "text": "The distance between you and him increases again.", "delay": 1.8 },
		# 30 — item choices
		{
			"speaker": "player", "text": "",
			"choices": _buildTeruItemChoices(has_sheet, has_card, has_stone, has_feather),
			"is_item_prompt": true
		},

		# ── LEAVE (OP5) ───────────────────────────────────────────────────
		# 31 — leave, offered nothing
		{ "speaker": "monologue", "text": "He watches you go.", "delay": 1.4 },
		# 32
		{ "speaker": "monologue", "text": "He says nothing. His hand rests back against the sheath.", "delay": 1.8 },
		# 33
		{ "speaker": "monologue", "text": "He glances once at your boat.", "delay": 1.4 },
		# 34
		{ "speaker": "monologue", "text": "Then away.", "delay": 1.2 },
		# 35
		{ "speaker": "monologue", "text": "The water fills the silence easily.", "delay": 2.0, "next": "tarot_begin" },

		# 36 — leave, offered sheet
		{ "speaker": "monologue", "text": "He doesn't watch you go.", "delay": 1.4 },
		# 37
		{ "speaker": "monologue", "text": "He is already looking at the water.", "delay": 1.6 },
		# 38
		{ "speaker": "monologue", "text": "But his hand is no longer on the sword.", "delay": 2.0, "next": "give_memory_fragment" },

		# 39 — leave, offered other items but not sheet
		{ "speaker": "fish", "text": "...", "delay": 1.5, "emotion": "blank" },
		# 40
		{ "speaker": "fish", "text": "Safe crossing.", "delay": 1.8, "next": "tarot_begin" },

		# ── MUSIC SHEET PATH (steps 41–73) ───────────────────────────────
		# 41
		{ "speaker": "fish", "text": "...", "delay": 2.0, "emotion": "blank" },
		# 42
		{ "speaker": "fish", "text": "?!", "delay": 0.8 },
		# 43
		{ "speaker": "fish", "text": "Where did you get this.", "delay": 1.6 },
		# 44
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "I picked it up somewhere.", "next": 45 }
			]
		},
		# 45
		{ "speaker": "fish", "text": "That melody.", "delay": 1.8 },
		# 46
		{ "speaker": "fish", "text": "I haven't heard it in... a very long time.", "delay": 2.0 },
		# 47
		{ "speaker": "fish", "text": "...", "delay": 2.5, "emotion": "blank" },
		# 48
		{ "speaker": "fish", "text": "I thought I would've forgotten it by now.", "delay": 1.8 },
		# 49
		{ "speaker": "fish", "text": "I suppose I heard it too often to forget.", "delay": 1.8 },
		# 50
		{ "speaker": "fish", "text": "I used to think it was annoying.", "delay": 1.6 },
		# 51 — branch 2
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "Annoying...?",               "next": 52 },
				{ "label": "You seem to remember it well.", "next": 63 }
			]
		},

		# ── SHEET BRANCH 2 OP1 ───────────────────────────────────────────
		# 52
		{ "speaker": "fish", "text": "It was.", "delay": 1.2 },
		# 53
		{ "speaker": "fish", "text": "Every day. Morning until late.", "delay": 1.6 },
		# 54
		{ "speaker": "fish", "text": "...", "delay": 2.0, "emotion": "blank" },
		# 55
		{ "speaker": "fish", "text": "I used to think that if I ignored it long enough, it would stop.", "delay": 2.2 },
		# 56
		{ "speaker": "fish", "text": "Or I would stop noticing it. Whichever came first.", "delay": 2.0 },
		# 57
		{ "speaker": "fish", "text": "One morning —", "delay": 1.4 },
		# 58
		{ "speaker": "fish", "text": "No song. No humming by the window where sunlight fell through the slats.", "delay": 2.4 },
		# 59
		{ "speaker": "fish", "text": "And I didn't say anything either.", "delay": 1.8 },
		# 60
		{ "speaker": "fish", "text": "The first week — I thought, good. I could enjoy the stillness again.", "delay": 2.2 },
		# 61
		{ "speaker": "fish", "text": "Second week. I noticed my eyes drifting toward the spot he sat.", "delay": 2.2 },
		# 62
		{ "speaker": "fish", "text": "And at some point, I started sitting there sometimes when nothing else called me away.", "delay": 2.4 },
		# 63 — OP1 continues / OP2 jumps here... actually OP2 starts at 64, let me keep them separate
		# re-index: OP1 ends, then OP2 starts at 71

		# still OP1:
		# 63 (continuing from 62)
		{ "speaker": "fish", "text": "Just... out of dumb reflex.", "delay": 1.8 },
		# 64
		{ "speaker": "fish", "text": "Like my body remembered what my mind forgot how to feel.", "delay": 2.2 },
		# 65
		{ "speaker": "monologue", "text": "A pause. He exhales once, slow.", "delay": 2.0 },
		# 66
		{ "speaker": "fish", "text": "...", "delay": 2.5, "emotion": "blank" },
		# 67
		{ "speaker": "monologue", "text": "He doesn't reach for the sheet. Doesn't ask for it back.", "delay": 1.8 },
		# 68
		{ "speaker": "fish", "text": "Keep it.", "delay": 1.4 },
		# 69
		{ "speaker": "monologue", "text": "He turns back to the water.", "delay": 1.6, "next": 29 },
		# returns to item loop

		# ── SHEET BRANCH 2 OP2 ───────────────────────────────────────────
		# 70 (jumped to from step 51 OP2)
		{ "speaker": "monologue", "text": "He stares at nothing. Not the player. Not the horizon. Just through something invisible, as if replaying a scene behind his eyes.", "delay": 3.0 },
		# 71
		{ "speaker": "fish", "text": "...Yeah.", "delay": 1.6, "emotion": "blank" },
		# 72
		{ "speaker": "fish", "text": "I remember how he'd hum off-key when tuning.", "delay": 2.0 },
		# 73
		{ "speaker": "fish", "text": "And how sunlight hit certain strings differently depending on the time of day.", "delay": 2.2 },
		# 74
		{ "speaker": "fish", "text": "I don't know why I remember that.", "delay": 1.8 },
		# 75
		{ "speaker": "fish", "text": "The light is different now.", "delay": 1.6 },
		# 76
		{ "speaker": "monologue", "text": "He looks back at the water.", "delay": 1.4 },
		# 77
		{ "speaker": "monologue", "text": "Something settles back into place on his face. The usual distance.", "delay": 2.0, "next": 29 },
		# returns to item loop

		# ── STONE PATH (steps 78–83) ──────────────────────────────────────
		# 78
		{ "speaker": "fish", "text": "A river stone.", "delay": 1.4 },
		# 79
		{ "speaker": "fish", "text": "One that has been in water long enough, the edges go.", "delay": 1.8 },
		# 80
		{ "speaker": "fish", "text": "Everything out here is worn down by something.", "delay": 1.8 },
		# 81
		{ "speaker": "monologue", "text": "He looks at it a moment longer than necessary.", "delay": 1.6 },
		# 82
		{ "speaker": "monologue", "text": "Then he holds it back out toward you.", "delay": 1.4 },
		# 83
		{
			"speaker": "player", "text": "",
			"choices": [
				{ "label": "He hands it back.", "next": 84 }
			]
		},
		# 84
		{ "speaker": "fish", "text": "Things worn this long tend to hold.", "delay": 2.0, "next": 29 },
		# returns to item loop

		# ── FEATHER PATH (steps 85–89) ────────────────────────────────────
		# 85
		{ "speaker": "fish", "text": "Someone tied this too tightly.", "delay": 1.6 },
		# 86
		{ "speaker": "monologue", "text": "He glances at the binding.", "delay": 1.2 },
		# 87
		{ "speaker": "fish", "text": "It's been held in one position so long it can't sit right anymore.", "delay": 2.0 },
		# 88
		{ "speaker": "fish", "text": "You kept it anyway.", "delay": 1.4 },
		# 89
		{ "speaker": "monologue", "text": "He doesn't say anything else about it. He looks back toward the water, like the subject has already passed.", "delay": 2.0, "next": 29 },
		# returns to item loop

		# ── CARD PATH (steps 90–95) ───────────────────────────────────────
		# 90
		{ "speaker": "fish", "text": "No name on it.", "delay": 1.4 },
		# 91
		{ "speaker": "monologue", "text": "He studies it for a moment.", "delay": 1.2 },
		# 92
		{ "speaker": "fish", "text": "Things like this usually wait for someone else to define them.", "delay": 2.0 },
		# 93
		{ "speaker": "fish", "text": "Most of them stay unfinished.", "delay": 1.6 },
		# 94
		{ "speaker": "monologue", "text": "He hands it back.", "delay": 1.0 },
		# 95
		{ "speaker": "fish", "text": "Could be either.", "delay": 1.2 },
		# 96
		{ "speaker": "fish", "text": "Doesn't change what it is now.", "delay": 1.8, "next": 29 },
		# returns to item loop
	]

static func _buildTeruItemChoices(has_sheet: bool, has_card: bool, has_stone: bool, has_feather: bool) -> Array:
	var sheet_offered  = GameState.flags.get("teru_offered_sheet", false)
	var offered_anything = GameState.flags.get("teru_offered_anything", false)

	# determine which leave ending to use
	var leave_next: int
	if sheet_offered:
		leave_next = 36   # hand no longer on sword
	elif offered_anything:
		leave_next = 39   # safe crossing
	else:
		leave_next = 31   # silence, nothing offered

	return [
		{ "label": "Offer the music sheet.", "next": 41, "disabled": not has_sheet or sheet_offered },
		{ "label": "Offer the card.",         "next": 90, "disabled": not has_card },
		{ "label": "Offer the stone.",        "next": 78, "disabled": not has_stone },
		{ "label": "Offer the feather.",      "next": 85, "disabled": not has_feather },
		{ "label": "Leave him to the quiet.", "next": leave_next, "disabled": false },
	]
	
