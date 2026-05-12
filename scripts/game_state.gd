# game_state.gd (Autoload)
extends Node

#states
var tutorial_complete: bool = false;
var currentFish: Fish = null;

# mechanics
var soul_bar: int = 0
var soul_bar_max: int = 3        # souls needed to level up
var soul_tier: int = 1           # current unlock tier
var memory_fragments: Array[String] = []

# souls
var freed_souls: Array[String] = [] # permanently gone, gave soul fragment
var flags: Dictionary = {} # # cross-fish story flags



# freeing souls by fish_id
func free_soul(fish_id: String) -> void:
	# prevents the same fish from being freed twice
	if freed_souls.has(fish_id):
		return;  # safety guard
		
	# gain progress on soul bar
	freed_souls.append(fish_id)
	
	# complete the tutorial !!
	if not tutorial_complete:
		var tutorial_fish = ["grumpy_old_man", "waiting_lady"]
		if tutorial_fish.all(func(id): return freed_souls.has(id)):
			tutorial_complete = true
	soul_bar += 1
	
	# once soul bar reaches max. gain a tier and reset
	if soul_bar >= soul_bar_max:
		soul_bar = 0
		soul_tier += 1
		# TODO: emit signal to show memory fragment UI

func isFreed (fish_id: String) -> bool:
	return freed_souls.has(fish_id);
	
