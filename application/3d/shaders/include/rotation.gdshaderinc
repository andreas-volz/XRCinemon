/*
 * Rotate UV coordinates around the center of the origin.
 * applying the standard 2D rotation matrix, then translating back.
 * For 90° steps, sin/cos reduce to 0 and +/-1, resulting in simple coordinate swaps.
 * Has additional some x/y mirror functions.
*/

/* rotate 90° counter-clockwise
 * use origin=vec2(0.5) as shortcut to rotate around the global midpoint
 */
vec2 rotate_90(vec2 uv_in, vec2 origin) {
	uv_in -= origin;
    uv_in = vec2(-uv_in.y, uv_in.x);
    uv_in += origin;
	
	return uv_in;
}

/* rotate 180°
 * use origin=vec2(0.5) as shortcut to rotate around the global midpoint
 */
vec2 rotate_180(vec2 uv_in, vec2 origin) {
	uv_in -= origin;
    uv_in = vec2(-uv_in.x, -uv_in.y);
    uv_in += origin;
	
	return uv_in;
}

/* rotate 270° counter-clockwise
 * use origin=vec2(0.5) as shortcut to rotate around the global midpoint
 */
vec2 rotate_270(vec2 uv_in, vec2 origin) {
	uv_in -= origin;
    uv_in = vec2(uv_in.y, -uv_in.x);
    uv_in += origin;
	
	return uv_in;
}

vec2 mirror_x(vec2 uv_in, vec2 origin) {
	uv_in -= origin;
	uv_in.x = 1.0 - uv_in.x;
	uv_in += origin;
	return uv_in;
}

vec2 mirror_y(vec2 uv_in, vec2 origin) {
	uv_in -= origin;
	uv_in.y = 1.0 - uv_in.y;
	uv_in += origin;
	return uv_in;
}