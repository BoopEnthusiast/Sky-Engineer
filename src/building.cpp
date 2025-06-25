#include "building.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/surface_tool.hpp>
#include <godot_cpp/classes/random_number_generator.hpp>
#include <algorithm>

using namespace godot;

void Building::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_points"), &Building::get_points);
    ClassDB::bind_method(D_METHOD("set_points", "the_points"), &Building::set_points);
    ADD_PROPERTY(PropertyInfo(Variant::PACKED_VECTOR3_ARRAY, "points"), "set_points", "get_points");

    ClassDB::bind_method(D_METHOD("get_colors"), &Building::get_colors);
    ClassDB::bind_method(D_METHOD("set_colors", "the_colors"), &Building::set_colors);
    ADD_PROPERTY(PropertyInfo(Variant::PACKED_COLOR_ARRAY, "colors"), "set_colors", "get_colors");

    ClassDB::bind_method(D_METHOD("get_manipulator_global_position"), &Building::get_manipulator_global_position);
    ClassDB::bind_method(D_METHOD("set_manipulator_global_position", "the_manipulator_global_position"), &Building::set_manipulator_global_position);
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "manipulator_global_position"), "set_manipulator_global_position", "get_manipulator_global_position");

    ClassDB::bind_method(D_METHOD("get_closest_point_to_manipulator"), &Building::get_closest_point_to_manipulator);
    ClassDB::bind_method(D_METHOD("set_closest_point_to_manipulator", "the_closest_point_to_manipulator"), &Building::set_closest_point_to_manipulator);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "closest_point_to_manipulator"), "set_closest_point_to_manipulator", "get_closest_point_to_manipulator");

    ClassDB::bind_method(D_METHOD("get_vertices"), &Building::get_vertices);
    ClassDB::bind_method(D_METHOD("set_vertices", "the_vertices"), &Building::set_vertices);
    ADD_PROPERTY(PropertyInfo(Variant::PACKED_VECTOR3_ARRAY, "vertices"), "set_vertices", "get_vertices");

    ClassDB::bind_method(D_METHOD("process_points", "calculate_points"), &Building::process_points);
    ClassDB::bind_method(D_METHOD("generate_mesh"), &Building::generate_mesh);
}

Building::Building() {
}

Building::~Building() {
}

void Building::process_points(bool calculate_points) {
    closest_point_to_manipulator = -1;
    vertices = PackedVector3Array();
    vertex_colors = PackedColorArray();

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

        if (calculate_points) {
            // Find the points in range
            TypedArray<Vector3> nearest_points = TypedArray<Vector3>();
            PackedColorArray nearest_point_colors = PackedColorArray();
            int other_index = 0;
            for (Vector3 other_point : points) {
                // Check it's not the same point
                if (other_point == point) {
                    other_index++;
                    continue;
                }

                // Find nearby points
                if (point.distance_squared_to(other_point) < MAX_CONNECTING_DISTANCE) {
                    nearest_points.append(other_point);
                    nearest_point_colors.append(colors.get(other_index));

                    if (nearest_points.size() >= MAX_VERTICY_CONNECTIONS_TEST) {
                        break;
                    }
                }

                other_index++;
            }

            // Sort by closest (AI wrote this bit)
            // Create vector of pairs to sort
            std::vector<std::pair<Vector3, Color>> pairs;
            for (int i =0; i < nearest_points.size(); i++) {
                pairs.emplace_back(nearest_points[i], nearest_point_colors[i]);
            }
            // Sort the pairs
            std::sort(pairs.begin(), pairs.end(), [&](const std::pair<Vector3, Color> &a, const std::pair<Vector3, Color> &b) {
                return point.distance_squared_to(a.first) < point.distance_squared_to(b.first);
            });
            // Write back to the typed array
            nearest_points.clear();
            nearest_point_colors.clear();
            for (auto &pair : pairs) {
                nearest_points.append(pair.first);
                nearest_point_colors.append(pair.second);
            }

            // Generate geometry points
            for (int i = 0; i < nearest_points.size() - 1 && i <= MAX_VERTICY_CONNECTIONS; i++) {
                for (int o = i + 1; o < nearest_points.size() && o <= MAX_VERTICY_CONNECTIONS; o++) {
                    // Generate vertices
                    vertices.append(nearest_points.get(i));
                    vertex_colors.append(nearest_point_colors.get(i));
                    vertices.append(nearest_points.get(o));
                    vertex_colors.append(nearest_point_colors.get(o));
                    vertices.append(point);
                    vertex_colors.append(colors.get(index));
                }
            }
        }

        index++;
    }
}

Ref<ArrayMesh> Building::generate_mesh() {
    Ref<SurfaceTool> surface;
    surface.instantiate();
    surface->begin(Mesh::PrimitiveType::PRIMITIVE_TRIANGLES);

    for (int i = 0; i < vertices.size(); i++) {
        surface->set_color(vertex_colors.get(i));
        surface->add_vertex(vertices.get(i));
    }

    return surface->commit();
}

void Building::set_points(const PackedVector3Array the_points) {
    points = the_points;
}

PackedVector3Array Building::get_points() const {
    return points;
}

void Building::set_colors(const PackedColorArray the_colors) {
    colors = the_colors;
}

PackedColorArray Building::get_colors() const {
    return colors;
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