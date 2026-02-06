extends Area2D

var portal_actif = false

func _ready():
	# Désactive le portail au démarrage
	visible = false
	monitoring = false
	$CollisionShape2D.disabled = true
	print("🚪 Portail créé (inactif)")

func appear():
	# Active le portail quand appelé par WaveManager
	visible = true
	portal_actif = true
	monitoring = true
	$CollisionShape2D.disabled = false
	
	# Lance l'animation
	if has_node("AnimatedSprite2D") and $AnimatedSprite2D.sprite_frames.has_animation("default"):
		$AnimatedSprite2D.play("default")
	
	print("✅ PORTAIL ACTIVÉ - Prêt à téléporter!")

func _on_body_entered(body):
	# Affiche ce qui entre
	print("🔍 Collision portail: ", body.name)
	
	# Si le portail est actif et que c'est un CharacterBody2D (le joueur)
	if portal_actif:
		print("🌀 TÉLÉPORTATION vers world_story.tscn")
		get_tree().change_scene_to_file("res://scenes/world_story.tscn")
