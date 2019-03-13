package;

import snow.modules.opengl.GL;
import gltoolbox.TextureTools;

class GPUCapabilities{

	//bools
	static public var writeToFloat(get, null):Bool;
	static public var writeToHalfFloat(get, null):Bool;
	static public var readFromFloat(get, null):Bool;
	static public var readFromHalfFloat(get, null):Bool;
	static public var floatTextureLinear(get, null):Bool;
	static public var halfFloatTextureLinear(get, null):Bool;

	//values
	static public var HALF_FLOAT(get, null):Int;

	//extensions
	static public var extTextureFloat(get, null):Dynamic;
	static public var extTextureHalfFloat(get, null):Dynamic;
	static public var extTextureFloatLinear(get, null):Dynamic;
	static public var extTextureHalfFloatLinear(get, null):Dynamic;

	//cached results
	static private var _writeToHalfFloat:Null<Bool> = null;
	static private var _readFromFloat:Null<Bool> = null;
	static private var _readFromHalfFloat:Null<Bool> = null;
	static private var _floatTextureLinear:Null<Bool> = null;
	static private var _halfFloatTextureLinear:Null<Bool> = null;

	static private var _HALF_FLOAT:Null<Int> = null;

	static private var _extTextureFloat:Dynamic = null;
	static private var _extTextureHalfFloat:Dynamic = null;
	static private var _extTextureFloatLinear:Dynamic = null;
	static private var _extTextureHalfFloatLinear:Dynamic = null;

	static public function report(){
		trace('writeToFloat: '+writeToFloat);
		trace('writeToHalfFloat: '+writeToHalfFloat);
		trace('readFromFloat: '+readFromFloat);
		trace('readFromHalfFloat: '+readFromHalfFloat);
		trace('floatTextureLinear: '+floatTextureLinear);
		trace('halfFloatTextureLinear: '+halfFloatTextureLinear);
		trace('HALF_FLOAT: '+'0x'+StringTools.hex(HALF_FLOAT));
	}

	//properties
	static private function get_writeToFloat():Bool{
		//attach float to a framebuffer and check for validation
		if(extTextureFloat == null)
			return false;

		var texture = TextureTools.createTexture(2, 2, {
			channelType: GL.RGBA,
			dataType: GL.FLOAT,
			filter: GL.NEAREST,
			wrapS: GL.CLAMP_TO_EDGE,
			wrapT: GL.CLAMP_TO_EDGE,
			unpackAlignment: 4
		});

		var framebuffer = GL.createFramebuffer();
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);

		//validate the framebuffer
		var isValid = GL.checkFramebufferStatus(GL.FRAMEBUFFER) == GL.FRAMEBUFFER_COMPLETE;

		GL.deleteTexture(texture);
		GL.deleteFramebuffer(framebuffer);
		GL.bindTexture(GL.TEXTURE_2D, null);
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);

		return isValid;
	}

	static private function get_writeToHalfFloat():Bool{
		//attach float to a framebuffer and check for validation
		if(extTextureHalfFloat == null)
			return false;

		var texture = TextureTools.createTexture(2, 2, {
			channelType: GL.RGBA,
			dataType: HALF_FLOAT,
			filter: GL.NEAREST,
			wrapS: GL.CLAMP_TO_EDGE,
			wrapT: GL.CLAMP_TO_EDGE,
			unpackAlignment: 4
		});

		var framebuffer = GL.createFramebuffer();
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);

		//validate the framebuffer
		var isValid = GL.checkFramebufferStatus(GL.FRAMEBUFFER) == GL.FRAMEBUFFER_COMPLETE;

		GL.deleteTexture(texture);
		GL.deleteFramebuffer(framebuffer);
		GL.bindTexture(GL.TEXTURE_2D, null);
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);

		return isValid;
	}

	static private function get_readFromFloat():Bool{
		if(_readFromFloat == null){
			_readFromFloat = extTextureFloat != null;
		}
		return _readFromFloat;
	}

	static private function get_readFromHalfFloat():Bool{
		if(_readFromHalfFloat == null){
			_readFromHalfFloat = extTextureHalfFloat != null;
		}
		return _readFromHalfFloat;
	}

	static private function get_floatTextureLinear():Bool{
		if(_floatTextureLinear == null){
			_floatTextureLinear = extTextureFloatLinear != null;
		}
		return _floatTextureLinear;
	}

	static private function get_halfFloatTextureLinear():Bool{
		if(_halfFloatTextureLinear == null){
			_halfFloatTextureLinear = extTextureHalfFloatLinear != null;
		}
		return _halfFloatTextureLinear;
	}

	static private function get_HALF_FLOAT():Int{
		if(_HALF_FLOAT == null){
			var ext = extTextureHalfFloat;
			if(ext != null){
				_HALF_FLOAT = ext.HALF_FLOAT_OES;
			}else{
				_HALF_FLOAT = 0x8D61;
			}
		}
		return _HALF_FLOAT;
	}

	static private function get_extTextureFloat():Dynamic{
		if(_extTextureFloat == null){
			_extTextureFloat = GL.getExtension('OES_texture_float');
		}
		return _extTextureFloat;
	}

	static private function get_extTextureHalfFloat():Dynamic{
		if(_extTextureHalfFloat == null){
			_extTextureHalfFloat = GL.getExtension('OES_texture_half_float');
		}
		return _extTextureHalfFloat;
	}

	static private function get_extTextureFloatLinear():Dynamic{
		if(_extTextureFloatLinear == null){
			_extTextureFloatLinear = GL.getExtension('OES_texture_float_linear');
		}
		return _extTextureFloatLinear;
	}

	static private function get_extTextureHalfFloatLinear():Dynamic{
		if(_extTextureHalfFloatLinear == null){
			_extTextureHalfFloatLinear = GL.getExtension('OES_texture_half_float_linear');
		}
		return _extTextureHalfFloatLinear;
	}

}