extends MultiMeshInstance3D

var count:int = 0

func _ready():
	var bas = Basis()
	bas = bas.scaled(Vector3(1,2,1))
	multimesh.set_instance_transform(0,Transform3D(bas ,Vector3(0,0,0)))


func spawn_limb(parent_index:int,at:float, direction:Vector3, angle:float, width:float):
	count += 1
	var parent = multimesh.get_instance_transform(parent_index)
	
	var cord = Vector3(0,at,0)
	
	var newloc = parent * cord
	
	var bas = parent.basis
	
	var rot = bas.get_rotation_quaternion()
	var dir = rot.get_axis()
	var anf = rot.get_angle()
	var sca = bas.get_scale()
	var newbas = Basis()
	
	#newbas = newbas.scaled(Vector3(sca.x * 0.35, 1.0, sca.z * 0.35))
	#newbas = newbas.rotated(Vector3(0,1,0),0.785)
	newbas = newbas.scaled(Vector3(width,0.0001,width))
	newbas = newbas.rotated(direction,angle)
	
	
	multimesh.set_instance_transform(count,Transform3D(newbas,newloc) )
	
	var child_origin = multimesh.get_instance_transform(count).origin
	
	return count
	pass

func grow_limb(index:int,amount:float):
	var tra = multimesh.get_instance_transform(index)
	var bas = tra.basis
	var sca = bas.get_scale()
	var qar = bas.get_rotation_quaternion()
	var dir = qar.get_axis().normalized()
	var ang = qar.get_angle()
	
	var newbas = Basis()
	newbas = newbas.scaled(Vector3(sca.x,sca.y + amount,sca.z))
	if dir.is_normalized():
		newbas = newbas.rotated(dir,ang)
	
	multimesh.set_instance_transform(index,Transform3D(newbas,tra.origin))
	pass
	

func transform_limb(index:int, height:float, width:float, direction:Vector3, angle:float, location:float):
	var bas = Basis()
	bas = bas.scaled(Vector3(width,height,width))
	bas = bas.rotated(direction,angle)
	multimesh.set_instance_transform(index,Transform3D(bas ,Vector3(0,location,0)))
