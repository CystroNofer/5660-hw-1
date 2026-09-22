#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in float fs_TailFactor;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

const vec3 col1 = vec3(1.0, 0.0, 0.0);
const vec3 col2 = vec3(1.0, 0.2, 0.1);
const vec3 col3 = vec3(0.2, 0.0, 0.0);

vec3 interp3(vec3 a, vec3 b, vec3 c, float t)
{
    float u1 = smoothstep(0.0, 0.5, t);
    float u2 = smoothstep(0.5, 1.0, t);

    return mix(mix(a, b, u1), c, u2);
}

float bias(float b, float t)
{
    return pow(t, log(b) / log(0.5f));
}

void main()
{
    float steppedTailFactor = floor(bias(0.35, clamp(fs_TailFactor, 0.0, 1.0)) * 4.0 + 1.0) / 4.0;
    out_Col = vec4(vec3(interp3(col1, col2, col3, steppedTailFactor)), 1.0);
    // out_Col = vec4(vec3(steppedTailFactor), 1.0);
}
