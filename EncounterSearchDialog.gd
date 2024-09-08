extends AcceptDialog

const MapWalker = preload("MapWalker.gd")
const StepData = preload("StepData.gd")

signal steps_updated(steps: Array)

@export var rosa_data : Resource

# This could be deduped a bit if we need more than 4, but this works fine so whatever
var _start_location
var _fight1
var _fight2
var _fight3
var _fight4
var _end_location1
var _end_location2
var _end_location3
var _end_location4

func _ready() -> void:
	rosa_data.ensure_loaded()

	_start_location = get_node("./VBoxContainer/S1/StartLocation")
	_fight1 = get_node("./VBoxContainer/F1/Fight")
	_fight2 = get_node("./VBoxContainer/F2/Fight")
	_fight3 = get_node("./VBoxContainer/F3/Fight")
	_fight4 = get_node("./VBoxContainer/F4/Fight")
	_end_location1 = get_node("./VBoxContainer/F1/GoalLocation")
	_end_location2 = get_node("./VBoxContainer/F2/GoalLocation")
	_end_location3 = get_node("./VBoxContainer/F3/GoalLocation")
	_end_location4 = get_node("./VBoxContainer/F4/GoalLocation")

	_fight1.add_item("<none>")
	_fight2.add_item("<none>")
	_fight3.add_item("<none>")
	_fight4.add_item("<none>")
	for enc in rosa_data.encounts:
		_fight1.add_item(enc.name)
		_fight2.add_item(enc.name)
		_fight3.add_item(enc.name)
		_fight4.add_item(enc.name)

	_on_type_item_selected(0)
	_update_end_locations(_end_location1, _fight1)
	_update_end_locations(_end_location2, _fight2)
	_update_end_locations(_end_location3, _fight3)
	_update_end_locations(_end_location4, _fight4)

func _on_type_item_selected(index: int) -> void:
	_start_location.clear()
	if index >= 0:
		for map in rosa_data.maps:
			if index == 0 && map.is_overworld():
				_start_location.add_item(map.description)
			elif index == 1 && map.is_underworld():
				_start_location.add_item(map.description)
			elif index == 2 && map.is_lunar():
				_start_location.add_item(map.description)
			elif index == 3 && map.is_interior():
				_start_location.add_item(map.description)

func _on_fight1_item_selected(_index: int) -> void:
	_update_end_locations(_end_location1, _fight1)

func _on_fight2_item_selected(_index: int) -> void:
	_update_end_locations(_end_location2, _fight2)

func _on_fight3_item_selected(_index: int) -> void:
	_update_end_locations(_end_location3, _fight3)

func _on_fight4_item_selected(_index: int) -> void:
	_update_end_locations(_end_location4, _fight4)

func _on_confirmed() -> void:
	var step_data = []
	var step_data1 = _calc_step_data(_start_location, _end_location1, _fight1)
	var step_data2 = _calc_step_data(_start_location, _end_location2, _fight2)
	var step_data3 = _calc_step_data(_start_location, _end_location3, _fight3)
	var step_data4 = _calc_step_data(_start_location, _end_location4, _fight4)

	if step_data1.size() > 0:
		step_data = step_data1 if step_data.size() == 0 else merge_steps_for_different_goals(step_data, step_data1)

	if step_data2.size() > 0:
		step_data = step_data2 if step_data.size() == 0 else merge_steps_for_different_goals(step_data, step_data2)

	if step_data3.size() > 0:
		step_data = step_data3 if step_data.size() == 0 else merge_steps_for_different_goals(step_data, step_data3)

	if step_data4.size() > 0:
		step_data = step_data4 if step_data.size() == 0 else merge_steps_for_different_goals(step_data, step_data4)

	steps_updated.emit(step_data)

func _update_end_locations(locations: OptionButton, fights: OptionButton) -> void:
	locations.clear()
	locations.add_item("<none>")
	var encounter = _get_encounter_from_optionbutton(fights)
	if encounter != null:
		for map in rosa_data.get_all_maps_with_encounter(encounter):
			locations.add_item(map.description)

func _get_map_from_optionbutton(btn: OptionButton) -> RefCounted:
	var index = btn.get_selected()
	if index >= 0:
		var map_name = btn.get_item_text(index)
		if map_name != "<none>":
			return rosa_data.get_map_by_description(map_name) 
	
	return null

func _get_encounter_from_optionbutton(btn: OptionButton) -> RefCounted:
	var index = btn.get_selected()
	if index >= 0:
		var enc_name = btn.get_item_text(index)
		if enc_name != "<none>":
			return rosa_data.get_encounter_by_name(enc_name)
	
	return null

func _calc_step_data(start: OptionButton, goal: OptionButton, fight: OptionButton) -> Array:
	var start_map = _get_map_from_optionbutton(start)
	var goal_map = _get_map_from_optionbutton(goal)
	var goal_fight = _get_encounter_from_optionbutton(fight)

	if start_map != null && goal_map != null && goal_fight != null:
		return MapWalker.find_encounter_steps(rosa_data, start_map, goal_map, goal_fight.number)

	return []

static func merge_steps_for_different_goals(stepsA: Array, stepsB: Array) -> Array:
	var result = []

	for i in range(stepsA.size()):
		var step_data = StepData.new()
		step_data.set_from_merge(stepsA[i], stepsB[i])
		result.push_back(step_data)

	return result
