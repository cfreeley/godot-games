extends RigidBody3D
class_name HoldableItem

## HoldableItem — An object the player can pick up and hold in their hands.
## Uses LEFT CLICK to pick up / drop; does NOT go into the inventory.
##
## If readable_text is set, the script automatically generates a texture by
## rendering a 2D label into a SubViewport and applying it to the first
## MeshInstance3D child.  No Label3D, no floating quads — just a real material.

@export var item_name: String = "Item"
@export var item_id: String = ""
@export_multiline var item_description: String = ""
@export_multiline var readable_text: String = ""  ## Baked into the mesh texture and shown in the HUD


func _ready() -> void:
	collision_layer = 4   # Layer 3 = Interactable
	collision_mask  = 1   # Layer 1 = World
	continuous_cd   = true

	apply_physics_settings()

	# Start texture generation early — it awaits only a couple of render frames,
	# well within the 0.2 s physics-unfreeze window below.
	if readable_text != "":
		_generate_note_texture()   # coroutine — runs in background

	# CSG collision is built asynchronously; a wall-clock timer is more reliable
	# than frame-counting for ensuring it's ready before we unfreeze.
	freeze = true
	await get_tree().create_timer(0.2).timeout
	if is_inside_tree():
		freeze = false


# ---------------------------------------------------------------------------
# Physics helpers
# ---------------------------------------------------------------------------

## Re-apply after any reparent/unfreeze — Godot can silently reset physics state.
func apply_physics_settings() -> void:
	# Paper falls straight down only; no sliding, no spinning.
	axis_lock_linear_x  = true
	axis_lock_linear_z  = true
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true
	linear_damp  = 4.0
	angular_damp = 10.0


# ---------------------------------------------------------------------------
# Note texture generation
# ---------------------------------------------------------------------------

func _generate_note_texture() -> void:
	var mesh_inst := _find_mesh_instance()
	if mesh_inst == null:
		return

	# SubViewport renders a 2D label into a texture that gets applied to the mesh.
	# A4-ish proportions at a resolution that's legible up close.
	const W := 256
	const H := 362
	const PAD := 18

	var vp := SubViewport.new()
	vp.size = Vector2i(W, H)
	vp.transparent_bg = false
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)

	var bg := ColorRect.new()
	bg.color = Color(0.91, 0.88, 0.78)
	bg.size  = Vector2(W, H)
	vp.add_child(bg)

	# Set position and size explicitly — containers added to a SubViewport
	# at runtime don't resolve their layout, so children end up zero-sized.
	var label := Label.new()
	label.position      = Vector2(PAD, PAD)
	label.size          = Vector2(W - PAD * 2, H - PAD * 2)
	label.text          = readable_text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0))
	vp.add_child(label)

	await get_tree().process_frame
	await get_tree().process_frame

	if not is_inside_tree():
		return

	vp.render_target_update_mode = SubViewport.UPDATE_DISABLED

	# BoxMesh shares UV space across all six faces (atlas layout), so the top
	# face only gets a small slice of the texture.  Replace it with a PlaneMesh,
	# which maps its single face to the full [0,1] UV range.
	var plane      := PlaneMesh.new()
	plane.size      = Vector2(0.21, 0.297)
	mesh_inst.mesh  = plane

	var mat := StandardMaterial3D.new()
	mat.albedo_texture             = vp.get_texture()
	mat.roughness                  = 0.55
	# Drive emission from the same texture so only the pale paper glows —
	# black ink pixels emit nothing and stay readable.
	mat.emission_enabled           = true
	mat.emission_texture           = vp.get_texture()
	mat.emission                   = Color(1.0, 1.0, 1.0)
	mat.emission_energy_multiplier = 0.55

	mesh_inst.set_surface_override_material(0, mat)


func _find_mesh_instance() -> MeshInstance3D:
	for child in get_children():
		if child is MeshInstance3D:
			return child
	return null


# ---------------------------------------------------------------------------
# Interaction
# ---------------------------------------------------------------------------

func get_interaction_prompt() -> String:
	return "[LMB]  Pick up  %s" % item_name
