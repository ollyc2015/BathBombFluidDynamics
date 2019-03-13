package snow.modules.interfaces;

import snow.types.Types;

@:noCompletion
@:allow(snow.system.input.Input)
interface Input {

    private function init():Void;
    private function update():Void;
    private function destroy():Void;
    private function on_event( event:SystemEvent ):Void;

    private function listen( window:snow.system.window.Window ):Void;
    private function unlisten( window:snow.system.window.Window ):Void;

} //Input