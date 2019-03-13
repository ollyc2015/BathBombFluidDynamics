package snow.modules.sdl;


import snow.types.Types;
import snow.system.input.Input;

@:noCompletion
class Input extends snow.core.native.input.Input {

    override function on_event( event : SystemEvent ) {

        super.on_event( event );

            //only care about input events
        if(event.type != SystemEventType.input) {
            return;
        }

        var _event = event.input;
        switch(_event.type) {
            case key:           handle_key_ev(_event);
            case touch:         handle_touch_ev(_event);
            case controller:    handle_controller_ev(_event);
            case mouse:         handle_mouse_ev(_event);
            case joystick:      handle_joystick_ev(_event);
            case unknown:   
            case _:    
        }

    } //on_event

    inline function handle_controller_ev(_input:InputEvent) {

        var _event : SDLControllerEvent = _input.event;
        //1 is fully up for the up/down values

        switch(_event.type) {
            case button_up: 
                system.dispatch_gamepad_button_up_event(
                    _event.which,
                    _event.button,
                    0,                  
                    _input.timestamp
                );

            case button_down:
                system.dispatch_gamepad_button_down_event(
                    _event.which,
                    _event.button,
                    1,
                    _input.timestamp
                );

            case axis:
                system.dispatch_gamepad_axis_event(
                    _event.which,
                    _event.axis,
                    _event.value,
                    _input.timestamp
                );

            case added:
                system.dispatch_gamepad_device_event(
                    _event.which,
                    _event.id,
                    device_added,
                    _input.timestamp
                );

            case removed:
                system.dispatch_gamepad_device_event(
                    _event.which,
                    _event.id,
                    device_removed,
                    _input.timestamp
                );

            case remapped:
                system.dispatch_gamepad_device_event(
                    _event.which,
                    _event.id,
                    device_remapped,
                    _input.timestamp
                );

        } //switch type

    } //handle_controller_ev

    inline function handle_joystick_ev(_input:InputEvent) {

        var _event : SDLJoystickEvent = _input.event;

        switch(_event.type) {

            case axis:
                system.dispatch_gamepad_axis_event(
                    _event.which,
                    _event.axis,
                    _event.value,
                    _input.timestamp
                );
            case button_down:
                system.dispatch_gamepad_button_down_event(
                    _event.which,
                    _event.button,
                    1,
                    _input.timestamp
                );
            case button_up:
                system.dispatch_gamepad_button_up_event(
                    _event.which,
                    _event.button,
                    0,
                    _input.timestamp
                );
            case added:
                system.dispatch_gamepad_device_event(
                    _event.which,
                    _event.id,
                    device_added,
                    _input.timestamp
                );

            case removed:
                system.dispatch_gamepad_device_event(
                    _event.which,
                    _event.id,
                    device_removed,
                    _input.timestamp
                );

            case ball:
            case hat:

        } //switch type

    } //handle_joystick_ev

    inline function handle_mouse_ev(_input:InputEvent) {

        var _event : SDLMouseEvent = _input.event;
        
        switch(_event.type) {
            case move:
                system.dispatch_mouse_move_event(
                    _event.x,
                    _event.y,
                    _event.xrel,
                    _event.yrel,
                    _input.timestamp,
                    _input.window_id
                );

            case down:
                system.dispatch_mouse_down_event(
                    _event.x,
                    _event.y,
                    _event.button,
                    _input.timestamp,
                    _input.window_id
                );

            case up:
                system.dispatch_mouse_up_event(
                    _event.x,
                    _event.y,
                    _event.button,
                    _input.timestamp,
                    _input.window_id
                );

            case wheel:
                system.dispatch_mouse_wheel_event(
                    _event.x,
                    _event.y,
                    _input.timestamp,
                    _input.window_id
                );

        } //switch type

    } //handle_mouse_ev

    inline function handle_touch_ev(_input:InputEvent) {
    
        //currently unused, but is available for future use
        // var _pressure = _event.event.pressure;
        // var _device_id = _event.event.touch_id;

        var _event : SDLTouchEvent = _input.event;

        switch(_event.type) {
            case down:
                system.dispatch_touch_down_event(
                    _event.x,
                    _event.y,
                    _event.finger_id,
                    _input.timestamp
                );

            case up:
                system.dispatch_touch_up_event(
                    _event.x,
                    _event.y,
                    _event.finger_id,
                    _input.timestamp
                );

            case move:  
                system.dispatch_touch_move_event(
                    _event.x,
                    _event.y,
                    _event.dx,
                    _event.dy,
                    _event.finger_id,
                    _input.timestamp
                );

        } //switch type

    } //handle_touch_ev

    inline function handle_key_ev(_input:InputEvent) {
        
        var _event:SDLKeyEvent = _input.event;

        switch(_event.type) {
            case down:
                system.dispatch_key_down_event(
                    _event.keysym.sym,
                    _event.keysym.scancode,
                    _event.repeat,
                    get_key_mod_state(_event),
                    _input.timestamp,
                    _input.window_id
                );

            case up:
                system.dispatch_key_up_event(
                    _event.keysym.sym,
                    _event.keysym.scancode,
                    _event.repeat,
                    get_key_mod_state(_event),
                    _input.timestamp,
                    _input.window_id
                );

            case textedit, textinput:
                system.dispatch_text_event(
                    _event.text,
                    (_event.start == null) ? 0 : _event.start,
                    (_event.length == null) ? 0 : _event.length,
                    (_event.type == textedit) ? TextEventType.edit : TextEventType.input,
                    _input.timestamp,
                    _input.window_id
                );

        } //switch event type

    } //handle_key_ev


        /** Helper to return a `ModState` (shift, ctrl etc) from a given `InputEvent` */
    function get_key_mod_state( _event:SDLKeyEvent ) : ModState {

        if( _event.type == KeyEventType.up || _event.type == KeyEventType.down ) {

            var mod_value = _event.keysym.mod;

            return {

                none    : mod_value == ModValue.NONE,

                lshift  : mod_value == ModValue.LSHIFT,
                rshift  : mod_value == ModValue.RSHIFT,
                lctrl   : mod_value == ModValue.LCTRL,
                rctrl   : mod_value == ModValue.RCTRL,
                lalt    : mod_value == ModValue.LALT,
                ralt    : mod_value == ModValue.RALT,
                lmeta   : mod_value == ModValue.LMETA,
                rmeta   : mod_value == ModValue.RMETA,

                num     : mod_value == ModValue.NUM,
                caps    : mod_value == ModValue.CAPS,
                mode    : mod_value == ModValue.MODE,

                ctrl    : mod_value == ModValue.LCTRL   || mod_value == ModValue.RCTRL,
                shift   : mod_value == ModValue.LSHIFT  || mod_value == ModValue.RSHIFT,
                alt     : mod_value == ModValue.LALT    || mod_value == ModValue.RALT,
                meta    : mod_value == ModValue.LMETA   || mod_value == ModValue.RMETA

            };

        } else {

                //no mod state for text events etc
            return {
                none:true,
                lshift:false,   rshift:false,
                lctrl:false,    rctrl:false,
                lalt:false,     ralt:false,
                lmeta:false,    rmeta:false,
                num:false,      caps:false,     mode:false,
                ctrl:false,     shift:false,    alt:false,  meta:false
            };

        } //!up && !down

    } //mod_state_from_event


} //Input

@:enum private abstract KeyEventType(Int) {

        /** A key down event */
    var down        = 768;
        /** A key up event */
    var up          = 769;
        /** A text input text edit event */
    var textedit    = 770;
        /** A text input typing event */
    var textinput   = 771;

} //KeyEventTypes

@:enum private abstract ControllerEventType(Int) {

        /** a gamepad axis movement event */
    var axis            = 1616;
        /** a gamepad button pressed event */
    var button_down     = 1617;
        /** a gamepad button released event */
    var button_up       = 1618;
        /** a gamepad connected event */
    var added           = 1619;
        /** a gamepad disconnected event */
    var removed         = 1620;
        /** a gamepad remapped event */
    var remapped        = 1621;

} //ControllerEventType

@:enum private abstract JosytickEventType(Int) {

        /** a joystick axis movement event */
    var axis            = 0x600;
        /** a joystick ball movement event */
    var ball            = 0x601;
        /** a joystick hat movement event */
    var hat             = 0x602;
        /** a joystick button pressed event */
    var button_down     = 0x603;
        /** a joystick button released event */
    var button_up       = 0x604;
        /** a joystick connected event */
    var added           = 0x605;
        /** a joystick disconnected event */
    var removed         = 0x606;

} //ControllerEventType

@:enum private abstract TouchEventType(Int) {

        /** A touch has begun */
    var down    = 1792;
        /** A touch has ended */
    var up      = 1793;
        /** A touch is moving */
    var move    = 1794;

} //TouchEventType

@:enum private abstract MouseEventType(Int) {

        /** A mouse moved event */
    var move    = 1024;
        /** A mouse button pressed event */
    var down    = 1025;
        /** A mouse button released event */
    var up      = 1026;
        /** A mouse wheel or scroll event */
    var wheel   = 1027;

} //MouseEventTypes

@:enum private abstract ModValue(Int) from Int to Int {

    var NONE    = 0x0000;
    var LSHIFT  = 0x0001;
    var RSHIFT  = 0x0002;
    var LCTRL   = 0x0040;
    var RCTRL   = 0x0080;
    var LALT    = 0x0100;
    var RALT    = 0x0200;
    var LMETA   = 0x0400;
    var RMETA   = 0x0800;
    var NUM     = 0x1000;
    var CAPS    = 0x2000;
    var MODE    = 0x4000;

} //ModValue


private typedef SDLKeyEvent = {
    var type: KeyEventType;
    var repeat: Bool;
    var keysym: {
        sym: Int,
        mod: Int,
        scancode: Int
    };
    //
    var text: String;
    var start: Null<Int>;
    var length: Null<Int>;
}

private typedef SDLTouchEvent = {
    var type: TouchEventType;
    var finger_id: Int;
    var x: Float;
    var y: Float;
    var dx: Null<Float>;
    var dy: Null<Float>;
}

private typedef SDLMouseEvent = {
    var type: MouseEventType;
    var x: Int;
    var y: Int;
    var button: Null<Int>;
    var xrel: Null<Int>;
    var yrel: Null<Int>;
}

private typedef SDLControllerEvent = {
    var type: ControllerEventType;
    var which: Int;
    var button: Null<Int>;
    var axis: Null<Int>;
    var value: Null<Float>;
    var id: String;
}

private typedef SDLJoystickEvent = {
    var type: JosytickEventType;
    var which: Int;
    var id: String;
    //button
    var button: Null<Int>;
    var state: Null<Int>;
    //hat, axis
    var value: Null<Float>;
    //axis
    var axis: Null<Int>;
    //hat
    var hat: Null<Int>;
    //ball motion
    var ball: Null<Int>;
    var xrel: Null<Int>;
    var yrel: Null<Int>;
}


