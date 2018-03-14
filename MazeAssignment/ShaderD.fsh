#version 300 es

precision highp float;
in vec4 v_color;
in vec3 v_normal;
in vec2 v_texcoord;
in vec3 v_position;
out vec4 o_fragColor;

uniform sampler2D texSampler;

uniform mat3 normalMatrix;
uniform bool passThrough;
uniform bool shadeInFrag;

void main()
{
    const vec4 fogColor = vec4(0.5f, 0.5f, 0.5f, 0.5f );
    const float fogStart = 4.0;
    const float fogEnd = 6.0;
    
    vec3 eyeNormal = normalize(normalMatrix * v_normal);
    vec3 lightPosition = vec3(5, 2.5, 10);
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
    vec4 surfaceColor = nDotVP * v_color * texture(texSampler, v_texcoord);
    
    float fogMix = clamp((length(v_position) - fogStart) / (fogEnd - fogStart), 0.0, 1.0);
    
    o_fragColor = mix(surfaceColor, fogColor, fogMix);
}

