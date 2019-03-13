uniform sampler2D texture;
varying vec2 texelCoord;

void main(void){
	vec2 v = texture2D(texture, texelCoord);
	gl_FragColor = vec4(s, -s);
}