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
    const float spotlightCutoff = 0.9961;
    
    vec3 eyeNormal = normalize(normalMatrix * v_normal);
    
    float nDotVP = max(0.0, dot(eyeNormal, vec3(0,0,1)));
    
    float spotlightValue = dot(normalize(v_position),vec3(0,0,-1));
    
    if (spotlightValue < spotlightCutoff) {
        nDotVP *= 0.5;
    }
    
    o_fragColor = nDotVP * v_color * texture(texSampler, v_texcoord);
    
}

