class_name FSMGraphResource
extends Resource

@export var states: Array[FSMStateResource] = []
@export var transitions: Array[FSMTransitionResource] = []

@export_storage var next_state_uid: int = 0
