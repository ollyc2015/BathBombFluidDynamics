package shaderblox.uniforms;
#if snow
import snow.modules.opengl.GL;
#elseif lime
import lime.graphics.opengl.GL;
import lime.math.Vector4;
import lime.graphics.opengl.GLUniformLocation;
#end

using shaderblox.helpers.GLUniformLocationHelper;

/**
 * Vector3 float uniform
 * @author Andreas Rønning
 */
class Vector3{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	inline public function new(x:Float = 0, y:Float = 0, z:Float = 0){
		this.x = x;
		this.y = y;
		this.z = z;
	}
	inline public function set(x:Float, y:Float, z:Float){
		this.x = x;
		this.y = y;
		this.z = z;
	}
}

@:keepSub
class UVec3 extends UniformBase<Vector3> implements IAppliable {
	public function new(name:String, index:GLUniformLocation, x:Float = 0, y:Float = 0, z:Float = 0) {
		super(name, index, new Vector3(x, y, z));
	}
	public inline function apply():Void {
		GL.uniform3f(location, data.x, data.y, data.z);
		dirty = false;
	}
}