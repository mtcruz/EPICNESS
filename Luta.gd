extends Node2D


# Initialize variables #########################################################
# Used for winning conditions
var epicness_current = 0
var epicness_max
var epicness_reached_peak = false
var stage_is_over = false
# used for combat calculations
var health_hero = 6
var health_hero_max = 6
var health_villain = 6
var health_villain_max = 6
var stamina_hero = 6
var stamina_hero_max = 6
var stamina_villain = 6
var stamina_villain_max = 6
var health_regen = 0
var health_damage = 0
var stamina_cost = 0
var stamina_damage = 0
var actor # the character making the action
var action_was_taken # a character made an action?
# Stage-related
var current_stage = 1
var stage_is_set = false
# Timings
var time_started
var time_now = 0
var time_transition = 0
var time_elapsed = 0


func _ready():
	$TransitionMessage.visible = false
	time_started = Time.get_unix_time_from_system()


func _process(_delta):
	
	if stage_is_over: # se a fase acabou, vamos para a próxima
		current_stage += 1
		stage_is_over  = false
		enable_buttons()
	if !stage_is_set: # Se a fase não está configurada, o fazemos
		set_stage()
	
	# Essa parte serve para tirar a mensagem de fim de estágio
	time_now = Time.get_unix_time_from_system()
	time_elapsed = time_now - time_started
	var time_since_transition = time_elapsed - time_transition
	if time_since_transition > 5:
		$TransitionMessage.visible = false
	
	# atualiza variáveis na tela a cada frame
	$DebugInfo.set_text(str(" | current_stage: ", current_stage, \
							" | stage_is_set: ", stage_is_set, \
							" | epicness_current: ", epicness_current, \
							" | epicness_max: ", epicness_max, \
							" | epicness_reached_peak: ", epicness_reached_peak, \
							" | stage_is_over: ", stage_is_over, \
							"\n | time_elapsed: ", time_elapsed,
							"\n | time_transition " , time_transition,
							"\n | time_now " , time_now))
	$HeroHealth.set_text("❤ %d" % [health_hero])
	$VillainHealth.set_text("🖤 %d" % [health_villain])
	$HeroStamina.set_text("💪 %d" % [stamina_hero])
	$VillainStamina.set_text("💪 %d" % [stamina_villain])
	if epicness_current != (epicness_max - 1):
		$Turns.set_text("%d / %d" % [epicness_current, epicness_max])
	elif epicness_current == (epicness_max - 1) and not epicness_reached_peak:
		$Turns.set_text("Max Epicness near")
		$SubMessage.set_text("End the battle now!")
	else:
		$Turns.set_text("%d / %d" % [epicness_current, epicness_max])
	
	# Roda funções de atualização
	check_stamina()
	check_damage()
	check_gameover()

# The stages ###################################################################

func set_stage():
	if current_stage == 1:
		epicness_max = 6
		$Message.text = "Stage 1"
		$SubMessage.text = "Reach max epicness with a final blow on the Villain"
	
	if current_stage == 2:
		epicness_max = 2
		$Message.text = "Stage 2"
		$SubMessage.text = "Reach max epicness with a final blow on the Villain"
	
	health_hero = health_hero_max
	stamina_hero = stamina_hero_max
	health_villain = health_villain_max
	stamina_villain = stamina_villain_max
	epicness_current = 0
	
	stage_is_over = false
	stage_is_set = true
	enable_buttons()
	


# Combat #######################################################################

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
		action_was_taken = false
		actor = "none"
		manage_epicness()


# Manage epicness
func manage_epicness():
	epicness_current += 1
	
	if epicness_current == 6:
		epicness_reached_peak = true


# Winning and losing Ganhando e perdendo #######################################

func check_gameover():
	if epicness_current == epicness_max and health_villain == 0:
		win()
	elif health_hero == 0:
		lose()
	elif health_villain == 0:
		lose()
	elif epicness_reached_peak:
		lose()

func win():
	$TransitionMessage/Line2.set_text("MAX EPICNESS ACHIEVED")
	$TransitionMessage/Line1.text = str("You win!")
	if health_hero == 0:
		$TransitionMessage/Line3.text = str("The hero's sacrifice will not be forgotten!")
	else:
		$TransitionMessage/Line3.text = str("The villain was slain epically!")
	end_stage()

func lose(): # Differentes mensagens a depender de quem morreu
	$TransitionMessage/Line1.text = str("You lose...")
	if epicness_reached_peak:
		$TransitionMessage/Line2.set_text("The epic moment passed")
		$TransitionMessage/Line3.text = str("The Monarch lost its interest in the battle")
	elif epicness_current != epicness_max:
		$TransitionMessage/Line3.text = str("The battle wasn't epic enough")
	elif health_villain <= 0:
		$TransitionMessage/Line3.text = str("The villain died before the battle got epic")
	elif health_hero <= 0:
		$TransitionMessage/Line3.text = str("The Hero died")
	end_stage()

func end_stage():
	stage_is_over = true
	epicness_reached_peak = false
	stage_is_set = false
	time_transition = time_elapsed
	$TransitionMessage.visible = true
	disable_buttons()
	#$StageMenu.visible = true
	#while 
	#stage_menu_interacted

func disable_buttons():
	$hero_move_1.disabled = true
	$hero_move_2.disabled = true
	$hero_move_3.disabled = true
	$villain_move_1.disabled = true
	$villain_move_2.disabled = true
	$villain_move_3.disabled = true


func enable_buttons():
	$hero_move_1.disabled = false
	$hero_move_2.disabled = false
	$hero_move_3.disabled = false
	$villain_move_1.disabled = false
	$villain_move_2.disabled = false
	$villain_move_3.disabled = false


# Character movesets ###########################################################
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


# etc ##########################################################################

func _on_reload_button_down():
	get_tree().reload_current_scene()

func _on_quit_button_down():
	get_tree().quit()
