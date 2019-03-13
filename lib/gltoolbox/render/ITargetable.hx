package gltoolbox.render;

#if snow
import snow.modules.opengl.GL;
#elseif lime
import lime.graphics.opengl.GL;
#end

interface ITargetable{
	public var width(default, null):Int;
	public var height(default, null):Int;
	public function activate():Void;
	public function clear(mask:Int = GL.COLOR_BUFFER_BIT):Void;
	public function resize(width:Int, height:Int):ITargetable;
}