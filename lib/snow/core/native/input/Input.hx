package snow.core.native.input;

import snow.types.Types;
import snow.api.Libs;
import snow.system.window.Window;


@:allow(snow.system.input.Input)
class Input implements snow.modules.interfaces.Input {

    var system : snow.system.input.Input;

    function new( _system:snow.system.input.Input ) system = _system;

//required by snow.modules.interfaces.Input

    function init() {}
    function update() {}
    function destroy() {}
    function on_event( _event : SystemEvent ) {}

    function listen( window:Window ) {}
    function unlisten( window:Window ) {}

//specifics

    public inline function text_input_start()
        snow_input_text_start();
    public inline function text_input_stop()
        snow_input_text_stop();
    public inline function text_input_rect(x:Int, y:Int, w:Int, h:Int)
        snow_input_text_rect(x, y, w, h);


    static var snow_input_text_start = Libs.load( "snow", "snow_input_text_start", 0 );
    static var snow_input_text_stop  = Libs.load( "snow", "snow_input_text_stop", 0 );
    static var snow_input_text_rect  = Libs.load( "snow", "snow_input_text_rect", 4 );

} //Input
