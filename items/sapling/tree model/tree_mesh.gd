class_name TreeMesh
extends MultiMeshInstance3D

var new_limb_index:int = 0

func _ready():
	spawn_trunk()

func spawn_trunk():
	var trunk_basis = Basis()
	trunk_basis = trunk_basis.scaled(Vector3(1,2,1))
	var trunk_transform = Transform3D(trunk_basis ,Vector3(0,0,0))
	multimesh.set_instance_transform(0,trunk_transform)
	$Foliage.spawn_foliage(0,trunk_transform)

func spawn_limb(parent_index:int,at:float, direction:Vector3, angle:float, width:float = 0.35) -> int:
	# Start rendering a limb instance branching from the limb represented by parent_index. Return the index of the new limb
	new_limb_index += 1
	
	var parent:Transform3D = multimesh.get_instance_transform(parent_index)

	var limb_origin:Vector3 = parent * Vector3(0,at,0)
	
	var new_basis = Basis()
	
	var parent_basis:Basis = parent.basis
	var rot = parent_basis.get_rotation_quaternion()
	var dir = rot.get_axis()
	var anf = rot.get_angle()
	var sca = parent_basis.get_scale()
	new_basis = new_basis.scaled(Vector3(sca.x * width, 0.0001, sca.z * width)) 
	
	new_basis = new_basis.rotated(direction,angle)
	new_basis = new_basis.rotated(parent_basis.get_rotation_quaternion().get_axis(),parent_basis.get_rotation_quaternion().get_angle())
	
	multimesh.set_instance_transform(new_limb_index,Transform3D(new_basis,limb_origin) )
	
	$Foliage.spawn_foliage(new_limb_index, Transform3D(new_basis,limb_origin))
	
	return new_limb_index

func grow_limb(index:int,amount:float):
	# Grows the limb represented by the given index by a given amount
	# TODO make limbs get thiccer as they grow...
	
	# TODO I don't like having to make a new transform every time. I could perhaps store the old scale
	#      in custom instance data. At least that would mean having to dig around the old transform
	#      looking for variables less.
	
	var old_transform:Transform3D = multimesh.get_instance_transform(index)
	var old_basis:Basis = old_transform.basis
	var old_scale:Vector3 = old_basis.get_scale()
	var rotation_quarternion:Quaternion = old_basis.get_rotation_quaternion()
	var direction:Vector3 = rotation_quarternion.get_axis().normalized()
	var angle:float = rotation_quarternion.get_angle()
	
	var new_basis:Basis = Basis()
	new_basis = new_basis.scaled(Vector3(old_scale.x,old_scale.y + amount,old_scale.z))
	if direction.is_normalized():
		new_basis = new_basis.rotated(direction,angle)
	
	var new_transform:Transform3D = Transform3D(new_basis,old_transform.origin)
	multimesh.set_instance_transform(index,new_transform)
	$Foliage.grow_foliage(index,amount,new_transform)

# DEPRECATED
func transform_limb(index:int, height:float, width:float, direction:Vector3, angle:float, location:float):
	# provides very specific control of limb features. Evil.
	var new_basis = Basis()
	new_basis = new_basis.scaled(Vector3(width,height,width))
	new_basis = new_basis.rotated(direction,angle)
	multimesh.set_instance_transform(index,Transform3D(new_basis ,Vector3(0,location,0)))

func set_instance_count(count:int):
	$Foliage.multimesh.instance_count = count
	multimesh.instance_count = count
