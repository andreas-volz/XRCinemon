shader_type spatial;
render_mode unshaded, cull_front;

#include "include/srgb_to_linear.gdshaderinc"
#include "include/eac_projection.gdshaderinc"

// filter_nearest prevents visible borders between quadrant tiles.
// If image quality becomes an issue, a custom bilinear sampler may be implemented.
uniform sampler2D video_texture : source_color; //filter_nearest

// convert the texture with srgb_to_linear()
uniform bool texture_is_srgb = false;

// specify a color to override the canvas to visualize empty screen
uniform bool force_color_override = false;
uniform vec4 override_color : source_color = vec4(0.0);

// range is 0...1
// rings → y (phi)
// segments → x (theta)
// view_range_* doesn't deform or project the texture. It just "cuts" the display.
uniform vec2 view_range_theta = vec2(0.0, 1.0);
uniform vec2 view_range_phi = vec2(0.0, 1.0);

// a vector that is multiplied for the projection (e.g. x=2.0 to map a default 180° video on a 360° sphere)
uniform vec2 projection_scale = vec2(1.0, 1.0);

uniform vec3 bg_color : source_color;

uniform vec2 texel_size;

varying vec3 sphere_direction;

uniform int bg_mode = 0;
const int BG_DISCARD = 0;
const int BG_COLOR = 1;

uniform int stereo_format = 0;
const int STEREO_FORMAT_MONO = 0;
const int STEREO_FORMAT_SIDE_BY_SIDE = 1;
const int STEREO_FORMAT_OVER_UNDER = 2;

uniform int projection_format = 0;
const int STANDARD_UV = 0;
const int EQUIANGULAR = 1; // EAC

void vertex() {
	// Pass the normalized sphere direction to the fragment shader via a varying.
	sphere_direction = normalize(VERTEX);
}

// Called for every pixel the material is visible on.
void fragment() {
	vec2 uv = UV;
	bool visible = true;

	bool inside_display =
	    uv.x >= view_range_theta.x &&
	    uv.x <= view_range_theta.y &&
	    uv.y >= view_range_phi.x &&
	    uv.y <= view_range_phi.y;

	// mirror horizontal because we're inside of the sphere
	uv.x = 1.0 - uv.x;
	
	// center at null point
	uv -= 0.5;
	
	// apply the projection scale
	uv = uv * projection_scale;
	
	// move it back
	uv += 0.5;

	// EAC activation
	if (projection_format == EQUIANGULAR) {
		
		uv = eac_projection(uv, sphere_direction);
		
		if (stereo_format != STEREO_FORMAT_MONO) {
			uv = rotate_270(uv, vec2(0.5));
		}
	}
		
	// position UV for choosen eyes
	// this enables the 3D stereo effect that shows another image half on each eye
	if (stereo_format != STEREO_FORMAT_MONO) {
		if (stereo_format == STEREO_FORMAT_SIDE_BY_SIDE) {
			if (VIEW_INDEX == VIEW_RIGHT) {
		    	uv.x = uv.x * 0.5 + 0.5;
			} else {
			    uv.x *= 0.5;
			}
		}
		else if (stereo_format == STEREO_FORMAT_OVER_UNDER) {
			if (VIEW_INDEX == VIEW_RIGHT) {
		    	uv.y = uv.y * 0.5 + 0.5;
			} else {
		    uv.y *= 0.5;
			}
		}
	}
		
	vec3 color;
	if (!inside_display) {
		// this is the background pixel case
		if (bg_mode == BG_COLOR) {
			color = bg_color.rgb;
		}
		else if (bg_mode == BG_DISCARD) {
			discard;
		}
    	
	}
	else {
		// get the colors (without alpha component)
		color = texture(video_texture, uv).rgb;
	}
	
	if (texture_is_srgb)
	{
	    color.rgb = srgb_to_linear(color.rgb);
	}
	
	if(force_color_override) {
		ALBEDO = override_color.rgb;
	}
	else {
		ALBEDO = color.rgb;
	}
}
