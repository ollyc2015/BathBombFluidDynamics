package snow.system.module;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;

@:noCompletion class Module {

    //module -> type package
    static var modules:Map<String, { type:String, module:Type }> = new Map();

    macro public function set( module:String, type:String ) {

        modules.set(module, { type:type, module:null });

        return macro null;

    } //set


    static function get_typepath(t:BaseType, params:Array<TypeParam>):TypePath {
        return {
            pack:t.pack,
            name:t.module.substring(t.module.lastIndexOf(".")+1),
            sub:t.name,
            params:params
        }
    }

    static function get_module_type(module:String) : Type {

        var error_str = 'Error getting module `$module` ';
        var info = modules.get(module);

            //Don't allow setting twice, for now
        if(info.module != null) {
            var existing_name = TypeTools.toString(info.module);
            Context.fatalError('$error_str : already assigned $module to $existing_name', Context.currentPos());
        }

        var types = Context.getModule(info.type);
            types = types.map(function(t){
                return Context.follow(t);
            });

        var typelist:Array<haxe.macro.TypeDefinition> = [];
        for(source in types) {
            switch(Context.follow(source)) {
                case TInst(tinst,tparams):
                    var t = tinst.get();
                    if(!t.isPrivate) {
                        var params = [for (p in tparams) TPType(Context.toComplexType(p))];
                        typelist.push({
                            pos: Context.makePosition({ min:0, max:0, file:t.module }),
                            pack: t.pack,
                            name: t.name,
                            kind: TDAlias( TPath(get_typepath(t, params)) ),
                            fields: []
                        });
                    }
                case TType(t,params):
                case TAbstract(t,params):
                case TEnum(t,params):
                case _:
            }
        }

        var modulepath = 'snow.system.module.'+module;
        Context.defineModule(modulepath, typelist);

            //make sure it's updated
        info.module = Context.getType(info.type);
        info.module = Context.follow(info.module);
        modules.set(module, info);

        return info.module;
    }

    macro public function assign(module:String) : Type {

        #if !display

            var not_found_err = 'No module has been set for $module!';

            if(!modules.exists(module)) {
                Context.fatalError(not_found_err, Context.currentPos());
            }

            return get_module_type(module);

        #else

            return null;

        #end

    } //get

}


#end