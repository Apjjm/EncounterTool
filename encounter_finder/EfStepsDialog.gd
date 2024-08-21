extends AcceptDialog

const EfUtils = preload("EfUtils.gd")

@onready var parsed_label = $VBoxContainer/ParsedData
@onready var text_edit = $VBoxContainer/TextEdit

signal steps_updated(steps: Array)

var step_data = []

#func _ready() -> void:
	#_on_text_changed()

func _on_text_changed() -> void:
	if self.text_edit.text == "":
		_on_reset_pressed()

	self.step_data = EfUtils.parse_from_encounter_finder(self.text_edit.text)
	if self.step_data.size() == 0:
		self.parsed_label.text = "Step data not parsed"
	else:
		self.parsed_label.text = "Read " + str(self.step_data.size()) + " steps"

	steps_updated.emit(self.step_data)

func _on_reset_pressed() -> void:
	self.parsed_label.text = "Paste in the output from the encounter finder"
	self.text_edit.text = ""
	self.step_data = []
	steps_updated.emit(self.step_data)
