@tool
extends EditorPlugin

#const WEIGHT_PAINT_DOCK = preload("res://addons/weightpaint2d/WeightPaintDock.tscn")
const FSM_GRAPH_EDITOR = preload("uid://diehibibjuqbg")

const MAIN_PANEL_NAME := "FSMGraph"

var fsm_graph_editor: FSMGraphEditor
#var weight_mesh_instance: WeightMeshInstance2D
var bottom_panel_button: Button

func _enter_tree():
	fsm_graph_editor = FSM_GRAPH_EDITOR.instantiate()
	# Add the panel to the bottom panel dock instead of the main screen
	bottom_panel_button = add_control_to_bottom_panel(fsm_graph_editor, MAIN_PANEL_NAME)
	
	# Connect to node selection changes
	get_editor_interface().get_selection().selection_changed.connect(_on_selection_changed)
	get_editor_interface().get_inspector().edited_object_changed.connect(_on_edited_object_changed)

func _exit_tree():
	get_editor_interface().get_selection().selection_changed.disconnect(_on_selection_changed)
	
	if fsm_graph_editor:
		remove_control_from_bottom_panel(fsm_graph_editor)
		fsm_graph_editor.queue_free()


func _has_main_screen():
	return false

#func _on_mesh_updated():
	#if weight_mesh_instance != null:
		#weight_mesh_instance.mesh = weight_paint_dock.weight_mesh_instance.mesh
		#show_weight_paint_dialog(weight_mesh_instance)

func _make_visible(visible):
	print("visible: ", visible)
	if visible:
		make_bottom_panel_item_visible(fsm_graph_editor)

func _get_plugin_name():
	return MAIN_PANEL_NAME

func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Mesh", "EditorIcons")

#func _can_handle(object: Object) -> bool:
	#var can_handle := object is FSMGraphResource
	#print("can_handle: ", can_handle)
	#return can_handle
	#
#func _parse_begin(object: Object) -> void:
	#print("parse object")
	## eigener Inspector-Inhalt

func _handles(object: Object) -> bool:
	return object is FSMGraphResource
	
func _edit(object: Object) -> void:
	print("EDIT: ", object)
	fsm_graph_editor.load_resource(object as FSMGraphResource)



func _on_edited_object_changed():
	var edited_object := get_editor_interface().get_inspector().get_edited_object()
	print("_on_edited_object_changed: ", edited_object)

func _on_selection_changed():
	print("selection")
	pass
	#if weight_mesh_instance != null:
		#if weight_mesh_instance.mesh_updated.is_connected(_on_mesh_updated):
			#weight_mesh_instance.mesh_updated.disconnect(_on_mesh_updated)
	#
	#var selected_nodes = get_editor_interface().get_selection().get_selected_nodes()
	#for node in selected_nodes:
		#if node is WeightMeshInstance2D:
			#weight_mesh_instance = node
			#weight_mesh_instance.mesh_updated.connect(_on_mesh_updated)
			#weight_paint_dock.paint_canvas.reset_view_transformation()
			#show_weight_paint_dialog(node)
			#break # only react to the first found WeightMeshInstance2D
		#elif node is MeshInstance2D:
			#show_convert_info()
		#else:
			#show_empty_dialog()

#func show_weight_paint_dialog(node: Node):
	#bottom_panel_button.visible = true
	
	#weight_paint_dock.weight_mesh_instance = weight_mesh_instance
	#weight_paint_dock.show_convert_meshinstance(false)
	#weight_paint_dock.paint_canvas.queue_redraw()

#func show_convert_info():
	##weight_mesh_instance = null
	#bottom_panel_button.visible = true
	#weight_paint_dock.paint_canvas.reset_view_transformation()
	#weight_paint_dock.weight_mesh_instance = null
	#weight_paint_dock.show_convert_meshinstance(true)
	#weight_paint_dock.paint_canvas.queue_redraw()
		
#func show_empty_dialog():
	##weight_mesh_instance = null
	#bottom_panel_button.visible = false
	#weight_paint_dock.paint_canvas.reset_view_transformation()
	#weight_paint_dock.weight_mesh_instance = null
	#weight_paint_dock.show_convert_meshinstance(false)
	#weight_paint_dock.paint_canvas.queue_redraw()
