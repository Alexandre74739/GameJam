extends Node2D

var temperature : int = 0 

# Correction du chemin selon ton arbre de scène
@onready var temp_label = $UI/Templabel
@onready var info_label = $UI/InfoLabel # Le nouveau label indicatif
@onready var map_chaude = $MapChaude

func _ready() -> void:
	# On initialise l'affichage
	update_temp_display()

func _on_temp_timer_timeout() -> void:
	# Évolution selon la map active
	if map_chaude.z_index >= 0:
		temperature += 1
	else:
		temperature -= 1
	
	update_temp_display()
	
	if temperature <= -20 or temperature >= 50:
		die()

func update_temp_display():
	if temp_label == null: return # Sécurité contre le crash
	
	temp_label.text = str(temperature) + "°C"
	
	# Gestion des couleurs et des phrases indicatives
	if temperature >= 40:
		temp_label.modulate = Color.RED
		info_label.text = "ALERTE : CHALEUR CRITIQUE !"
		info_label.modulate = Color.RED
	elif temperature <= -10:
		temp_label.modulate = Color.DARK_BLUE
		info_label.text = "ALERTE : FROID GLACIAL !"
		info_label.modulate = Color.DARK_BLUE
	else:
		temp_label.modulate = Color.WHITE
		info_label.text = "Température stable"
		info_label.modulate = Color.WHITE

func die():
	get_tree().reload_current_scene()
