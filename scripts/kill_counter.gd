extends Label

var kill_count = 0

func _ready():
	update_display()

func add_kill():
	kill_count += 1
	update_display()
	print("💀 Ennemis tués : ", kill_count)

func update_display():
		text = "Kills: " + str(kill_count)

func reset_counter():
	kill_count = 0
	update_display()
