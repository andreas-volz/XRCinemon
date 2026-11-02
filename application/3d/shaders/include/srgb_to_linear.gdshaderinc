/*
 * Convert a color from sRGB color space into linear RGB.
 *
 * Andreas Volz <avolz.mobile@gmail.com>
 * 
 * IEC 61966-2-1:1999
 * Multimedia systems and equipment - Colour measurement and management - Part 2-1: Colour management - Default RGB colour space - sRGB 
 *
 * Most images and videos are stored in sRGB because it matches human
 * perception. The sRGB curve allocates more precision to dark tones,
 * because the human eye is more sensitive there.
 *
 * The problem:
 * Lighting calculations are mathematical operations and require linear
 * color values. Adding light, multiplying colors, reflections, etc. only
 * produce physically correct results in linear space.
 *
 * Example:
 *
 *     sRGB value 0.5 != 50% brightness
 *
 * In linear RGB:
 *
 *     0.5 sRGB ≈ 0.214 linear
 *
 * Therefore textures/videos often need to be converted before entering
 * the lighting pipeline.
 *
 * The official sRGB transfer function is:
 *
 *     if C_srgb <= 0.04045:
 *
 *         C_linear = C_srgb / 12.92
 *
 *     else:
 *
 *         C_linear = ((C_srgb + 0.055) / 1.055) ^ 2.4
 *
 * The simple approximation:
 *
 *     linear = pow(srgb, 2.2)
 *
 * is commonly used and often visually acceptable, but this function
 * implements the actual sRGB standard.
 */
vec3 srgb_to_linear(vec3 srgb)
{
    /*
     * The sRGB curve has a small linear section near black.
     *
     * This avoids problems caused by applying the gamma curve to very
     * dark values, where the real sRGB curve behaves differently.
     */
    vec3 lower = srgb / 12.92;

    /*
     * The main part of the sRGB curve.
     *
     * The exponent 2.4 removes the perceptual encoding applied when the
     * image/video was stored.
     *
     * This converts the compressed sRGB values back into physically
     * meaningful linear light values.
     */
    vec3 higher = pow(
        (srgb + vec3(0.055)) / vec3(1.055),
        vec3(2.4)
    );

    /*
     * Select which part of the curve to use.
     *
     * step(edge, value):
     *
     *     returns 0.0 when value < edge
     *     returns 1.0 otherwise
     *
     * For values <= 0.04045:
     *
     *     use the linear section
     *
     * For values > 0.04045:
     *
     *     use the gamma curve
     *
     * mix(a, b, factor):
     *
     *     factor 0.0 -> returns a
     *     factor 1.0 -> returns b
     *
     * This is done per RGB channel.
     */
    vec3 cutoff = step(vec3(0.04045), srgb);

    return mix(lower, higher, cutoff);
}
