#ifndef BUILDING_H
#define BUILDING_H

#include <godot_cpp/core/object.hpp>
#include <godot_cpp/variant/packed_vector3_array.hpp>
#include <godot_cpp/variant/packed_color_array.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/classes/array_mesh.hpp>

namespace godot {

class Building : public Object {
    GDCLASS(Building, Object)

    const int NEAREST_POINTS_COUNT = 2;
    const int MAX_CONNECTING_DISTANCE = 5;
    const int MIN_DISTANCE_BETWEEN_POINTS = 1;
    const int MAX_SELECTING_DISTANCE = 1;
    const int MAX_VERTICY_CONNECTIONS_TEST = 20;
    const int MAX_VERTICY_CONNECTIONS = 5;

    // Things to set before processing points
    PackedVector3Array points;
    PackedColorArray colors;
    Vector3 manipulator_global_position;

    // Set after processing points
    int closest_point_to_manipulator;
    PackedVector3Array vertices;
    PackedColorArray vertex_colors;
    Ref<ArrayMesh> generate_mesh();

protected:
	static void _bind_methods();

public:
    void set_points(const PackedVector3Array the_points);
    PackedVector3Array get_points() const;

    void set_colors(const PackedColorArray the_colors);
    PackedColorArray get_colors() const;

    void set_manipulator_global_position(const Vector3 the_manipulator_global_position);
    Vector3 get_manipulator_global_position() const;

    void process_points(bool calculate_points);

    void set_closest_point_to_manipulator(const int the_closest_point_to_manipulator); 
    int get_closest_point_to_manipulator() const;

    void set_vertices(const PackedVector3Array the_vertices);
    PackedVector3Array get_vertices() const;

	Building();
	~Building();
};

}

#endif // BUILDING_H