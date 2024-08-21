extends RefCounted

const StepData = preload("StepData.gd")

const color_bg : Color = Color(0, 0, 0, 0.4)
const color_good : Color = Color.YELLOW
const color_reset : Color = Color.DARK_ORANGE
const color_text : Array = [Color.WHITE, Color.PINK, Color.YELLOW, Color.ORANGE]
const step_width : float = 1.0
const step_font_size : int = 5

var step_data : StepData
var offset : Vector2
var grid_size : Vector2
var box_visible : bool = true
var text_visible : bool = true
var text_override : String = ""

var _box_color : Color
var _formation_lines : Array = []
var _formation_colors : Array = []

func _init(data: StepData, grid: Vector2):
	step_data = data
	grid_size = grid

func place(position: Vector2):
	offset = (position / grid_size).floor() * grid_size

func unplace():
	offset = Vector2.INF

func is_placed():
	return offset.is_finite()

func overlaps(position: Vector2):
	var other_pos = (position / grid_size).floor() * grid_size
	return offset.is_equal_approx(other_pos)

func calculate_drawings(formation_letters: Dictionary, location_colors: Dictionary, letters_used: Array, verbose: bool):
	_formation_lines.clear()
	_formation_colors.clear()
	_box_color = color_reset
	
	if step_data.encounters.size() > 0:
		if !verbose && _all_encounters_same_at_and_on(step_data.encounters) && step_data.encounters[0].goal_encounter_on > 0:
			_formation_lines.push_back("? " + str(step_data.encounters[0].goal_encounter_on - 1))
			_formation_colors.push_back(location_colors[step_data.encounters[0].goal_encounter_at])
			_box_color = color_good
		else:
			for g1 in _group_encounters_by_encounter_at(step_data.encounters, verbose):
				for g2 in _group_encounters_by_encounter_on(g1, verbose):
					var letters = _encounters_to_encounter_letters(g2, formation_letters, letters_used)
					if letters != "" && g2[0].goal_encounter_on > 0:
						_formation_lines.push_back(letters + " " + str(g2[0].goal_encounter_on-1))
						_formation_colors.push_back(location_colors[g2[0].goal_encounter_at])
						_box_color = color_good
					elif letters != "":
						_formation_lines.push_back(letters + " x")
						_formation_colors.push_back(color_reset)

func draw_box(cavas: CanvasItem, cam_pos: Vector2):
	if box_visible && is_placed():
		var pos = (offset / grid_size).floor() * grid_size - cam_pos
		var pad = Vector2(1,1)
		cavas.draw_rect(Rect2(pos, grid_size), color_bg, true)
		cavas.draw_rect(Rect2(pos+pad, grid_size-2*pad), _box_color, false)

func draw_text(canvas: CanvasItem, cam_pos: Vector2, cam_zoom: Vector2, font: Font):
	if text_visible && is_placed():
		var pos = (offset / grid_size).floor() * grid_size - cam_pos

		if text_override != "":
			pos += Vector2(2, 4 + step_font_size)
			_draw_text_with_size(canvas, pos, cam_zoom, text_override, color_text[0], font)
			return

		pos += Vector2(3, 1 + step_font_size)
		for i in range(_formation_lines.size()): 
			_draw_text_with_size(canvas, pos, cam_zoom, _formation_lines[i], _formation_colors[i], font)
			pos += Vector2(0, step_font_size)

static func _draw_text_with_size(canvas: CanvasItem, pos: Vector2, cam_zoom: Vector2, text: String, color: Color, font: Font):
	canvas.draw_string(font, pos * cam_zoom, text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(step_font_size*cam_zoom.x), color)

static func _all_encounters_same_at_and_on(encounters: Array) -> bool:
	for e in encounters:
		if e.goal_encounter_on != encounters[0].goal_encounter_on || e.goal_encounter_at != encounters[0].goal_encounter_at:
			return false

	return true

static func _group_encounters_by_encounter_at(encounters: Array, verbose: bool) -> Array:
	var result = []
	for e in encounters:
		if e.goal_encounter_on <= 0 && !verbose:
			continue
		
		var inserted = false

		for g in result:
			if g[0].goal_encounter_at == e.goal_encounter_at:
				g.push_back(e)
				inserted = true

		if !inserted:
			result.push_back([e])

	return result

static func _group_encounters_by_encounter_on(encounters: Array, verbose: bool) -> Array:
	var result = []
	for e in encounters:
		if e.goal_encounter_on <= 0 && !verbose:
			continue
		
		var inserted = false

		for g in result:
			if g[0].goal_encounter_on == e.goal_encounter_on:
				g.push_back(e)
				inserted = true

		if !inserted:
			result.push_back([e])

	return result

static func _encounters_to_encounter_letters(encounters: Array, formation_letters: Dictionary, letters_used: Array) -> String:
	var letters = []
	for e in encounters:
		var letter = formation_letters[e.formation]
		letters.push_back(letter)
		if !letters_used.has(letter):
			letters_used.push_back(letter)

	letters.sort()
	return "".join(letters)
