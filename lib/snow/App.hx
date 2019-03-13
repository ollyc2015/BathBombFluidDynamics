package snow;

import snow.system.input.Input;
import snow.types.Types;

    //Note all times in snow are in seconds.

/** The default type of snow application, with variable delta, update limit, render limit, timescale and more. 
    See the {App Guide} for complete details. */
class App {

//Access to the snow API

        /** use this to access the api features. *i.e* `app.assets.text(_id)` */
    public var app : Snow;

//Configurable values

        /** the scale of time */
    public var timescale : Float = 1;
        /** if this is non zero this will be passed in */
    public var fixed_delta : Float = 0;
        /** if this is non zero, rendering will be forced to this rate */
    public var render_rate : Float = -1;
        /** if this is non zero, updates will be forced to this rate */
    public var update_rate : Float = 0;
        /** the maximum frame time */
    public var max_frame_time : Float = 0.25;

//Timing information

        /** the time the last frame took to run */
    public var delta_time : Float = 1/60;
        /** the simulated time the last frame took to run, relative to scale etc */
    public var delta_sim : Float = 1/60;
        /** the start time of the last frame */
    public var last_frame_start : Float = 0.0;
        /** the current simulation time */
    public var current_time : Float = 0;
        /** the start time of this frame */
    public var cur_frame_start : Float = 0.0;
        /** the alpha time for a render between frame updates */
    public var alpha : Float = 1.0;

//Internal values

        /** for update_rate, the time when the next tick should occur around */
    var next_tick : Float = 0;
        /** for update_rate, the time when the next tick should occur around */
    var next_render : Float = 0;

//override these in your game class

        /** The default constructor of an App is empty, so you can override it if you want, but take note that this happens way before snow is ready for use. Use [ready](#ready) for entry point. */
    public function new() {}
        /** Called by snow to request config changes, override this to change the defaults.
            This happens before ready, so the values are available when ready is called. */
    public function config( config:AppConfig ) : AppConfig  { return config; }
        /** Your entry point. Called for you when you can initialize your application */
    public function ready() {}
        /** Your update loop. Called every frame for you. The dt value depends on the timing configuration (see the {App Guide}) */
    public function update(dt:Float) {}
        /** Your exit point. Called for you when you should shut down your application */
    public function ondestroy() {}
        /** Low level event handler from snow core. Often handled by the subsystems so check there first. */
    public function onevent( event:SystemEvent ) {}

        /** Called each frame *before* everything, the beginning of the frame. Use with understanding. */
    public function ontickstart() {}
        /** Called each frame *after* everything, at the end of the frame. Use with understanding. */
    public function ontickend() {}

        /** Called for you when a key is pressed down */
    public function onkeydown( keycode:Int, scancode:Int, repeat:Bool, mod:ModState, timestamp:Float, window_id:Int ) {}
        /** Called for you when a key is released */
    public function onkeyup( keycode:Int, scancode:Int, repeat:Bool, mod:ModState, timestamp:Float, window_id:Int ) {}
        /** Called for you when text input is happening. Use this for textfields, as it handles the complexity of unicode etc. */
    public function ontextinput( text:String, start:Int, length:Int, type:TextEventType, timestamp:Float, window_id:Int ) {}

        /** Called for you when a mouse button is pressed */
    public function onmousedown( x:Int, y:Int, button:Int, timestamp:Float, window_id:Int ) {}
        /** Called for you when a mouse button is released */
    public function onmouseup( x:Int, y:Int, button:Int, timestamp:Float, window_id:Int ) {}
        /** Called for you when the mouse wheel moves */
    public function onmousewheel( x:Int, y:Int, timestamp:Float, window_id:Int ) {}
        /** Called for you when the mouse moves */
    public function onmousemove( x:Int, y:Int, xrel:Int, yrel:Int, timestamp:Float, window_id:Int ) {}

        /** Called for you when a touch is released, use the `touch_id` to track which */
    public function ontouchdown( x:Float, y:Float, touch_id:Int, timestamp:Float ) {}
        /** Called for you when a touch is first pressed, use the `touch_id` to track which */
    public function ontouchup( x:Float, y:Float, touch_id:Int, timestamp:Float ) {}
        /** Called for you when a touch is moved, use the `touch_id` to track which */
    public function ontouchmove( x:Float, y:Float, dx:Float, dy:Float, touch_id:Int, timestamp:Float ) {}

        /** Called for you when a connected gamepad axis moves, use `which` to determine gamepad id */
    public function ongamepadaxis( gamepad:Int, axis:Int, value:Float, timestamp:Float ) {}
        /** Called for you when a connected gamepad button is pressed, use `which` to determine gamepad id */
    public function ongamepaddown( gamepad:Int, button:Int, value:Float, timestamp:Float ) {}
        /** Called for you when a connected gamepad button is released, use `which` to determine gamepad id */
    public function ongamepadup( gamepad:Int, button:Int, value:Float, timestamp:Float ) {}
        /** Called for you when a gamepad is connected or disconnected, use `which` to determine gamepad id. 
            `id` is the string name identifier for the controller, specified from the system. */
    public function ongamepaddevice( gamepad:Int, id:String, type:GamepadDeviceEventType, timestamp:Float ) {}



//No need to interact with these, unless you want pre-ready init, just call super.on_internal_init() etc
//to maintain expected App behavior. You can override behavior in the base class, like AppFixedTimestep

        //internal facing api
    @:allow(snow.Snow)
    function on_internal_init() {

        cur_frame_start = app.time;
        last_frame_start = cur_frame_start;
        current_time = 0;
        delta_time = 0.016;

    } //on_internal_init

    @:allow(snow.Snow)
    function on_internal_update() {

        if(update_rate != 0) {

            if(app.time < next_tick) {
                return;
            }

            next_tick = app.time + update_rate;

        } //update_rate

            //the start of this frame is now
        cur_frame_start = app.time;
            //delta is time since the last frame start
        delta_time = (cur_frame_start - last_frame_start);
            //last frame start is updated to now
        last_frame_start = cur_frame_start;

            //clamp delta to max frame time, preventing large deltas
        if(delta_time > max_frame_time) {
            delta_time = max_frame_time;
        }

            //which delta we are going to use, fixed or variable
        var used_delta = (fixed_delta == 0) ? delta_time : fixed_delta;
            //timescale the delta to the given scale
        used_delta *= timescale;
            //update the simulated delta value
        delta_sim = used_delta;

            //update the internal "time" counter
        current_time += used_delta;
            //do the internal systems update
        app.do_internal_update( used_delta );

    } //on_internal_update

    @:allow(snow.Snow)
    function on_internal_render() {

            //and finally call render, if it's time
        if(render_rate != 0) {
            if(render_rate < 0 || (next_render < app.time)) {
                app.render();
                next_render += render_rate;
            }
        }

    } //on_internal_render

} //App



/** Read the {App Guide} for full info, and for even more information see : http://gafferongames.com/game-physics/fix-your-timestep/
    this stores and calculates a fixed game update loop, and rendering interpolation is required
    for smooth updates between frames. */
class AppFixedTimestep extends App {

        /** fixed simulation update speed */
    public var frame_time : Float = 0.0167;
        /** the overflow of the updates. This is used internally, for you, to calculate the alpha time for rendering interpolation as follows `alpha = overflow / frame_time;` */
    public var overflow : Float = 0.0;

    @:allow(snow.Snow)
    override function on_internal_init() {

        super.on_internal_init();

        frame_time = 1.0/60.0;
        last_frame_start = app.time;

    } //on_internal_init

        //no super.on_internal_update because this entirely controls
        //the update loop for the application itself
    @:allow(snow.Snow)
    override function on_internal_update() {

        cur_frame_start = app.time;
        delta_time = (cur_frame_start - last_frame_start);
        delta_sim = delta_time * timescale;

        if(delta_sim > max_frame_time) {
            delta_sim = max_frame_time;
        }

        last_frame_start = cur_frame_start;

        overflow += delta_sim;

        while(overflow >= frame_time) {

            app.do_internal_update(frame_time * timescale);

            current_time += frame_time * timescale;

            overflow -= frame_time * timescale;

        } //overflow >= frame_time

            //work this out before a render
        alpha = overflow / frame_time;

    } //on_internal_update

} //AppFixedTimestep
