extends Node2D

# === CONFIGURATION ===
@export var water_rise_speed = 16.0  # Vitesse de montée (16 pixels = 1 bloc/seconde)
@export var water_trigger_x = 500.0  # Position X où l'eau commence à monter

@export var story_texts: Array[String] = [
	"2099 : Le point de non-retour est franchi",
	"Le jour de dépassement de la Terre arrive dès Janvier",
	"Les mutants sont les cicatrices d'une Terre à l'agonie",
	"L'APOCALYPSE EST LÀ. GRIMPEZ POUR SURVIVRE !",
	"Plus haut... toujours plus haut..."
]

# Positions X ou Y où les textes apparaissent
@export var text_trigger_positions: Array[Vector2] = [
	Vector2(0, 0),    # Texte 1 : Quand X > 200 (début horizontal)
	Vector2(400, 0),    # Texte 2 : Quand X > 600 (milieu horizontal)
	Vector2(900, 0),    # Texte 3 : Quand X > 900 (avant la montée)
	Vector2(900, -200), # Texte 4 : Quand Y < -200 (pendant la montée)
	Vector2(900, -400), # Texte 5 : Quand Y < -400 (plus haut)
]

@export var text_duration = 4.0

# === RÉFÉRENCES ===
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var water_rect = $WaterRect
@onready var story_label = $UI/StoryLabel

# === VARIABLES ===
var is_water_rising = false
var current_text_index = 0
var text_timer = 0.0
var is_showing_text = false

func _ready():
	if story_label:
		story_label.visible = false
		story_label.modulate.a = 0.0
	
	print("📊 Textes configurés pour les positions : ", text_trigger_positions)

func _process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		return
	
	# Debug (décommente pour voir la position du joueur)
	# print("Position joueur : X=", player.global_position.x, " Y=", player.global_position.y)
	
	check_water_trigger()
	update_water_position(delta)
	check_player_drowning()
	check_text_trigger()
	update_text_timer(delta)

func check_water_trigger():
	# Déclencher l'eau quand le joueur dépasse une certaine position X
	if not is_water_rising and player.global_position.x >= water_trigger_x:
		is_water_rising = true
		print("🌊 L'EAU COMMENCE À MONTER ! Position X = ", player.global_position.x)

func update_water_position(delta):
	if is_water_rising and water_rect:
		# L'eau monte (Y diminue)
		water_rect.position.y -= water_rise_speed * delta

func check_player_drowning():
	if is_water_rising and water_rect and player:
		var water_top = water_rect.global_position.y
		
		# Si le joueur est en dessous (ou au niveau) de l'eau
		if player.global_position.y >= water_top - 20:
			if player.has_method("die"):
				print("💀 Le joueur s'est noyé à Y = ", player.global_position.y)
				player.die()

func check_text_trigger():
	if current_text_index >= story_texts.size():
		return
	
	var trigger_pos = text_trigger_positions[current_text_index]
	var player_pos = player.global_position
	
	# Vérifier si le joueur a atteint la position de déclenchement
	var triggered = false
	
	# Pour les 3 premiers textes : basé sur X (mouvement horizontal)
	if current_text_index < 3:
		triggered = player_pos.x >= trigger_pos.x
	# Pour les textes suivants : basé sur Y (montée verticale)
	else:
		triggered = player_pos.y <= trigger_pos.y
	
	if triggered:
		print("📜 Texte ", current_text_index + 1, " déclenché")
		show_text(story_texts[current_text_index])
		current_text_index += 1

func show_text(text: String):
	if not story_label:
		return
	
	story_label.text = text
	story_label.visible = true
	is_showing_text = true
	text_timer = 0.0
	
	var tween = create_tween()
	tween.tween_property(story_label, "modulate:a", 1.0, 0.5)

func hide_text():
	if not story_label:
		return
	
	var tween = create_tween()
	tween.tween_property(story_label, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	story_label.visible = false
	is_showing_text = false

func update_text_timer(delta):
	if is_showing_text:
		text_timer += delta
		if text_timer >= text_duration:
			hide_text()
