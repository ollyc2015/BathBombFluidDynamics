package snow.core.web.io;

#if snow_web

import snow.types.Types;
import snow.api.buffers.Uint8Array;
import snow.api.Promise;
import snow.api.Debug.*;


@:allow(snow.system.io.IO)
class IO implements snow.modules.interfaces.IO {

    var system : snow.system.io.IO;

    function new( _system:snow.system.io.IO ) system = _system;

//Public API

    public function url_open( _url:String ) {

        if(_url != null && _url.length > 0) {
            js.Browser.window.open(_url, '_blank');
        }

    } //url_open

        /** Load bytes from the file path/url given.
            On web a request is sent for the data */
    public function data_load( _path:String, ?_options:IODataOptions ) : Promise {

        return new Promise(function(resolve,reject) {

                //defaults
            var _async = true;
            var _binary = true;

            if(_options != null) {
                if(_options.binary != null) _binary = _options.binary;
            }

            var request = new js.html.XMLHttpRequest();
                request.open("GET", _path, _async);

            if(_binary) {
                request.overrideMimeType('text/plain; charset=x-user-defined');
            } else {
                request.overrideMimeType('text/plain; charset=UTF-8');
            }

                //only _async can set the type it seems
            if(_async) {
                #if (haxe_ver < 3.2)
                    request.responseType = 'arraybuffer';
                #else
                    request.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER;
                #end
            }

            request.onload = function(data) {

                if(request.status == 200) {
                    resolve( new Uint8Array(request.response) );
                } else {
                    reject(Error.error('request status was ${request.status} / ${request.statusText}'));
                }

            } //onload

            request.send();

        });

    } //data_load

    public function data_save( _path:String, _data:Uint8Array, ?_options:IODataOptions ) : Bool {

        return false;

    } //data_save


        /** Returns the path where string_save operates.
            One targets where this is not a path, the path will be prefaced with `< >/`,
            i.e on web targets the path will be `<localstorage>/` followed by the ID. */
    public function string_save_path( _slot:Int = 0 ) : String {

        var _pref_path = '<localstorage>';
        var _slot_path = string_slot_id(_slot);
        var _path = haxe.io.Path.join([_pref_path, _slot_path]);

        return haxe.io.Path.normalize(_path);

    } //string_save_path

//Internal API

    function init() {}
    function update() {}
    function destroy() {}
    function on_event( _event:SystemEvent ) {}

    inline function string_slot_id(_slot:Int = 0) {
        var _parts = system.app.snow_config.app_package.split('.');
        var _appname = _parts.pop();
        var _org = _parts.join('.');

        return '$_org/$_appname/${system.string_save_prefix}.$_slot';
    }

    inline function string_slot_destroy( _slot:Int = 0 ) : Bool {

        var storage = js.Browser.window.localStorage;
        if(storage == null) {
            log('localStorage isnt supported in this browser?!');
            return false;
        }

        var _id = string_slot_id(_slot);

        storage.removeItem(_id);

        return false;

    } //string_slot_destroy

        //flush the string map to disk
    inline function string_slot_save( _slot:Int = 0, _contents:String ) : Bool {

        var storage = js.Browser.window.localStorage;
        if(storage == null) {
            log('localStorage isnt supported in this browser?!');
            return false;
        }

        var _id = string_slot_id(_slot);

        storage.setItem(_id, _contents);

        return true;

    } //string_slot_save

        //get the string contents of this slot,
        //or null if not found/doesn't exist
    inline function string_slot_load( _slot:Int = 0 ) : String {

        var storage = js.Browser.window.localStorage;
        if(storage == null) {
            log('localStorage isnt supported in this browser?!');
            return null;
        }

        var _id = string_slot_id(_slot);

        return storage.getItem(_id);

    } //string_slot_load

    inline function string_slot_encode( _string:String ) : String {
        return js.Browser.window.btoa(_string);
    }

    inline function string_slot_decode( _string:String ) : String {
        return js.Browser.window.atob(_string);
    }


} //IO

#end //snow_web
