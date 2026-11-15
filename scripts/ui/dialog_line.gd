extends Resource

class_name DialogLine

#Class exports who is speaking and what is being said
enum STATE_SPEAKER { HERO, OTHER }
@export var SPEAKER := STATE_SPEAKER.HERO
@export_multiline var TEXT: String
@export var VOICE := ""
@export var PORTRAIT: Texture2D
