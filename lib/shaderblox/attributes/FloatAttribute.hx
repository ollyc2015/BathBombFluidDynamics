package shaderblox.attributes;

#if snow
import snow.modules.opengl.GL;
#elseif lime
import lime.graphics.opengl.GL;
#end

/**
 * 4-byte float vertex attribute occupying a variable number of floats
 * @author Andreas Rønning
 */
class FloatAttribute extends Attribute
{
	public function new(name:String, location:Int, nFloats:Int = 1) 
	{
		this.name = name;
		this.location = location;
		byteSize = nFloats * 4;
		itemCount = nFloats;
		type = GL.FLOAT;
	}
	public function toString():String 
	{
		return "[FloatAttribute itemCount=" + itemCount + " byteSize=" + byteSize + " location=" + location + " name=" + name + "]";
	}
	
}