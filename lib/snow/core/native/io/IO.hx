package snow.core.native.io;

import haxe.io.Bytes;
import snow.api.File;
import snow.api.Libs;
import snow.types.Types;
import snow.api.Promise;
import snow.api.buffers.Uint8Array;
import snow.api.Debug.*;

import sys.FileSystem;
import haxe.io.Path;


/** This class is a low level cross platform IO helper.
    If you want file access, use `Assets` instead, unless really required. */
@:allow(snow.system.io.IO)
class IO implements snow.modules.interfaces.IO {

    var system:snow.system.io.IO;

    function new( _system:snow.system.io.IO ) system = _system;

//Public API

        /** Return the full path that the application is located */
    public function app_path() : String {

        return snow_app_path();

    } //app_path

         /** On platforms where this makes sense, get the application specific writeable data path.
             Uses the package from `SnowConfig`, passed through from flow projects or boot config. */
    public function app_path_prefs() : String {

        var _parts = system.app.snow_config.app_package.split('.');
        var _appname = _parts.pop();
        var _org = _parts.join('.');

        return snow_pref_path( _org, _appname );

    } //app_path_prefs

//Static public API functions specific to native/desktop.

    #if desktop


        /** Call this to add a directory to watch for file change notifications.
            This is for directories only. Children files + sub folders children files will notify of change.
            supports:`windows` `mac` `linux` only */
        public function watch_add( _path:String ) : Void {

            if(_path != null && _path.length > 0) {
                snow_io_add_watch( path_resolve(_path) );
            }

        } //watch_add

        /** Call this to remove a watched directory.
            supports:`windows` `mac` `linux` only */
        public function watch_remove( _path:String ) : Void {

            if(_path != null && _path.length > 0) {
                snow_io_remove_watch( path_resolve(_path) );
            }

        } //watch_remove

        //File dialogs, only available on platforms where it makes sense.

        /** Call this to open a native platform file open dialog.
            Returns a blank string if they cancel or any error occurs.
            supports: `windows` `mac` `linux` */
        public function dialog_open( ?_title:String = "Select file", ?_filters:Array<FileFilter> ) : String {

                //disallow null to the native code
            if(_filters == null) {
                _filters = [];
            }

            return snow_io_dialog_open( _title, _filters );

        } //dialog_open

            /** Call this to open a native platform file save dialog.
                Returns a blank string if they cancel or any error occurs.
                supports:`windows` `mac` `linux` */
        public function dialog_save( ?_title:String = "Save file", ?_filter:FileFilter ) : String {

                //sending as an array simplifies common
                //code on the native side, but a single extension
                //for a save dialog is logical, or no filter for all files.
            var _filters : Array<FileFilter> = [];

            if(_filter != null) {
                _filters.push(_filter);
            }

            return snow_io_dialog_save( _title, _filters );

        } //dialog_save

            /** Call this to open a native platform folder select dialog.
                Returns a blank string if they cancel or any error occurs.
                supports:`windows` `mac` `linux` */
        public function dialog_folder( ?_title:String = "Select folder" ) : String {

            return snow_io_dialog_folder( _title );

        } //dialog_folder

    #end // desktop


//API concrete Implementation

    //String load/save

            /** Returns the path where string_save operates.
                One targets where this is not a path, the path will be prefaced with `< >/`,
                i.e on web targets the path will be `<localstorage>/` followed by the ID. */
        public function string_save_path( _slot:Int = 0 ) : String {

            var _pref_path = app_path_prefs();
            var _path = haxe.io.Path.join([_pref_path, '${system.string_save_prefix}.$_slot']);

            return haxe.io.Path.normalize(_path);

        } //string_save_path

    //

            /** Opens the specified url in the default browser */
        public function url_open( _url:String ) {

            if(_url != null && _url.length > 0) {
                snow_io_url_open( _url );
            }

        } //url_open

    //Data

            /** Load bytes from the file path/url given.
                On web a request is sent for the data */
        public function data_load( _path:String, ?_options:IODataOptions ) : Promise {

            return new Promise(function(resolve, reject) {

                var _dest = _data_load(_path, _options);

                if(_dest == null) {
                    reject(Error.error('data_load file cannot be opened $_path'));
                    return;
                }

                resolve(_dest);

            });

        } //data_load

            /** Save bytes to the file path/url given. Overwrites the file without warning.
                Does not ensure the path (i.e doesn't check or create folders).
                On platforms where this doesn't make sense (web) this will do nothing atm */
        public function data_save( _path:String, _data:Uint8Array, ?_options:IODataOptions ) : Bool {

            var _binary = (_options != null && _options.binary);
            var _file = File.from_file(_path, _binary ? 'wb' : 'w' );

            if(_file != null) {
                var count : Int = _file.write( _data, _data.length, 1 );

                    _file.close();

                return count == 1;
            }

            return false;

        } //data_save

//Internal API

    function init() {}
    function update() {}
    function destroy() {}
    function on_event( _event:SystemEvent ) {}

//Internal

    inline function string_slot_destroy( _slot:Int = 0 ) : Bool {

        var _path = string_save_path(_slot);
        var _result = true;

        _debug('remove string slot $_slot from path $_path');

        try {
            sys.FileSystem.deleteFile(_path);
        } catch(e:Dynamic) {
            _result = false;
        }

        return _result;

    } //string_slot_destroy

        //flush the string map to disk
    inline function string_slot_save( _slot:Int = 0, _contents:String ) : Bool {

        var _path = string_save_path(_slot);
        var _data = Uint8Array.fromBytes( Bytes.ofString(_contents) );

        return data_save(_path, _data);

    } //string_slot_save

        //get the string contents of this slot,
        //or null if not found/doesn't exist
    inline function string_slot_load( _slot:Int = 0 ) : String {

        var _data = _data_load(string_save_path(_slot));

        if(_data == null) {
            return null;
        }

        return _data.toBytes().toString();

    } //string_slot_load

    inline function string_slot_encode( _string:String ) : String {
        assertnull(_string);
        var _bytes = haxe.io.Bytes.ofString(_string);
        return haxe.crypto.Base64.encode(_bytes);
    }

    inline function string_slot_decode( _string:String ) : String {
        assertnull(_string);
        var _bytes = haxe.crypto.Base64.decode(_string);
        return _bytes.toString();
    }

        //The data load implementation
    function _data_load( _path:String, ?_options:IODataOptions ) : Uint8Array {

        var _binary = (_options != null && _options.binary);
        var _file = File.from_file(_path, _binary ? 'rb' : 'r' );

        if(_file == null) return null;

            //jump to the end, measure size
        _file.seek(0, FileSeek.end);

        var size = _file.tell();

            //reset to beginning
        _file.seek(0, FileSeek.set);

            //create a buffer to read to
        var _dest = new Uint8Array(size);
        var _read = _file.read(_dest, _dest.length, 1);

            //close+release the file handle
        _file.close();

        return _dest;

    } //_data_load


        // :temp: feature from newer version of haxe std
    static function isAbsolute ( path : String ) : Bool {
        if (StringTools.startsWith(path, '/')) return true;
        if (path.charAt(2) == ':') return true;
        return false;
    }

        //convert a path to absolute (if needed) and normalize, remove slash, etc
    static function path_resolve( _path:String ) {

        if(!isAbsolute(_path)) {
            _path = FileSystem.fullPath(_path);
        }

        _path = Path.normalize(_path);
        _path = Path.removeTrailingSlashes(_path);

        return _path;

    } //path_resolve

//Bindings


    static var snow_io_url_open         = Libs.load( "snow", "snow_io_url_open", 1 );
    static var snow_app_path            = Libs.load( "snow", "snow_app_path", 0 );
    static var snow_pref_path           = Libs.load( "snow", "snow_pref_path", 2 );

    #if desktop

        static var snow_io_add_watch        = Libs.load( "snow", "snow_io_add_watch", 1 );
        static var snow_io_remove_watch     = Libs.load( "snow", "snow_io_remove_watch", 1 );

        static var snow_io_dialog_open      = Libs.load( "snow", "snow_io_dialog_open", 2 );
        static var snow_io_dialog_save      = Libs.load( "snow", "snow_io_dialog_save", 2 );
        static var snow_io_dialog_folder    = Libs.load( "snow", "snow_io_dialog_folder", 1 );

    #end //desktop

} //IO

