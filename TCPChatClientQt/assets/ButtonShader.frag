#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
};

void main()
{
    vec2 uv = qt_TexCoord0;
    uv =  (uv - 0.5) * 2.0;

    float r = progress;
    float d = abs(length(uv) - r);

    d = (d * 15.0 - r - 0.9) / 3.;
    d = abs(d);
    d = smoothstep(0.1, 0.4, 0.02 / d);

    float glow = d * (1.0 - r);
    glow = (1.0 - r) * glow;

    vec3 color = vec3(0.898, 0.894, 0.886);

    fragColor = vec4(color * glow, glow) * qt_Opacity;
}