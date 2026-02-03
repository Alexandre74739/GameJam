extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -300.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var sfx_attaque = $SfxAttaque 

var is_attacking = false
var is_dead = false # AJOUT : Pour bloquer les autres animations

func _physics_process(delta: float) -> void:
	if is_dead: return # AJOUT : Stoppe tout mouvement si mort

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack_action()

	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * SPEED
		_animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_key_pressed(KEY_UP) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	update_animations()

func update_animations():
	if is_dead: # PRIORITÉ ABSOLUE : Mort
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

# FONCTION DE MORT CORRIGÉE
func die():
	if is_dead: return # Évite de mourir deux fois
	is_dead = true
	
	velocity = Vector2.ZERO # Arrête le mouvement
	_animated_sprite.play("death") # Lance l'animation
	
	# Attendre la fin de l'animation ou un timer
	await get_tree().create_timer(0.6).timeout
	
	# FIX CRASH : call_deferred pour recharger la scène proprement
	call_deferred("reset_game")

func reset_game():
	get_tree().reload_current_scene()

func attack_action():
	is_attacking = true
	if sfx_attaque:
		sfx_attaque.play()
	await _animated_sprite.animation_finished
	is_attacking = false
