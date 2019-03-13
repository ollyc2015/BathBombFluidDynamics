package shaderblox.uniforms;
#if snow
import snow.modules.opengl.GL;
#elseif lime
import lime.graphics.opengl.GL;
import lime.math.Vector4;
import lime.graphics.opengl.GLUniformLocation;
#end

using shaderblox.helpers.GLUniformLocationHelper;

class Vector4{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var w:Float;
	inline public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0){
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	inline public function set(x:Float, y:Float, z:Float, w:Float){
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
}

/**
 * Vector4 float uniform
 * @author Andreas Rønning
 */

@:keepSub
class UVec4 extends UniformBase<Vector4> implements IAppliable  {
	public function new(name:String, index:GLUniformLocation, x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0) {
		super(name, index, new Vector4(x, y, z, w));
	}
	public inline function apply():Void {
		GL.uniform4f(location, data.x, data.y, data.z, data.w);
		dirty = false;
	}
}