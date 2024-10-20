shader_type canvas_item;

void fragment() {
  vec4 input_color = texture(TEXTURE, UV);
  float avg = (input_color.r + input_color.g + input_color.b) / 2.0;
  if (avg < .2) {
    COLOR = vec4(1.0,0,0,0);
  }
  vec2 dir = UV - vec2(.5,.5);
	float radius = length(dir) * 2.0;
  if (radius > .9) {
    COLOR.a = 0.0;
  }
}

// 0, pi/4, pi/2, pi

void vertex() {
  vec2 dir = UV - vec2(.5,.5);
  float tmod =  sin(TIME) / 2.0 + 2.0;
  VERTEX += vec2(1.0/tmod, 1.0/tmod) / tmod;
  float offset = (UV.x + (2.0*UV.y)) * (PI/2.0);
  VERTEX += vec2(cos(TIME*2.0 + offset)*30.0, sin(TIME*2.0 + offset)*30.0);
}