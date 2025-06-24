#ifndef BUILDING_H
#define BUILDING_H

#include <godot_cpp/core/object.hpp>
#include <godot_cpp/variant/packed_vector3_array.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/classes/array_mesh.hpp>

namespace godot {

class Building : public Object {
    GDCLASS(Building, Object)

    static Building *singleton;

protected:
	static void _bind_methods();

public:
    static Building *get_singleton() {
        return singleton;
    }

    static PackedVector3Array points;
    static Vector3 manipulator_mesh_global_position;
    static void add_point(Vector3 point);

    static void process_points();
    
    static int closest_point_to_manipulator;
    static PackedVector3Array vertices;
    static ArrayMesh mesh;

	Building();
	~Building();
};

}

#endif