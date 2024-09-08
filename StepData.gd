extends RefCounted

class FormationEncounterData extends RefCounted:
	var formation: String
	var goal_encounter_on: int
	var goal_encounter_at: String

class StepEncounterData extends RefCounted:
	var steps: int
	var goal_encounter_on: int
	var goal_encounter_at: String

var encounters_by_formation: Array = []
var encounters_by_stepcount: Array = []

func add_encounter_by_formation(formation: String, encounter_on: int, encounter_at: String):
	var enc = FormationEncounterData.new()
	enc.formation = formation
	enc.goal_encounter_on = encounter_on
	enc.goal_encounter_at = encounter_at
	encounters_by_formation.push_back(enc)

func add_encounter_by_steps(steps: int, encounter_on: int, encounter_at: String):
	var enc = StepEncounterData.new()
	enc.steps = steps
	enc.goal_encounter_on = encounter_on
	enc.goal_encounter_at = encounter_at
	encounters_by_stepcount.push_back(enc)

func set_from_merge(stepDataA, stepDataB):
	encounters_by_formation = []
	encounters_by_stepcount = []
	_merge_encounters_by_formation(stepDataA, stepDataB)
	_merge_encounters_by_steps(stepDataA, stepDataB)

func has_encounter_formation(formation: String):
	for enc in encounters_by_formation:
		if formation == enc.formation:
			return true
	
	return false

func has_encounter_steps(steps: int):
	for enc in encounters_by_stepcount:
		if steps == enc.steps:
			return true
	
	return false

func _merge_encounters_by_formation(sA, sB):
	# Prefer steps with a smaller number of encounters needed
	for encA in sA.encounters_by_formation:
		for encB in sB.encounters_by_formation:
			if encA.formation == encB.formation && encA.goal_encounter_on > 0 && encB.goal_encounter_on > 0:
				var enc = FormationEncounterData.new()
				enc.formation = encA.formation
				enc.goal_encounter_on = encA.goal_encounter_on if encA.goal_encounter_on <= encB.goal_encounter_on else encB.goal_encounter_on
				enc.goal_encounter_at = encA.goal_encounter_at if encA.goal_encounter_on <= encB.goal_encounter_on else encB.goal_encounter_at
				encounters_by_formation.push_back(enc)
				break

	# Then add any steps that we didn't minimise
	for enc in sA.encounters_by_formation:
		if enc.goal_encounter_on > 0 && !has_encounter_formation(enc.formation):
			encounters_by_formation.push_back(enc)

	for enc in sB.encounters_by_formation:
		if enc.goal_encounter_on > 0 && !has_encounter_formation(enc.formation):
			encounters_by_formation.push_back(enc)

	# Then add any failed steps that we didn't minimise
	for enc in sA.encounters_by_formation:
		if !has_encounter_formation(enc.formation):
			encounters_by_formation.push_back(enc)

	for enc in sB.encounters_by_formation:
		if !has_encounter_formation(enc.formation):
			encounters_by_formation.push_back(enc)

func _merge_encounters_by_steps(sA, sB):
	# Prefer steps with a smaller number of encounters needed
	for encA in sA.encounters_by_stepcount:
		for encB in sB.encounters_by_stepcount:
			if encA.steps == encB.steps && encA.goal_encounter_on > 0 && encB.goal_encounter_on > 0:
				var enc = StepEncounterData.new()
				enc.steps = encA.steps
				enc.goal_encounter_on = encA.goal_encounter_on if encA.goal_encounter_on <= encB.goal_encounter_on else encB.goal_encounter_on
				enc.goal_encounter_at = encA.goal_encounter_at if encA.goal_encounter_on <= encB.goal_encounter_on else encB.goal_encounter_at
				encounters_by_stepcount.push_back(enc)
				break

	# Then add any steps that we didn't minimise
	for enc in sA.encounters_by_stepcount:
		if !has_encounter_steps(enc.steps) && enc.goal_encounter_on > 0:
			encounters_by_stepcount.push_back(enc)

	for enc in sB.encounters_by_stepcount:
		if !has_encounter_steps(enc.steps) && enc.goal_encounter_on > 0:
			encounters_by_stepcount.push_back(enc)

	# Then add any failed steps that we didn't minimise
	for enc in sA.encounters_by_stepcount:
		if !has_encounter_steps(enc.steps):
			encounters_by_stepcount.push_back(enc)

	for enc in sB.encounters_by_stepcount:
		if !has_encounter_steps(enc.steps):
			encounters_by_stepcount.push_back(enc)
