shader_type spatial;
render_mode unshaded, cull_front; // cull_front cull_disabled

#include "res://application/3d/shaders/include/srgb_to_linear.gdshaderinc"
#include "res://application/3d/shaders/include/eac_projection.gdshaderinc"

// filter_nearest prevents visible borders between quadrant tiles.
// If image quality becomes an issue, a custom bilinear sampler may be implemented.
uniform sampler2D video_texture : filter_nearest, source_color; // filter_nearest

uniform vec2 texel_size;

varying vec3 sphere_direction;



void vertex() {
	// Pass the normalized sphere direction to the fragment shader via a varying.
	sphere_direction = normalize(VERTEX);
}


// Called for every pixel the material is visible on.
void fragment() {
	vec2 uv = UV;
	vec3 color;
	
	uv = eac_projection(uv, sphere_direction);
	
	color = texture(video_texture, uv).rgb;
	ALBEDO = color.rgb;
}
