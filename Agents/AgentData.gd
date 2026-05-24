class_name Agent extends Resource


@export var name : StringName
@export var cost : int
@export var reputation : float
@export var mission_status: Dictionary = {
	"State": false, #State of the mission(false = no active mission)
	"Objective": 0, #RandomStrings.random_objectives[]
	"Duration": 0, #days
	"Location": 0 #RandomStrings.random_location[]
}

static var furtiveness_skill_range := NumberRange.new(1, 20, 1)
@export var furtiveness_skill : float #For stealth missions

static var assault_skill_range := NumberRange.new(1, 20, 1)
@export var assault_skill : float #For assault missions

var index : int #Touching this variable is not advised since you may get your finger burned by the screen
