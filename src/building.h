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

    PackedVector3Array points;
    Vector3 manipulator_mesh_global_position;
    void add_point(Vector3 point);

    void process_points();
    
    int closest_point_to_manipulator;
    PackedVector3Array vertices;
    ArrayMesh mesh;

	Building();
	~Building();
};

}

#endif