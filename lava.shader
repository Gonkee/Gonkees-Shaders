shader_type canvas_item;

// Gonkee's lava shader for Godot 3 - full tutorial https://youtu.be/Iv7QlvPaBWo
// If you use this shader, I would prefer it if you gave credit to me and my channel

uniform int OCTAVES = 4;

uniform vec4 red : hint_color;
uniform vec4 yellow : hint_color;
uniform vec4 grey : hint_color;
uniform vec4 black : hint_color;

float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(56.0934483, 78.3674596)) * 1000.0) * 1000.0);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	// 4 corners of a rectangle surrounding our point
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < OCTAVES; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 coord = UV * 10.0;
	
	float noise1 = fbm(coord + vec2(TIME * -0.5, TIME * 0.5));
	float noise2 = fbm(coord + vec2(0, TIME * -0.5));
	
	float combined = noise1 * noise2;
	
	COLOR = vec4(vec3(combined), 1.0);
	
	if (combined > 0.25) {
		COLOR = mix(red, yellow, (combined - 1.0) * 1.0 + 1.0);
	} else {
		COLOR = mix(grey, black, combined * 3.0);
	}
}




