#version 300 es

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

uniform float u_TailLength;

out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.

out vec3 vanishPosCS;

out vec3 posCS;

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    posCS = vs_Pos.xyz;
    posCS.z = 0.999;
    vec4 tempV4 = u_ViewProj * vec4(0.0, u_TailLength * 10.0, 0.0, 1.0);
    vanishPosCS = tempV4.xyz / tempV4.w;  // M matrix is identity anyway

    gl_Position = vec4(posCS, 1.0);
}
