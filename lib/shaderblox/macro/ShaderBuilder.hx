package shaderblox.macro;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.TypePath;
import haxe.macro.Type.ClassType;
import haxe.rtti.Meta;

import shaderblox.macro.MacroTools;
import shaderblox.glsl.GLSLTools;
import shaderblox.glsl.GLSLTools.GLSLGlobal;

using Lambda;

/**
 * ...
 * @author Andreas Rønning
 */
private typedef FieldDef = {index:Null<Int>, typeName:String, fieldName:String, extrainfo:Dynamic };
private typedef AttribDef = {index:Int, typeName:String, fieldName:String, itemCount:Int };
private enum SourceKind{
	Frag;
	Vert;
}
class ShaderBuilder
{
	#if macro
	
	static var uniformFields:Array<FieldDef>;
	static var attributeFields:Array<AttribDef>;	
	static var vertSource = "";
	static var fragSource = "";

	static inline var GL_FLOAT:Int = 0x1406;
	static inline var GL_INT:Int = 0x1404;

	static function getSources(type:ClassType):Array<String> {
		var meta = type.meta.get();
		var out = [];
		var str:String;
		for (i in meta.array()) {
			switch(i.name) {
				case ":vert":
					str = MacroTools.getString(i.params[0]);
					str = pragmas(GLSLTools.unifyLineEndings(str));
					out[0] = str;
				case ":frag":
					str = MacroTools.getString(i.params[0]);
					str = pragmas(GLSLTools.unifyLineEndings(str));
					out[1] = str;
			}
		}
		return out;
	}
	
	public static function build():Array<Field> {
		var type = Context.getLocalClass().get();

		//handle build-metas
		for (f in type.meta.get().array()) {
			if (f.name == ":shaderNoBuild") return null;
		}
		
		uniformFields = [];
		attributeFields = [];

		var position = Context.currentPos();

		//get current class sources, taking care of overriding main()
		var localSources:Array<String> = getSources(Context.getLocalClass().get());
		var localVertSource = localSources[0];
		var localFragSource = localSources[1];
		
		// -- Process Sources --
		#if debug
		trace("Building " + Context.getLocalClass());
		#end
		var sources:Array<Array<String>> = [];
		
		//get super class sources
		var t2 = type;
		while (t2.superClass != null) {
			t2 = t2.superClass.t.get();
			if (t2.superClass != null) {
				#if debug
				trace("\tIncluding: " + t2.name);
				#end
				sources.unshift(getSources(t2));
			}
		}

		//add local sources after super class so as to override anything beneath
		sources.push(localSources);

		//strip comments from sources
		for (i in 0...sources.length) {
			var s = sources[i];
			if(s[0]==null)s[0]="";
			if(s[1]==null)s[1]="";
			s[0] = GLSLTools.stripComments(s[0]);
			s[1] = GLSLTools.stripComments(s[1]);
		}

		//find highest level class with main
		var highestMainVert:Int = -1;
		var highestMainFrag:Int = -1;
		for (i in 0...sources.length) {
			var s = sources[i];
			if(GLSLTools.hasMain(s[0]))
				highestMainVert = i;

			if(GLSLTools.hasMain(s[1]))
				highestMainFrag = i;
		}

		//strip main from source if not highest
		for (i in 0...sources.length) {
			var s = sources[i];

			if(i<highestMainVert)
				s[0] = GLSLTools.stripMain(s[0]);
			if(i<highestMainFrag)
				s[1] = GLSLTools.stripMain(s[1]);
		}

		// -- Assemble complete source --
		vertSource = "";
		fragSource = "";

		var defaultESPrecision = "
#ifdef GL_ES
precision highp float;
precision highp sampler2D;
#endif\n";
		vertSource += defaultESPrecision;
		fragSource += defaultESPrecision;

		for(i in 0...sources.length){
			var s = sources[i];
			vertSource += "\n"+s[0]+"\n";
			fragSource += "\n"+s[1]+"\n";
		}

		// -- Add assembled glsl strings to class as fields --
		var fields = Context.getBuildFields();

		// -- Add fields to class from local glsl --
		buildAttributes(position, fields, localVertSource);
		buildUniforms(position, fields, localVertSource, localFragSource);
		buildConsts(position, fields, localVertSource, localFragSource);

		//override initSources() and createProperties()
		buildOverrides(fields);

		var finalFields = buildFieldInitializers(fields);
		return finalFields;
	}

	static function buildAttributes(position, fields:Array<Field>, vertSource:String) {
		var attributes = GLSLTools.extractGlobals(vertSource, ['attribute']);
		for(a in attributes)
			buildAttribute(position, fields, a);
	}

	static function buildUniforms(position, fields:Array<Field>, vertSource:String, fragSource:String) {
		var vuniforms = GLSLTools.extractGlobals(vertSource, ['uniform']);
		var funiforms = GLSLTools.extractGlobals(fragSource, ['uniform']);
		for(u in vuniforms) buildUniform(position, fields, u);
		for(u in funiforms) buildUniform(position, fields, u);
	}

	static function buildConsts(position, fields:Array<Field>, vertSource:String, fragSource:String){
		var vconsts = GLSLTools.extractGlobals(vertSource, ['const']);
		var fconsts = GLSLTools.extractGlobals(fragSource, ['const']);
		for(c in vconsts) buildConst(position, fields, c, Vert);
		for(c in fconsts) buildConst(position, fields, c, Frag);
	}
	
	static function buildAttribute(position, fields, attribute:GLSLGlobal):Void {
		//Avoid field redefinitions
		if (MacroTools.checkIfFieldDefined(attribute.name)) return;
		
		for (existing in attributeFields) {
			if (existing.fieldName == attribute.name) return; 
		}
		var pack = ["shaderblox", "attributes"];
		var itemCount:Int = 0;
		var itemType:Int = -1;
		switch(attribute.type) {
			case "float":
				itemCount = 1;
				itemType = GL_FLOAT;
			case "vec2":
				itemCount = 2;
				itemType = GL_FLOAT;
			case "vec3":
				itemCount = 3;
				itemType = GL_FLOAT;
			case "vec4":
				itemCount = 4;
				itemType = GL_FLOAT;
			default:
				throw "Unknown attribute type: " + attribute.type;
		}
		var attribClassName:String = switch(itemType) {
			case GL_FLOAT:
				"FloatAttribute";
			default:
				throw "Unknown attribute type: " + itemType;
		}
		var type = { pack : pack, name : attribClassName, params : [], sub : null };
		var fld = {
				name : attribute.name, 
				doc : null, 
				meta : [], 
				access : [APublic], 
				kind : FVar(TPath(type), null), 
				pos : position 
			};
		fields.push(fld);
		var f = { index:attributeFields.length, fieldName: fld.name, typeName:pack.join(".") + "." + attribClassName, itemCount:itemCount };
		attributeFields.push(f);
	}

	static function buildUniform(position, fields, uniform:GLSLGlobal) {
		if (MacroTools.checkIfFieldDefined(uniform.name)) return;
		
		for (existing in uniformFields) {
			if (existing.fieldName == uniform.name) return; 
		}

		var pack = ["shaderblox", "uniforms"];
		var type = { pack : pack, name : "UMatrix", params : [], sub : null };
		var extrainfo:Dynamic = null;
		switch(uniform.type) {
			case "samplerCube":
				type.name = "UTexture";
				extrainfo = true;
			case "sampler2D":
				type.name = "UTexture";
				extrainfo = false;
			case "mat4":
				type.name = "UMatrix";
			case "bool":
				type.name = "UBool";
			case "int":
				type.name = "UInt";
			case "float":
				type.name = "UFloat";
			case "vec2":
				type.name = "UVec2";
			case "vec3":
				type.name = "UVec3";
			case "vec4":
				type.name = "UVec4";
			default:
				throw "Unknown uniform type: " + uniform.type;
		}
		var f = {
				name : uniform.name, 
				doc : null, 
				meta : [], 
				access : [APublic], 
				kind : FVar(TPath(type), null), 
				pos : position 
			};
		fields.push(f);
		uniformFields.push( 
			{index:#if !js -1 #else null #end, fieldName: f.name, typeName:pack.join(".") + "." + type.name, extrainfo:extrainfo } 
		);
	}

	static function buildConst(position, fields:Array<Field>,  const:GLSLGlobal, sourceKind:SourceKind){
		if (MacroTools.checkIfFieldDefined(const.name)) return;
		
		//when field changes, the shader should update const value and recompile
		//public var (CONSTANT):Dynamic = (value);
		var constField = {
			name: const.name,
			doc: null,
			meta: [],
			access: [APublic],
			kind: FProp("default","set",macro : Dynamic, null),
			pos: Context.currentPos()
		}

		//public var set_(CONSTANT) (value:Dynamic){ // sets constant value, calls update shader }
		var constName = const.name;
		var constSetterExpr:Expr;
		switch(sourceKind){
			case Vert:
				constSetterExpr = macro {
					this.$constName = value;
					this._vertSource = shaderblox.glsl.GLSLTools.injectConstValue(this._vertSource, $v{const.name}, value);
					if(this._ready) this.destroy();
					return value;
				}
			case Frag:
				constSetterExpr = macro {
					this.$constName = value;
					this._fragSource = shaderblox.glsl.GLSLTools.injectConstValue(this._fragSource, $v{const.name}, value);
					if(this._ready) this.destroy();
					return value;
				}
		}
		var constSetter = {
			name: "set_"+const.name,
			doc: null,
			meta: [],
			access: [APrivate],
			kind: FFun({
					args:[{
							name: 'value',
							type: macro : Dynamic,
							opt: null,
							value: null
					}],
					params:[],
					ret: null,
					expr: constSetterExpr
				}),
			pos: Context.currentPos()
		}

		fields.push(constField);
		fields.push(constSetter);
	}

	static function buildOverrides(fields:Array<Field>){		
		var createPropertiesFunc = {
			name : "createProperties", 
			doc : null, 
			meta : [], 
			access : [AOverride, APrivate], 
			kind : FFun( { args:[], params:[], ret:null, expr:macro { super.createProperties(); }} ),
			pos : Context.currentPos() 
		};
		fields.push(createPropertiesFunc);

		var initSourcesFunc = {
			name : "initSources", 
			doc : null, 
			meta : [], 
			access : [AOverride, APublic], 
			kind : FFun( { args:[], params:[], ret:null, expr:macro {
						this._vertSource = $v{vertSource};
						this._fragSource = $v{fragSource};
					}
			} ),
			pos : Context.currentPos() 
		};
		fields.push(initSourcesFunc);
	}
	
	static function buildFieldInitializers(allFields:Array<Field>){
		for (f in allFields) {
			switch(f.name) {
				case "createProperties":
					switch(f.kind) {
						case FFun(func):
							switch(func.expr.expr) {
								case EBlock(exprs):
									//Populate our variables
									//Create an array of uniforms
										
									//uniforms
									for (uni in uniformFields) {
										var fieldName:String = uni.fieldName;

										var typePathArray = uni.typeName.split(".");
										var typeName = typePathArray.pop();

										var typePath:TypePath = {
											name: typeName,
											pack: typePathArray
										}

										if (typeName == "UTexture"){
											exprs.push(
												macro {
													var instance = new $typePath($v{ uni.fieldName }, null, $v{ uni.extrainfo });
													this.$fieldName = instance;
													_uniforms.push(instance);
												}
											);
										}else {
											exprs.push(
												macro {
													var instance = new $typePath($v{ uni.fieldName }, null);
													this.$fieldName = instance;
													_uniforms.push(instance);
												}
											);
										}
									}

									//attributes
									var stride:Int = 0;
									for (att in attributeFields) {
										var fieldName:String = att.fieldName;

										var typePathArray = att.typeName.split(".");
										var typeName = typePathArray.pop();

										var typePath:TypePath = {
											name: typeName,
											pack: typePathArray
										}

										var name:String = att.fieldName;
										var numItems:Int = att.itemCount;
										stride += numItems * 4;
										exprs.push(
											macro {
												var instance = new $typePath($v { att.fieldName }, $v { att.index }, $v { numItems });
												this.$fieldName = instance;
												_attributes.push(instance);
											}
										);
									}
									exprs.push(
										macro {
											_aStride += $v { stride };
										}
									);
								default:
							}
						default:
					}
			}
		}
		
		uniformFields = null;
		attributeFields = null;
		return allFields;
	}

	static function pragmas(src:String):String {
		var lines = src.split("\n");
		var found:Bool = true;
		for (i in 0...lines.length) {
			var l = lines[i];
			if (l.indexOf("#pragma include") > -1) {
				var info = l.substring(l.indexOf('"') + 1, l.lastIndexOf('"'));
				lines[i] = pragmas(sys.io.File.getContent(info));
			}
		}
		return lines.join("\n");
	}
	#end
}