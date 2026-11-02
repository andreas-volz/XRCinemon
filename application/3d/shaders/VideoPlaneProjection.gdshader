shader_type spatial;
render_mode unshaded, cull_front;

#include "include/srgb_to_linear.gdshaderinc"

uniform bool horizontal_mirror = false;

uniform sampler2D video_texture : source_color;

// convert the texture with srgb_to_linear()
uniform bool texture_is_srgb = false;

// specify a color to override the canvas to visualize empty screen
uniform bool force_color_override = false;
uniform vec4 override_color : source_color = vec4(0.0);

// range is 0...1
// segments → x (theta)
// view_range_* doesn't deform or project the texture. It just "cuts" the display.
uniform vec2 view_range_theta = vec2(0.0, 1.0);

// TODO: only sphere shader compatibility - resolve
uniform vec2 projection_scale = vec2(1.0, 1.0);

uniform vec2 corner_size = vec2(0.0, 0.0);

// Normalize geometry-specific UV space to generic display UV space. (e.g. y=2.0 to ignore cap/bottom from cylinder)
uniform vec2 uv_normalization = vec2(1.0, 1.0);

// this is the main texture scale variable for the shader
uniform vec2 fit_scale = vec2(1.0, 1.0);

uniform vec3 letterbox_color : source_color = vec3(0.0);
uniform int letterbox_mode = 0;
const int LETTERBOX_DISCARD = 0;
const int LETTERBOX_COLOR = 1;

uniform int stereo_format = 0;
const int STEREO_FORMAT_MONO = 0;
const int STEREO_FORMAT_SIDE_BY_SIDE = 1;
const int STEREO_FORMAT_OVER_UNDER = 2;

// TODO: this is only for sphere shader compatibility
uniform int projection_format = 0;
const int STANDARD_UV = 0;
const int EQUIANGULAR = 1; // EAC

// internal needed to pass variable from vertex() to fragment()
varying vec3 sphere_direction;

vec2 discard_round_corner(vec2 uv_in, vec2 corner_center) {
	// Calculate the position relative to the ellipse center
	vec2 delta = uv_in - corner_center;

	// Normalize the horizontal and vertical distances by the corresponding corner dimensions
	delta = delta / corner_size;

	// Check whether the point lies outside the normalized ellipse.
	// A squared distance greater than 1.0 means the point is outside the boundary.
	if(dot(delta, delta) > 1.0) {
	    discard;
	}
	return uv_in;
}

vec2 discard_round_corners(vec2 uv_in) {
	
	// top left corner
	if(uv_in.x < corner_size.x && uv_in.y < corner_size.y) {
		vec2 corner_center = corner_size;
		
		uv_in = discard_round_corner(uv_in, corner_center);
	}
	
	// top right corner
	if (uv_in.x > 1.0 - corner_size.x && uv_in.y < corner_size.y) {
	    vec2 corner_center = vec2(1.0 - corner_size.x, corner_size.y);

	    uv_in = discard_round_corner(uv_in, corner_center);
	}
	
	// bottom left corner
	if (uv_in.x < corner_size.x && uv_in.y > 1.0 - corner_size.y) {
	    vec2 corner_center = vec2(corner_size.x, 1.0 - corner_size.y);
	    uv_in = discard_round_corner(uv_in, corner_center);
	}

	// bottom right corner
	if (uv_in.x > 1.0 - corner_size.x && uv_in.y > 1.0 - corner_size.y) {
	    vec2 corner_center = vec2(1.0) - corner_size;
	    uv_in = discard_round_corner(uv_in, corner_center);
	}
	
	return uv_in;
}

void vertex() {
	// Pass the normalized sphere direction to the fragment shader via a varying.
	sphere_direction = normalize(VERTEX);
}

// Called for every pixel the material is visible on.
void fragment() {
	vec2 uv = UV;
	float mask = 1.0; // default use the complete UV and no mask
		
	// UV normalization has to be done before center at null point at first
	uv *= uv_normalization;
	
	if(letterbox_mode == LETTERBOX_COLOR) {
		uv = discard_round_corners(uv);
	}
	
	// center at null point
	uv -= 0.5;
	
	// the inside test has to be done after center at null point
	bool inside_display =
	    uv.x >= view_range_theta.x &&
	    uv.x <= view_range_theta.y;

	// do the scaling
	uv *= fit_scale;

	// move it back
	uv += 0.5;

	if(letterbox_mode == LETTERBOX_DISCARD) {
		uv = discard_round_corners(uv);
	}
	
	// vertical mirror
	if(horizontal_mirror) {
		uv.x = 1.0 - uv.x;
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
	
	// get the colors (without alpha component)
	vec3 color = texture(video_texture, uv).rgb;

	// calculate the letterbox and mask it
	// this has to be done after uv is scaled and moved back
	// mark the inside are for both directions 0..1
	vec2 inside_letterbox = step(vec2(0.0), uv) * step(uv, vec2(1.0));
	
	// create the AND mask for both directions
	mask = inside_letterbox.x * inside_letterbox.y;
	
	if(letterbox_mode == LETTERBOX_DISCARD) {
		// don't draw the colored letterbox, but skip the drawing
		// if some fade out might be needed this must be solved with alpha
		if(mask == 0.0) {
 		   discard;
		}
	}
	else if(letterbox_mode == LETTERBOX_COLOR) {
		// mix the letterbox and video color by masking it out
		color = mix(letterbox_color, color, mask);
	}
	
	if (!inside_display) {
		discard;
	}
	
	if (texture_is_srgb)
	{
	    color.rgb = srgb_to_linear(color.rgb);
	}
	
	float alpha = 1.0;
	if(force_color_override) {
		color.rgb = override_color.rgb;
		alpha = override_color.a;
	}
	else {
		//
	}
	
	ALBEDO = color.rgb;
	ALPHA = alpha;

}
