/*
TODO
* Remove FlowVelocityField (or add it as optional with a const bool)
* Ensure POT textures by choosing dimensions carefully from the count
 	(eg: change: var dataWidth:Int = Math.ceil( Math.sqrt(newCount) );)
 	* currently requiring POT square, we need an alogo to find nearest pot rectangle
*/


package;

import gltoolbox.TextureTools;
import snow.modules.opengl.GL;
import snow.api.buffers.Float32Array;

import gltoolbox.GeometryTools;
import gltoolbox.render.RenderTarget2Phase;
import shaderblox.ShaderBase;


class GPUParticles{
	var gl = GL;

	public var positionData:RenderTarget2Phase;
	public var velocityData:RenderTarget2Phase;

	public var particleUVs:GLBuffer;

	public var velocityStepShader:VelocityStep;
	public var positionStepShader:PositionStep;
	public var initialPositionShader:InitialPosition;
	public var initialVelocityShader:InitialVelocity;

	public var dragCoefficient(get, set):Float;
	public var flowScaleX(get, set):Float;
	public var flowScaleY(get, set):Float;
	public var flowVelocityField(get, set):GLTexture;
	public var flowIsFloat(null, set):Bool;

	public var count(default, null):Int;

	public var floatData(default, null):Bool;

	var textureQuad:GLBuffer;
	var floatDataType:Null<Int> = null;

	public function new(count:Int){
		#if !js
		gl.enable(gl.VERTEX_PROGRAM_POINT_SIZE);//enable gl_PointSize (always enabled in webgl)
		#end

		if(GPUCapabilities.writeToFloat){
			floatDataType = GL.FLOAT;
		}else if(GPUCapabilities.writeToHalfFloat){
			floatDataType = GPUCapabilities.HALF_FLOAT;
		}

		floatData = floatDataType != null;

		//quad for writing to textures
		textureQuad = GeometryTools.getCachedUnitQuad();

		//create shaders
		velocityStepShader = new VelocityStep();
		positionStepShader = new PositionStep();
		initialPositionShader = new InitialPosition();
		initialVelocityShader = new InitialVelocity();

		velocityStepShader.FLOAT_DATA = floatData ? "true" : "false";
		positionStepShader.FLOAT_DATA = floatData ? "true" : "false";
		initialPositionShader.FLOAT_DATA = floatData ? "true" : "false";
		initialVelocityShader.FLOAT_DATA = floatData ? "true" : "false";

		//set params
		this.dragCoefficient = 1;
		this.flowScaleX = 1;
		this.flowScaleY = 1;
		this.flowIsFloat = false;

		//trigger creation of particle textures
		setCount(count);

		//write initial data
		reset();
	}

	public inline function step(dt:Float){
		//step velocity
		velocityStepShader.dt.data = dt;
		velocityStepShader.positionData.data = positionData.readFromTexture;
		velocityStepShader.velocityData.data = velocityData.readFromTexture;
		renderShaderTo(velocityStepShader, velocityData);

		//step position
		positionStepShader.dt.data = dt;
		positionStepShader.positionData.data = positionData.readFromTexture;
		positionStepShader.velocityData.data = velocityData.readFromTexture;
		renderShaderTo(positionStepShader, positionData);
	}

	public inline function reset(){
		renderShaderTo(initialPositionShader, positionData);
		renderShaderTo(initialVelocityShader, velocityData);
	}

	public function setCount(newCount:Int):Int{
		//setup particle data
		var dataWidth:Int = Math.ceil( Math.sqrt(newCount) );
		var dataHeight:Int = dataWidth;
		//position
		if(positionData == null){
			positionData = new RenderTarget2Phase(dataWidth, dataHeight, TextureTools.createTextureFactory({
				channelType: GL.RGBA,
				dataType: floatData ? floatDataType : GL.UNSIGNED_BYTE,
				filter: gl.NEAREST
			}));			
		}else{
			positionData.resize(dataWidth, dataHeight);
		}

		//velocity
		if(velocityData == null){
			velocityData = new RenderTarget2Phase(dataWidth, dataHeight, TextureTools.createTextureFactory({
				channelType: GL.RGBA,
				dataType: floatData ? floatDataType : GL.UNSIGNED_BYTE,
				filter: gl.NEAREST
			}));			
		}else{
			velocityData.resize(dataWidth, dataHeight);
		}

		//create particle vertex buffers that direct vertex shaders to particles to texel coordinates
		if(this.particleUVs != null){
			gl.deleteBuffer(this.particleUVs);//clear old buffer
		}

		this.particleUVs = gl.createBuffer();

		var arrayUVs = new Float32Array(dataWidth*dataHeight*2);//flattened by columns
		var index:Int;
		for(i in 0...dataWidth){
			for(j in 0...dataHeight){
				index = (i*dataHeight + j)*2;
				arrayUVs[index] = i/dataWidth;
				arrayUVs[++index] = j/dataHeight;
			}
		}

		gl.bindBuffer(gl.ARRAY_BUFFER, this.particleUVs);
		gl.bufferData(gl.ARRAY_BUFFER, arrayUVs, gl.STATIC_DRAW);
		gl.bindBuffer(gl.ARRAY_BUFFER, null);

		//compute initial position jitter from particle density
		var particleSpacing = 2/dataWidth;
		initialPositionShader.jitterAmount.data = particleSpacing;

		return this.count = newCount;
	}

	inline function renderShaderTo(shader:ShaderBase, target:RenderTarget2Phase){
		gl.viewport(0, 0, target.width, target.height);
		gl.bindFramebuffer(gl.FRAMEBUFFER, target.writeFrameBufferObject);

		gl.bindBuffer(gl.ARRAY_BUFFER, textureQuad);

		shader.activate(true, true);
		gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
		shader.deactivate();

		target.swap();
	}

	inline function get_dragCoefficient()   return velocityStepShader.dragCoefficient.data;
	inline function get_flowScaleX()        return velocityStepShader.flowScale.data.x;
	inline function get_flowScaleY()        return velocityStepShader.flowScale.data.y;
	inline function get_flowVelocityField() return velocityStepShader.flowVelocityField.data;

	inline function set_dragCoefficient(v:Float)       return velocityStepShader.dragCoefficient.data = v;
	inline function set_flowScaleX(v:Float)            return velocityStepShader.flowScale.data.x = v;
	inline function set_flowScaleY(v:Float)            return velocityStepShader.flowScale.data.y = v;
	inline function set_flowVelocityField(v:GLTexture) return velocityStepShader.flowVelocityField.data = v;
	inline function set_flowIsFloat(v:Bool)            return velocityStepShader.FLOAT_VELOCITY = v ? "true" : "false";
}

@:vert('
	attribute vec2 vertexPosition;
	varying vec2 texelCoord;

	void main(){
		texelCoord = vertexPosition;
		gl_Position = vec4(vertexPosition*2.0 - vec2(1.0, 1.0), 0.0, 1.0 );//converts to clip space	
	}
')
@:frag('
	varying vec2 texelCoord;
')
class PlaneTexture extends ShaderBase{}

@:frag('
	uniform float dt;
	uniform sampler2D positionData;
	uniform sampler2D velocityData;
')
class ParticleBase extends PlaneTexture{}

@:frag('
	//field packing functions
	#pragma include("src/shaders/glsl/float-packing.glsl")
	#pragma include("src/shaders/glsl/fluid/field-packing.glsl")
	#pragma include("src/shaders/glsl/particles/field-packing.glsl")

	uniform float dragCoefficient;
	uniform vec2 flowScale;
	uniform sampler2D flowVelocityField;

	void main(){
		//particle data
		vec2 p = unpackParticlePosition(texture2D(positionData, texelCoord));
		vec2 v = unpackParticleVelocity(texture2D(velocityData, texelCoord));

		//flow velocity
		vec2 vf = unpackFluidVelocity(texture2D(flowVelocityField, p*.5 + .5)) * flowScale;

		//update particle velocity
		v += (vf - v) * dragCoefficient;

		//write out new velocity
		gl_FragColor = packParticleVelocity(v);
	}
')
class VelocityStep extends ParticleBase{}

@:frag('
	//field packing functions
	#pragma include("src/shaders/glsl/float-packing.glsl")
	#pragma include("src/shaders/glsl/particles/field-packing.glsl")

	void main(){
		//particle data
		vec2 p = unpackParticlePosition(texture2D(positionData, texelCoord));
		vec2 v = unpackParticleVelocity(texture2D(velocityData, texelCoord));

		//update position
		p += v * dt;

		//write out new position
		gl_FragColor = packParticlePosition(p);
	}
')
class PositionStep extends ParticleBase{}

@:frag('
	//field packing functions
	#pragma include("src/shaders/glsl/float-packing.glsl")
	#pragma include("src/shaders/glsl/particles/field-packing.glsl")
	#pragma include("src/shaders/glsl/math.glsl")


	uniform float jitterAmount;

	void main(){
		vec2 initialPosition = vec2(texelCoord.x, texelCoord.y) * 2.0 - 1.0;
		//jitter
		initialPosition.x += rand(initialPosition)*jitterAmount;
		initialPosition.y += rand(initialPosition + 0.3415)*jitterAmount;

		gl_FragColor = packParticlePosition(initialPosition);
	}
')
class InitialPosition extends PlaneTexture{}

@:frag('
	//field packing functions
	#pragma include("src/shaders/glsl/float-packing.glsl")
	#pragma include("src/shaders/glsl/particles/field-packing.glsl")
	
	void main(){
		gl_FragColor = packParticleVelocity(vec2(0));
	}
')
class InitialVelocity extends PlaneTexture{}

@:vert('
	//field packing functions
	#pragma include("src/shaders/glsl/float-packing.glsl")
	#pragma include("src/shaders/glsl/particles/field-packing.glsl")

	uniform sampler2D positionData;
	uniform sampler2D velocityData;

	attribute vec2 particleUV;
	varying vec4 color;
	
	void main(){
		vec2 p = unpackParticlePosition(texture2D(positionData, particleUV));
		vec2 v = unpackParticleVelocity(texture2D(velocityData, particleUV));

		gl_PointSize = 1.0;
		gl_Position = vec4(p, 0.0, 1.0);

		color = vec4(209, 226, 255, 1.0);
	}
')
@:frag('
	varying vec4 color;

	void main(){
		gl_FragColor = vec4(color);
	}
')
class RenderParticles extends ShaderBase{}