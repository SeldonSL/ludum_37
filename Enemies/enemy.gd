# SquadMember
extends KinematicBody2D

# Atributes
export var speed = 100 # enemy speed
export var life = 3 # enemy life

# State
var currentLife = life
var is_dead = false
var shootAngle = PI/2
var target = null
var target_wr = null
var path = []
# Resources
var weapon_1 = preload("res://Weapons/weapon_1.tscn")

onready var sound = get_node("/root/menu_music/SamplePlayer")

func _ready():
	add_to_group("enemies")
	_on_AI_timeout()

func _process(delta):
	# Movement
	if (path.size()>1):
			var to_walk = speed * delta
			while(to_walk>0 and path.size()>=2):
				var pfrom = path[path.size()-1]
				var pto = path[path.size()-2]
				var d = pfrom.distance_to(pto)
				if (d<=to_walk):
					path.remove(path.size()-1)
					to_walk-=d
				else:
					path[path.size()-1] = pfrom.linear_interpolate(pto,to_walk/d)
					to_walk=0
			var atpos = path[path.size()-1]			
			shootAngle = get_pos().angle_to_point(atpos) + PI
			set_rot(shootAngle)
			shootAngle = -(shootAngle - PI/2)
			set_pos(atpos)

			if (path.size()<2):
				path=[]
				#get_node("ActionMenu").set_rot(-shootAngle)
				set_process(false)
				get_node("Timer").start()
				get_node("AI").start()
				print (target)
				if (target_wr.get_ref()):
					shootAngle = - get_global_pos().angle_to_point(target.get_global_pos()) + 3 * PI / 2

				
func add_life(lifeValue):
	if is_dead:
		return
		
	currentLife += lifeValue
	if currentLife > life:
		currentLife = life
		
	if currentLife <= 0:
		get_node("Particles2D").set_emitting(true)
		set_process(false)
		get_node("Timer").stop()
		
		get_node("Sprite").hide()
		is_dead = true
		get_node("death").start()
		sound.play("Explosion11", true)

func _on_shoot_timeout():

	get_node("Weapon").fire_weapon(shootAngle)
	
func _on_AI_timeout():
	var choice = randi() % 10
	var angle_off = randi() % 360
	var offset = Vector2(150 * cos(deg2rad(angle_off)), 150 * sin(deg2rad(angle_off)))
	var squad = get_tree().get_nodes_in_group("squad")
	var pos
	
	if choice >= 6:
		target = get_tree().get_root().get_node("level/data_nexus")
		pos = get_tree().get_root().get_node("level/data_nexus").get_pos()
	else:
		target = squad[floor(choice/6 * squad.size())]
		pos = target.get_pos()
	
	target_wr = weakref(target);
	path = Array(get_tree().get_root().get_node("level/room").get_simple_path(get_pos(),pos + offset, true))
	path.invert()
	set_process(true)
	get_node("Timer").stop()
	get_node("AI").stop()



func _on_death_timeout():
	queue_free()
	

