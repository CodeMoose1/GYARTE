shader_type spatial;

//uniform sampler2D depth_texture : hint_depth_texture, repeat_disable;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX.y += sin(VERTEX.x + TIME) * sin(VERTEX.z + TIME);
	
}

void fragment() {
	//float depth = (texture(depth_texture, SCREEN_UV).r * INV_PROJECTION_MATRIX[2].w + INV_PROJECTION_MATRIX[3].w);
	
	ALBEDO = vec3(0, 0, 0.5);
	
	ALPHA = 0.7;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
