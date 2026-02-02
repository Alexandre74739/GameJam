extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -300.0

@onready var _animated_sprite = $AnimatedSprite2D
# On récupère le nœud audio pour le son de l'épée
@onready var sfx_attaque = $SfxAttaque 

var is_attacking = false

func _physics_process(delta: float) -> void:
	# 1. Gestion de la Gravité
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Déclenchement de l'Attaque (Touche Espace / Action "attack")
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack_action()

	# 3. Mouvement Horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# On permet le mouvement même en attaquant, mais on peut réduire la vitesse si on veut
	if direction:
		velocity.x = direction * SPEED
		_animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Gestion du Saut (Flèche du haut)
	if Input.is_key_pressed(KEY_UP) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	update_animations()

func update_animations():
	# PRIORITÉ 1 : L'animation d'attaque bloque les autres visuels
	if is_attacking:
		_animated_sprite.play("attack")
		return 
	
	# PRIORITÉ 2 : Animations de déplacement classiques
	if not is_on_floor():
		_animated_sprite.play("jump")
	elif velocity.x != 0:
		_animated_sprite.play("walk")
	else:
		_animated_sprite.play("idle")

func attack_action():
	is_attacking = true
	
	# Joue le bruitage "tap-eppe"
	if sfx_attaque:
		sfx_attaque.play()
	
	# On attend la fin de l'animation d'attaque avant de redonner la priorité aux autres
	# Note : L'animation "attack" dans SpriteFrames ne doit pas être en boucle (Loop)
	await _animated_sprite.animation_finished
	
	is_attacking = false

# Cette fonction peut rester vide si la logique est gérée dans le script du Coin
func _on_coin_body_entered(_body: Node2D) -> void:
	pass
