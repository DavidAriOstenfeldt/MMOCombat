shader_type spatial;
render_mode cull_front, unshaded;

uniform bool enabled = true;
uniform vec4 outline_color : source_color;
uniform float outline_width = 1.0;

void vertex() {
	if (enabled) {
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);
	
	vec2 offset = normalize(clip_normal.xy) / VIEWPORT_SIZE * clip_position.w * outline_width * 2.0;
	
	clip_position.xy += offset;
	
	POSITION = clip_position;
	}
}

void fragment() {
	if (enabled) {
		ALBEDO = outline_color.rgb;
		if (outline_color.a < 1.0) {
			ALPHA = outline_color.a;
		}
	}
}