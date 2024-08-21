extends Node2D

const RenderedStep = preload("RenderedStep.gd")
const StepData = preload("StepData.gd")

@export var verbose_mode : bool = true
@export var render_grid : bool = true
@export var grid_color : Color = Color.LIGHT_GRAY
@export var grid_color_region : Color = Color.LIGHT_CORAL
@export var grid_size : Vector2 = Vector2(16.0, 16.0)
@export var cursor_color : Color = Color.WHITE
@export var cursor_width : float = 1.0
@export var font : Font
@export var info_font_size : int = 24
@export var ui_text_color : Color = Color.WHITE
@export var goal_encounter_colors : Array = [Color.WHITE, Color.LIGHT_SALMON, Color.LIGHT_YELLOW, Color.PINK]

var rect : Rect2
var steps : Array
var formation_letters : Dictionary
var location_colors : Dictionary
var next_step : int = 0
var last_message : String
var last_message_delay : float = 0

func set_message(message: String):
	last_message = message
	last_message_delay = 3.0

func insert_step() -> void:
	var cursor = _cursor_pos()
	for step in self.steps:
		if step.overlaps(cursor):
			return

	if self.next_step < self.steps.size():
		self.steps[self.next_step].place(cursor)	
		self.next_step += 1

func remove_step() -> void:
	if self.next_step > 0:
		self.next_step -= 1
		self.steps[self.next_step].unplace()

func clear_steps() -> void:
	var all_clear = true
	for step in self.steps:
		all_clear = all_clear && !step.is_placed()
		step.unplace()
	
	if all_clear:
		self.next_step = 0

func _ready() -> void:
	grid_color.a = 0.25
	cursor_color.a = 0.25
	grid_color_region.a = 1.0

func _process(delta: float) -> void:
	if last_message_delay > 0:
		last_message_delay -= delta
	else:
		last_message = ""

	queue_redraw()

func _update_step_log(step_datas: Array) -> void:
	self.steps = []
	self.next_step = 0
	self.formation_letters = {}
	self.location_colors = {}

	var all_formations = {}
	for step in step_datas:
		self.steps.push_back(RenderedStep.new(step, self.grid_size))

		for enc in step.encounters:
			if enc.formation != "" && !all_formations.has(enc.formation):
				var letter = char(65 + all_formations.size())
				all_formations[enc.formation] = letter

			if enc.goal_encounter_at != "" && enc.goal_encounter_at != "reset" && !self.location_colors.has(enc.goal_encounter_at):
				var color = goal_encounter_colors[self.location_colors.size()]
				self.location_colors[enc.goal_encounter_at] = color

	# Encounter finder might still not always list formations for some encounters
	if self.verbose_mode:
		all_formations[""] = "?"
	
	var letters_used = []
	for step in self.steps:
		step.calculate_drawings(all_formations, self.location_colors, letters_used, self.verbose_mode)

	# Some formations never appear, so we will do a 2nd pass with the minimum letter set needed
	for formation in all_formations:
		if formation != "" && letters_used.has(all_formations[formation]):
			var letter = char(65 + self.formation_letters.size())
			self.formation_letters[formation] = letter

	if self.verbose_mode:
		self.formation_letters[""] = "?"

	for step in self.steps:
		step.calculate_drawings(self.formation_letters, self.location_colors, [], self.verbose_mode)

	if self.steps.size() > 0:
		self.steps[0].box_visible = false
		self.steps[0].text_override = "start"

func _cursor_pos():
	return rect.size * 0.5 + rect.position

func _draw():
	if render_grid:
		_draw_grid(grid_size, grid_color)
		_draw_grid(grid_size * 32, grid_color_region)
		_draw_cursor()

	for step in self.steps:
		step.draw_box(self, rect.position)
	
	# Text wants to be independent of zoom, so we have to do some local space hackery to work around this
	var xform = get_global_transform()
	var zoom = get_viewport().get_camera_2d().zoom
	draw_set_transform(Vector2(0,0), 0, Vector2(1, 1) / zoom)
	for step in self.steps:
		step.draw_text(self, rect.position, zoom, font)
	_draw_ui()
	draw_set_transform_matrix(xform)

func _draw_ui():
	draw_rect(Rect2(0, 0, 300, 4000), Color(0, 0, 0, 0.6), true)

	var textPos = Vector2(get_viewport_rect().end.x - 200, 32)
	_draw_text_with_size(textPos, "Step: " + str(next_step) + " / " + str(steps.size()), info_font_size, ui_text_color)
	
	if last_message != "":
		textPos = Vector2(get_viewport_rect().end.x * 0.5, get_viewport_rect().end.y - 32)
		_draw_text_with_size(textPos, last_message, info_font_size, ui_text_color)
		
	textPos = Vector2(32, 200)
	_draw_text_with_size(textPos, "Formations:", info_font_size, ui_text_color)
	textPos += Vector2(0, info_font_size + 2)

	for f in self.formation_letters.keys():
		var letter = self.formation_letters[f]
		if f.count(",") > 1:
			var idx = f.find(",", f.find(",")+1)
			_draw_text_with_size(textPos, "  " + letter + ": " + f.substr(0, idx), info_font_size, ui_text_color)
			textPos += Vector2(0, info_font_size + 2)
			_draw_text_with_size(textPos, "             " + f.substr(idx+1), info_font_size, ui_text_color)
			textPos += Vector2(0, info_font_size + 3)
		else:
			_draw_text_with_size(textPos, "  " + letter + ": " + f, info_font_size, ui_text_color)
			textPos += Vector2(0, info_font_size + 3)

	textPos += Vector2(0, info_font_size + 3)
	_draw_text_with_size(textPos, "Locations:", info_font_size, ui_text_color)
	textPos += Vector2(0, info_font_size + 3)

	for f in self.location_colors.keys():
		_draw_text_with_size(textPos, " " + f, info_font_size, self.location_colors[f])
		textPos += Vector2(0, info_font_size + 3)

func _draw_grid(step: Vector2, col : Color):
	var startPos = (rect.position / step).floor() * step - rect.position
	var endPos = (rect.end / step).ceil() * step - rect.position
	for x in range(startPos.x, endPos.x - startPos.x, step.y):
		draw_line(Vector2(x, startPos.y), Vector2(x, endPos.y), col)

	for y in range(startPos.y, endPos.y - startPos.y, step.x):
		draw_line(Vector2(startPos.x, y), Vector2(endPos.x, y), col)

func _draw_cursor():
	var pos = (_cursor_pos() / grid_size).floor() * grid_size - rect.position
	draw_rect(Rect2(pos, grid_size), cursor_color, true)

func _draw_text_with_size(pos: Vector2, text: String, size: int, color: Color):
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
