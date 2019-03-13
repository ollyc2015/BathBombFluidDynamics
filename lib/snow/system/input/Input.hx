package snow.system.input;

import snow.types.Types;
import snow.system.window.Window;

#if (!macro && !display && !scribe)
    private typedef InputModule = haxe.macro.MacroType<[snow.system.module.Module.assign('Input')]>;
#end


typedef MapIntBool = Map<Int, Bool>;
typedef MapIntFloat = Map<Int, Float>;

/** The snow input system. Accessed via `app.input` */
@:allow(snow.Snow)
class Input {

        /** access to snow from subsystems */
    @:noCompletion public var app : Snow;
        /** access to platform implementation */
    @:noCompletion public var module : snow.system.module.Input;

        /** constructed internally, use `app.input` */
    function new( _app:Snow ) {

        app = _app;

        module = new snow.system.module.Input(this);

        module.init();

        //keys

            key_code_pressed = new Map();
            key_code_down = new Map();
            key_code_released = new Map();

            scan_code_pressed = new Map();
            scan_code_down = new Map();
            scan_code_released = new Map();

        //mouse

            mouse_button_pressed = new Map();
            mouse_button_down = new Map();
            mouse_button_released = new Map();

        //gamepad

            gamepad_button_pressed = new Map();
            gamepad_button_down = new Map();
            gamepad_button_released = new Map();
            gamepad_axis_values = new Map();

        //touch

            touches_down = new Map();

    } //new


//Public facing API


    //Key immediate style access

            /** returns true if the `Key` value was pressed in the latest frame */
        public function keypressed( _code:Int ) : Bool {
            return key_code_pressed.exists(_code);
        } //keypressed

            /** returns true if the `Key` value was released in the latest frame */
        public function keyreleased( _code:Int ) : Bool {
            return key_code_released.exists(_code);
        } //keyreleased

            /** returns true if the `Key` value is down at the time of calling this */
        public function keydown( _code:Int ) : Bool {
           return key_code_down.exists(_code);
        } //keydown

            /** returns true if the `Scan` value was pressed in the latest frame */
        public function scanpressed( _code:Int ) : Bool {
            return scan_code_pressed.exists(_code);
        } //scanpressed

            /** returns true if the `Scan` value was released in the latest frame */
        public function scanreleased( _code:Int ) : Bool {
            return scan_code_released.exists(_code);
        } //scanreleased

            /** returns true if the `Scan` value is down at the time of calling this */
        public function scandown( _code:Int ) : Bool {
           return scan_code_down.exists(_code);
        } //keydown

    //Mouse immediate style access

            /** returns true if the mouse button was pressed in the latest frame */
        public function mousepressed( _button:Int ) : Bool {
            return mouse_button_pressed.exists(_button);
        } //keypressed

            /** returns true if the mouse button was released in the latest frame */
        public function mousereleased( _button:Int ) : Bool {
            return mouse_button_released.exists(_button);
        } //mousereleased

            /** returns true if the mouse button value is down at the time of calling this */
        public function mousedown( _button:Int ) : Bool {
           return mouse_button_down.exists(_button);
        } //mousedown

    //Gamepad immediate style access

            /** returns true if the mouse button was pressed in the latest frame */
        public function gamepadpressed( _gamepad:Int, _button:Int ) : Bool {

            var _gamepad_state = gamepad_button_pressed.get(_gamepad);
            return _gamepad_state != null ? _gamepad_state.exists(_button) : false;

        } //keypressed

            /** returns true if the gamepad button was released in the latest frame */
        public function gamepadreleased( _gamepad:Int, _button:Int ) : Bool {

            var _gamepad_state = gamepad_button_released.get(_gamepad);
            return _gamepad_state != null ? _gamepad_state.exists(_button) : false;

        } //gamepadreleased

            /** returns true if the gamepad button value is down at the time of calling this */
        public function gamepaddown( _gamepad:Int, _button:Int ) : Bool {

           var _gamepad_state = gamepad_button_down.get(_gamepad);
            return _gamepad_state != null ? _gamepad_state.exists(_button) : false;

        } //gamepaddown

            /** returns true if the gamepad button value is down at the time of calling this */
        public function gamepadaxis( _gamepad:Int, _axis:Int ) : Float {

            var _gamepad_state = gamepad_axis_values.get(_gamepad);
            if(_gamepad_state != null) {
                if(_gamepad_state.exists(_axis)) {
                    return _gamepad_state.get(_axis);
                }
            }

            return 0;

        } //gamepaddown

        /** manually dispatch a key down event through the system, delivered to the app handlers, internal and external */
    public function dispatch_key_down_event( keycode:Int, scancode:Int, repeat:Bool, mod:ModState, timestamp:Float, window_id:Int ) {

            //only do the realtime flags if not key repeat
        if(!repeat) {
                //flag the key as pressed, but unprocessed (false)
            key_code_pressed.set(keycode, false);
                //flag it as down, because keyup removes it
            key_code_down.set(keycode, true);
                //flag the scan as pressed, but unprocessed (false)
            scan_code_pressed.set(scancode, false);
                //flag it as down, because keyup removes it
            scan_code_down.set(scancode, true);
        }

            //forward the event
        app.host.onkeydown(keycode, scancode, repeat, mod, timestamp, window_id);

    } //dispatch_key_down_event

        /** manually dispatch a key up event through the system, delivered to the app handlers, internal and external */
    public function dispatch_key_up_event( keycode:Int, scancode:Int, repeat:Bool, mod:ModState, timestamp:Float, window_id:Int ) {

            //flag it as released but unprocessed
        key_code_released.set(keycode, false);
            //remove the down flag
        key_code_down.remove(keycode);

            //flag it as released but unprocessed
        scan_code_released.set(scancode, false);
            //remove the down flag
        scan_code_down.remove(scancode);


            //dispatch the event
        app.host.onkeyup(keycode, scancode, repeat, mod, timestamp, window_id);

    } //dispatch_key_up_event

        /** manually dispatch a text event through the system, delivered to the app handlers, internal and external */
    public function dispatch_text_event( text:String, start:Int, length:Int, type:TextEventType, timestamp:Float, window_id:Int ) {

        app.host.ontextinput( text, start, length, type, timestamp, window_id );

    } //dispatch_text_event


        /** manually dispatch a mouse move event through the system, delivered to the app handlers, internal and external */
    public function dispatch_mouse_move_event( x:Int, y:Int, xrel:Int, yrel:Int, timestamp:Float, window_id:Int ) {

        app.host.onmousemove( x, y, xrel, yrel, timestamp, window_id );

    } //dispatch_mouse_move_event

        /** manually dispatch a mouse button down event through the system, delivered to the app handlers, internal and external */
    public function dispatch_mouse_down_event( x:Int, y:Int, button:Int, timestamp:Float, window_id:Int ) {

            //flag the button as pressed, but unprocessed (false)
        mouse_button_pressed.set(button, false);
            //flag it as down, because mouseup removes it
        mouse_button_down.set(button, true);


        app.host.onmousedown( x, y, button, timestamp, window_id );

    } //dispatch_mouse_down_event

        /** manually dispatch a mouse button up event through the system, delivered to the app handlers, internal and external */
    public function dispatch_mouse_up_event( x:Int, y:Int, button:Int, timestamp:Float, window_id:Int ) {

            //flag it as released but unprocessed
        mouse_button_released.set(button, false);
            //remove the down flag
        mouse_button_down.remove(button);


        app.host.onmouseup( x, y, button, timestamp, window_id );

    } //dispatch_mouse_up_event

        /** manually dispatch a mouse wheel event through the system, delivered to the app handlers, internal and external */
    public function dispatch_mouse_wheel_event( x:Int, y:Int, timestamp:Float, window_id:Int ) {

        app.host.onmousewheel( x, y, timestamp, window_id );

    } //dispatch_mouse_wheel_event

        /** manually dispatch a touch down through the system, delivered to the app handlers, internal and external */
    public function dispatch_touch_down_event( x:Float, y:Float, touch_id:Int, timestamp:Float ) {

        if(!touches_down.exists(touch_id)) {
            touch_count++;
            touches_down.set(touch_id, true);
        }

        app.host.ontouchdown( x, y, touch_id, timestamp );

    } //dispatch_touch_down_event

        /** manually dispatch a touch up through the system, delivered to the app handlers, internal and external */
    public function dispatch_touch_up_event( x:Float, y:Float, touch_id:Int, timestamp:Float ) {

        app.host.ontouchup( x, y, touch_id, timestamp );

        if(touches_down.remove(touch_id)) {
            touch_count--;
        }

    } //dispatch_touch_up_event

        /** manually dispatch a touch move through the system, delivered to the app handlers, internal and external */
    public function dispatch_touch_move_event( x:Float, y:Float, dx:Float, dy:Float, touch_id:Int, timestamp:Float ) {

        app.host.ontouchmove( x, y, dx, dy, touch_id, timestamp );

    } //dispatch_touch_move_event

        /** manually dispatch a gamepad axis event through the system, delivered to the app handlers, internal and external */
    public function dispatch_gamepad_axis_event( gamepad:Int, axis:Int, value:Float, timestamp:Float ) {

            //if not existing, add it's map
        if(!gamepad_axis_values.exists(gamepad)) {
            gamepad_axis_values.set(gamepad, new Map());
        }

            //update the axis value
        gamepad_axis_values.get(gamepad).set(axis, value);

        app.host.ongamepadaxis( gamepad, axis, value, timestamp );

    } //dispatch_gamepad_axis_event

        /** manually dispatch a gamepad button down event through the system, delivered to the app handlers, internal and external */
    public function dispatch_gamepad_button_down_event( gamepad:Int, button:Int, value:Float, timestamp:Float ) {

            //if not existing, add it's map
        if(!gamepad_button_pressed.exists(gamepad)) {
            gamepad_button_pressed.set(gamepad, new Map());
        }

        if(!gamepad_button_down.exists(gamepad)) {
            gamepad_button_down.set(gamepad, new Map());
        }

            //flag it as released but unprocessed
        gamepad_button_pressed.get(gamepad).set(button, false);
            //flag it as down, because gamepadup removes it
        gamepad_button_down.get(gamepad).set(button, true);


        app.host.ongamepaddown( gamepad, button, value, timestamp );

    } //dispatch_gamepad_button_down_event

        /** manually dispatch a gamepad button up event through the system, delivered to the app handlers, internal and external */
    public function dispatch_gamepad_button_up_event( gamepad:Int, button:Int, value:Float, timestamp:Float ) {

           //if not existing, add it's map, this should never happen,
           //but rather be safe than crashy. :todo:shipping:
        if(!gamepad_button_released.exists(gamepad)) {
            gamepad_button_released.set(gamepad, new Map());
        }

        if(!gamepad_button_down.exists(gamepad)) {
            gamepad_button_down.set(gamepad, new Map());
        }

            //flag it as released but unprocessed
        gamepad_button_released.get(gamepad).set(button, false);
            //flag it as down, because gamepadup removes it
        gamepad_button_down.get(gamepad).remove(button);

        app.host.ongamepadup( gamepad, button, value, timestamp );

    } //dispatch_gamepad_button_up_event

        /** manually dispatch a gamepad device event through the system, delivered to the app handlers, internal and external */
    public function dispatch_gamepad_device_event( gamepad:Int, id:String, type:GamepadDeviceEventType, timestamp:Float ) {

        app.host.ongamepaddevice( gamepad, id, type, timestamp );

    } //dispatch_gamepad_device_event

//Interal API

        /** Attach to a window to listen for input from it */
    @:noCompletion public function listen( _window:Window ) {

        module.listen(_window);

    } //listen

        /** Detach a listening window, stopping listening of input from it */
    @:noCompletion public function unlisten( _window:Window ) {

        module.unlisten(_window);

    } //unlisten

        /** Called when a system event is dispatched through the core */
    @:noCompletion public function on_event( _event:SystemEvent ) {

        module.on_event( _event );

    } //on_event


        /** Handle any input related processing, called by Snow */
    function update() {

        module.update();

        _update_keystate();
        _update_gamepadstate();
        _update_mousestate();

    } //update

        /** Destroy and clean up etc. */
    function destroy() {

        module.destroy();

    } //destroy

//internal

        /** update mouse pressed/released/down states */
    function _update_mousestate() {

        for(_code in mouse_button_pressed.keys()){

            if(mouse_button_pressed.get(_code)){
                mouse_button_pressed.remove(_code);
            } else {
                mouse_button_pressed.set(_code, true);
            }

        } //each mouse_button_pressed

        for(_code in mouse_button_released.keys()){

            if(mouse_button_released.get(_code)){
                mouse_button_released.remove(_code);
            } else {
                mouse_button_released.set(_code, true);
            }

        } //each mouse_button_released

    } //_update_mousestate

        /** update gamepad pressed/released/down/axis states */
    function _update_gamepadstate() {

        for(_gamepad_pressed in gamepad_button_pressed){
            for(_button in _gamepad_pressed.keys()) {

                if(_gamepad_pressed.get(_button)){
                    _gamepad_pressed.remove(_button);
                } else {
                    _gamepad_pressed.set(_button, true);
                }

            } //each _gamepad_pressed
        } //each gamepad_button_pressed

        for(_gamepad_released in gamepad_button_released){
            for(_button in _gamepad_released.keys()) {

                if(_gamepad_released.get(_button)){
                    _gamepad_released.remove(_button);
                } else {
                    _gamepad_released.set(_button, true);
                }

            } //each _gamepad_released
        } //each gamepad_button_released

    } //_update_gamepadstate

        /** update key pressed/released/down states */
    function _update_keystate() {

            //remove any stale key pressed value
            //unless it wasn't alive for a full frame yet,
            //then flag it so that it may be
        for(_code in key_code_pressed.keys()){

            if(key_code_pressed.get(_code)){
                key_code_pressed.remove(_code);
            } else {
                key_code_pressed.set(_code, true);
            }

        } //each key_code_pressed

            //remove any stale key released value
            //unless it wasn't alive for a full frame yet,
            //then flag it so that it may be
        for(_code in key_code_released.keys()){

            if(key_code_released.get(_code)){
                key_code_released.remove(_code);
            } else {
                key_code_released.set(_code, true);
            }

        } //each key_code_released

    //scans

            //remove any stale key pressed value
            //unless it wasn't alive for a full frame yet,
            //then flag it so that it may be
        for(_code in scan_code_pressed.keys()){

            if(scan_code_pressed.get(_code)){
                scan_code_pressed.remove(_code);
            } else {
                scan_code_pressed.set(_code, true);
            }

        } //each scan_code_pressed

            //remove any stale key released value
            //unless it wasn't alive for a full frame yet,
            //then flag it so that it may be
        for(_code in scan_code_released.keys()){

            if(scan_code_released.get(_code)){
                scan_code_released.remove(_code);
            } else {
                scan_code_released.set(_code, true);
            }

        } //each scan_code_released

    } //_update_keystate



        //this is the keycode based flags for keypressed/keyreleased/keydown
    var key_code_down : MapIntBool;
    var key_code_pressed : MapIntBool;
    var key_code_released : MapIntBool;

        //this is the scancode based flags for scanpressed/scanreleased/scandown
    var scan_code_down : MapIntBool;
    var scan_code_pressed : MapIntBool;
    var scan_code_released : MapIntBool;

        //this is the mouse button based flags for mousepressed/mousereleased/mousedown
    var mouse_button_down : MapIntBool;
    var mouse_button_pressed : MapIntBool;
    var mouse_button_released : MapIntBool;

        //this is the gamepad button based flags for gamepadpressed/gamepadreleased/gamepaddown
    var gamepad_button_down : Map<Int, MapIntBool >;
    var gamepad_button_pressed : Map<Int, MapIntBool >;
    var gamepad_button_released : Map<Int, MapIntBool >;
    var gamepad_axis_values : Map<Int, MapIntFloat >;

        //map of the touches currently down,
        //:todo:wip:
    @:noCompletion public var touch_count : Int = 0;
    @:noCompletion public var touches_down : MapIntBool;


} //Input


