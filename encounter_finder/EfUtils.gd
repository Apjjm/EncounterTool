extends RefCounted

const StepData = preload("../StepData.gd")

static func parse_from_encounter_finder(step_data: String) -> Array:
	var result : Array = [StepData.new()]
	var lines = step_data.split("\n", false)
	var i = 0

	while i<lines.size():
		var parts = lines[i].split(" ", false)
		i += 1
		
		if parts.size() < 2 || !parts[1].is_valid_int() || !parts[0].to_lower().begins_with("step"):
			continue

		assert(result.size() == parts[1].to_int())
		var s = StepData.new()
		result.push_back(s)
		
		if i<lines.size() && lines[i].to_lower().begins_with("no encounters"):
			i += 1
			continue

		while (i+1)<lines.size() && !lines[i].to_lower().begins_with("step") && !lines[i+1].to_lower().begins_with("step"):
			var e = _encounter_info_from_lines(lines[i], lines[i+1])
			if e != null:
				s.encounters_by_formation.push_back(e)
			else:
				print_debug("Issue parsing encounter on step " + str(s.step) + "with lines:\n  " + lines[i] + "\n  " + lines[i+1])
			i+=2

	return result

static func _encounter_info_from_lines(line1: String, line2: String) -> StepData.FormationEncounterData:
	# Example: 7 Encounters | 2 Encounters with formation Imp x3
	var parts = line1.split(" ", false)
	if parts.size() < 2 || !parts[0].is_valid_int() || parts[1].to_lower() != "encounters":
		return null

	if parts[0].to_int() == 0:
		return null

	var info = StepData.FormationEncounterData.new()
	info.formation = ""
	#info.num_encounters = parts[0].to_int()

	if parts.size() > 5 && parts[2].to_lower() == "with" && parts[3].to_lower() == "formation":
		for i in range(4, parts.size()):
			info.formation += parts[i] + " "

	# Example: Encounter 2 at Elements Room has your desired fight
	parts = line2.split(" ")
	if parts.size() == 0:
		return null
	elif parts.size() == 1 && parts[0].to_lower() == "reset":
		info.goal_encounter_on = -1
		info.goal_encounter_at = "reset"
	elif parts.size() > 3 && parts[0].to_lower() == "encounter" && parts[1].is_valid_int():
		info.goal_encounter_on = parts[1].to_int()
		info.goal_encounter_at = parts[3]
	elif parts.size() > 1 && parts[0].to_lower() == "encounter":
		info.goal_encounter_on = parts[1].to_int()

	return info
