extends PanelContainer

var fps: String
@onready var property_container: VBoxContainer = $MarginContainer/PropertyContainer

func _ready() -> void:
	Global.debug = self
	visible = false
	add_property("FPS", fps)

func _process(delta: float) -> void:
	if visible:
		fps = "%.2f" % (1.0/delta)
		add_property("FPS", fps)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("console"):
		visible = !visible

func add_property(title: String, value) -> void:
	var property
	#attempt to find property before creating it if it doesn't exist
	property = property_container.find_child(title,true,false)
	if !property:
		property = Label.new()
		property_container.add_child(property)
		property.name = title
		property.text = property.name + ": " + str(value)
	elif visible: # update value instead if property with that name exists
		property.text = property.name + ": " + str(value)
