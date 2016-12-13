extends Area2D

export var life = 100
var currentLife = life

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _draw():
	draw_rect(Rect2(-22,25,50,12),  Color(0.871, 0.808, 0.612))
	draw_rect(Rect2(-20,27,46.0*currentLife/life, 8),  Color(0.635, 0.071, 0.196))
	
func add_life(lifeValue):
	
	currentLife += lifeValue
	print (currentLife)
	if currentLife > life:
		currentLife = life
	
	update()	
	if currentLife <= 0:
		print ("Game OVER")
		get_tree().get_root().get_node("level/loose").show()
		get_tree().set_pause(true)
		queue_free()
	
