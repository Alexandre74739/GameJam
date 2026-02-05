extends Node

# Timer pour passer au menu après l'intro
@onready var intro_timer = Timer.new()

func _ready():
	# Ajouter le timer à la scène
	add_child(intro_timer)
	intro_timer.one_shot = true
	intro_timer.timeout.connect(_on_intro_finished)
	$"scène intro/AnimationPlayer".play("arrivee_perso")
	
	# Durée de l'intro en secondes (ajustez selon votre besoin)
	intro_timer.start(34.4)

func _on_intro_finished():
	$"scène intro/MusiqueIntro".stop()
	# Passer au menu principal
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

# Option : Permettre de passer l'intro en appuyant sur une touche
func _input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_on_intro_finished()
