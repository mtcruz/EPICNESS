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

# Habilidades de cada personagem ###############################################
# Buttons for the Hero moveset 
func _on_hero_move_1(): # Weak attack
	health_villain -= 2
	stamina_hero -= 1
	epicness_current += 1
func _on_hero_move_2(): # Strong attack
	health_villain -= 4
	stamina_hero -= 3
	epicness_current += 1
func _on_hero_move_3(): # Heal self
	health_hero += 2
	stamina_hero -= 2
	epicness_current += 1

# Buttons for the Villain moveset 
func _on_villain_move_1(): # Strong attack
	health_hero -= 3
	stamina_villain -= 3
	epicness_current += 1
func _on_villain_move_2(): # Kamikaze attack
	health_hero -= 5
	health_villain -= 3
	stamina_villain -= 6
func _on_villain_move_3(): # Regenerate stamina
	stamina_villain += 6

# atualiza variáveis na tela a cada frame
func _process(_delta):
	$HeroHealth.set_text("❤ %d" % [health_hero])
	$VillainHealth.set_text("🖤 %d" % [health_villain])
	$HeroStamina.set_text("💪 %d" % [stamina_hero])
	$VillainStamina.set_text("💪 %d" % [stamina_villain])
	$Turns.set_text("%d / %d" % [epicness_current, epicness_max])
	check_gameover()


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
