#include "building.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/surface_tool.hpp>

using namespace godot;

void Building::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_points"), &Building::get_points);
    ClassDB::bind_method(D_METHOD("set_points", "the_points"), &Building::set_points);
    ADD_PROPERTY(PropertyInfo(Variant::PACKED_VECTOR3_ARRAY, "points"), "set_points", "get_points");

    ClassDB::bind_method(D_METHOD("get_manipulator_global_position"), &Building::get_manipulator_global_position);
    ClassDB::bind_method(D_METHOD("set_manipulator_global_position", "the_manipulator_global_position"), &Building::set_manipulator_global_position);
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "manipulator_global_position"), "set_manipulator_global_position", "get_manipulator_global_position");

    ClassDB::bind_method(D_METHOD("get_closest_point_to_manipulator"), &Building::get_closest_point_to_manipulator);
    ClassDB::bind_method(D_METHOD("set_closest_point_to_manipulator", "the_closest_point_to_manipulator"), &Building::set_closest_point_to_manipulator);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "closest_point_to_manipulator"), "set_closest_point_to_manipulator", "get_closest_point_to_manipulator");

    ClassDB::bind_method(D_METHOD("get_vertices"), &Building::get_vertices);
    ClassDB::bind_method(D_METHOD("set_vertices", "the_vertices"), &Building::set_vertices);
    ADD_PROPERTY(PropertyInfo(Variant::PACKED_VECTOR3_ARRAY, "vertices"), "set_vertices", "get_vertices");

    ClassDB::bind_method(D_METHOD("process_points"), &Building::process_points);
    ClassDB::bind_method(D_METHOD("generate_mesh"), &Building::generate_mesh);
}

Building::Building() {
}

Building::~Building() {
}

void Building::process_points() {
    closest_point_to_manipulator = -1;
    vertices = PackedVector3Array();

    int index = 0;
    for (const Vector3 point : points) {
        // Find the closest point to the point manipulator 
        float distance_to_manipulator = point.distance_squared_to(manipulator_global_position);

        if (distance_to_manipulator < MAX_SELECTING_DISTANCE) {
            if (closest_point_to_manipulator < 0) {
                closest_point_to_manipulator = index;
            } else if (points.get(closest_point_to_manipulator).distance_squared_to(manipulator_global_position) > distance_to_manipulator) {
                closest_point_to_manipulator = index;
            }
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
                vertices.append(nearest_points.get(o));
                vertices.append(nearest_points.get(i));
                vertices.append(point);
            }
        }

        index++;
    }
}

Ref<ArrayMesh> Building::generate_mesh() {
    Ref<SurfaceTool> surface;
    surface.instantiate();
    surface->begin(Mesh::PrimitiveType::PRIMITIVE_TRIANGLES);

    for (Vector3 vertex : vertices) {
        surface->add_vertex(vertex);
    }

    surface->index();

    return surface->commit();
}

void Building::set_points(const PackedVector3Array the_points) {
    points = the_points;
}

PackedVector3Array Building::get_points() const {
    return points;
}

void Building::set_manipulator_global_position(const Vector3 the_manipulator_global_position) {
    manipulator_global_position = the_manipulator_global_position;
}

Vector3 Building::get_manipulator_global_position() const {
    return manipulator_global_position;
}

void Building::set_closest_point_to_manipulator(const int the_closest_point_to_manipulator) {
    closest_point_to_manipulator = the_closest_point_to_manipulator;
}

int Building::get_closest_point_to_manipulator() const {
    return closest_point_to_manipulator;
}

void Building::set_vertices(const PackedVector3Array the_vertices) {
    vertices = the_vertices;
}

PackedVector3Array Building::get_vertices() const {
    return vertices;
}