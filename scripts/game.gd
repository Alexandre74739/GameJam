extends Node2D

var temperature : int = 0 

# Chemins mis à jour selon la structure VBoxContainer
@onready var temp_label = $UI/HUD_Cadre/VBoxContainer/Templabel
@onready var info_label = $UI/HUD_Cadre/VBoxContainer/InfoLabel
@onready var map_chaude = $MapChaude

func _ready() -> void:
	update_temp_display()

func _on_temp_timer_timeout() -> void:
	# Évolution selon quelle map est au premier plan
	if map_chaude.z_index >= 0:
		temperature += 1
	else:
		temperature -= 1
	
	update_temp_display()
	
	if temperature <= -20 or temperature >= 50:
		die()

func update_temp_display():
	if temp_label == null: return
	
	temp_label.text = str(temperature) + "°C"
	
	# Gestion sélective des couleurs (Uniquement sur temp_label)
	if temperature >= 40:
		temp_label.modulate = Color.RED
		info_label.text = "ALERTE : CHALEUR CRITIQUE !"
	elif temperature <= -10:
		temp_label.modulate = Color("#1e90ff")
		info_label.text = "ALERTE : FROID GLACIAL !"
	else:
		temp_label.modulate = Color.WHITE
		info_label.text = "Température stable"

func die():
	print("Mort par température !")
	get_tree().reload_current_scene()
