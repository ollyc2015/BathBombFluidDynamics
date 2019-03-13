package shaderblox.uniforms;
#if snow
import snow.modules.opengl.GL;
#elseif lime
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLUniformLocation;
#end

using shaderblox.helpers.GLUniformLocationHelper;

/**
 * Float uniform
 * @author Andreas Rønning
 */
 
@:keepSub
class UFloat extends UniformBase<Float> implements IAppliable  {
	public function new(name:String, index:GLUniformLocation, f:Float = 0.0) {
		super(name, index, f);
	}
	public inline function apply():Void {
		GL.uniform1f(location, data);
		dirty = false;
	}
}