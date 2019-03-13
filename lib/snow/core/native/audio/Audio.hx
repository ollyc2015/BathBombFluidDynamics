package snow.core.native.audio;

import snow.types.Types;
import snow.api.buffers.Uint8Array;
import snow.api.Promise;

@:allow(snow.system.audio.Audio)
class Audio implements snow.modules.interfaces.Audio {

    var system : snow.system.audio.Audio;

    function new( _system:snow.system.audio.Audio ) system = _system;

    function init() {}
    function update() {}
    function destroy() {}
    function on_event(event:SystemEvent) {}

    public function create_sound( _id:String, _name:String, _streaming:Bool=false, ?_format:AudioFormatType ) : Promise {
        trace('Audio: create_sound in root module. Nothing will happen.');
        return null;
    }

    public function create_sound_from_bytes( _name:String, _bytes:Uint8Array, _format:AudioFormatType ) : Sound {
        trace('Audio: create_sound_from_bytes in root module. Nothing will happen.');
        return null;
    }

        //:todo:
    public function suspend() {}
        //:todo:
    public function resume() {}

} //AudioSystem

typedef Sound = snow.system.audio.Sound;
