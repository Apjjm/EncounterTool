extends RefCounted

const StepData = preload("StepData.gd")

const color_bg : Color = Color(0, 0, 0, 0.45)
const color_bg_start : Color = Color(0.75, 0.75, 0.75, 0.45)
const color_good : Color = Color.YELLOW
const color_reset : Color = Color.DARK_ORANGE
const color_text : Array = [Color.WHITE, Color.PINK, Color.YELLOW, Color.ORANGE]
const step_width : float = 1.0
const step_font_size : int = 5
const max_steps_to_count : int = 50

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

func calculate_drawings(formation_letters: Dictionary, location_colors: Dictionary, letters_used: Array, use_stepcounts: bool, use_fomations: bool):
	_formation_lines.clear()
	_formation_colors.clear()
	_box_color = color_reset

	if _try_calculate_stepcount_drawings(location_colors, use_stepcounts, use_fomations):
		return
	
	if _try_calculate_formation_drawings(formation_letters, location_colors, letters_used, use_fomations):
		return

func _try_calculate_stepcount_drawings(location_colors: Dictionary, use_stepcounts: bool, use_fomations: bool):
	if !use_stepcounts || step_data.encounters_by_stepcount.size() == 0:
		return false

	if use_fomations && !_is_searching_by_stepcount_better(step_data):
		return false

	var groups = _group_encounters_by_at_on_with_steps(step_data.encounters_by_stepcount)
	if groups.size() > 3:
		return false # We can't render this many options without it overflowing the box

	# Only one group including resets, so we can render this like a formation based encounter really - it's either a reset or any encounter
	if groups.size() == 1:
		if groups[0][0].goal_encounter_on > 0:
			_formation_lines.push_back("? " + str(step_data.encounters_by_stepcount[0].goal_encounter_on - 1))
			_formation_colors.push_back(location_colors[step_data.encounters_by_stepcount[0].goal_encounter_at])
			_box_color = color_good
		return true

	# Maybe we can group encounters up, such that either all the resets are together or all the non-resets are together
	var mono_groups = 0
	var multi_group = []
	var max_counting_required = 0
	for g in groups:
		if g.size() == 1:
			mono_groups += 1
			max_counting_required = max(max_counting_required, g[0].steps)
		elif g.size() > 1:
			multi_group = g

	# We really don't want to be counting to like 100, just look at the encounters if we can
	if max_counting_required > max_steps_to_count && use_fomations:
		return false

	if mono_groups == groups.size() - 1 && multi_group.size() > 0:
		for g in groups:
			if g.size() == 1:
				_formation_lines.push_back(str(g[0].steps) + ": " + (str(g[0].goal_encounter_on - 2) if g[0].goal_encounter_on > 1 else "X"))
				_formation_colors.push_back(color_reset if g[0].goal_encounter_on <= 0 else location_colors[g[0].goal_encounter_at])
		
		_formation_lines.push_back("∗: " + (str(multi_group[0].goal_encounter_on - 2) if multi_group[0].goal_encounter_on > 1 else "X"))
		_formation_colors.push_back(color_reset if multi_group[0].goal_encounter_on <= 0 else location_colors[multi_group[0].goal_encounter_at])
		_box_color = color_good
		return true

	var filtered = _filter_sort_goal_encounters_by_steps(step_data.encounters_by_stepcount)
	if filtered.size() > 3:
		return false

	for enc in filtered:
		_formation_lines.push_back(str(enc.steps) + ": " + str(enc.goal_encounter_on - 2))
		_formation_colors.push_back(location_colors[enc.goal_encounter_at])
	
	_box_color = color_good
	return true

func _try_calculate_formation_drawings(formation_letters: Dictionary, location_colors: Dictionary, letters_used: Array,  use_fomations: bool):
	if !use_fomations || step_data.encounters_by_formation.size() == 0:
		return false

	if all_encounters_at_same_at_and_on(step_data.encounters_by_formation) && step_data.encounters_by_formation[0].goal_encounter_on > 0:
		_formation_lines.push_back("? " + str(step_data.encounters_by_formation[0].goal_encounter_on - 1))
		_formation_colors.push_back(location_colors[step_data.encounters_by_formation[0].goal_encounter_at])
		_box_color = color_good
		return true

	for g1 in _group_encounters_by_encounter_at(step_data.encounters_by_formation):
		for g2 in _group_encounters_by_encounter_on(g1):
			var letters = _encounters_to_encounter_letters(g2, formation_letters, letters_used)
			if letters != "" && g2[0].goal_encounter_on > 0:
				_formation_lines.push_back(letters + " " + str(g2[0].goal_encounter_on-1))
				_formation_colors.push_back(location_colors[g2[0].goal_encounter_at])
				_box_color = color_good
			elif letters != "":
				_formation_lines.push_back(letters + " X")
				_formation_colors.push_back(color_reset)

	return true

func draw_box(cavas: CanvasItem, cam_pos: Vector2, box_style: int, is_first_placed: bool):
	if box_visible && is_placed():
		var pos = (offset / grid_size).floor() * grid_size - cam_pos
		if box_style % 3 == 0:
			var bgc = color_bg_start if is_first_placed else color_bg
			cavas.draw_rect(Rect2(pos, grid_size), Color(bgc.r, bgc.g, bgc.b, bgc.a * 0.5), true)
			if _box_color == color_good:
				cavas.draw_rect(Rect2(pos+Vector2(1,1), grid_size-Vector2(2,2)), color_bg, true)
			else:
				cavas.draw_line(pos + Vector2(6,6), pos + grid_size - Vector2(6,6), _box_color, true)
				cavas.draw_line(pos + Vector2(grid_size.x-6, 6), pos + Vector2(6, grid_size.y-6), _box_color, true)
		else:
			cavas.draw_rect(Rect2(pos, grid_size), color_bg_start if is_first_placed else color_bg, true)
			cavas.draw_rect(Rect2(pos+Vector2(1,1), grid_size-Vector2(2,2)), _box_color, false, -1.0 if box_style % 3 == 2 else 1.0)

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

static func all_encounters_at_same_at_and_on(encounters: Array) -> bool:
	for e in encounters:
		if e.goal_encounter_on != encounters[0].goal_encounter_on || e.goal_encounter_at != encounters[0].goal_encounter_at:
			return false

	return true

static func _group_encounters_by_encounter_at(encounters: Array) -> Array:
	var result = []
	for e in encounters:
		if e.goal_encounter_on <= 0:
			continue
		
		var inserted = false

		for g in result:
			if g[0].goal_encounter_at == e.goal_encounter_at:
				g.push_back(e)
				inserted = true

		if !inserted:
			result.push_back([e])

	return result

static func _group_encounters_by_encounter_on(encounters: Array) -> Array:
	var result = []
	for e in encounters:
		if e.goal_encounter_on <= 0:
			continue
		
		var inserted = false

		for g in result:
			if g[0].goal_encounter_on == e.goal_encounter_on:
				g.push_back(e)
				inserted = true

		if !inserted:
			result.push_back([e])

	return result

static func _group_encounters_by_at_on_with_steps(encounters: Array) -> Array:
	var result = []
	for e1 in encounters:
		var inserted = false
		for g in result:
			if g[0].goal_encounter_on == e1.goal_encounter_on && g[0].goal_encounter_at == e1.goal_encounter_at:
				for i in range(g.size()):
					if e1.steps > g[i].steps:
						inserted = true
						g.insert(i, e1)
						break

				if !inserted:
					g.push_back(e1)
					inserted = true

		if !inserted:
			result.push_back([e1])
			inserted = true

	return result

static func _filter_sort_goal_encounters_by_steps(encounters: Array) -> Array:
	var result = []
	for e in encounters:
		if e.goal_encounter_on > 0:
			var inserted = false
			for i in range(result.size()):
				if result[i].steps < e.steps:
					result.insert(i, e)
					inserted = true
					break

			if !inserted:
				result.push_back(e)

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

static func _is_searching_by_stepcount_better(stepData):
	var max_on_stepcount = -1
	var min_on_stepcount = 99
	var avg_on_stepcount = 0
	for enc in stepData.encounters_by_stepcount:
		min_on_stepcount = min(min_on_stepcount, enc.goal_encounter_on)
		max_on_stepcount = max(max_on_stepcount, enc.goal_encounter_on)
		if enc.goal_encounter_on > 0:
			avg_on_stepcount += float(enc.goal_encounter_on) / stepData.encounters_by_stepcount.size()
	
	if max_on_stepcount == -1:
		return false
		
	var max_on_formation = -1
	var avg_on_formation = 0
	for enc in stepData.encounters_by_formation:
		max_on_formation = max(max_on_formation, enc.goal_encounter_on)
		if enc.goal_encounter_on > 0:
			avg_on_formation += float(enc.goal_encounter_on) / stepData.encounters_by_formation.size()

	if max_on_formation == -1 || max_on_stepcount < max_on_formation:
		return true
	
	# If doing stepcount means we can take less encounters, prefer it
	# This can be because to find a common encounter by formation we have to always take more
	# Or, it could be because we never have to reset for this square, so we can see if steps help
	# us sometimes find a better encounter - giving us a better average
	return min_on_stepcount > 0 && avg_on_stepcount < avg_on_formation