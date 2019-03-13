package snow.modules.interfaces;

import snow.api.buffers.Uint8Array;
import snow.api.Promise;
import snow.system.audio.Sound;
import snow.types.Types;

@:noCompletion
@:allow(snow.system.audio.Audio)
interface Audio {

    private function init():Void;
    private function update():Void;
    private function destroy():Void;
    private function on_event( event:SystemEvent ):Void;

    function create_sound( _id:String, _name:String, _streaming:Bool=false, ?_format:AudioFormatType ) : Promise;
    function create_sound_from_bytes( _name:String, _bytes:Uint8Array, _format:AudioFormatType ):Sound;

    function suspend():Void;
    function resume():Void;

} //Input