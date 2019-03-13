package shaderblox.uniforms;
#if snow
import snow.modules.opengl.GL;
#elseif lime
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLUniformLocation;
#end

using shaderblox.helpers.GLUniformLocationHelper;

/**
 * Int uniform
 * @author Andreas Rønning
 */
 
@:keepSub
class UInt extends UniformBase<Int> implements IAppliable  {
	public function new(name:String, index:GLUniformLocation, f:Int = 0) {
		super(name, index, f);
	}
	public inline function apply():Void {
		GL.uniform1i(location, data);
		dirty = false;
	}
}