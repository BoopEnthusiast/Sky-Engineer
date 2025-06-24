#include "building.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void Building::_bind_methods() {
}

Building::Building() {
}

Building::~Building() {
}

void Building::add_point(Vector3 point) {
    points.append(point);
}

void Building::process_points() {
    int i = 0;
    for (Vector3 point : points) {
        // Find the closest point to the point manipulator 
        float distance_to_manipulator = point.distance_squared_to(manipulator_mesh_global_position);

        print_line(point);

        i++;
    }
}