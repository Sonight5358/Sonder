#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
};

layout(binding = 1) uniform sampler2D source;

float random(vec2 uv)
{
    return fract(
        sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453
    );
}

void main()
{
    vec4 color = texture(source, qt_TexCoord0);

    float noise = random(gl_FragCoord.xy) - 0.5;

    // Small color changing
    color.rgb += noise * 0.008;

    fragColor = color * qt_Opacity;
}