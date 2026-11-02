
// Returns the UV coordinate at the center of the specified quadrant.
vec2 get_quadrant_midpoint(ivec2 quadrant_count, ivec2 quadrant_test) {
	
	vec2 quadrant_size = vec2(1.0 / float(quadrant_count.x), 1.0 / float(quadrant_count.y));
	
	vec2 quadrant_midpoint = vec2(quadrant_size.x * float(quadrant_test.x) + quadrant_size.x / 2.0, 
								  quadrant_size.y * float(quadrant_test.y) + quadrant_size.y / 2.0);
	
	return quadrant_midpoint;
}

// Returns the top-left UV coordinate of the specified quadrant.
vec2 get_quadrant_position(ivec2 quadrant_count, ivec2 quadrant_test) {
	
	vec2 quadrant_size = vec2(1.0 / float(quadrant_count.x), 1.0 / float(quadrant_count.y));
	
	vec2 quadrant_position = vec2(quadrant_size.x * float(quadrant_test.x), 
								  quadrant_size.y * float(quadrant_test.y));
	
	return quadrant_position;
}

// Translates UV coordinates from one quadrant to another while preserving their relative position.
vec2 translate_to_quadrant(vec2 uv_in, ivec2 quadrant_count, ivec2 source_quadrant, ivec2 target_quadrant) {
	vec2 translation = get_quadrant_midpoint(quadrant_count, source_quadrant) - get_quadrant_midpoint(quadrant_count, target_quadrant);
	return uv_in + translation;
}

// Adjusts UV coordinates around a given origin to compensate for the aspect ratio of individual quadrants.
vec2 correct_quadrant_aspect(vec2 uv_in, ivec2 quadrant_count, vec2 origin) {
	vec2 quadrant_size = vec2(1.0 / float(quadrant_count.x), 1.0 / float(quadrant_count.y));
	float quadrant_aspect = quadrant_size.y / quadrant_size.x;
	
	uv_in -= origin;
	uv_in.x =  uv_in.x / quadrant_aspect;
	uv_in.y = uv_in.y * quadrant_aspect;
	uv_in += origin;
	
	return uv_in;
}
