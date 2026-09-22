#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

uniform float u_Time;
uniform float u_TailLength;
uniform float u_RadialNoiseStrength;
uniform float u_RadialNoiseVariance;
uniform float u_PolarNoiseStrength;
uniform float u_PolarNoiseVariance;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out float fs_TailFactor;

const vec4 lightPos = vec4(5, 5, 3, 1);  // The position of our virtual light, which is used to compute the shading of
                                         // the geometry in the fragment shader.

const float PI = 3.14159265359;
const float TWO_PI = 6.28318530717;

float bias(float b, float t)
{
    return pow(t, log(b) / log(0.5f));
}

float gain(float g, float t)
{
    if (t < 0.5)
    {
        return bias(1.0 - g, 2.0 * t) / 2.0;
    }
    return 1.0 - bias(1.0 - g, 2.0 - 2.0 * t) / 2.0;
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    float tailFactor = pow(max(vs_Pos.y, 0.0), 3.0);  // Local y stretch

    float fBMCenterDist = bias(0.75, length(vs_Pos.xz));
    float fBMRadialFactor = u_RadialNoiseStrength + max(sin(fBMCenterDist * 61.169 - u_Time), 0.0) * u_RadialNoiseVariance;

    float fBMPolarUV = atan(vs_Pos.x / vs_Pos.z) + fBMCenterDist * 5.989;
    float t1 = fBMPolarUV * 0.418 - u_Time;
    float fBMPolarFactor =
        abs(t1 - floor(t1 + 0.5)) * 1.5 +  // Triangle wave with amp 0.75
        sin(fBMPolarUV * 3.031 - u_Time) * 0.2 +
        cos(fBMPolarUV * 11.967 - u_Time) * 0.05;
    fBMPolarFactor = u_PolarNoiseStrength + fBMPolarFactor * u_PolarNoiseVariance;

    vec3 tailOffsetDir = -vs_Pos.xyz;
    tailOffsetDir.y += u_TailLength;
    tailOffsetDir = normalize(tailOffsetDir);
    vec4 modelposition = u_Model * (vs_Pos + vec4(tailOffsetDir * (fBMRadialFactor + fBMPolarFactor) * gain(0.2, tailFactor) * u_TailLength, 0.0));

    fs_LightVec = lightPos - modelposition;                 // Compute the direction in which the light source lies
    
    fs_TailFactor = vs_Pos.y;

    gl_Position = u_ViewProj * modelposition;               // gl_Position is a built-in variable of OpenGL which is
                                                            // used to render the final positions of the geometry's vertices
}
