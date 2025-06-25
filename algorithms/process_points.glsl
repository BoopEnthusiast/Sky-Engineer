#[compute]
#version 450

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) readonly restrict buffer InputBuffer {
    vec3 input_data[];
    int input_data_size;
};

layout(set = 0, binding = 0, std430) writeonly restrict buffer OutputBuffer {
    vec3 output_data[];
};

void main() {
    
}