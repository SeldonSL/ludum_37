extends Node

export var angle = 30
export var distance = 100
var bullet = preload("res://Weapons/bullet_enemy.tscn")
#onready var sound = get_node("/root/menu_music/SamplePlayer")

func _ready():
	pass

func fire_weapon(firing_angle):

	# check if enemy is within range
	var enemies = get_tree().get_nodes_in_group("squad")
	for enemy in enemies:
		var d = get_parent().get_global_pos().distance_to(enemy.get_global_pos())
		var alfa = - get_parent().get_global_pos().angle_to_point(enemy.get_global_pos()) + 3*PI / 2

		if d <= distance and (alfa <= firing_angle + deg2rad(angle)) and (alfa >= firing_angle - deg2rad(angle)): # fire (first enemy encountered)	
		 	# create bullet node
			var b = bullet.instance()
			b.set_rot(3*PI/2-alfa)
			get_tree().get_root().add_child(b)
			
			# set initial angle
			var dir_angle = Vector2(45 * cos(3*PI/2-alfa), 45 * sin(3*PI/2-alfa)) 
			b.set_pos(get_parent().get_pos())# + dir_angle)
			b.set_angle(alfa)
			
			break
			
		elif alfa >= 2 * PI and d <= distance and (alfa <= firing_angle + 2 * PI + deg2rad(angle)) and (alfa >= firing_angle + 2* PI - deg2rad(angle)): # fire (first enemy encountered)	
			# create bullet node
			var b = bullet.instance()
			b.set_rot(3*PI/2-alfa)
			get_tree().get_root().add_child(b)
			
			# set initial angle
			var dir_angle = Vector2(0,0) #Vector2(45 * cos(3*PI/2-alfa), 45 * sin(3*PI/2-alfa)) 
			b.set_pos(get_parent().get_pos())#get_parent().get_pos())# + dir_angle)
			b.set_angle(alfa)
			
			break
			
			# play sound
			#sound.play("Laser_09", true)
		


