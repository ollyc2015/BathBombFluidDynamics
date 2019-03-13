package gltoolbox.shaders;

import shaderblox.ShaderBase;

@:vert('
	attribute vec2 vertexPosition;
	varying vec2 texelCoord;

	void main(){
		texelCoord = vertexPosition;
		gl_Position = vec4(vertexPosition*2.0 - 1.0, 0.0, 1.0 );//converts to clip space	
	}
')
@:frag('
	uniform sampler2D texture;

	varying vec2 texelCoord;

	void main(){
		gl_FragColor = texture2D(texture, texelCoord);
	}
')
class Resample extends ShaderBase{
	static public var instance = new Resample();
}