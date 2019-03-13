package snow.modules.interfaces;

import snow.types.Types;
import snow.api.buffers.Uint8Array;
import snow.api.Promise;

@:noCompletion
@:allow(snow.system.io.IO)
interface Assets {

    private function init():Void;
    private function update():Void;
    private function destroy():Void;
    private function on_event( event:SystemEvent ):Void;

//image

        /** Image info load from file path. Use `app.assets`. Returns a promise for ImageInfo */
    function image_load_info( _path:String, ?_components:Int = 4 ) : Promise;
        /** Create an image info from image bytes. Use `app.assets` */
    function image_info_from_bytes( _path:String, _bytes:Uint8Array, ?_components:Int = 4 ) : Promise;
        /** Create an image info from raw (already decoded) image pixels. */
    function image_info_from_pixels( _id:String, _width:Int, _height:Int, _pixels:Uint8Array ) : ImageInfo;

} //Assets
