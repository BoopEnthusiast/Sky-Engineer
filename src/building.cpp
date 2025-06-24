#include "building.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/surface_tool.hpp>

using namespace godot;

void Building::_bind_methods() {
}

Building::Building() {
}

Building::~Building() {
}

void Building::process_points() {
    int i = 0;
    for (const Vector3 point : points) {
        // Find the closest point to the point manipulator 
        float distance_to_manipulator = point.distance_squared_to(manipulator_global_position);

        if (distance_to_manipulator < MAX_SELECTING_DISTANCE && closest_point_to_manipulator < 0) {
            closest_point_to_manipulator = i;
        } else if (points[closest_point_to_manipulator].distance_squared_to(manipulator_global_position) > distance_to_manipulator && distance_to_manipulator < MAX_SELECTING_DISTANCE) {
            closest_point_to_manipulator = i;
        }

        // Find the points in range
        PackedVector3Array nearest_points = PackedVector3Array();
        for (Vector3 other_point : points) {
            if (other_point == point) {
                continue;
            }

            if (point.distance_squared_to(other_point) < MAX_CONNECTING_DISTANCE) {
                nearest_points.append(other_point);
            }
        }

        for (int i = 0; i < nearest_points.size() - 1; i++) {
            for (int o = i + 1; o < nearest_points.size(); o++) {
                vertices.append(nearest_points[o]);
                vertices.append(nearest_points[i]);
                vertices.append(point);
            }
        }

        i++;
    }
}

Ref<ArrayMesh> Building::generate_mesh() {
    SurfaceTool surface = SurfaceTool();
    surface.begin(Mesh::PrimitiveType::PRIMITIVE_TRIANGLES);

    for (Vector3 vertex : vertices) {
        surface.add_vertex(vertex);
    }

    surface.index();

    return surface.commit();
}