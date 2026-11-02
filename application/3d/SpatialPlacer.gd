class_name SpatialPlacer
extends Node3D

# TODO: generic mechanism needed to trigger a SpatialPlacer.FLOATING update after UI scene change

enum PlacementStrategy {
	## Fixed position and orientation in world space.
	FIXED,
	## Fixed position, facing the player's horizontal viewing direction.
	FIXED_BILLBOARD,
	## Positioned once relative to the player, then remains fixed in world space.
	FLOATING,
	## Continuously follows the player's position and horizontal viewing direction.
	FOLLOWING
}

var spatial_parent: Node3D

@export var placement_strategy: PlacementStrategy : set=set_placement_strategy

func set_placement_strategy(strategy: PlacementStrategy):
	placement_strategy = strategy
	match placement_strategy:
		PlacementStrategy.FLOATING:
			placemement_strategy_floating()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spatial_parent = get_parent() as Node3D
	set_placement_strategy(placement_strategy)

func _process(_delta: float) -> void:
	match placement_strategy:
		PlacementStrategy.FIXED:
			placemement_strategy_fixed(spatial_parent.global_transform)
		PlacementStrategy.FIXED_BILLBOARD:
			placemement_strategy_fixed_billboard(spatial_parent.global_position, Services.spatial_anchor_service.camera.global_position)
		PlacementStrategy.FOLLOWING:
				placemement_strategy_floating()

func placemement_strategy_fixed(display_transform: Transform3D):
	if spatial_parent:
		spatial_parent.global_transform = display_transform

func placemement_strategy_fixed_billboard(display_position: Vector3, viewer_position: Vector3):
	if spatial_parent:
		spatial_parent.global_position = display_position
		spatial_parent.look_at(viewer_position, Vector3.UP, true)

func placemement_strategy_floating():
	if spatial_parent and Services.spatial_anchor_service.camera:
		var anchor_transform: Transform3D = Services.spatial_anchor_service.camera.global_transform * self.transform
		var anchor_position: Vector3 = anchor_transform.origin
		var anchor_rotation: Vector3 = anchor_transform.basis.get_euler()
		# Zero the Z component to prevent the object from tilting around the forward axis.
		anchor_rotation.z = 0.0
		
		spatial_parent.global_position = anchor_position
		spatial_parent.rotation.x = anchor_rotation.x
		spatial_parent.rotation.y = anchor_rotation.y
		spatial_parent.rotation.z = anchor_rotation.z
	
