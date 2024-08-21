extends Resource

@export var map_file : String
@export var encounters_file : String

# Note - There is some descrepencies in the data between https://simbu95.github.io/FF4EncounterFinder/ and this tool.
# e.g https://github.com/simbu95/FF4EncounterFinder/blob/56c84dcddf9ee0afb65773cfd87f48264311b6eb/static/CommonEncounters.json#L63
# for mysidia it says formation[6] = Imp Cap. x4, Imp x2 but rosa data says it is Needler x2, SwordRat x2
# This means on 2nd possible encounter for mac giant one tool says use Imp Cap. x4 and one says use Neederx2 encounter.
# TODO: just test this in game and see which is right?

#Note - real solution would be to do an importer, but this is easier
var encounts: Array
var groups: Array
var maps: Array
var _loaded = false

class Encount extends RefCounted:
	var number: int # 2. A number from 0 to 511 indicating the formation number.
	var name: String # 3. A textual description of the encounter. May be omitted if another same number already has name.
	var party: String # 4. The party for which this particular line provides data (We don't use this)
	var avg_duration: float # 5. The average duration of an encounter in frames (We don't use this)
	var min_duration: float # 6. The minimum duration of an encounter in frames (We don't use this)

class Group extends RefCounted:
	var number: int # 2. The number of the group, ranging from 0 to 255.
	var formations: Array # 3. eight numbers indicating the formation numbers that are in this group.

class Map extends RefCounted:
	var number: String # 2. The map number, consisting of four hexadecimal numbers. 
	var rate: int # 3. The encounter rate of the map/region.
	var group: int # 4. The encounter group of the map/region.
	var title: String # 5. The title of the map. Probably a - for overworld things.
	var description: String # 6. The description of the map.

	func is_overworld():
		return self.number.begins_with("0")

	func is_underworld():
		return self.number.begins_with("1")

	func is_lunar():
		return self.number.begins_with("2")
	
	func is_interior():
		return self.number.begins_with("3")

func ensure_loaded():
	if _loaded:
		return

	if map_file != "":
		var f = FileAccess.open(map_file, FileAccess.READ)
		_parse_data(f.get_as_text())

	if encounters_file != "":
		var f = FileAccess.open(encounters_file, FileAccess.READ)
		_parse_data(f.get_as_text())

	_filter_named_encounters()
	_loaded = true

func get_map_by_description(desc: String) -> Map:
	for map in self.maps:
		if map.description == desc:
			return map
	return null

func get_encounter_by_name(name: String) -> Encount:
	for enc in self.encounts:
		if enc.name == name:
			return enc
	return null

func get_all_maps_with_encounter(encount: Encount) -> Array:
	var result = []
	for map in self.maps:
		for enc in get_encounters_for_map(map):
			if enc.number == encount.number:
				result.push_back(map)
				break
	
	return result

# Return array of encounter objects for this map
func get_encounters_for_map(map: Map) -> Array:
	var result = []
	for g in self.groups:
		if g.number == map.group:
			for eId in g.formations:
				for e in self.encounts:
					if e.number == eId:
						result.push_back(e)
						break
			return result

	return result

# Parse a rosa data file
func _parse_data(data: String):
	var lines = data.split("\n", false)
	for line in lines:
		var parts = line.strip_edges().split("\t", false)
		if parts.size() == 6 && parts[0] == "MAP":
			var map = Map.new()
			map.number = parts[1].strip_edges()
			map.rate = parts[2].strip_edges().to_int()
			map.group = parts[3].strip_edges().to_int()
			map.title = parts[4].strip_edges()
			map.description = parts[5].strip_edges()
			self.maps.push_back(map)
		elif parts.size() == 10 && parts[0] == "GROUP":
			var group = Group.new()
			group.number = parts[1].strip_edges().to_int()
			group.formations = [parts[2].strip_edges().to_int(),
			 parts[3].strip_edges().to_int(),
			 parts[4].strip_edges().to_int(),
			 parts[5].strip_edges().to_int(),
			 parts[6].strip_edges().to_int(),
			 parts[7].strip_edges().to_int(),
			 parts[8].strip_edges().to_int(),
			 parts[9].strip_edges().to_int()]
			self.groups.push_back(group)
		elif parts.size() == 6 && parts[0] == "ENCOUNT":
			var encount = Encount.new()
			encount.number = parts[1].strip_edges().to_int()
			encount.name = parts[2].strip_edges()
			encount.party = parts[3].strip_edges()
			encount.avg_duration = parts[4].strip_edges()
			encount.min_duration = parts[5].strip_edges()
			self.encounts.push_back(encount)
		else:
			assert(parts.size() > 0, "Unknown rosa data: " + line)

# Reduce only to named encounters
func _filter_named_encounters():
	var new_encounts = []
	for e1 in encounts:
		if e1.name != "-" && e1.name != "":
			new_encounts.push_back(e1)

	self.encounts = new_encounts
