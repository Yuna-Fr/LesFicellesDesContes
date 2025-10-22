shader_type canvas_item;

uniform sampler2D grad_tex1;
uniform sampler2D grad_tex2;
uniform float fade : hint_range(0.0, 1.0);

void fragment()
{
    vec4 col1 = texture(grad_tex1, UV);
    vec4 col2 = texture(grad_tex2, UV);
    COLOR = mix(col1, col2, fade);
}
