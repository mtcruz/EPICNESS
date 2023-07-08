extends Node2D

@export var health_hero = 6
@export var health_hero_max = 6
@export var health_villain = 6
@export var health_villain_max = 6
@export var stamina_hero = 6
@export var stamina_hero_max = 6
@export var stamina_villain = 6
@export var stamina_villain_max = 6
@export var epicness_current = 0
@export var epicness_max = 6
var game_is_over = false
var actor # the character making the action
var action_was_taken # a character made an action?

# used for combat calculations
var health_regen = 0
var health_damage = 0
var stamina_cost = 0
var stamina_damage = 0

# atualiza variáveis na tela a cada frame
func _process(_delta):
	$HeroHealth.set_text("❤ %d" % [health_hero])
	$VillainHealth.set_text("🖤 %d" % [health_villain])
	$HeroStamina.set_text("💪 %d" % [stamina_hero])
	$VillainStamina.set_text("💪 %d" % [stamina_villain])
	$Turns.set_text("%d / %d" % [epicness_current, epicness_max])
	check_stamina()
	check_damage()
	check_gameover()


# Deactivates buttons in case there is not enough stamina
func check_stamina(): # Beware, this is ugly[]
	if stamina_villain < 3: # Villain's move 1
		$villain_move_1.disabled = true
	else:
		$villain_move_1.disabled = false
		
	if stamina_villain < 5: # Villain's move 2
		$villain_move_2.disabled = true
	else:
		$villain_move_2.disabled = false
		
	if stamina_hero < 1: # Hero's move 1
		$hero_move_1.disabled = true
	else:
		$hero_move_1.disabled = false

	if stamina_hero < 3: # Hero's move 2
		$hero_move_2.disabled = true
	else:
		$hero_move_2.disabled = false

	if stamina_hero < 1: # Hero's move 3
		$hero_move_3.disabled = true
	else:
		$hero_move_3.disabled = false


# Calculates combat variables and applies them
func check_damage():
	if actor == "hero":
		health_hero += health_regen
		health_villain -= health_damage
		stamina_hero -= stamina_cost
		stamina_villain -= stamina_damage
		action_was_taken = true
	elif actor == "villain":
		health_hero -= health_damage
		health_villain += health_regen
		stamina_hero -= stamina_damage
		stamina_villain -= stamina_cost
		action_was_taken = true
	
	# Prevent negative
	if health_hero < 0:
		health_hero = 0
	if health_villain < 0:
		health_villain = 0
	if stamina_hero < 0:
		stamina_hero = 0
	if stamina_villain < 0:
		stamina_villain = 0
	
	# Reset combat variables if action was taken
	if action_was_taken:
		health_regen = 0
		health_damage = 0
		stamina_cost = 0
		stamina_damage = 0
		epicness_current += 1
		action_was_taken = false
		actor = "none"


# Habilidades de cada personagem ###############################################
# Buttons for the Hero moveset 
func _on_hero_move_1(): # Weak attack
	actor = "hero"
	health_damage = 2
	stamina_cost = 1
func _on_hero_move_2(): # Strong attack
	actor = "hero"
	health_damage = 4
	stamina_damage = 1
	stamina_cost = 3
func _on_hero_move_3(): # Heal self
	actor = "hero"
	health_regen = 2
	stamina_cost = 2

# Buttons for the Villain moveset 
func _on_villain_move_1(): # Strong attack
	actor = "villain"
	health_damage = 3
	stamina_cost = 3
func _on_villain_move_2(): # Kamikaze attack
	actor = "villain"
	health_regen = -3
	health_damage = 5
	stamina_cost = 6
func _on_villain_move_3(): # Regenerate stamina
	actor = "villain"
	stamina_cost = -6


# Ganhando e perdendo ##########################################################

func check_gameover():
	if epicness_current == epicness_max:
		win()
	elif health_hero == 0:
		lose()
	elif health_villain == 0:
		lose()

func win():
	$Message.text = str("You win!")
	$SubMessage.text = str("Villain was slain epically")
	game_is_over = true
	disable_buttons()

func lose(): # Differentes mensagens a depender de quem morreu
	if health_villain <= 0:
		$SubMessage.text = str("The villain died before the battle got epic :(")
	elif health_hero <= 0:
		$SubMessage.text = str("The Hero died!")
	game_is_over = true
	disable_buttons()

func disable_buttons():
	$hero_move_1.disabled = true
	$hero_move_2.disabled = true
	$hero_move_3.disabled = true
	$villain_move_1.disabled = true
	$villain_move_2.disabled = true
	$villain_move_3.disabled = true


# Funcionalidades ##############################################################

func _on_reload_button_down():
	get_tree().reload_current_scene()

func _on_quit_button_down():
	get_tree().quit()
