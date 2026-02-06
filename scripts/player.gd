extends CharacterBody2D
class_name Player

const SPEED = 120.0
const JUMP_VELOCITY = -300.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var sfx_attaque = $SfxAttaque 
@onready var attack_area = $AttackArea # Récupère ton nouveau nœud

var is_attacking = false
var is_dead = false 

func _physics_process(delta: float) -> void:
	if is_dead: 
		return # Empêche tout mouvement si mort

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Lancement de l'attaque
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack_action()

	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction and not is_attacking: # On bloque le déplacement pendant l'attaque pour plus de réalisme
		velocity.x = direction * SPEED
		_animated_sprite.flip_h = direction < 0
		# On oriente la zone d'attaque selon la direction du regard
		attack_area.scale.x = -1 if direction < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_key_pressed(KEY_UP) and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	update_animations()

func update_animations():
	if is_dead:
		_animated_sprite.play("death")
		return
		
	if is_attacking:
		_animated_sprite.play("attack")
		return 
	
	if not is_on_floor():
		_animated_sprite.play("jump")
	elif velocity.x != 0:
		_animated_sprite.play("walk")
	else:
		_animated_sprite.play("idle")

func attack_action():
	is_attacking = true
	if sfx_attaque:
		sfx_attaque.play()
	
	# ÉTAPE CRUCIALE : On active la zone d'attaque uniquement ici
	attack_area.set_deferred("monitoring", true)
	
	await _animated_sprite.animation_finished
	
	# On éteint la zone après le coup
	attack_area.set_deferred("monitoring", false)
	is_attacking = false

func die():
	if is_dead: return 
	is_dead = true
	
	# Jouer le son de game over
	var sfx_game_over = AudioStreamPlayer.new()
	sfx_game_over.stream = load("res://assets/sounds/son_game_over.mp3")
	add_child(sfx_game_over)
	sfx_game_over.play()
	
	velocity = Vector2.ZERO 
	_animated_sprite.play("death") # Priorité absolue dans update_animations
	
	# On désactive les collisions avec les ennemis pour ne pas mourir en boucle
	set_collision_layer_value(1, false) 
	
	await get_tree().create_timer(3).timeout
	call_deferred("reset_game")

func reset_game():
	# Mettre le jeu en pause
	get_tree().paused = true
	
	# Créer un CanvasLayer pour afficher par-dessus tout
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Au-dessus de tout
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS  # Continue à fonctionner même en pause
	get_tree().root.add_child(canvas_layer)
	
	# Charger et afficher la page dead
	var dead_scene = load("res://scenes/pagedead.tscn").instantiate()
	dead_scene.process_mode = Node.PROCESS_MODE_ALWAYS  # Les boutons fonctionnent en pause
	canvas_layer.add_child(dead_scene)

# Assure-toi que ce signal est bien connecté dans l'éditeur
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Ennemy: 
		print("Ennemi touché !")
		body.die_pnj() # Appelle la mort du PNJ
