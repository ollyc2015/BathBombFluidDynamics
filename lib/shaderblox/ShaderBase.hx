package shaderblox;
#if snow
import snow.modules.opengl.GL;
#elseif lime
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
#end

import shaderblox.attributes.Attribute;
import shaderblox.uniforms.IAppliable;
import shaderblox.uniforms.UTexture;

using shaderblox.helpers.GLUniformLocationHelper;
/**
 * Base shader type. Extend this to define new shader objects.
 * Subclasses of ShaderBase must define shader source metadata. 
 * See example/SimpleShader.hx.
 * @author Andreas Rønning
 */

@:autoBuild(shaderblox.macro.ShaderBuilder.build()) 
class ShaderBase
{
	//variables prepended with _ to avoid collisions with glsl variable names
	var _uniforms:Array<IAppliable> = [];
	var _attributes:Array<Attribute> = [];
	var _textures:Array<UTexture> = [];

	public var _prog(default, null):GLProgram;
	public var _active(default, null):Bool;
	var _name:String;
	var _vert:GLShader;
	var _frag:GLShader;
	var _ready:Bool;
	var _numTextures:Int;
	var _aStride:Int;

	public var _vertSource(default, null):String;
	public var _fragSource(default, null):String;

	public function new() {
		_name = ("" + Type.getClass(this)).split(".").pop();
		initSources();
		createProperties();
	}
	
	private function initSources():Void {}

	private function createProperties():Void {}
	
	public function create():Void{
		compile(_vertSource, _fragSource);
		_ready = true;
	}
	
	public function destroy():Void {
		GL.deleteShader(_vert);
		GL.deleteShader(_frag);
		GL.deleteProgram(_prog);
		_prog = null;
		_vert = null;
		_frag = null;
		_ready = false;
	}
	
	function compile(vertSource:String, fragSource:String) {
		var vertexShader = GL.createShader (GL.VERTEX_SHADER);
		GL.shaderSource (vertexShader, vertSource);
		GL.compileShader (vertexShader);

		if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) {
			trace("Error compiling vertex shader: " + GL.getShaderInfoLog(vertexShader));
			trace("\n"+vertSource);
			throw "Error compiling vertex shader";
		}

		var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
		GL.shaderSource (fragmentShader, fragSource);
		GL.compileShader (fragmentShader);
		
		if (GL.getShaderParameter (fragmentShader, GL.COMPILE_STATUS) == 0) {
			trace("Error compiling fragment shader: " + GL.getShaderInfoLog(fragmentShader)+"\n");
			var lines = fragSource.split("\n");
			var i = 0;
			for (l in lines) {
				trace((i++) + " - " + l);
			}
			throw "Error compiling fragment shader";
		}
		
		var shaderProgram = GL.createProgram ();

		GL.attachShader (shaderProgram, vertexShader);
		GL.attachShader (shaderProgram, fragmentShader);
		GL.linkProgram (shaderProgram);
		
		if (GL.getProgramParameter (shaderProgram, GL.LINK_STATUS) == 0) {
			throw "Unable to initialize the shader program.\n"+GL.getProgramInfoLog(shaderProgram);
		}
		
		var numUniforms = GL.getProgramParameter(shaderProgram, GL.ACTIVE_UNIFORMS);
		var uniformLocations:Map<String,GLUniformLocation> = new Map<String, GLUniformLocation>();
		while (numUniforms-->0) {
			var uInfo = GL.getActiveUniform(shaderProgram, numUniforms);
			var loc = GL.getUniformLocation(shaderProgram, uInfo.name);
			uniformLocations[uInfo.name] = loc;
		}
		var numAttributes = GL.getProgramParameter(shaderProgram, GL.ACTIVE_ATTRIBUTES);
		var attributeLocations:Map<String,Int> = new Map<String, Int>();
		while (numAttributes-->0) {
			var aInfo = GL.getActiveAttrib(shaderProgram, numAttributes);
			var loc:Int = cast GL.getAttribLocation(shaderProgram, aInfo.name);
			attributeLocations[aInfo.name] = loc;
		}
		
		_vert = vertexShader;
		_frag = fragmentShader;
		_prog = shaderProgram;
		
		//Validate uniform locations
		var count = _uniforms.length;
		var removeList:Array<IAppliable> = [];
		_numTextures = 0;
		_textures = [];
		for (u in _uniforms) {
			var loc = uniformLocations.get(u.name);
			if (Std.is(u, UTexture)) {
				var t:UTexture = cast u;
				t.samplerIndex = _numTextures++;
				_textures[t.samplerIndex] = t;
			}
			if (loc.isValid()) {				
				u.location = loc;
				#if (debug && !display) trace("Defined uniform "+u.name+" at "+u.location); #end
			}else {
				removeList.push(u);
				#if (debug && !display) trace("WARNING(" + _name + "): unused uniform '" + u.name +"'"); #end
			}
		}
		while (removeList.length > 0) {
			_uniforms.remove(removeList.pop());
		}
		//TODO: Graceful handling of unused sampler uniforms.
		/**
		 * 1. Find every sampler/samplerCube uniform
		 * 2. For each sampler, assign a sampler index from 0 and up
		 * 3. Go through uniform locations, remove inactive samplers
		 * 4. Pack remaining _active sampler
		 */
		
		//Validate attribute locations
		for (a in _attributes) {
			var loc = attributeLocations.get(a.name);
			a.location = loc == null? -1:loc;
			#if (debug && !display) if (a.location == -1) trace("WARNING(" + _name + "): unused attribute '" + a.name +"'"); #end
			#if (debug && !display) trace("Defined attribute "+a.name+" at "+a.location); #end
		}
	}
	
	public inline function activate(initUniforms:Bool = true, initAttribs:Bool = false):Void {
		if (_active) {
			if (initUniforms) setUniforms();
			if (initAttribs) setAttributes();
			return;
		}
		if (!_ready) create();
		GL.useProgram(_prog);
		if (initUniforms) setUniforms();
		if (initAttribs) setAttributes();
		_active = true;
	}
	
	public function deactivate():Void {
		if (!_active) return;
		_active = false;
		disableAttributes();
		// GL.useProgram(null);, seems to be fairly slow and we can get away without it
	}
	
	public inline function setUniforms() {
		for (u in _uniforms) {
			u.apply();
		}
	}
	public inline function setAttributes() {
		var offset:Int = 0;
		for (i in 0..._attributes.length) {
			var att = _attributes[i];
			var location = att.location;
			if (location != -1) {
				GL.enableVertexAttribArray(location);
				GL.vertexAttribPointer (location, att.itemCount, att.type, false, _aStride, offset);
			}
			offset += att.byteSize;
		}
	}
	function disableAttributes() {
		for (i in 0..._attributes.length) {
			var idx = _attributes[i].location;
			if (idx == -1) continue;
			GL.disableVertexAttribArray(idx);
		}
	}

	public function toString():String {
		return "[Shader(" + _name+", attributes:" + _attributes.length + ", uniforms:" + _uniforms.length + ")]";
	}
}