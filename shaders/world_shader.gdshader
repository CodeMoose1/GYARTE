shader_type spatial;

uniform float turf_angle = 1.0;
uniform float snow_altitude = 40.0;
uniform float grass_altitude = 20.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 terrain_color;
	vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float slope = worldNormal.y / sqrt(worldNormal.x * worldNormal.x + worldNormal.z * worldNormal.z);
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	if (slope > turf_angle){
		if (world_pos.y > snow_altitude){
			terrain_color = vec3(0.8, 0.8, 0.8);
		}else if (world_pos.y > grass_altitude){
			terrain_color = vec3(0, 0.7, 0);
		}else{
			terrain_color = vec3(0.7, 0.7, 0.0);
		}
	} else{
		terrain_color = vec3(0.3, 0.3, 0.3);
	}
	//terrain_color *= clamp(slope/3.0, 0.0, 1.0);
	ALBEDO = terrain_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
