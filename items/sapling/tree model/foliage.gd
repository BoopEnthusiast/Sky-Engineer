class_name Foliage
extends MultiMeshInstance3D

func spawn_foliage(index:int, parent:Transform3D):
	# creates a foliage instance around a branch represented by the branch index, and transform
	var limb_tip:Vector3 = parent * Vector3(0,0.75,0)
	var parent_basis:Basis = parent.basis
	multimesh.set_instance_transform(index,Transform3D(parent_basis,limb_tip))

func grow_foliage(index:int, amount:float,limb_transform:Transform3D):
	# grows the foliage instance attaced to a branch represented by the branch index and transform by the given amount
	
	#decomposes the branch's transform into its components
	var limb_tip:Vector3 = limb_transform * Vector3(0,0.75,0)
	var old_transform:Transform3D = multimesh.get_instance_transform(index)
	var old_basis:Basis = old_transform.basis
	var old_scale:Vector3 = old_basis.get_scale()
	var rotation_quarternion:Quaternion = old_basis.get_rotation_quaternion()
	var direction:Vector3 = rotation_quarternion.get_axis().normalized()
	var angle:float = rotation_quarternion.get_angle()
	
	#create a new new basis, scaled based on the amount of growth.
	var new_basis:Basis = Basis()
	new_basis = new_basis.scaled(Vector3(old_scale.x + (amount/2),old_scale.y + amount,old_scale.z + (amount/2)))
	if direction.is_normalized():
		new_basis = new_basis.rotated(direction,angle)
	
	#create a new transform based on the new scale, and apply it to the foliage instance.
	multimesh.set_instance_transform(index,Transform3D(new_basis,limb_tip))
