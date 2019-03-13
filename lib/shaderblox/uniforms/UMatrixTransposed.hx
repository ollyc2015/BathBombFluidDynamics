package shaderblox.uniforms;
#if lime
import lime.utils.Matrix3D;
import lime.graphics.opengl.GL;
#elseif snow
import falconer.utils.Matrix3D;
import snow.modules.opengl.GL;
import lime.graphics.opengl.GLUniformLocation;
#end

using shaderblox.helpers.GLUniformLocationHelper;

/**
 * Transposed Matrix3D uniform
 * @author Andreas Rønning
 */

@:keepSub
class UMatrixTransposed extends UniformBase<Matrix3D> implements IAppliable {
	public function new(index:GLUniformLocation, ?m:Matrix3D) {
		if (m == null) m = new Matrix3D();
		super(index, m);
	}
	public inline function apply():Void {
		GL.uniformMatrix3D(location, true, data);
		dirty = false;
	}
}