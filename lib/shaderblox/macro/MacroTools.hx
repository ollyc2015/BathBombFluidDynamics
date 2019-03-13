package shaderblox.macro;

import haxe.macro.Context;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.ClassType;
import haxe.macro.Type.Ref;
import haxe.macro.Expr;


class MacroTools{
    #if macro
    static public function getClassField(name:String):ClassField{
        var type:ClassType = Context.getLocalClass().get();
        while(type != null){
            for(f in type.fields.get())
                if(f.name == name) return f;
            //try superclass
            type = type.superClass != null ? type.superClass.t.get() : null;
        }
        return null;
    }
    
    static public function checkIfFieldDefined(name:String):Bool {
        return getClassField(name) != null;
    }

    static public function getString(e:Expr):String {
        switch( e.expr ) {
            case EConst(c):
                switch( c ) {
                    case CString(s): return s;
                    case _:
                }
            case EField(e, f):  
            case _:
        }
        throw("No const");
    }
    #end
}