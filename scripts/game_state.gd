# game_state.gd (Autoload)
extends Node

#states
var currentFish: Fish = null;

# mechanics
var soul_bar: int = 0
var soul_bar_max: int = 3        # souls needed to level up

# changed soul tier to a linear progression
var grumpy_freed: bool = false  # waiting lady only unlocks after this
var waiting_lady_won: bool = false  # kid only unlocks after this
var kid_freed: bool = false  # samurai only unlocks after this


var memory_fragments: Array[String] = []
var collected_items: Dictionary = {}

# souls
var freed_souls: Array[String] = [] # permanently gone, gave soul fragment
var flags: Dictionary = {} # # cross-fish story flags


# freeing souls by fish_id
func free_soul(fish_id: String) -> void:
	if freed_souls.has(fish_id):
		return;  # safety guard

	freed_souls.append(fish_id)
	soul_bar += 1
	
	match fish_id:
		"grumpy_old_man": grumpy_freed = true
		"waiting_lady": waiting_lady_won = true
		"kid_fish": kid_freed = true
	
	# soul_bar_max reset removed until memory fragment UI is built
	#if soul_bar >= soul_bar_max:
		#soul_bar = 0

func isFreed (fish_id: String) -> bool:
	return freed_souls.has(fish_id);
	
