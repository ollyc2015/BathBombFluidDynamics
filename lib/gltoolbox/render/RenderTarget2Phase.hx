package gltoolbox.render;

#if snow
import snow.modules.opengl.GL;
#elseif lime
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GL;
#end 

import shaderblox.ShaderBase;

class RenderTarget2Phase implements ITargetable{

	public var width 			 (default, null):Int;
	public var height 			 (default, null):Int;
	public var writeFrameBufferObject (default, null):GLFramebuffer;
	public var writeToTexture         (default, null):GLTexture;
	public var readFrameBufferObject  (default, null):GLFramebuffer;
	public var readFromTexture        (default, null):GLTexture;

	var textureFactory:Int->Int->GLTexture;

	public inline function new(width:Int, height:Int, ?textureFactory:Int->Int->GLTexture){
		if(textureFactory == null) textureFactory = gltoolbox.TextureTools.createTextureFactory();
		this.width = width;
		this.height = height;
		this.textureFactory = textureFactory;

		if(textureQuad == null)
			textureQuad = gltoolbox.GeometryTools.getCachedUnitQuad(GL.TRIANGLE_STRIP);

		this.writeFrameBufferObject = GL.createFramebuffer();
		this.readFrameBufferObject  = GL.createFramebuffer();

		resize(width, height);
	}

	public function resize(width:Int, height:Int):ITargetable{
		var newWriteToTexture  = textureFactory(width, height);
		var newReadFromTexture = textureFactory(width, height);

		//attach texture to frame buffer object's color component
		GL.bindFramebuffer(GL.FRAMEBUFFER, this.writeFrameBufferObject);
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, newWriteToTexture, 0);

		//attach texture to frame buffer object's color component
		GL.bindFramebuffer(GL.FRAMEBUFFER, this.readFrameBufferObject);
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, newReadFromTexture, 0);

		if(this.readFromTexture != null){
			var resampler = gltoolbox.shaders.Resample.instance;
			resampler.texture.data = this.readFromTexture;

			GL.bindFramebuffer(GL.FRAMEBUFFER, readFrameBufferObject);
			GL.viewport(0, 0, width, height);

			GL.bindBuffer(GL.ARRAY_BUFFER, textureQuad);

			resampler.activate(true, true);
			GL.drawArrays(GL.TRIANGLE_STRIP, 0, 4);
			resampler.deactivate();

			GL.deleteTexture(this.readFromTexture);
		}else clearRead();

		if(this.writeToTexture != null)
			GL.deleteTexture(this.writeToTexture);	
		else clearWrite();

		this.width = width;
		this.height = height;
		this.writeToTexture = newWriteToTexture;
		this.readFromTexture = newReadFromTexture;
		
		return this;
	}

	public inline function activate(){
		GL.bindFramebuffer(GL.FRAMEBUFFER, writeFrameBufferObject);
	}

	var tmpFBO:GLFramebuffer;
	var tmpTex:GLTexture;
	public inline function swap(){
		tmpFBO                 = writeFrameBufferObject;
		writeFrameBufferObject = readFrameBufferObject;
		readFrameBufferObject  = tmpFBO;

		tmpTex          = writeToTexture;
		writeToTexture  = readFromTexture;
		readFromTexture = tmpTex;
	}

	public inline function clear(mask:Int = GL.COLOR_BUFFER_BIT){
		clearRead(mask);
		clearWrite(mask);
	}

	public inline function clearRead(mask:Int = GL.COLOR_BUFFER_BIT){
		GL.bindFramebuffer(GL.FRAMEBUFFER, readFrameBufferObject);
		GL.clearColor (0, 0, 0, 1);
		GL.clear (mask);
	}

	public inline function clearWrite(mask:Int = GL.COLOR_BUFFER_BIT){
		GL.bindFramebuffer(GL.FRAMEBUFFER, writeFrameBufferObject);
		GL.clearColor (0, 0, 0, 1);
		GL.clear (mask);
	}

	public inline function dispose(){
		GL.deleteFramebuffer(writeFrameBufferObject);
		GL.deleteFramebuffer(readFrameBufferObject);
		GL.deleteTexture(writeToTexture);
		GL.deleteTexture(readFromTexture);
	}

	static var textureQuad:GLBuffer;
	
}

