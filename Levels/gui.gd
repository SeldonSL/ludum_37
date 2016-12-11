extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var total_time = get_parent().get_node("Countdown").get_wait_time()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("AP").set_text("Actions Points:  "+str(get_parent().current_AP))

func _on_Timer_timeout():
	var time = get_parent().get_node("Countdown").get_time_left()
	var upload = int(100 - 100.0 * time / total_time)
	get_node("Timer").set_text("Upload:  " + str(upload) +"  %"  )
