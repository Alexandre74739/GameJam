extends Node2D

# === CONFIGURATION ===
@export var water_rise_speed = 16.0
@export var water_trigger_x = 500.0

@export var story_texts: Array[String] = [
	"2099 : Le point de non-retour est franchi",
	"Le jour de dépassement de la Terre arrive dès Janvier",
	"Les mutants sont les cicatrices d'une Terre à l'agonie",
	"L'APOCALYPSE EST LÀ. GRIMPEZ POUR SURVIVRE !",
	"Plus haut... toujours plus haut...",
	"L'océan ne monte pas : il reprend ce que nous lui avons volé.",
	"Chaque degré gagné a été payé par une espèce disparue.",
	"Nous avons brûlé le futur pour rien.",
	"La chaleur a fondu les glaces, le froid a gelé nos cœurs.",
	"L'ADN n'a pas survécu au climat : les mutants sont nés.",
	"Les mutants ne sont pas des monstres, mais notre reflet.",
	"Le plastique dans nos veines, la poussière dans nos poumons.",
	"La croissance infinie était un suicide collectif.",
	"Grimper n'est pas gagner. C'est juste retarder la fin.",
	"La Terre se moque de notre survie. Elle veut juste respirer."
]

@export var text_trigger_positions: Array[Vector2] = [
	Vector2(0, -150),   # Texte 3
	Vector2(0, -300),   # Texte 4
	Vector2(0, -400),   # Texte 5
	Vector2(0, -700),   # Texte 6
	Vector2(0, -900),   # Texte 7
	Vector2(0, -1000),  # Texte 8
	Vector2(0, -1200),  # Texte 9
	Vector2(0, -1400),  # Texte 10
	Vector2(0, -1600),  # Texte 11
	Vector2(0, -1800),  # Texte 12
	Vector2(0, -2000),  # Texte 13
	Vector2(0, -2100),  # Texte 14
]

@export var text_duration = 5.0

# === RÉFÉRENCES ===
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var water_rect = $WaterRect
@onready var story_label = $UI/MarginContainer/StoryLabel

# === VARIABLES ===
var is_water_rising = false
var current_text_index = 0
var text_timer = 0.0
var is_showing_text = false

func _ready():
	if story_label:
		story_label.visible = false
		story_label.modulate.a = 0.0
	print("📊 Système de narration prêt.")

func _process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		return
	
	check_water_trigger()
	update_water_position(delta)
	check_player_drowning()
	check_text_trigger()
	update_text_timer(delta)

func check_water_trigger():
	if not is_water_rising and player.global_position.x >= water_trigger_x:
		is_water_rising = true
		print("🌊 L'EAU MONTE !")

func update_water_position(delta):
	if is_water_rising and water_rect:
		water_rect.position.y -= water_rise_speed * delta

func check_player_drowning():
	if is_water_rising and water_rect and player:
		var water_top = water_rect.global_position.y
		if player.global_position.y >= water_top - 10:
			if player.has_method("die"):
				player.die()

func check_text_trigger():
	if current_text_index >= story_texts.size():
		return
	
	var trigger_pos = text_trigger_positions[current_text_index]
	var player_pos = player.global_position
	var triggered = false
	
	if current_text_index < 3:
		triggered = player_pos.x >= trigger_pos.x
	else:
		triggered = player_pos.y <= trigger_pos.y
	
	if triggered:
		show_text(story_texts[current_text_index])
		current_text_index += 1

func show_text(text: String):
	if not story_label: return
	
	var tween = create_tween()
	story_label.text = text
	story_label.visible = true
	is_showing_text = true
	text_timer = 0.0
	tween.tween_property(story_label, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)

func hide_text():
	if not story_label: return
	var tween = create_tween()
	tween.tween_property(story_label, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
	await tween.finished
	if not is_showing_text:
		story_label.visible = false

func update_text_timer(delta):
	if is_showing_text:
		text_timer += delta
		if text_timer >= text_duration:
			is_showing_text = false
			hide_text()
