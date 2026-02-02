extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -300.0

@onready var _animated_sprite = $AnimatedSprite2D

var is_attacking = false

func _physics_process(delta: float) -> void:
	# 1. Gravité (toujours active)
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Gestion de l'Attaque (Espace)
	# On déclenche l'attaque sans bloquer les variables de mouvement
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack_action()

	# 3. Mouvement Horizontal (Toujours possible, même en attaquant)
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		_animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Saut (Flèche du haut)
	if Input.is_key_pressed(KEY_UP) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	update_animations()

func update_animations():
	# PRIORITÉ 1 : Si on attaque, on joue l'animation d'attaque
	if is_attacking:
		_animated_sprite.play("attack")
		return # On sort de la fonction pour ne pas écraser l'attaque par "walk"
	
	# PRIORITÉ 2 : Sinon, on joue les animations de mouvement classiques
	if not is_on_floor():
		_animated_sprite.play("jump")
	elif velocity.x != 0:
		_animated_sprite.play("walk")
	else:
		_animated_sprite.play("idle")

func attack_action():
	is_attacking = true
	# On attend la fin de l'animation d'attaque
	await _animated_sprite.animation_finished
	is_attacking = false
