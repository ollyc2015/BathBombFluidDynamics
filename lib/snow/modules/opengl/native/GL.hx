package snow.modules.opengl.native;

import snow.api.buffers.ArrayBufferView;
import snow.api.buffers.Float32Array;
import snow.api.buffers.Int32Array;

typedef GLActiveInfo = {

    size : Int,
    type : Int,
    name : String

} //GLActiveInfo


typedef GLShaderPrecisionFormat = {

    rangeMin : Int,
    rangeMax : Int,
    precision : Int,

} //GLShaderPrecisionFormat

typedef GLContextAttributes = {

    alpha:Bool,
    depth:Bool,
    stencil:Bool,
    antialias:Bool,
    premultipliedAlpha:Bool,
    preserveDrawingBuffer:Bool

} //GLContextAttributes


class GLObject {
        /** The native GL handle/id. read only */
    public var id (default, null) : Int;
        /** The invalidated state. read only */
    public var invalidated (default,set) : Bool;
    public function new( id:Int ) this.id = id;
    function toString() : String return 'GLObject($id)';
    function set_invalidated( value:Bool ) : Bool {
        id = -1; return invalidated = value;
    } //set_invalidated
}

abstract GLUniformLocation(Null<Int>) from Null<Int> to Null<Int> {}

@:noCompletion class GLBO extends GLObject { override function toString() return 'GLBuffer($id)'; }
@:noCompletion class GLFBO extends GLObject { override function toString() return 'GLFramebuffer($id)'; }
@:noCompletion class GLRBO extends GLObject { override function toString() return 'GLRenderbuffer($id)'; }
@:noCompletion class GLSO extends GLObject { override function toString() return 'GLShader($id)'; }
@:noCompletion class GLTO extends GLObject { override function toString() return 'GLTexture($id)'; }
@:noCompletion class GLPO extends GLObject {
    public var shaders : Array<GLShader>;
    public function new( id:Int ) { super( id ); shaders = []; } //new
    override function toString() return 'GLProgram($id)';
}

abstract GLBuffer(GLBO) {
    public var id (get,never):Int;
    public var invalidated (get,set):Bool;
    inline public function new(_id:Int) this = new GLBO(_id);
    inline function get_id() return this.id;
    inline function get_invalidated() return this.invalidated;
    inline function set_invalidated(_invalidated:Bool) return this.invalidated = _invalidated;
    @:to inline public function toInt() : Int return this.id;
    @:to inline public function toDynamic() : Dynamic return this.id;
    @:to inline public function toNullInt() : Null<Int> return this.id;
    @:from inline static public function fromInt(_id:Int) return new GLBuffer(_id);
    @:from inline static public function fromDynamic(_id:Dynamic) return new GLBuffer(Std.int(_id));
}

abstract GLFramebuffer(GLFBO) {
    public var id (get,never) : Int;
    public var invalidated (get,set) : Bool;
    inline public function new(_id:Int) this = new GLFBO(_id);
    inline function get_id() return this.id;
    inline function get_invalidated() return this.invalidated;
    inline function set_invalidated(_invalidated:Bool) return this.invalidated = _invalidated;
    @:to inline public function toInt() : Int return this.id;
    @:to inline public function toDynamic() : Dynamic return this.id;
    @:to inline public function toNullInt() : Null<Int> return this.id;
    @:from inline static public function fromInt(_id:Int) return new GLFramebuffer(_id);
    @:from inline static public function fromDynamic(_id:Dynamic) return new GLFramebuffer(Std.int(_id));
} //GLFramebuffer

abstract GLRenderbuffer(GLRBO) {
    public var id (get,never) : Int;
    public var invalidated (get,set) : Bool;
    inline public function new(_id:Int) this = new GLRBO(_id);
    inline function get_id() return this.id;
    inline function get_invalidated() return this.invalidated;
    inline function set_invalidated(_invalidated:Bool) return this.invalidated = _invalidated;
    @:to inline public function toInt() : Int return this.id;
    @:to inline public function toDynamic() : Dynamic return this.id;
    @:to inline public function toNullInt() : Null<Int> return this.id;
    @:from inline static public function fromInt(_id:Int) return new GLRenderbuffer(_id);
    @:from inline static public function fromDynamic(_id:Dynamic) return new GLRenderbuffer(Std.int(_id));
} //GLRenderbuffer


abstract GLTexture(GLTO) {
    public var id (get,never):Int;
    public var invalidated (get,set):Bool;
    inline public function new(_id:Int) this = new GLTO(_id);
    inline function get_id() return this.id;
    inline function get_invalidated() return this.invalidated;
    inline function set_invalidated(_invalidated:Bool) return this.invalidated = _invalidated;
    @:to inline public function toInt() : Int return this.id;
    @:to inline public function toDynamic() : Dynamic return this.id;
    @:to inline public function toNullInt() : Null<Int> return this.id;
    @:from inline static public function fromInt(_id:Int) return new GLTexture(_id);
    @:from inline static public function fromDynamic(_id:Dynamic) return new GLTexture(Std.int(_id));
}

abstract GLShader(GLSO) {
    public var id (get,never):Int;
    public var invalidated (get,set):Bool;
    inline public function new(_id:Int) this = new GLSO(_id);
    inline function get_id() return this.id;
    inline function get_invalidated() return this.invalidated;
    inline function set_invalidated(_invalidated:Bool) return this.invalidated = _invalidated;
    @:to inline public function toInt() : Int return this.id;
    @:to inline public function toDynamic() : Dynamic return this.id;
    @:to inline public function toNullInt() : Null<Int> return this.id;
    @:from inline static public function fromInt(_id:Int) return new GLShader(_id);
    @:from inline static public function fromDynamic(_id:Dynamic) return new GLShader(Std.int(_id));
}

@:forward(shaders)
abstract GLProgram(GLPO) {
    public var id (get,never):Int;
    public var invalidated (get,set):Bool;
    inline public function new(_id:Int) this = new GLPO(_id);
    inline function get_id() return this.id;
    inline function get_invalidated() return this.invalidated;
    inline function set_invalidated(_invalidated:Bool) return this.invalidated = _invalidated;
    @:to inline public function toInt() : Int return this.id;
    @:to inline public function toDynamic() : Dynamic return this.id;
    @:to inline public function toNullInt() : Null<Int> return this.id;
    @:from inline static public function fromInt(_id:Int) return new GLProgram(_id);
    @:from inline static public function fromDynamic(_id:Dynamic) return new GLProgram(Std.int(_id));
}

#if snow_render_gl_native
    typedef GL = snow.modules.opengl.native.GL_Native;
#else
    typedef GL = snow.modules.opengl.native.GL_FFI;
#end
