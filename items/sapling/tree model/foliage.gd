extends MultiMeshInstance3D

func _ready():
	var ten = 10
	#multimesh.set_instance_transform(0,Transform3D(Basis() ,Vector3(1,1,1)))

func spawn_foliage(index:int, parent:Transform3D):
	var limb_tip:Vector3 = parent * Vector3(0,0.75,0)
	
	var parent_basis:Basis = parent.basis
	
	multimesh.set_instance_transform(index,Transform3D(parent_basis,limb_tip))

func grow_foliage(index:int, amount:float,limb_transform:Transform3D):
	var limb_tip:Vector3 = limb_transform * Vector3(0,0.75,0)
	var old_transform:Transform3D = multimesh.get_instance_transform(index)
	var old_basis:Basis = old_transform.basis
	var old_scale:Vector3 = old_basis.get_scale()
	var rotation_quarternion:Quaternion = old_basis.get_rotation_quaternion()
	var direction:Vector3 = rotation_quarternion.get_axis().normalized()
	var angle:float = rotation_quarternion.get_angle()
	
	var new_basis:Basis = Basis()
	new_basis = new_basis.scaled(Vector3(old_scale.x + (amount/2),old_scale.y + amount,old_scale.z + (amount/2)))
	if direction.is_normalized():
		new_basis = new_basis.rotated(direction,angle)
	
	multimesh.set_instance_transform(index,Transform3D(new_basis,limb_tip))
