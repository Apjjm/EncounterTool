extends Camera2D

@export var cam_speed = Vector2(256,256)
@export var cam_zoom_speed = Vector2(0.25, 0.25)

@onready var folder_dialog = $"../FileDialog"
@onready var steps_dialog = $"../NewStepsDialog"
@onready var overlay = $"Overlay"
@onready var background1 = $"Map1"
@onready var background2 = $"Map2"
@onready var background3 = $"Map3"
@onready var background4 = $"Map4"

var world_offset = Vector2(0,0)
var saved_world_offset = Vector2.INF
var root_path = ""

func _ready() -> void:
	move_world()

func _physics_process(delta: float) -> void:
	if steps_dialog.visible || steps_dialog.visible || folder_dialog.visible:
		return
	
	if Input.is_action_just_pressed("add_info"):
		steps_dialog.show()
		return
	
	if Input.is_action_just_pressed("snapshot"):
		if self.root_path == "":
			folder_dialog.show()
		else:
			snapshot()

	var mult = 1.0
	if Input.is_action_pressed("fast"):
		mult *= 4.0
	if Input.is_action_pressed("slow"):
		mult *= 0.5
	if Input.is_action_pressed("up"):
		self.world_offset.y -= self.cam_speed.y * mult * delta / self.zoom.y
	if Input.is_action_pressed("down"):
		self.world_offset.y += self.cam_speed.y * mult * delta / self.zoom.y
	if Input.is_action_pressed("left"):
		self.world_offset.x -= self.cam_speed.x * mult * delta / self.zoom.x
	if Input.is_action_pressed("right"):
		self.world_offset.x += self.cam_speed.x * mult * delta / self.zoom.x
	if Input.is_action_just_pressed("zoom_in") and self.zoom.x < 8.00:
		change_zoom(self.cam_zoom_speed)
	if Input.is_action_just_pressed("zoom_out") and self.zoom.x > 0.25:
		change_zoom(-self.cam_zoom_speed)
	if Input.is_action_pressed("add_step"):
		self.overlay.insert_step()
	if Input.is_action_just_pressed("del_step"):
		self.overlay.remove_step()
	if Input.is_action_just_pressed("clear_step"):
		self.overlay.clear_steps()
	if Input.is_action_just_pressed("hide"):
		self.overlay.render_grid = !self.overlay.render_grid
	if Input.is_action_just_pressed("set_cam"):
		self.saved_world_offset = self.world_offset
		self.overlay.set_message("Saved offset")
	if Input.is_action_just_pressed("change_map"):
		var was4 = self.background4.visible
		self.background4.visible = self.background3.visible
		self.background3.visible = self.background2.visible
		self.background2.visible = self.background1.visible
		self.background1.visible = was4

	move_world()
	
func snapshot():
	var oldOffset = self.world_offset
	var oldGrid = self.overlay.render_grid
	if self.saved_world_offset.is_finite():
		self.world_offset = self.saved_world_offset
		
	self.overlay.set_message("")
	self.overlay.render_grid = false
	
	await self.get_tree().process_frame
	await self.get_tree().process_frame
	
	var snap = get_viewport().get_texture().get_image()
	var filename = "snap-" + str(Time.get_ticks_msec() % 9999999999) + ".png"
	snap.save_png(self.root_path + "/" + filename)
	self.overlay.set_message("Saved: " + filename)
	
	self.world_offset = oldOffset
	self.overlay.render_grid = oldGrid

func on_dialog_path_confirmed(dir: String):
	self.root_path = dir
	await self.get_tree().process_frame
	snapshot()

func change_zoom(zoom_delta: Vector2):
	var mid0 = 0.5 * (self.get_viewport_rect().size / self.zoom)
	var mid1 = 0.5 * (self.get_viewport_rect().size / (self.zoom + zoom_delta))
	self.zoom += zoom_delta
	self.world_offset -= mid1 - mid0

func move_world() -> void:
	var rect : Rect2 = self.get_viewport_rect()
	rect.position += self.world_offset.floor()
	rect.size /= self.zoom
	self.background1.region_rect = rect
	self.background2.region_rect = rect
	self.background3.region_rect = rect
	self.background4.region_rect = rect
	self.overlay.rect = rect
