extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var HeartFull = $HeartFull
onready var HeartEmpty = $HeartEmpty

const HEART_WIDTH = 15

func set_hearts(val):
	if HeartFull != null:
		HeartFull.rect_size.x = val * HEART_WIDTH
		
	
func set_max_hearts(val):	
	if HeartEmpty != null:
		HeartEmpty.rect_size.x = val * HEART_WIDTH
	
func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
