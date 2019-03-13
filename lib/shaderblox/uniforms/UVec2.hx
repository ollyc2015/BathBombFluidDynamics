package shaderblox.uniforms;

using shaderblox.helpers.GLUniformLocationHelper;

#if snow
import snow.modules.opengl.GL;
class Vector2{
	public var x:Float;
	public var y:Float;
	inline public function new(x:Float = 0, y:Float = 0){
		this.x = x;
		this.y = y;
	}
	inline public function set(x:Float, y:Float){
		this.x = x;
		this.y = y;
	}
}
#elseif lime
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLUniformLocation;
import lime.math.Vector2;
#end


/**
 * Vector2 float uniform
 * @author Andreas Rønning
 */

@:keepSub
class UVec2 extends UniformBase<Vector2> implements IAppliable  {
	public function new(name:String, index:GLUniformLocation, x:Float = 0, y:Float = 0) {
		super(name, index, new Vector2(x, y));
	}
	public inline function apply():Void {
		GL.uniform2f(location, data.x, data.y);
		dirty = false;
	}
}