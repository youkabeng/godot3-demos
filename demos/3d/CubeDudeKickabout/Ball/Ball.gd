extends RigidBody

var spawn

func _ready():
	spawn = get_tree().get_root().find_node("BallSpawn", true, false)

func reset():
	translation = spawn.translation
	axis_lock_linear_x = false
	axis_lock_linear_y = false
	axis_lock_linear_z = false

func freeze():
	axis_lock_linear_x = true
	axis_lock_linear_y = true
	axis_lock_linear_z = true
