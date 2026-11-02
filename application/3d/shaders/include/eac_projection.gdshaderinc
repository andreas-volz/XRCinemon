#include "quadrant_mapping.gdshaderinc"
#include "rotation.gdshaderinc"

vec2 trim_x(vec2 uv_in, vec2 origin, float trim_factor) {
	
	uv_in -= origin;
	uv_in *= vec2(trim_factor, 1.0);
	uv_in += origin;
	
	return uv_in;
}

vec2 trim_y(vec2 uv_in, vec2 origin, float trim_factor) {
	
	uv_in -= origin;
	uv_in *= vec2(1.0, trim_factor);
	uv_in += origin;
	
	return uv_in;
}

/*
Rotation/mapping logic for 3x2 format
┌───────┬───────┬───────┐
│ Left  │ Front │ Right │
├───────┼───────┼───────┤
│ Down  │ Back  │  Up   │
└───────┴───────┴───────┘
*/
vec2 eac_projection(vec2 uv_in, vec3 sphere_direction) {
	
	// define the quadrant size of the texture
	ivec2 qc_32 = ivec2(3, 2);
	
	// define the specific qudrant positions to later adress them
	ivec2 q_00 = ivec2(0, 0);
	ivec2 q_10 = ivec2(1, 0);
	ivec2 q_20 = ivec2(2, 0);
	ivec2 q_01 = ivec2(0, 1);
	ivec2 q_11 = ivec2(1, 1);
	ivec2 q_21 = ivec2(2, 1);
	
	vec3 direction = sphere_direction;
	float y = direction.y;
	float x = direction.x;
	float z = direction.z;
	
	// Convert the direction vector into local cube-face coordinates in the specific face cases below.
	// Both coordinates span the range [-1, +1] across the complete face.
	vec2 puv;

	// TODO: this is only a PoC experiment to play with seam padding
	float trim_factor = 0.992; //0.996 => 0.004 == 1 px at this resolution

	/*
	 * Scale the local coordinates to the normalized size of one quadrant.
	 * The reciprocal converts the number of quadrants into its normalized dimension.
	 * The factor 2 accounts for the local coordinate range [-1, +1], which spans 2 units.
	 */
	vec2 quadrant_scale;
	quadrant_scale = 1.0 / (vec2(qc_32) * 2.0);
	
	/*
	 * A normalized direction vector points from the sphere center toward its surface.
	 * We determine which cube face this direction belongs to by finding its dominant axis.
	 * abs() is used because the magnitude determines the dominant axis, regardless of sign.
	 * The sign then determines which side of that axis is selected: positive or negative.
	 * For example, y > 0 means the direction points toward the positive Y face (Y+).
	 * abs(y) >= abs(x) && abs(y) >= abs(z) means Y is the dominant axis.
	 * The six possible combinations therefore divide the sphere into six cube-face regions.
	 * Each region represents the directions that would intersect the corresponding cube face.
	 * Equal component magnitudes lie exactly on a boundary between two faces.
	 * The >= comparisons define a deterministic tie-breaking rule for those boundary points.
	 */
	
	// Y+, Top
	if (y > 0.0 && abs(y) >= abs(x) && abs(y) >= abs(z)) {
		// Normalize the direction by dividing by the dominant axis
		puv.x = x / y;
		puv.y = z / y;
		
		/*
		 * EAC maps the cube-face coordinate p_x to the normalized texture coordinate q_u.
		 * https://blog.google/products-and-platforms/products/google-ar-vr/bringing-pixels-front-and-center-vr-video/
		 *
		 * Starting with the EAC formula:
		 *     q_u = (2 / PI) * atan(2 * p_x) + 1/2
		 *
		 * Our p_u is already normalized from [-1, +1], therefore:
		 *     p_u = 2 * p_x
		 *
		 * The result is converted back from [0, 1] to [-1, +1]:
		 *     2 * q_u - 1 = (4 / PI) * atan(p_u)
		 *
		 * The same transformation is applied independently to both axes.
		 */
		puv = (4.0 / PI) * atan(puv);
		
		// Transform the face-local UV coordinates into global texture space
		// by scaling them to the quadrant size and offsetting them to the
		// quadrant midpoint.
		uv_in = puv * quadrant_scale + get_quadrant_midpoint(qc_32, q_21);
		
		vec2 origin = get_quadrant_midpoint(qc_32, q_21);
		
		// TODO: this is only a PoC experiment to play with seam padding
		//uv_in = trim_x(uv, origin, trim_factor);
		
		uv_in = rotate_270(uv_in, get_quadrant_midpoint(qc_32, q_21));
		uv_in = correct_quadrant_aspect(uv_in, qc_32, get_quadrant_midpoint(qc_32, q_21));
		uv_in = mirror_x(uv_in, get_quadrant_midpoint(qc_32, q_21));
	}
	// Y-, Bottom
	if (y < 0.0 && abs(y) >= abs(x) && abs(y) >= abs(z)) {
		// Normalize the direction by dividing by the dominant axis
		puv.x = x / y;
		puv.y = z / y;
		
		puv = (4.0 / PI) * atan(puv);
		
		uv_in = puv * quadrant_scale + get_quadrant_midpoint(qc_32, q_01);
		
		vec2 origin = get_quadrant_midpoint(qc_32, q_01);
		//uv_in = trim_x(uv, origin, trim_factor);
		
		uv_in = rotate_90(uv_in, get_quadrant_midpoint(qc_32, q_01));
		uv_in = correct_quadrant_aspect(uv_in, qc_32, get_quadrant_midpoint(qc_32, q_01));
	}
	// X+, Right
	if (x > 0.0 && abs(x) >= abs(y) && abs(x) >= abs(z)) {
		// Normalize the direction by dividing by the dominant axis
		puv.x = z / x;
		puv.y = y / x;
		
		puv = (4.0 / PI) * atan(puv);

		uv_in = puv * quadrant_scale + get_quadrant_midpoint(qc_32, q_20);
		
		vec2 origin = get_quadrant_midpoint(qc_32, q_20);
		//uv_in = trim_y(uv, origin, trim_factor);
		
		uv_in = rotate_180(uv_in, get_quadrant_midpoint(qc_32, q_20));
		uv_in = mirror_x(uv_in, get_quadrant_midpoint(qc_32, q_20));
	}
	// X-, Left
	if (x < 0.0 && abs(x) >= abs(y) && abs(x) >= abs(z)) {
		// Normalize the direction by dividing by the dominant axis
		puv.x = z / x;
		puv.y = y / x;
		
		puv = (4.0 / PI) * atan(puv);
		
		uv_in = puv * quadrant_scale + get_quadrant_midpoint(qc_32, q_00);
		
		vec2 origin = get_quadrant_midpoint(qc_32, q_00);
		//uv_in = trim_y(uv_in, origin, trim_factor);
	}
	// Z+, Back
	if (z > 0.0 && abs(z) >= abs(x) && abs(z) >= abs(y)) {
		// Normalize the direction by dividing by the dominant axis
		puv.x = x / z;
		puv.y = y / z;
		
		puv = (4.0 / PI) * atan(puv);
		
		uv_in = puv * quadrant_scale + get_quadrant_midpoint(qc_32, q_11);
		
		vec2 origin = get_quadrant_midpoint(qc_32, q_11);
		//uv_in = trim_x(uv_in, origin, trim_factor);
		
		uv_in = rotate_270(uv_in, get_quadrant_midpoint(qc_32, q_11));
		uv_in = correct_quadrant_aspect(uv_in, qc_32, get_quadrant_midpoint(qc_32, q_11));
	}
	// Z-, Front
	if (z < 0.0 && abs(z) >= abs(x) && abs(z) >= abs(y)) {
		// Normalize the direction by dividing by the dominant axis
		puv.x = x / z;
		puv.y = y / z;
		
		puv = (4.0 / PI) * atan(puv);
		
		uv_in = puv * quadrant_scale + get_quadrant_midpoint(qc_32, q_10);
		
		vec2 origin = get_quadrant_midpoint(qc_32, q_10);
		//uv_in = trim_y(uv_in, origin, trim_factor);
		
		uv_in = mirror_x(uv_in, get_quadrant_midpoint(qc_32, q_10));
	}
	
	return uv_in;
}
