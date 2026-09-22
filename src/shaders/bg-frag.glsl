#version 300 es

precision highp float;

in vec4 fs_Col;

in vec3 posCS;
in vec3 vanishPosCS;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float hash(float x)
{
    return fract(sin(x * 127.1) * 43758.5453);
}

float noise(float f)
{
    float i = floor(f);
    float t = fract(f);

    // Smooth interpolation
    t = t * t * (3.0 - 2.0 * t);

    float a = hash(i);
    float b = hash(i + 1.0);

    return mix(a, b, t);
}

void main()
{
    float dirFactor = clamp(dot(normalize(vanishPosCS), normalize(posCS)), 0.0, 1.0);
    dirFactor = smoothstep(0.92, 0.96, dirFactor);

    vec3 screenUV = cross(normalize(vanishPosCS), normalize(posCS));

    float radial = atan(screenUV.y / screenUV.x);
    radial = step(0.125, noise(radial * 71.69));
    radial = max(radial, dirFactor);

    out_Col = vec4(vec3(radial), 1.0);
}