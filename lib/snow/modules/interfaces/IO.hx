package snow.modules.interfaces;

import snow.types.Types;
import snow.api.Promise;
import snow.api.buffers.Uint8Array;

@:noCompletion
@:allow(snow.system.io.IO)
interface IO {

    private function init():Void;
    private function update():Void;
    private function destroy():Void;
    private function on_event( event:SystemEvent ):Void;

    function url_open( _url:String ):Void;
    function data_load( _path:String, ?_options:IODataOptions ) : Promise;
    function data_save( _path:String, _data:Uint8Array, ?_options:IODataOptions ) : Bool;

} //IO