extends Node2D

# === CONFIGURATION ===
@export var water_rise_speed = 16.0
@export var water_trigger_x = 500.0

# On garde tes textes originaux et on complète la suite de l'histoire
@export var story_texts: Array[String] = [
	"2099 : Le point de non-retour est franchi",                    # Index 0 (X)
	"Le jour de dépassement de la Terre arrive dès Janvier",       # Index 1 (X)
	"Les mutants sont les cicatrices d'une Terre à l'agonie",       # Index 2 (X)
	"L'APOCALYPSE EST LÀ. GRIMPEZ POUR SURVIVRE !",                # Index 3 (Y)
	"Plus haut... toujours plus haut...",                          # Index 4 (Y)
	"L'océan ne monte pas : il reprend ce que nous lui avons volé.",# Index 5 (Y)
	"Chaque degré gagné a été payé par une espèce disparue.",       # Index 6 (Y)
	"Nous avons brûlé le futur pour rien.", # Index 7 (Y)
	"La chaleur a fondu les glaces, le froid a gelé nos cœurs.",     # Index 8 (Y)
	"L'ADN n'a pas survécu au climat : les mutants sont nés.", # Index 9 (Y)
	"Les mutants ne sont pas des monstres, mais notre reflet.",     # Index 10 (Y)
	"Le plastique dans nos veines, la poussière dans nos poumons.",  # Index 11 (Y)
	"La croissance infinie était un suicide collectif.",            # Index 12 (Y)
	"Grimper n'est pas gagner. C'est juste retarder la fin.",       # Index 13 (Y)
	"La Terre se moque de notre survie. Elle veut juste respirer."   # Index 14 (Y)
]

# Les positions X ne comptent que pour les index 0, 1, 2.
# À partir de l'index 3, seul le Y (négatif) déclenche le texte.
@export var text_trigger_positions: Array[Vector2] = [
	# Phase d'introduction au sol (déplacement horizontal)
	Vector2(100, 0),    # Texte 0 : 2099 Le point de non-retour
	Vector2(300, 0),    # Texte 1 : Jour de dépassement
	Vector2(450, 0),    # Texte 2 : Les mutants sont les cicatrices
	Vector2(0, -150),   # Texte 3 : L'Apocalypse (Tout début de la montée)
	Vector2(0, -300),   # Texte 4 : Sortie immédiate de la zone basse
	Vector2(0, -400),   # Texte 5 : Premier palier de plateformes
	Vector2(0, -700),   # Texte 6 : Ascension vers le premier tiers
	Vector2(0, -900),   # Texte 7 : La pollution
	Vector2(0, -1000),  # Texte 8 : Le vide commence
	Vector2(0, -1200),  # Texte 9 : Les mutants (milieu du parcours)
	Vector2(0, -1400),  # Texte 10 : Réflexion sur nous-mêmes
	Vector2(0, -1600),  # Texte 11 : Le plastique dans les veines
	Vector2(0, -1800),  # Texte 12 : La croissance infinie
	Vector2(0, -2000),  # Texte 13 : Presque au sommet (Y=-2000)
	Vector2(0, -2100),  # Texte 14 : Message final tout en haut !
]

@export var text_duration = 5.0 # Un peu plus long pour laisser le temps de lire

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
	print("📊 Système de narration prêt. Objectif : Sommet de l'apocalypse.")

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
		if player.global_position.y >= water_top - 10: # Marge plus serrée
			if player.has_method("die"):
				player.die()

func check_text_trigger():
	if current_text_index >= story_texts.size():
		return
	
	var trigger_pos = text_trigger_positions[current_text_index]
	var player_pos = player.global_position
	var triggered = false
	
	# Transition Horizontale (Début du jeu)
	if current_text_index < 3:
		triggered = player_pos.x >= trigger_pos.x
	# Transition Verticale (La montée)
	else:
		triggered = player_pos.y <= trigger_pos.y
	
	if triggered:
		show_text(story_texts[current_text_index])
		current_text_index += 1

func show_text(text: String):
	if not story_label: return
	
	# On arrête un éventuel fondu sortant en cours
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
	if not is_showing_text: # Sécurité si un nouveau texte est apparu entre-temps
		story_label.visible = false

func update_text_timer(delta):
	if is_showing_text:
		text_timer += delta
		if text_timer >= text_duration:
			is_showing_text = false
			hide_text()
