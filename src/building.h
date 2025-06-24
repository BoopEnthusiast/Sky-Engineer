#ifndef BUILDING_H
#define BUILDING_H

#include <godot_cpp/core/object.hpp>
#include <godot_cpp/variant/packed_vector3_array.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/classes/array_mesh.hpp>

namespace godot {

class Building : public Object {
    GDCLASS(Building, Object)

    const int NEAREST_POINTS_COUNT = 2;
    const int MAX_CONNECTING_DISTANCE = 7;
    const int MAX_SELECTING_DISTANCE = 1;

protected:
	static void _bind_methods();

public:

    PackedVector3Array points;
    Vector3 manipulator_global_position;

    void process_points();
    
    int closest_point_to_manipulator;
    PackedVector3Array vertices;
    Ref<ArrayMesh> generate_mesh();

	Building();
	~Building();
};

}

#endif // BUILDING_H