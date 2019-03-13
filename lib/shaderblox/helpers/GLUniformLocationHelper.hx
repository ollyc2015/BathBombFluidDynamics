package shaderblox.helpers;

#if snow
import snow.modules.opengl.GL;
#elseif lime
import lime.graphics.opengl.GLUniformLocation;
#end

//exists to fix issue in lime when comparing a GLUniformLocation with null (to test for validity)
class GLUniformLocationHelper{
	static public inline function isValid(u:GLUniformLocation):Bool{
		#if snow
		return  u != null;
		#elseif lime
		return  #if !js (u >= 0); #else (u != null); #end
		#end
	}
}