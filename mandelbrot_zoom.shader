shader_type canvas_item;

// Gonkee's Mandelbrot zoom shader for Godot 3 - full tutorial https://youtu.be/kv3uGJq12fc

// in vec2's representing complex numbers,
// x is the real component and y is the imaginary component

vec2 complex_square(vec2 num) {
	float real = num.x * num.x - num.y * num.y;
	float imag = 2.0 * num.x * num.y;
	return vec2(real, imag);
}

vec2 mandelbrot(vec2 z, vec2 c) {
	return complex_square(z) + c;
}

void fragment() {
	
	int iterations = 200;
	vec2 z = vec2(0.0, 0.0);
	float z_mag = 0.0;
	
	vec2 c = UV - 0.5;
	c.y *= -1.0;
	c /= pow(1.5, TIME - 3.0);
	c.y += 0.1;
	c.x -= sqrt( 0.755 * 0.755 - 0.1 * 0.1 );
	
	float iterations_used = 0.0;
	
	for (int i = 0; i < iterations; i++) {
		z = mandelbrot(z, c);
		z_mag = sqrt(z.x * z.x + z.y * z.y);
		iterations_used++;
		
		if (z_mag >= 2.0) {
			break;
		}
	}
	
	COLOR = vec4(vec3(1.0 - iterations_used / float(iterations)), 1.0);
}
