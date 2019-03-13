package snow.core.web.input;

#if snow_web

import snow.types.Types;
import snow.system.window.Window;
import snow.core.web.input.DOMKeys;

import snow.api.Debug.*;

typedef WebGamepadButton = {
    value : Float,
    pressed : Bool
}

typedef WebGamepad = {
    axes : Array<Float>,
    index : Int,
    buttons : Array<WebGamepadButton>,
    id : String,
    timestamp : Float
}

@:allow(snow.system.input.Input)
class Input implements snow.modules.interfaces.Input {

    var active_gamepads : Map<Int, WebGamepad>;
    var gamepads_supported : Bool = false;

    var system : snow.system.input.Input;

 	function new( _system:snow.system.input.Input ) system = _system;

    function init() {

            //key input is page wide, not just per canvas
        js.Browser.document.addEventListener('keypress', on_keypress);
        js.Browser.document.addEventListener('keydown',  on_keydown);
        js.Browser.document.addEventListener('keyup',    on_keyup);

            //initialize gamepads if they exist
        active_gamepads = new Map();
        gamepads_supported = (get_gamepad_list() != null);

            //flag the state of deviceorientation api
        if( untyped __js__('window.DeviceOrientationEvent') ) {
            js.Browser.window.addEventListener('deviceorientation', on_orientation);
            js.Browser.window.addEventListener('devicemotion', on_motion);
        }

        log('Gamepads supported: $gamepads_supported');

    } //init

    function update() {

        if(gamepads_supported) {
            poll_gamepads();
        }

    } //update

    function destroy() {}

    function listen( window:Window ) {

        window.handle.addEventListener('contextmenu', on_contextmenu );

        window.handle.addEventListener('mousedown',  on_mousedown);
        window.handle.addEventListener('mouseup',    on_mouseup);
        window.handle.addEventListener('mousemove',  on_mousemove);

        window.handle.addEventListener('mousewheel', on_mousewheel);
        window.handle.addEventListener('wheel',      on_mousewheel);

        window.handle.addEventListener('touchstart', on_touchdown);
        window.handle.addEventListener('touchend',   on_touchup);
        window.handle.addEventListener('touchmove',  on_touchmove);

    } //listen

    function unlisten( window:Window ) {}
    function on_event( _event : SystemEvent ) {}

    public function text_input_start() {
        // :unsupported: :todo:
    } //text_input_start

    public function text_input_stop() {
        // :unsupported: :todo:
    } //text_input_stop

    public function text_input_rect(x:Int, y:Int, w:Int, h:Int) {
        // :unsupported: :todo:
    } //text_input_rect

//Orientation

    function on_orientation( event ) {

        system.app.dispatch_system_event({
            type: SystemEventType.input,
            input: {
                type: InputEventType.joystick,
                timestamp: system.app.time,
                event: {
                    type: 'orientation',
                    alpha: event.alpha,
                    beta: event.beta,
                    gamma: event.gamma
                }
            },
        });


    } //on_orientation

    function on_motion( event ) {

        system.app.dispatch_system_event({
            type: SystemEventType.input,
            input: {
                type: InputEventType.joystick,
                timestamp: system.app.time,
                event: {
                    type: 'motion',
                    acceleration: event.acceleration,
                    accelerationIncludingGravity: event.accelerationIncludingGravity,
                    rotationRate: event.rotationRate
                }
            },
        });

    } //on_motion

//Gamepad
    function poll_gamepads() {

        //just in case
        if(!gamepads_supported) return;

        var list = get_gamepad_list();
        if(list != null) {
            for(i in 0 ... list.length) {
                if( untyped list[i] != null ) {
                    handle_gamepad( untyped list[i] );
                } else {
                    //if an entry in the list was null,
                    //check if it was here already before
                    var _gamepad = active_gamepads.get(i);
                    if(_gamepad != null) {

                        system.dispatch_gamepad_device_event(
                            _gamepad.index,
                            _gamepad.id,
                            GamepadDeviceEventType.device_removed,
                            system.app.time //:todo:gamepadtimestamp:
                        );

                    } //_gamepad != null

                        //and remove it so it only fires once
                    active_gamepads.remove(i);

                } //list[i] != null
            } //for each in the list
        } //if there is a list

    } //poll_gamepads

    function handle_gamepad( _gamepad : Dynamic ) {

        //disconnected gamepads we don't need
        if(_gamepad == null) return;

            //check if this gamepad exists already
        if( !active_gamepads.exists( _gamepad.index ) ) {

                //if not we add it to the list
            var _new_gamepad : WebGamepad = {
                id : _gamepad.id,
                index : _gamepad.index,
                axes : [],
                buttons : [],
                timestamp : system.app.time //:todo:gamepadtimestamp:
            };

            var axes : Array<Float> = cast _gamepad.axes;
            for(value in axes) {
                _new_gamepad.axes.push(value);
            }

            var _button_list : Array<WebGamepadButton> = cast _gamepad.buttons;
            for(_button in _button_list) {
                _new_gamepad.buttons.push({ pressed:false, value:0 });
            }

            active_gamepads.set( _new_gamepad.index, _new_gamepad );

            system.dispatch_gamepad_device_event(
                _new_gamepad.index,
                _new_gamepad.id,
                GamepadDeviceEventType.device_added,
                _new_gamepad.timestamp
            );

        } else {

                //found in the list so we can update it if anything changed
            var gamepad = active_gamepads.get(_gamepad.index);

                //but only if the timestamp differs :todo:gamepadtimestamp:
                //failfox at least doesn't store timestamp changes -_-
            // if(gamepad.timestamp != _gamepad.timestamp) {

                    //update the id if it changed
                if(gamepad.id != _gamepad.id) { gamepad.id = _gamepad.id; }

                    //:todo: see :gamepadtimestamp:
                // gamepad.timestamp = _gamepad.timestamp;

                    //we store the list of changed indices
                    //so we can call the handler functions with each
                var axes_changed : Array<Int> = [];
                var buttons_changed : Array<Int> = [];
                    //the last known values
                var last_axes : Array<Float> = gamepad.axes;
                var last_buttons : Array<WebGamepadButton> = gamepad.buttons;

                    //the new known values
                var new_axes : Array<Float> = cast _gamepad.axes;
                var new_buttons : Array<WebGamepadButton> = cast _gamepad.buttons;

                    //check for axes changes
                var axis_index : Int = 0;
                for(axis in new_axes) {

                    if(axis != last_axes[axis_index]) {
                        axes_changed.push(axis_index);
                        gamepad.axes[axis_index] = axis;
                    }

                    axis_index++;

                } //axis in new_axes

                    //check for button changes
                var button_index : Int = 0;
                for(button in new_buttons) {

                    if( button.value != last_buttons[button_index].value ) {
                        buttons_changed.push(button_index);
                        gamepad.buttons[button_index].pressed = button.pressed;
                        gamepad.buttons[button_index].value = button.value;
                    }

                    button_index++;

                } //button in new_buttons

                    //now forward any axis changes to the wrapper
                for(index in axes_changed) {

                    system.dispatch_gamepad_axis_event(
                        gamepad.index,
                        index,
                        new_axes[index],
                        gamepad.timestamp
                    );

                } //for each axis changed

                    //then forward any button changes to the wrapper
                for(index in buttons_changed) {

                    if(new_buttons[index].pressed == true) {

                        system.dispatch_gamepad_button_down_event(
                            gamepad.index,
                            index,
                            new_buttons[index].value,
                            gamepad.timestamp
                        );

                    } else {

                        system.dispatch_gamepad_button_up_event(
                            gamepad.index,
                            index,
                            new_buttons[index].value,
                            gamepad.timestamp
                        );

                    } //new_buttons[index].pressed

                } //for each button change

                //:todo: see :gamepadtimestamp:
            // } //timestamp changed

        } //exists

    } //handle_gamepad

    function fail_gamepads() {

        gamepads_supported = false;
        log("Gamepads are not supported in this browser :(");

    } //fail_gamepads

        //It's really early for gamepads in browser
    function get_gamepad_list() : Dynamic {

            //try official api first
        if( untyped js.Browser.navigator.getGamepads != null ) {
            return untyped js.Browser.navigator.getGamepads();
        }

            //try newer webkit GetGamepads() function
        if( untyped js.Browser.navigator.webkitGetGamepads != null ) {
            return untyped js.Browser.navigator.webkitGetGamepads();
        }

            //if we make it here we failed support so fail out
        fail_gamepads();

        return null;

    } //get_gamepad_list

//Mouse
    function on_mousedown( _mouse_event:js.html.MouseEvent ) {

        var _window : Window = system.app.windowing.window_from_handle(cast _mouse_event.target);

            //buttons are 1 index, on native, so we increase button
        system.dispatch_mouse_down_event(
            (_mouse_event.pageX - js.Browser.window.pageXOffset) - _window.x,
            (_mouse_event.pageY - js.Browser.window.pageYOffset) - _window.y,
            _mouse_event.button+1,
            _mouse_event.timeStamp,
            _window.id
        );

    } //on_mousedown

    function on_mouseup( _mouse_event:js.html.MouseEvent ) {

        var _window : Window = system.app.windowing.window_from_handle(cast _mouse_event.target);

        system.dispatch_mouse_up_event(
            (_mouse_event.pageX - js.Browser.window.pageXOffset) - _window.x,
            (_mouse_event.pageY - js.Browser.window.pageYOffset) - _window.y,
            _mouse_event.button+1,
            _mouse_event.timeStamp,
            _window.id
        );

    } //on_mouseup

    function on_mousemove( _mouse_event:js.html.MouseEvent ) {

        var _window : Window = system.app.windowing.window_from_handle(cast _mouse_event.target);

        var _movement_x : Null<Int> = untyped _mouse_event.movementX;
        var _movement_y : Null<Int> = untyped _mouse_event.movementY;

        if(_movement_x == null) {
            if(untyped _mouse_event.webkitMovementX != null) {
                _movement_x = untyped _mouse_event.webkitMovementX;
                _movement_y = untyped _mouse_event.webkitMovementY;
            } else if(untyped _mouse_event.mozMovementX != null) {
                _movement_x = untyped _mouse_event.mozMovementX;
                _movement_y = untyped _mouse_event.mozMovementY;
            }
        }

        system.dispatch_mouse_move_event(
            (_mouse_event.pageX - js.Browser.window.pageXOffset) - _window.x,
            (_mouse_event.pageY - js.Browser.window.pageYOffset) - _window.y,
            _movement_x,
            _movement_y,
            _mouse_event.timeStamp,
            _window.id
        );

    } //on_mousemove


    function on_mousewheel( _wheel_event:js.html.WheelEvent ) {

        if(system.app.config.web.prevent_default_mouse_wheel) {
            _wheel_event.preventDefault();
        }

        var _window : Window = system.app.windowing.window_from_handle(cast _wheel_event.target);

        var _x : Int = 0;
        var _y : Int = 0;

            //:todo:haxe:3.2: deltaX/deltaY added in haxe 3.2.0
        if(untyped _wheel_event.deltaY != null) {
            _y  = untyped _wheel_event.deltaY;
        } else if((untyped _wheel_event.wheelDeltaY) != null) {
            _y = Std.int(-(untyped _wheel_event.wheelDeltaY)/3);
        }

        if(untyped _wheel_event.deltaX != null) {
            _x  = untyped _wheel_event.deltaX;
        } else if((untyped _wheel_event.wheelDeltaX) != null) {
            _x = Std.int(-(untyped _wheel_event.wheelDeltaX)/3);
        }

            //the /16 here is the default em size of a web page
            //because native scrolls in lines, and web scrolls in pixels,
            //sometimes, fuuu
        system.dispatch_mouse_wheel_event(
            Math.round(_x/16),
            Math.round(_y/16),
            _wheel_event.timeStamp,
            _window.id
        );

    } //on_mousewheel

    function on_contextmenu( _event:js.html.MouseEvent ) {

        if(system.app.config.web.no_context_menu) {
            _event.preventDefault();
        }

    } //on_contextmenu

//Keys

    //window id is 1 for keys as they come from the page, so always the main window

        //a list of keycodes that should not generate text
        //based events because... browsers.
    static var _keypress_blacklist = [Key.backspace, Key.enter];
        //keypress gives us typable keys
    function on_keypress( _key_event:js.html.KeyboardEvent ) {

        if(_key_event.which != 0 &&
           _keypress_blacklist.indexOf(_key_event.keyCode) == -1) {

            var _text = String.fromCharCode(_key_event.charCode);

            system.dispatch_text_event(
                _text, 0, _text.length,     //text, start, length
                TextEventType.input,        //TextEventType
                _key_event.timeStamp,       //timestamp
                1                           //window
            );

        } //not special

    } //on_keypress

    function on_keydown( _key_event:js.html.KeyboardEvent ) {

        var _keycode : Int = convert_keycode(_key_event.keyCode);
        var _scancode : Int = Key.to_scan(_keycode);
        var _mod_state : ModState = mod_state_from_event(_key_event);

        if(system.app.config.web.prevent_default_keys.indexOf(_keycode) != -1) {
            _key_event.preventDefault();
        }

        system.dispatch_key_down_event(
            _keycode,
            _scancode,
            untyped _key_event.repeat,
            _mod_state,
            _key_event.timeStamp,
            1
        );

    } //on_keydown

    function on_keyup( _key_event:js.html.KeyboardEvent ) {


        var _keycode : Int = convert_keycode(_key_event.keyCode);
        var _scancode : Int = Key.to_scan(_keycode);
        var _mod_state : ModState = mod_state_from_event(_key_event);

        if(system.app.config.web.prevent_default_keys.indexOf(_keycode) != -1) {
            _key_event.preventDefault();
        }

        system.dispatch_key_up_event(
            _keycode,
            _scancode,
            untyped _key_event.repeat,
            _mod_state,
            _key_event.timeStamp,
            1
        );

    } //on_keyup

	function mod_state_from_event( _key_event : js.html.KeyboardEvent ) : ModState {

        var _none : Bool =
            !_key_event.altKey &&
            !_key_event.ctrlKey &&
            !_key_event.metaKey &&
            !_key_event.shiftKey;

        return {
            none    : _none,
            lshift  : _key_event.shiftKey,
            rshift  : _key_event.shiftKey,
            lctrl   : _key_event.ctrlKey,
            rctrl   : _key_event.ctrlKey,
            lalt    : _key_event.altKey,
            ralt    : _key_event.altKey,
            lmeta   : _key_event.metaKey,
            rmeta   : _key_event.metaKey,
            num     : false, //:unsupported:
            caps    : false, //:unsupported:
            mode    : false, //:unsupported:
            ctrl    : _key_event.ctrlKey,
            shift   : _key_event.shiftKey,
            alt     : _key_event.altKey,
            meta    : _key_event.metaKey
        };

    } //mod_state_from_event

        //This takes a *DOM* keycode and returns a snow Keycodes value
    function convert_keycode(dom_keycode:Int) : Int {

            //this converts the uppercase into lower case,
            //since those are fixed values it doesn't need to be checked
        if (dom_keycode >= 65 && dom_keycode <= 90) {
            return dom_keycode + 32;
        }

            //this will pass back the same value if unmapped
        return DOMKeys.dom_key_to_keycode(dom_keycode);

    } //convert_keycode

//Touch

    function on_touchdown( _touch_event:js.html.TouchEvent ) {

        var _window : Window = system.app.windowing.window_from_handle(cast _touch_event.target);

        for(touch in _touch_event.changedTouches) {

            var _x:Float = (touch.pageX - js.Browser.window.pageXOffset) - _window.x;
            var _y:Float = (touch.pageY - js.Browser.window.pageYOffset) - _window.y;
                _x = (_x / _window.width);
                _y = (_y / _window.height);

            system.dispatch_touch_down_event(
                _x,
                _y,
                touch.identifier,
                system.app.time
            );
        }
    } //on_touchdown

    function on_touchup( _touch_event:js.html.TouchEvent ){

        var _window : Window = system.app.windowing.window_from_handle(cast _touch_event.target);

        for(touch in _touch_event.changedTouches) {

            var _x:Float = (touch.pageX - js.Browser.window.pageXOffset) - _window.x;
            var _y:Float = (touch.pageY - js.Browser.window.pageYOffset) - _window.y;
                _x = (_x / _window.width);
                _y = (_y / _window.height);

            system.dispatch_touch_up_event(
                _x,
                _y,
                touch.identifier,
                system.app.time
            );
        }

    } //on_touchup

    function on_touchmove( _touch_event:js.html.TouchEvent ){

        var _window : Window = system.app.windowing.window_from_handle(cast _touch_event.target);

        for(touch in _touch_event.changedTouches) {

            var _x:Float = (touch.pageX - js.Browser.window.pageXOffset) - _window.x;
            var _y:Float = (touch.pageY - js.Browser.window.pageYOffset) - _window.y;
                _x = (_x / _window.width);
                _y = (_y / _window.height);

            system.dispatch_touch_move_event(
                _x,
                _y,
                0,
                0,
                touch.identifier,
                system.app.time
            );
        }

    } //on_touchmove


} //Input

#end //snow_web
