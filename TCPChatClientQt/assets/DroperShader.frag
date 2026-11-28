#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    vec2 size;
};

void main()
{
    vec2 p = (qt_TexCoord0 - 0.5) * size;
    vec2 halfSize = size * 0.5 - vec2(4.0);
    float radius = 8.0;

    float PI = 3.14159265;

    float glow = 0.0;

    float amount = 3.0;

    for (float i = 0.0; i < amount; ++i)
    {
        float phase = fract(progress * 0.5 + float(i) / amount);
        float position = phase * 30.0;

        vec2 waveHalfSize = halfSize - vec2(position);
        vec2 q = abs(p) - waveHalfSize + radius;

        float distanceToWave = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;

        float d = abs(distanceToWave);

        float opacityStripe = 0.5;

        float stripe = (1.0 - smoothstep(0.5, 1.25, d)) * opacityStripe;
        float fade = sin(phase * PI);

        glow = max(glow, stripe * fade);
    }

    vec3 color = vec3(0.898, 0.894, 0.886);
    fragColor = vec4(color * glow, glow) * qt_Opacity;
}