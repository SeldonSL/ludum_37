extends Node

# class member variables 
export var max_AP = 10

var current_AP = max_AP 

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	

func _on_AP_Timer_timeout():
	current_AP += 1
	current_AP = min (current_AP, max_AP)
	get_node("GUI/AP").set_text("Action Points:  " + str(current_AP))

func _on_Countdown_timeout():
	print ("Level complete!")
	pass # replace with function body
