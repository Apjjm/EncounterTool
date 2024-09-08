extends RefCounted

const RosaStepper = preload("./rosa/RosaStepper.gd")
const RosaData = preload("./rosa/RosaData.gd")
const StepData = preload("StepData.gd")

const max_steps = 512
const max_encounters = 5

class FoundEncounter:
	var start_map: RefCounted
	var goal_map: RefCounted
	var first_encouter: RefCounted
	var goal_encounter: RefCounted
	var first_encounter_steps = -1
	var next_encounter_steps = -1
	var goal_encounters_on = []

	func has_goal_encounter() -> bool:
		return goal_encounters_on.size() > 0
		
	func get_goal_encounter_after_next() -> int:
		for e in goal_encounters_on:
			if e > 1:
				return e
		return -1

static func find_encounter_steps(data: RosaData, start_map: RosaData.Map, goal_map: RosaData.Map, goal_encounter_id: int) -> Array:
	var start_formations = data.get_encounters_for_map(start_map)
	var goal_formations = data.get_encounters_for_map(goal_map)
	if start_formations.size() != 8:
		print_debug("Start formations not present on map or data incomplete: " + str(start_formations.size()))
		return []
		
	if goal_formations.size() != 8:
		print_debug("Goal formations not present on map or data incomplete: " + str(goal_formations.size()))
		return []
	
	var encounters = []
	for s in range(256):
		var encounter = _find_encounter_for_seed(s, start_map, goal_map, start_formations, goal_formations, goal_encounter_id)
		encounters.push_back(encounter)

	_log_encounters_per_seed(encounters, start_map, goal_map, goal_encounter_id)
	
	var results = []
	for step in max_steps:
		var step_data = StepData.new()
		results.push_back(step_data)

		var step_encounters = _filter_encounters_by_first_step(encounters, step)
		var encounter_groups = _group_encounters_by_first_encounter(step_encounters)
		for e in _flatten_groups_by_unambig_num_encounters_needed(encounter_groups, step):
			var encounter_on = e.goal_encounters_on[0] if e.has_goal_encounter() else -1
			var encounter_at = goal_map.description if e.has_goal_encounter() else "reset"
			step_data.add_encounter_by_formation(e.first_encouter.name, encounter_on, encounter_at)
		
		encounter_groups = _group_encounters_by_2nd_encounter_steps(step_encounters)
		for e in _flatten_groups_by_unambig_num_encounters_needed(encounter_groups, step):
			var encounter_on = e.get_goal_encounter_after_next()
			var encounter_at = goal_map.description if encounter_on > 0 else "reset"
			step_data.add_encounter_by_steps(e.next_encounter_steps, encounter_on, encounter_at)

	return results

static func _filter_encounters_by_first_step(found_encounters: Array, step: int) -> Array:
	var result = []
	for encounter in found_encounters:
		if encounter.first_encounter_steps == step:
			result.push_back(encounter)

	return result

static func _group_encounters_by_2nd_encounter_steps(found_encounters: Array) -> Array:
	var result = []
	for encounter in found_encounters:
		var inserted = false

		for other in result:
			if encounter.next_encounter_steps == other[0].next_encounter_steps:
				other.push_back(encounter)
				inserted = true
				break

		if !inserted:
			result.push_back([encounter])

	return result

static func _group_encounters_by_first_encounter(found_encounters: Array) -> Array:
	var result = []
	for encounter in found_encounters:
		var inserted = false

		for other in result:
			if encounter.first_encouter.number == other[0].first_encouter.number:
				other.push_back(encounter)
				inserted = true
				break

		if !inserted:
			result.push_back([encounter])

	return result

static func _flatten_groups_by_unambig_num_encounters_needed(groups: Array, step: int) -> Array:
	var result = []

	for group in groups: 
		if group.size() == 0:
			continue
		
		# For each encounter formation we see, that could mean encounters after the following additional encounters
		var possible_encounters_on = []
		for g in group:
			for e in g.goal_encounters_on:
				if !possible_encounters_on.has(e):
					possible_encounters_on.push_back(e)
		possible_encounters_on.sort()

		# is there a number of additional encounters we can take to make sure we always land on the fight we want?
		var shared_possible_encounters_on = []
		for e in possible_encounters_on:
			var shared = true
			for g in group:
				shared = shared && g.goal_encounters_on.has(e)
			if shared:
				shared_possible_encounters_on.push_back(e)

		if shared_possible_encounters_on.size() == 0:
			# Multiple seeds generate the same encounter here, but depending on seeds you need to walk more/fewer steps!
			# This isn't great news, obviously, because now we can't tell what to do from the formation alone.
			#print(" Removed an ambiguous formation on step ", step)
			var enc = FoundEncounter.new()
			enc.start_map = group[0].start_map
			enc.goal_map = group[0].goal_map
			enc.first_encouter = group[0].first_encouter
			enc.first_encounter_steps = group[0].first_encounter_steps
			enc.next_encounter_steps = group[0].next_encounter_steps
			result.push_back(enc)
		else:
			# Multiple seeds gave the same pair(s) of encounters, but they all have this pairing.
			var enc = FoundEncounter.new()
			enc.start_map = group[0].start_map
			enc.goal_map = group[0].goal_map
			enc.first_encouter = group[0].first_encouter
			enc.first_encounter_steps = group[0].first_encounter_steps
			enc.next_encounter_steps = group[0].next_encounter_steps
			enc.goal_encounter = group[0].goal_encounter
			enc.goal_encounters_on = shared_possible_encounters_on
			result.push_back(enc) 

	return result

static func _find_encounter_for_seed(initial_seed: int, start_map: RosaData.Map, goal_map: RosaData.Map, start_formations: Array, goal_formations: Array, goal_encounter_id: int) -> FoundEncounter:
	var stepper = RosaStepper.new(start_map.rate, initial_seed)
	var result = FoundEncounter.new()
	result.start_map = start_map
	result.goal_map = goal_map
	
	for f in goal_formations:
		if f.number == goal_encounter_id:
			result.goal_encounter = f
	
	# Walk around our starting area for a bit, if we get an encounter, make a note of where it was and then try the goal map
	var goal_encounter_on = 0
	for s in range(max_steps):
		var id = stepper.step()
		if id >=0:
			goal_encounter_on += 1
			if goal_encounter_on > max_encounters:
				break
			
			if result.first_encouter == null:
				result.first_encouter = start_formations[id]
				result.first_encounter_steps = s+1
			elif result.next_encounter_steps < 0:
				result.next_encounter_steps = s+1-result.first_encounter_steps
			
			if _is_next_encounter_goal(stepper, goal_map.rate, goal_formations, goal_encounter_id):
				result.goal_encounters_on.push_back(goal_encounter_on)

	return result

static func _is_next_encounter_goal(start_stepper: RosaStepper, rate: int, goal_formations: Array, goal_encounter_id: int) -> bool:
	# On a parallel universe, pretend we are now in the goal map - let's walk that area now until we find an encounter...
	var stepper = RosaStepper.new(rate, 0)
	stepper.set_seeds_from(start_stepper)

	for s in range(max_steps):
		var id = stepper.step()
		if id >= 0:
			return goal_formations[id].number == goal_encounter_id
	
	return false

static func _log_encounters_per_seed(encounters: Array, start_map: RosaData.Map, goal_map: RosaData.Map, goal_encounter_id: int):
	print("Start: ", start_map.description, "  Goal: ", goal_map.description, "  Goal encounter id: ", goal_encounter_id)
	print("seed, encounter 1 steps, encounter 1 formation, encounter 2 steps, goal encounters")
	for i in range(encounters.size()):
		print(i, ",", encounters[i].first_encounter_steps, ",", encounters[i].first_encouter.name.replace(",", ""), ",", encounters[i].next_encounter_steps, ",", "/".join(encounters[i].goal_encounters_on))
	print("---")
