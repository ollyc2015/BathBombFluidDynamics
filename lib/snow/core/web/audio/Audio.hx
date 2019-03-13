package snow.core.web.audio;

#if snow_web

import snow.types.Types;

@:allow(snow.system.audio.Audio)
class Audio implements snow.modules.interfaces.Audio {

    var system : snow.system.audio.Audio;

    function new( _system:snow.system.audio.Audio ) system = _system;

    function init() {}
    function update() {}
    function destroy() {}
    function on_event(event:SystemEvent) {}

        //:todo:
    public function suspend() {}
        //:todo:
    public function resume() {}

} //AudioSystem

typedef Sound = snow.system.audio.Sound;

#end //snow_web
