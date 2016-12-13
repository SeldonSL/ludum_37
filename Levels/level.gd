extends Node

# class member variables 
export var max_AP = 10
var enemy = preload("res://Enemies/enemy.tscn")
var current_AP = max_AP 

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	randomize()
	_on_enemy_spawn_timeout()
	

func _on_AP_Timer_timeout():
	current_AP += 1
	current_AP = min (current_AP, max_AP)
	get_node("GUI/AP").set_text("Action Points:  " + str(current_AP))

func _on_Countdown_timeout():
	print ("Level complete!")
	get_node("win").show()
	get_tree().set_pause(true)
	pass # replace with function body


func _on_enemy_spawn_timeout():
	var n_enemies = randi() % 5 + 1
	for i in range (0, n_enemies):
		var e = enemy.instance()
		e.set_scale(Vector2(0.3,0.3))
		var offset = randi()% 60 - 30
		var pos = randi() % 100
		if pos <= 50:			
			e.set_pos(get_node("enemy_pos1").get_pos() + Vector2(pos/2, pos/2))
		else:
			e.set_pos(get_node("enemy_pos2").get_pos() + Vector2(pos/2, pos/2))
		add_child(e)
		

		
	
