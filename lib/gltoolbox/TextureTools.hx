package gltoolbox;

#if snow
import snow.api.buffers.ArrayBufferView;
import snow.modules.opengl.GL;
#elseif lime
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
#end

typedef TextureFactory = Int->Int->GLTexture; //(width, height):GLTexture

typedef TextureParams = {
	@:optional var channelType:Int;
	@:optional var dataType:Int;
	@:optional var filter:Int;
	@:optional var wrapS:Int;
	@:optional var wrapT:Int;
	@:optional var unpackAlignment:Int;
	@:optional var webGLFlipY:Bool;
}

class TextureTools{

	static public var defaultParams:TextureParams = {
		channelType     : GL.RGBA,
		dataType        : GL.UNSIGNED_BYTE,
		filter          : GL.NEAREST,
		wrapS           : GL.CLAMP_TO_EDGE,
		wrapT           : GL.CLAMP_TO_EDGE,
		unpackAlignment : 4,
		webGLFlipY      : #if js true #else false #end
	};

	static public inline function createTextureFactory(?params:TextureParams):TextureFactory{
		return function (width:Int, height:Int){
			return createTexture(width, height, params);
		}
	}

	static public inline function createFloatTextureRGB(width:Int, height:Int):GLTexture{
		return createTexture(width, height, {
			channelType: GL.RGB,
			dataType: GL.FLOAT
		});
	}

	static public inline function createFloatTextureRGBA(width:Int, height:Int):GLTexture{
		return createTexture(width, height, {
			channelType: GL.RGBA,
			dataType: GL.FLOAT
		});
	}

	static public function createTexture(width:Int, height:Int, ?params:TextureParams, data:ArrayBufferView = null):GLTexture{
		if(params == null) params = {};
		if(data == null) data = null;//@! work around for WebKit bug in texImage2D (refused to accept undefined)

		//extend default params
		for(f in Reflect.fields(defaultParams))
			if(!Reflect.hasField(params, f))
				Reflect.setField(params, f, Reflect.field(defaultParams, f));

		var texture:GLTexture = GL.createTexture();
		GL.bindTexture (GL.TEXTURE_2D, texture);

		//set params
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, params.filter); 
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, params.filter); 
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, params.wrapS);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, params.wrapT);

		GL.pixelStorei(GL.UNPACK_ALIGNMENT, params.unpackAlignment); //see (see http://www.khronos.org/opengles/sdk/docs/man/xhtml/glPixelStorei.xml)
		GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, (params.webGLFlipY ? 1 : 0));

		//set data
		GL.texImage2D(GL.TEXTURE_2D, 0, params.channelType, width, height, 0, params.channelType, params.dataType, data);

		//unbind
		GL.bindTexture(GL.TEXTURE_2D, null);

		return texture;
	}

}