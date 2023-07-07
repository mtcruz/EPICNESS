extends Node2D

# Definir vida e stamina de cada personagem
@export var health_hero = 100
@export var health_villain = 100
@export var stamina_hero = 100
@export var stamina_villain = 100

# Definir número de turnos
@export var turn_current = 0
@export var turn_max = 10

func _process(delta):
	$HeroHealth.text = str(health_hero)
	$VillainHealth.text = str(health_villain)
	$HeroStamina.text = str(stamina_hero)
	$VillainStamina.text = str(stamina_villain)
	$Turns.text = str(turn_current)
	check_gameover()

# Moves hero -----
func _on_soco_cruzado_button_down():
	health_villain -= 10
	stamina_hero -= 10
	turn_current += 1
	
func _on_chute_frontal_button_down():
	health_villain -= 10
	stamina_hero -= 10

# Moves villain ----
func _on_cabecada_button_down():
	health_hero -= 10
	stamina_villain -= 10
	
func _on_empurrada_button_down():
	health_hero -= 10
	stamina_villain -= 10

func check_gameover():
	if turn_current == turn_max:
		win()
	elif health_villain == 0:
		lose()
	elif health_hero == 0:
		lose()

func win():
	$Message.text = str("You win!")

func lose():
	$Message.text = str("You lose :(")
