#include "building.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/surface_tool.hpp>
#include <godot_cpp/classes/random_number_generator.hpp>
#include <godot_cpp/templates/hash_map.hpp>
#include <algorithm>
#include <unordered_map>

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

    ClassDB::bind_method(D_METHOD("get_building"), &Building::get_building);
    ClassDB::bind_method(D_METHOD("set_building", "the_building"), &Building::set_building);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "building"), "set_building", "get_building");

    ClassDB::bind_method(D_METHOD("process_points", "calculate_points"), &Building::process_points);

    ClassDB::bind_method(D_METHOD("get_closest_point_to_manipulator"), &Building::get_closest_point_to_manipulator);
    ClassDB::bind_method(D_METHOD("set_closest_point_to_manipulator", "the_closest_point_to_manipulator"), &Building::set_closest_point_to_manipulator);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "closest_point_to_manipulator"), "set_closest_point_to_manipulator", "get_closest_point_to_manipulator");

    ClassDB::bind_method(D_METHOD("get_closest_building_to_manipulator"), &Building::get_closest_building_to_manipulator);
    ClassDB::bind_method(D_METHOD("set_closest_building_to_manipulator", "the_closest_building_to_manipulator"), &Building::set_closest_building_to_manipulator);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "closest_building_to_manipulator"), "set_closest_building_to_manipulator", "get_closest_building_to_manipulator");

    ClassDB::bind_method(D_METHOD("get_lowest_point_in_world"), &Building::get_lowest_point_in_world);
    ClassDB::bind_method(D_METHOD("set_lowest_point_in_world", "the_lowest_point_in_world"), &Building::set_lowest_point_in_world);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "lowest_point_in_world"), "set_lowest_point_in_world", "get_lowest_point_in_world");

    ClassDB::bind_method(D_METHOD("get_vertices"), &Building::get_vertices);
    ClassDB::bind_method(D_METHOD("set_vertices", "the_vertices"), &Building::set_vertices);
    ADD_PROPERTY(PropertyInfo(Variant::PACKED_VECTOR3_ARRAY, "vertices"), "set_vertices", "get_vertices");

    ClassDB::bind_method(D_METHOD("generate_mesh"), &Building::generate_mesh);
}

Building::Building() {
}

Building::~Building() {
}

void Building::process_points(bool calculate_points) {
    float min_manipulator_distance = MAX_SELECTING_DISTANCE;
    lowest_point_in_world = 0.0;
    vertices.clear();
    vertex_colors.clear();

    // Pre-allocate with possible size (AI)
    if (calculate_points) {
        int estimated_trignales = points.size() * MAX_VERTICY_CONNECTIONS * (MAX_VERTICY_CONNECTIONS - 1) / 2;
        vertices.resize(estimated_trignales * 3);
        vertex_colors.resize(estimated_trignales * 3);
    }

    // Spacial partitioning (AI)
    HashMap<Vector2i, PackedInt32Array> spatial_grid;
    const float GRID_SIZE = MAX_CONNECTING_DISTANCE;

    // Handle the closest things to manipulator if there's no points
    if (points.size() <= 0) {
        closest_building_to_manipulator = -1;
        closest_point_to_manipulator = -1;
    }

    // Build spacial grid (AI)
    for (int i = 0; i < points.size(); i++) {
        Vector3 point = points[i];
        Vector2i grid_pos = Vector2i(
            static_cast<int>(point.x / GRID_SIZE),
            static_cast<int>(point.z / GRID_SIZE)
        );

        if (!spatial_grid.has(grid_pos)) {
            spatial_grid[grid_pos] = PackedInt32Array();
        }
        spatial_grid[grid_pos].append(i);
    }

    int vertex_write_index = 0;

    for (int index = 0; index < points.size(); index++) {
        const Vector3& point = points[index];

        // Find the closest point to the point manipulator 
        float distance_to_manipulator = point.distance_squared_to(manipulator_global_position);
        float true_closest_distance_to_manipulator = manipulator_global_position.distance_squared_to(true_closest_point_to_manipulator);

        if (distance_to_manipulator < min_manipulator_distance && distance_to_manipulator <= true_closest_distance_to_manipulator) {
            min_manipulator_distance = distance_to_manipulator;
            closest_point_to_manipulator = index;
            closest_building_to_manipulator = building;
            true_closest_point_to_manipulator = point;
        }

        if (!calculate_points) {
            continue;
        }

        // Find the lowest point in the world
        if (point.y < lowest_point_in_world) {
            lowest_point_in_world = point.y;
        }

        // Use spacial grid to find nearby points (AI)
        Vector2i center_grid = Vector2i(
            static_cast<int>(point.x / GRID_SIZE),
            static_cast<int>(point.z / GRID_SIZE)
        );

        // Structure to store nearby points with distances (AI)
        struct NearbyPoint {
            Vector3 position;
            Color color;
            float distance;
            int original_index;
        };

        std::vector<NearbyPoint> nearby_points;
        nearby_points.reserve(MAX_VERTICY_CONNECTIONS_TEST);

        // Check surrounding grid cells (AI)
        for (int dx = -1; dx <= 1; dx++) {
            for (int dz = -1; dz <= 1; dz++) {
                // Get the grid position to check
                Vector2i check_posisition = center_grid + Vector2i(dx, dz);
                if (!spatial_grid.has(check_posisition)) {
                    continue;
                }

                const PackedInt32Array& cell_indices = spatial_grid[check_posisition];
                for (int i = 0; i < cell_indices.size(); i++) {
                    // Get the other point to check
                    int other_index = cell_indices[i];
                    if (other_index == index) {
                        continue;
                    }
                    const Vector3& other_point = points[other_index];
                    float distance = point.distance_squared_to(other_point);

                    // Add ones within range to nearby points (partial sort)
                    if (distance < MAX_CONNECTING_DISTANCE) {
                        if (nearby_points.size() < MAX_VERTICY_CONNECTIONS_TEST) {
                            nearby_points.push_back({
                                other_point,
                                colors[other_index],
                                distance,
                                other_index
                            });
                        } else if (distance < nearby_points.back().distance) {
                            nearby_points.back() = {
                                other_point,
                                colors[other_index],
                                distance,
                                other_index
                            };
                        }

                        // Keep partially sorted
                        if (nearby_points.size() == MAX_VERTICY_CONNECTIONS_TEST) {
                            std::partial_sort(
                                nearby_points.begin(),
                                nearby_points.begin() + MAX_VERTICY_CONNECTIONS,
                                nearby_points.end(),
                                [](const NearbyPoint& a, const NearbyPoint& b) {
                                    return a.distance < b.distance;
                                });
                        }
                    }
                }
            }
        }

        // Sort points that'll be used
        int connections_to_use = std::min((float)nearby_points.size(), MAX_VERTICY_CONNECTIONS);
        if (connections_to_use > 1) {
            std::sort(
                nearby_points.begin(),
                nearby_points.end(),
                [](const NearbyPoint& a, const NearbyPoint& b) {
                    return a.distance < b.distance;
                }
            );
        }

        // Generate triangles
        if (nearby_points.size() > 1) {
            for (int i = 0; i < connections_to_use - 1 && i < MAX_VERTICY_CONNECTIONS; i++) {
                for (int o = i + 1; o < connections_to_use && o < MAX_VERTICY_CONNECTIONS; o++) {
                    // Make sure to not go over preallocated size (AI)
                    if (vertex_write_index + 2 > vertices.size()) {
                        vertices.resize(vertices.size() * 2);
                        vertex_colors.resize(vertex_colors.size() * 2);
                    }

                    NearbyPoint near_point_1 = nearby_points[i];
                    NearbyPoint near_point_2 = nearby_points[o];

                    if (near_point_1.position.distance_squared_to(near_point_2.position) > MAX_CONNECTING_DISTANCE) {
                        continue;
                    }

                    // Generate vertices
                    vertices[vertex_write_index] = near_point_1.position;
                    vertex_colors[vertex_write_index] = near_point_1.color;
                    vertex_write_index++;

                    vertices[vertex_write_index] = near_point_2.position;
                    vertex_colors[vertex_write_index] = near_point_2.color;
                    vertex_write_index++;

                    vertices[vertex_write_index] = point;
                    vertex_colors[vertex_write_index] = colors[index];
                    vertex_write_index++;
                }
            }
        }
    }

    // Clear the closest point to the manipulator if out of range
    if (min_manipulator_distance >= MAX_SELECTING_DISTANCE && building == closest_building_to_manipulator) {
        closest_point_to_manipulator = -1;
    }

    // Trim arrays to actual size (AI)
    if (calculate_points) {
        vertices.resize(vertex_write_index);
        vertex_colors.resize(vertex_write_index);
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

void Building::set_building(const int the_building) {
    building = the_building;
}

int Building::get_building() const {
    return building;
}

void Building::set_closest_point_to_manipulator(const int the_closest_point_to_manipulator) {
    closest_point_to_manipulator = the_closest_point_to_manipulator;
}

int Building::get_closest_point_to_manipulator() const {
    return closest_point_to_manipulator;
}

void Building::set_closest_building_to_manipulator(const int the_closest_building_to_manipulator) {
    closest_building_to_manipulator = the_closest_building_to_manipulator;
}

int Building::get_closest_building_to_manipulator() const {
    return closest_building_to_manipulator;
}

void Building::set_lowest_point_in_world(const float the_lowest_point_in_world) {
    lowest_point_in_world = the_lowest_point_in_world;
}

float Building::get_lowest_point_in_world() const {
    return lowest_point_in_world;
}

void Building::set_vertices(const PackedVector3Array the_vertices) {
    vertices = the_vertices;
}

PackedVector3Array Building::get_vertices() const {
    return vertices;
}