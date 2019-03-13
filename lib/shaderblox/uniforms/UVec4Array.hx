package shaderblox.uniforms;
#if snow
import snow.io.typedarray.Float32Array;
import snow.render.opengl.GL;
import falconer.utils.Vector3D;
#elseif lime
import lime.graphics.opengl.GL;
import lime.math.Vector4;
import lime.graphics.opengl.GLUniformLocation;
#end

using shaderblox.helpers.GLUniformLocationHelper;

class InternalUVec4 extends UniformBase<Float32Array> implements IAppliable  {
	public function new(name:String, index:GLUniformLocation, length:Int) {
		trace('UVec4Array created ($length)');
		super(name, index, new Float32Array(length * 4));
	}

	public inline function apply():Void {
		trace('applying UVec4 $data');
		// GL.uniform4f(location,data);
		dirty = false;
	}
}

@:forward
abstract UVec4(InternalUVec4){

}