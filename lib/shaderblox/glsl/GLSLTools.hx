//:TODO: globals functions don't currently exclude non-global scope which might be an issue for complex shaders with many consts embedded

package shaderblox.glsl;

using Lambda;

typedef GLSLGlobal = {?storageQualifier:String, ?precision:String, type:String, name:String, ?arraySize:Int};


//fairly primitive glsl parsing with regex
class GLSLTools {
	static var PRECISION_QUALIFIERS = ['lowp', 'mediump', 'highp'];
 	static var MAIN_FUNC_REGEX = new EReg('(\\s|^)(('+PRECISION_QUALIFIERS.join('|')+')\\s+)?(void)\\s+(main)\\s*\\([^\\)]*\\)\\s*\\{', 'm');
 	static var STORAGE_QUALIFIERS = ['const', 'attribute', 'uniform', 'varying'];
 	static var STORAGE_QUALIFIER_TYPES = [
 		'const'     => ['bool','int','float','vec2','vec3','vec4','bvec2','bvec3','bvec4','ivec2','ivec3','ivec4','mat2','mat3','mat4'],
 		'attribute' => ['float','vec2','vec3','vec4','mat2','mat3','mat4'],
 		'uniform'   => ['bool','int','float','vec2','vec3','vec4','bvec2','bvec3','bvec4','ivec2','ivec3','ivec4','mat2','mat3','mat4','sampler2D','samplerCube'],
 		'varying'   => ['float','vec2','vec3','vec4','mat2','mat3','mat4']
 	];

 	//:todo: value should be ConstType and have function toGLSL():String
    //:todo: should only consider global scope
 	static public function injectConstValue(src:String, name:String, value:String){
 		var storageQualifier = 'const';
 		var types = STORAGE_QUALIFIER_TYPES[storageQualifier];

    	var reg = new EReg(storageQualifier+'\\s+(('+PRECISION_QUALIFIERS.join('|')+')\\s+)?('+types.join('|')+')\\s+([^;]+)', 'm');

        var src = stripComments(src);

        var currStr = src;
        //determine const position and length
    	while(reg.match(currStr)){
        	var declarationPos = reg.matchedPos();

        	var rawDeclarationString = reg.matched(0);

            //Search rawDeclarationString
            //rawDeclarationString is exploded by brackets so that ',' contained within can be ignored
            var exploded = bracketExplode(rawDeclarationString, "()");

            //concatenate just the root scope of the raw name string
            var rootScopeStr = exploded.contents.fold(function (n, rs)
                return rs + (Std.is(n, StringNode) ? n.toString() : "")
            , "");

            //try to locate const with supplied name
            //(name) =
            var rConstName = new EReg('\\b('+name+')\\b\\s*=', 'm');//here initializer is required and there are no square brackets

            var nameFound = rConstName.match(rootScopeStr);
            if(nameFound){
                var namePos = rConstName.matchedPos();
                //determine the length of the initializer
                var initializerLength = 0;
                if((initializerLength = rConstName.matchedRight().indexOf(',')) == -1){
                    initializerLength = rConstName.matchedRight().length;
                }
                //initializer range in compressed coordinates (concatenated root scope of rawDeclarationString)
                var initializerRangeInRootStr = {
                    start: namePos.pos+namePos.len,
                    end: namePos.pos+namePos.len+initializerLength
                }
                //convert 'compressed' coordinates into exploded (ie, taking into account ignored scopes)
                //then add on the position of the 
                var absoluteOffset = src.length - currStr.length + declarationPos.pos;
                var initializerRangeAbsolute = {
                    start: compressedToExploded(exploded, initializerRangeInRootStr.start) + absoluteOffset,
                    end: compressedToExploded(exploded, initializerRangeInRootStr.end) + absoluteOffset
                }

                //replace initializer in src
                var srcBefore = src.substring(0, initializerRangeAbsolute.start);
                var srcAfter = src.substring(initializerRangeAbsolute.end);

                return srcBefore+value+srcAfter;
            }
            //next global declaration
            currStr = reg.matchedRight();    
        }

        //failed to find const
    	return null;
 	}

    static function compressedToExploded(scope:ScopeNode, compressedPosition:Int){
        var CC = compressedPosition;
        var stringTotal = 0;
        var nodeTotal = 0;
        var targetIndex:Null<Int> = null;
        for (i in 0 ... scope.contents.length) {
            var n = scope.contents[i];
            var len = n.toString().length;
            if(Std.is(n, StringNode)){
                if(stringTotal+len > CC){
                    targetIndex = i;
                    break;
                }
                stringTotal += len;
            }
            nodeTotal += len;
        }
        return (CC - stringTotal) + nodeTotal;
    }


    static public function extractGlobals(src:String, ?storageQualifiers:Array<String>):Array<GLSLGlobal>{
    	if(storageQualifiers == null)
    		storageQualifiers = STORAGE_QUALIFIERS;

    	if(src == null) return [];

    	var str = stripComments(src);

    	var globals = new Array<GLSLGlobal>();

    	for (storageQualifier in storageQualifiers) {
    		var types = STORAGE_QUALIFIER_TYPES[storageQualifier];

    		//format: (precision)? (type) (name1 (= (value))?, name2 (= (value))?);
    		var reg = new EReg(storageQualifier+'\\s+(('+PRECISION_QUALIFIERS.join('|')+')\\s+)?('+types.join('|')+')\\s+([^;]+)', 'm');
    		
    		while(reg.match(str)){
    	        var precision = reg.matched(2);
    	        var type = reg.matched(3);
    	        var rawNamesStr = reg.matched(4);

    	        //Extract comma separated names and array sizes (ie light1, light2 and name[size])
    	        //	also evaluate any initialization expressions (ie strength = 2.3)
    	        //	there is no mechanism for initializing arrays at declaration time from within a shader

    	        //format: (name) ([arraySize])? = (expression), ...
    	        var rName = ~/^\s*([\w\d_]+)\s*(\[(\d*)\])?\s*(=\s*(.+))?$/im;
    	        for(rawName in rawNamesStr.split(',')){
    				if(!rName.match(rawName)) continue;//name does not conform

    	           	var global = {
    	           		storageQualifier: storageQualifier,
    	           		precision: precision,
    	           		type: type,
    	           		name: rName.matched(1),
    	           		arraySize: Std.parseInt(rName.matched(3))
    	           	};

    	           	//validity checks
    	           	//if storageQualifier is 'const', arraySize must be null because const requires initialization and arrays cannot be initialized here
    	           	//for all other storageQualifiers value must be null because these cannot be initialized

    	            globals.push(global);
    	        }

    	        str = reg.matchedRight();
    	    }

    	}

        return globals;
    }
	
	static public function stripComments(src:String):String {
		return (~/(\/\*([\s\S]*?)\*\/)|(\/\/(.*)$)/igm).replace(src, '');//#1 = block comments, #2 = line comments
	}

	static public function unifyLineEndings(src:String):String {
		return StringTools.trim(src.split("\r").join("\n").split("\n\n").join("\n"));
	}

	static public function hasMain(src:String):Bool{
		if(src == null)return false;
		var str = stripComments(src);
		return MAIN_FUNC_REGEX.match(str);
	}

	static public function stripMain(src:String):String {
		if(src == null)return null;
		var str = src;
		var reg = MAIN_FUNC_REGEX;
        
        var matched = reg.match(str);
        if(!matched)return str;
        
        var remainingStr = reg.matchedRight();
        
        var mainEnd:Int = 0;
        //find closing bracket
        var open = 1;
        for(i in 0...remainingStr.length){
            var c = remainingStr.charAt(i);
            if(c=="{")open++;else if(c=="}")open--;
        	if(open==0){
                mainEnd = i+1;
                break;
            }
        }

		return reg.matchedLeft()+remainingStr.substring(mainEnd, remainingStr.length);
	}

	static function GLSLGlobalToString(g:GLSLGlobal):String{
    	return	(g.storageQualifier != null ? g.storageQualifier : '')+' '+
    			(g.precision != null ? g.precision : '')+' '+
    			g.type+' '+
    			g.name+
    			(g.arraySize != null ? '['+g.arraySize+']' : '')+';';

    }


    //:todo: support multiple sets of brackets (eg: '(){}[]')
    //:todo: needs error handling!
    static function bracketExplode(src, brackets:String /* eg: "{}" */){
        if(brackets.length != 2) return null;

        var open = brackets.charAt(0), close = brackets.charAt(1);

        var root = new ScopeNode();
        //scope source
        var scopeStack = new Array<ScopeNode>();
        var currentScope = root;
        var currentNode:INode<Dynamic> = null;
        var c, level = 0;
        for(i in 0...src.length){
            c = src.charAt(i);
            if(c==open){
                level++;
                var newScope = new ScopeNode(brackets);
                currentScope.push(newScope);
                
                scopeStack.push(currentScope);             
                currentScope = newScope;
                
                currentNode = currentScope;
            }else if(c==close){
                level--;
                currentScope = scopeStack.pop();                
                currentNode = currentScope;
            }else{
                if(!Std.is(currentNode, StringNode)){
                    currentNode = new StringNode();
                    currentScope.push(currentNode);
                }
                
                cast(currentNode, StringNode).contents += c;
            }
        }
                    
        return root;
    }

}

private interface INode<T>{
    public var contents:T;
    public function toString():String;
}

private class StringNode implements INode<String>{
    public var contents:String;
    public function new(str:String = "")
        this.contents = str;

    public function toString()
        return contents;
}

private class ScopeNode implements INode<Array<INode<Dynamic>>>{
    public var contents:Array<INode<Dynamic>>;
    public var openBracket = "";
    public var closeBracket = "";
    public function new(?brackets:String){
        this.contents = new Array<INode<Dynamic>>();
        if(brackets != null){
            this.openBracket = brackets.charAt(0);
            this.closeBracket = brackets.charAt(1);
        }
    }

    public inline function push(v:INode<Dynamic>) return contents.push(v);

    public function toString(){
        var str:String = openBracket;
        for(n in contents)
            str += n.toString();
        return str + closeBracket;
    }
}