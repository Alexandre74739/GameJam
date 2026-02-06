extends Area2D
 
func _ready():
	# AVANT : On cache tout au lancement du jeu
	visible = false
	# On désactive le monitoring pour ne pas changer de map par erreur
	monitoring = false 
	# Optionnel : désactive aussi le collider physiquement pour être sûr
	$CollisionShape2D.set_deferred("disabled", true)
	self.connect("body_entered", _on_body_entered)
	print("🚪 Portail créé")
 
func appear():
	# APRÈS : Appelée par le WaveManager
	visible = true
	monitoring = true
	# On réactive le collider pour que le joueur puisse entrer
	$CollisionShape2D.set_deferred("disabled", false)
	# Lance l'animation si elle existe
	if $AnimatedSprite2D.sprite_frames.has_animation("default"):
		$AnimatedSprite2D.play("default")
	print("✅ PORTAIL ACTIVÉ - portal_unlocked =", WaveManager.portal_unlocked)
 
func _on_body_entered(body : Node2D):
	print("🔍 Quelqu'un entre:", body.name, "| Groupe Player?", body.is_in_group("Player"), "| Portal unlocked?", WaveManager.portal_unlocked)
	if body.is_in_group("Player") and WaveManager.portal_unlocked: 
		print("🌀 TÉLÉPORTATION!")
		get_tree().change_scene_to_file("res://scenes/world_story.tscn")
