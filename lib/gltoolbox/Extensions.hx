package gltoolbox;

#if snow
import snow.modules.opengl.GL;
#elseif lime
import lime.graphics.opengl.GL;
#end

class Extensions{
	
	//https://www.opengl.org/archives/resources/features/OGLextensions/
	static public function isSupported(extensionName:String, dontStripPrefixes:Bool = false){
		
		function stripPrefixes(ext:String):String{
			var prefixRegex = ~/^([A-Z]+_)?([A-Z]+_)?([\w_]+)$/;
			prefixRegex.match(ext);
			return prefixRegex.matched(3);
		}

		if(!dontStripPrefixes) extensionName = stripPrefixes(extensionName);

		for(ext in GL.getSupportedExtensions()){
			if(!dontStripPrefixes) ext = stripPrefixes(ext);
			if(ext == extensionName) return true;
		}

		return false;
	}

}