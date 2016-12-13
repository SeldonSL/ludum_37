# SquadMember
extends KinematicBody2D

# Atributes
export var speed = 100 # player speed
export var life = 100 # player life
export var stimpacks = 1000

# State
var currentLife = life
var is_dead = false
var isMoving = false
var new_pos
var isHealing = false
var isUsingPowerup = false
var isAiming = false
var shootAngle = PI/2
var current_stimpacks = 0
var path = []
var hasShield = false
var shield_damage = 10
var hasGranade = false
var granade_pos
var granade_radius = 1000
var hasTurret = false
var turret_pos
# Resources
var weapon_1 = preload("res://Weapons/weapon_1.tscn")
onready var action_menu = get_node("ActionMenu")
onready var sound = get_node("/root/menu_music/SamplePlayer")

func _ready():
	add_to_group("squad")	

func _process(delta):
	# Movement
	if (path.size()>1):
			var to_walk = speed
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
			get_node("ActionMenu").set_rot(-shootAngle)
			shootAngle = -(shootAngle - PI/2)
			set_pos(atpos)

			if (path.size()<2):
				path=[]
				#get_node("ActionMenu").set_rot(-shootAngle)
				set_process(false)
				get_node("Timer").start()

func _unhandled_input(event):
	# Motion
	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed and isMoving:
		new_pos = get_global_mouse_pos()
		set_process(true)
		set_process_unhandled_input(false) 
		isMoving = false
		update()

	if event.type == InputEvent.MOUSE_MOTION \
    and isMoving:
		path = Array(get_parent().get_node("room").get_simple_path(get_pos(),get_global_mouse_pos(), true))
		path.invert()
		update()
	
	# Aiming
	if event.type == InputEvent.MOUSE_MOTION \
    and isAiming:
		var mousePos = get_global_mouse_pos() 
		shootAngle = get_pos().angle_to_point(mousePos)
		shootAngle = - (shootAngle - PI/2) + PI
		look_at(mousePos)
		update()
		get_node("ActionMenu").set_rot(shootAngle - PI/2)

	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed and isAiming:
		isAiming = false
		get_node("Timer").start()
		set_process_unhandled_input(false) 
		update()
	
	# Granade
	if event.type == InputEvent.MOUSE_MOTION \
    and hasGranade:
		var mousePos = get_global_mouse_pos() 
		granade_pos = mousePos
		look_at(mousePos)
		update()
		get_node("ActionMenu").set_rot(shootAngle - PI/2)

	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed and hasGranade:
		hasGranade = false
		get_node("Timer").start()
		granade_pos = get_global_mouse_pos()
		shoot_granade(granade_pos)
		set_process_unhandled_input(false) 
		update()
	
	# Turret
	if event.type == InputEvent.MOUSE_MOTION \
    and hasTurret:
		var mousePos = get_global_mouse_pos() 
		turret_pos = mousePos
		look_at(mousePos)
		update()
		get_node("ActionMenu").set_rot(shootAngle - PI/2)

	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed and hasTurret:
		hasTurret = false
		get_node("Timer").start()
		turret_pos = get_global_mouse_pos()
		get_node("Turret").show()
		get_node("Turret").set_global_pos(turret_pos)
		get_node("Turret/Timer").start()
		get_node("Turret/Timer_turret_down").start()
		set_process_unhandled_input(false) 
		update()

func add_life(lifeValue):
	if is_dead:
		return
	
	if hasShield and lifeValue < 0:
		shield_damage +=lifeValue
		if shield_damage <= 0:
			hasShield = false
			shield_damage = 10
			return
				
	currentLife += lifeValue
	if currentLife > life:
		currentLife = life
	
	update()
	get_node("ActionMenu/Label").set_text("Life = "+str(int(currentLife*100.0/life))+"%")
	if currentLife <= 0:
		get_node("Particles2D").set_emitting(true)
		set_process(false)
		get_node("Timer").stop()
		sound.play("Explosion5", true)
		get_node("Sprite").hide()
		is_dead = true
		get_node("death").start()

#################### Action MENU ##################33
func _input_event(viewport, event, shape_idx):
	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed and not isMoving and not isAiming:
		for action in action_menu.get_children():
			action.show()
		var ap =  get_parent().current_AP
		if ap < 3:
			get_node("ActionMenu/Powerup").hide()
		if ap < 2 or current_stimpacks >= stimpacks:
			get_node("ActionMenu/Heal").hide()
		if ap < 1:
			get_node("ActionMenu/Move").hide()		
		action_menu.show()

func _on_move_input_event( viewport, event, shape_idx ):
	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed:
		print("Move")
		isMoving = true
		action_menu.hide()
		set_process_unhandled_input(true) 
		get_node("Timer").stop()
		get_parent().current_AP -= 1		
		get_node("../GUI/AP").set_text("Action Points:  " + str(get_parent().current_AP))

func _on_aim_input_event( viewport, event, shape_idx ):
	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed:
		print("Aim")
		action_menu.hide()
		set_process_unhandled_input(true) 
		isAiming = true
		get_node("Timer").stop()

func _on_heal_input_event( viewport, event, shape_idx ):
	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed:
		print("Heal")
		sound.play("Powerup12", true)
		action_menu.hide()
		currentLife += int(life/3)
		currentLife = min(currentLife, life)
		current_stimpacks += 1
		get_parent().current_AP -= 2
		get_node("../GUI/AP").set_text("Action Points:  " + str(get_parent().current_AP))


func _on_powerup_input_event( viewport, event, shape_idx ):
	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed:
		print("Powerup")
		action_menu.hide() 
		get_parent().current_AP -= 3
		get_node("../GUI/AP").set_text("Action Points:  " + str(get_parent().current_AP))
		
		if has_node("Shield"):
			hasShield = true
			update()
		elif has_node("Granade"):
			set_process_unhandled_input(true) 
			hasGranade = true
			get_node("Timer").stop()
		elif has_node("Turret"):
			print("Turret")
			set_process_unhandled_input(true) 
			hasTurret = true
			get_node("Timer").stop()




func _on_shoot_timeout():
	get_node("Weapon").fire_weapon(shootAngle)
	
############   DRAWING  ################

func draw_circle_arc( center, radius, angle_from, angle_to, color ):
    var nb_points = 32
    var points_arc = Vector2Array()

    for i in range(nb_points+1):
        var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
        var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
        points_arc.push_back( point )

    for indexPoint in range(nb_points):
        draw_line(points_arc[indexPoint], points_arc[indexPoint+1], color, 4)

func draw_circle_arc_poly( center, radius, angle_from, angle_to, color ):
    var nb_points = 32
    var points_arc = Vector2Array()
    points_arc.push_back(center)
    var colors = ColorArray([color])

    for i in range(nb_points+1):
        var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
        points_arc.push_back(center + Vector2( cos( deg2rad(angle_point) ), sin( deg2rad(angle_point) ) ) * radius)
    draw_polygon(points_arc, colors)

func _draw():
	if hasGranade:
		draw_circle_arc((granade_pos-get_global_pos()).rotated(-get_rot())/get_scale().x,  granade_radius, 0, 359, Color(1,0,0))
	
	if hasTurret:
		draw_circle_arc((turret_pos-get_global_pos()).rotated(-get_rot())/get_scale().x,  300, 0, 359, Color(1,0,0))
		
	if hasShield:
		var center = Vector2(0,0)
		var radius = 400
		var angle_from = 0
		var angle_to = 355
		var color = Color(1, 1, 1)
		draw_circle_arc( center, radius, angle_from, angle_to, color )
		
	if isMoving:
		var p1 = Vector2(0,0)
		for i in range(0,path.size()):
			var pt = path[path.size() - i -1 ] - get_global_pos()
			draw_line(p1.rotated(-get_rot())/get_scale().x, pt.rotated(-get_rot())/get_scale().x, Color(1,0,0), 3)
			p1 = pt
				
	elif isAiming:
		var w_angle = get_node("Weapon").angle
		var w_dist  = get_node("Weapon").distance
		draw_circle_arc_poly(Vector2(0,0), w_dist /get_scale().x, -w_angle + 180 , w_angle + 180, Color(1,0,0, 0.5))

func _on_death_timeout():
	var squad = get_tree().get_nodes_in_group("squad")
	if squad.size() == 1:
		print("Game OVER :(")
		get_tree().get_root().get_node("level/loose").show()
		get_tree().set_pause(true)
	queue_free()

func shoot_granade(pos):
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		var d = granade_pos.distance_to(e.get_global_pos())
		if d < granade_radius:
			e.add_life(-10)
		get_node("ParticleGranade").set_global_pos(granade_pos)
		get_node("ParticleGranade").set_emitting(true)
		get_node("timer_granade").start()


func _on_timer_granade_timeout():
	get_node("ParticleGranade").set_emitting(false)


func _on_Timer_turret_timeout():
	get_node("Turret/weapon").fire_weapon(shootAngle)
	print ("shooting")


func _on_Timer_turret_down_timeout():
	get_node("Turret/Timer").stop()
	get_node("Turret").hide()
