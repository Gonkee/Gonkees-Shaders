shader_type canvas_item;

// Gonkee's noise textures, original video: https://youtu.be/ybbJz6C9YYA
// this file heavily references https://thebookofshaders.com/

float rand(vec2 coord){
	// prevents randomness decreasing from coordinates too large
	coord = mod(coord, 10000.0);
	// returns "random" float between 0 and 1
	return fract(sin(dot(coord, vec2(12.9898,78.233))) * 43758.5453);
}

vec2 rand2( vec2 coord ) {
	// prevents randomness decreasing from coordinates too large
	coord = mod(coord, 10000.0);
	// returns "random" vec2 with x and y between 0 and 1
    return fract(sin( vec2( dot(coord,vec2(127.1,311.7)), dot(coord,vec2(269.5,183.3)) ) ) * 43758.5453);
}

float value_noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	// 4 corners of a rectangle surrounding our point
	float tl = rand(i);
	float tr = rand(i + vec2(1.0, 0.0));
	float bl = rand(i + vec2(0.0, 1.0));
	float br = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	float topmix = mix(tl, tr, cubic.x);
	float botmix = mix(bl, br, cubic.x);
	float wholemix = mix(topmix, botmix, cubic.y);
	
	return wholemix;

}


float perlin_noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	// 4 corners of a rectangle surrounding our point
	// must be up to 2pi radians to allow the random vectors to face all directions
	float tl = rand(i) * 6.283;
	float tr = rand(i + vec2(1.0, 0.0)) * 6.283;
	float bl = rand(i + vec2(0.0, 1.0)) * 6.283;
	float br = rand(i + vec2(1.0, 1.0)) * 6.283;
	
	// original unit vector = (0, 1) which points downwards
	vec2 tlvec = vec2(-sin(tl), cos(tl));
	vec2 trvec = vec2(-sin(tr), cos(tr));
	vec2 blvec = vec2(-sin(bl), cos(bl));
	vec2 brvec = vec2(-sin(br), cos(br));
	
	// getting dot product of each corner's vector and its distance vector to current point
	float tldot = dot(tlvec, f);
	float trdot = dot(trvec, f - vec2(1.0, 0.0));
	float bldot = dot(blvec, f - vec2(0.0, 1.0));
	float brdot = dot(brvec, f - vec2(1.0, 1.0));
	
	// putting these values through abs() gives an interesting effect
//	tldot = abs(tldot);
//	trdot = abs(trdot);
//	bldot = abs(bldot);
//	brdot = abs(brdot);
	
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	float topmix = mix(tldot, trdot, cubic.x);
	float botmix = mix(bldot, brdot, cubic.x);
	float wholemix = mix(topmix, botmix, cubic.y);
	
	return 0.5 + wholemix;
}

float cellular_noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float min_dist = 99999.0;
	// going through the current tile and the tiles surrounding it
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			
			// generate a random point in each tile,
			// but also account for whether it's a farther, neighbouring tile
			vec2 node = rand2(i + vec2(x, y)) + vec2(x, y);
			
			// check for distance to the point in that tile
			// decide whether it's the minimum
			float dist = sqrt((f - node).x * (f - node).x + (f - node).y * (f - node).y);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}

float fbm(vec2 coord){
	int OCTAVES = 4;
	
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < OCTAVES; i++){
		value += perlin_noise(coord) * scale;
		normalize_factor += scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value / normalize_factor;
}


void fragment() {
	vec2 coord = UV * 10.0;
	
	float noise;
//	noise = rand(coord);
//	noise = value_noise(coord);
//	noise = perlin_noise(coord);
//	noise = cellular_noise(coord);
	noise = fbm(coord);
	
	COLOR = vec4(vec3(noise), 1.0);
}
