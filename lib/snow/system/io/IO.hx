package snow.system.io;

import snow.Snow;
import snow.types.Types;
import snow.api.buffers.Uint8Array;
import snow.api.Promise;
import snow.api.Debug.*;

#if (!macro && !display && !scribe)
    private typedef IOModule = haxe.macro.MacroType<[snow.system.module.Module.assign('IO')]>;
#end

@:allow(snow.Snow)
class IO {


    @:noCompletion public var app : Snow;

    /** Access to the platform specific api, if any */
    public var module : snow.system.module.IO;

    /** The string_save file name prefix. For example, the default being `slot.0`,
        by changing this you can rename the save slots to `custom.0`.
        Only the prefix will change, the slot index is always appended with `.` for predictability. */
    public var string_save_prefix : String = 'slot';

        /** Constructed internally, use `app.io` */
    @:allow(snow.Snow)
    function new( _app:Snow ) {

        app = _app;

        module = new snow.system.module.IO(this);

        module.init();

    } //new

        /** Call this to open a url in the default browser */
    public inline function url_open( _url:String ) {

        module.url_open(_url);

    } //url_open

        /** Load bytes from the file path/url given.
            On web a request is sent for the data */
    public inline function data_load( _path:String, ?_options:IODataOptions ) : Promise {

        return module.data_load( _path, _options );

    } //data_load


        /** Save bytes to the file path/url given.
            On platforms where this doesn't make sense (web) this will do nothing atm */
    public inline function data_save( _path:String, _data:Uint8Array, ?_options:IODataOptions ) : Bool {

        return module.data_save( _path, _data, _options );

    } //data_save

        /** Returns a promise for data, optionally provided by the given provider, and optionally processed by the given processor. */
    public function data_flow<T>( _id:String, ?_processor:Snow->String->T->Promise, ?_provider:Snow->String->Promise ) : Promise {

        if(_provider == null) _provider = default_provider;

        return new Promise(function(resolve, reject) {

            _provider(app, _id).then(

                function(data) {
                    if(_processor != null) {
                        _processor(app, _id, data).then(resolve, reject);
                    } else {
                        resolve(data);
                    }
                }

            ).error(reject);

        }); //promise

    } //data_flow

        /** The string slot <-> key:value pairs,
            for the string sync API. */
    var string_slots: Map<Int, Map<String, String> >;

        /** Returns the path where string_save operates.
            One targets where this is not a path, the path will be prefaced with `< >/`,
            i.e on web targets the path will be `<localstorage>/` followed by the ID. */
    public function string_save_path( _slot:Int = 0 ) : String {

        return module.string_save_path(_slot);

    } //string_save_path

        //:todo: clear() and remove()

        /** Save a string value by key, with an optional slot.
            To remove a saved key, pass value in as null.
            Works on all targets as a simple save/load mechanism.
            Data saved is plain text but obscured with basic encoding.
            Any further obfuscation can be done on the value prior to saving.
            Returns false if the save failed, errors being logged. */
    public function string_save( _key:String, _value:String, _slot:Int = 0 ) : Bool {

        var _string_map = string_slots_sync(_slot);

        var _encoded_key = module.string_slot_encode(_key);

            //if the value is null, we remove the key
        if(_value == null) {

            _debug('removing key $_key ($_encoded_key)');

            _string_map.remove(_encoded_key);

        } else {

            var _encoded_value = module.string_slot_encode(_value);

            _debug('storing key $_key:$_value as $_encoded_key:$_encoded_value');

            _string_map.set(_encoded_key, _encoded_value);

        }

        var _contents = haxe.Serializer.run(_string_map);
            _contents = module.string_slot_encode(_contents);

        return module.string_slot_save(_slot, _contents);

    } //string_save

        /** Load a string value by key, with an optional slot.
            Works on all targets as a simple save/load mechanism.
            Returns the string or null if the key was invalid, or the slot was not found. */
    public function string_load( _key:String, _slot:Int = 0 ) : String {

        var _string_map = string_slots_sync(_slot);

        var _encoded_key = module.string_slot_encode(_key);
        var _encoded_value = _string_map.get(_encoded_key);

        _debug('reading `$_key` as $_encoded_key:$_encoded_value');

        if(_encoded_value == null) {
            return null;
        }

        return module.string_slot_decode(_encoded_value);

    } //string_load

        /** Destroy a specific string slot, removing all values stored.
            Does not ask for confirmation. Returns true if successful, false otherwise. */
    public function string_destroy(_slot:Int = 0) : Bool {

        if(string_slots == null) {
            string_slots = new Map();
        } else {
            string_slots.remove(_slot);
        }

        return module.string_slot_destroy(_slot);

    } //string_destroy

//Internal string load/save

        //check if the string map exists yet,
        //if not, try to load it,
        //if it doesn't exist yet, make it.
        //returns a valid map for the slot
    inline function string_slots_sync( _slot:Int = 0 ) {

        //not loaded yet?
        if(string_slots == null) {
            string_slots = new Map();
        }

        var _string_map = string_slots.get(_slot);

        if(_string_map == null) {

            var _string = module.string_slot_load(_slot);
            if(_string == null) {
                _string_map = new Map();
            } else {
                _string = module.string_slot_decode(_string);
                _string_map = haxe.Unserializer.run(_string);
            }

            string_slots.set(_slot, _string_map);

        }

        return _string_map;

    } //string_slots_sync

//Internal

        /** The default data flow provider */
    inline function default_provider(_app:Snow, _id:String) return data_load(_id);

        /** Called by Snow when a system event happens. */
    inline function on_event( _event:SystemEvent ) {

        module.on_event( _event );

    } //on_event

        /** Called by Snow, update any IO related processing */
    inline function update() {

        module.update();

    } //update

        /** Called by Snow, cleans up IO */
    inline function destroy() {

        module.destroy();

    } //destroy


} //IO
