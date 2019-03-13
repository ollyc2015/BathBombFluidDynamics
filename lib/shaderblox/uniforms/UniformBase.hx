package shaderblox.uniforms;

#if snow
import snow.modules.opengl.GL;
#elseif lime
import lime.graphics.opengl.GLUniformLocation;
#end

/**
 * Generic uniform type
 * @author Andreas Rønning
 */

@:generic
@:remove 
class UniformBase<T> {
	public var name:String;
	public var location:GLUniformLocation;
	public var data(default, set):T;
	public var dirty:Bool;
	function new(name:String, index:GLUniformLocation, data:T) {
		this.name = name;
		this.location = index;
		this.data = data;
	}
	public inline function set(data:T):T {
		return this.data = data;
	}
	public inline function setDirty() {
		dirty = true;
	}
	inline function set_data(data:T):T{
		setDirty();		
		return this.data = data;
	}
}