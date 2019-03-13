package snow.core.web;

#if snow_web

import snow.types.Types;
import snow.api.Debug.*;


/** Implemented in the platform specific concrete versions of this class */
@:allow(snow.Snow)
@:noCompletion
class Core {

    var app:snow.Snow;
    var start_timestamp : Float = 0.0;

    function new( _app:Snow ) {

        app = _app;
        start_timestamp = timestamp();

        guess_os();

    } //new

        /** Called by the snow internals to intiialize the core and subsystems of the framework, with the event handler passed in for where to deliver system events */
    function init( _event_handler : SystemEvent->Void ) : Void {

            //When we are done in here, start the main init procedure
        app.dispatch_system_event({ type:SystemEventType.init });

            //After it's had time to init, we fire the ready state
        app.dispatch_system_event({ type:SystemEventType.ready });


            //Then if requested, start the main loop
        if(app.snow_config.has_loop) {
            request_update();
        }

    } //init

        /** Called to explicitly shutdown the framework cleanly. Called by `quit` and `app_terminated` type events by the core, for example. */
    function shutdown() : Void {

    } //shutdown

        /** Get the most precise timestamp available on the platform, in seconds (time is always in seconds in snow). */
    function timestamp() : Float {

        var now : Float;

        if(js.Browser.window.performance != null) {
            now = js.Browser.window.performance.now()/1000.0;
        } else {
            now = haxe.Timer.stamp();
        }

        return now - start_timestamp;

    } //timestamp

//Internal


        //Internal value only, for use ONLY when request animation frame is unavailable.
        //Don't use this value for anything... use the other time constructs in snow.App
    var _lf_timestamp : Float = 0.016;
    var _time_now : Float = 0.0;

    function request_update() {

            //If they support RAF use it, else fallback
        if(js.Browser.window.requestAnimationFrame != null) {

            js.Browser.window.requestAnimationFrame(snow_core_loop);

        } else {

            log('warning : requestAnimationFrame not found, falling back to render_rate! render_rate:' + app.host.render_rate );

                //schedule the callback again
            js.Browser.window.setTimeout(function(){

                    //cache the current time
                var _now = timestamp();
                    //increase the time value by the time since last frame
                _time_now += (_now - _lf_timestamp);
                    //call the callback, to match RAF stuff
                snow_core_loop( _time_now * 1000.0 );
                    //update the last frame stamp
                _lf_timestamp = _now;

            }, Std.int(app.host.render_rate*1000.0) );

        } //no request anim frame

    } //request_update

        //This is the actual main loop code, called by RAF or setTimeout etc.
    function snow_core_loop( ?_t:Float = 0.016 ) : Bool {

            //internal update
        update();
            //dispatch the event to the framework + host
        app.dispatch_system_event({ type:SystemEventType.update });
            //ask for another update
        request_update();
            //
        return true;

    } //snow_core_loop

    function update() {

    }

    function guess_os() {

        var _ver = js.Browser.navigator.appVersion;
        var _agent = js.Browser.navigator.userAgent;

        inline function has(_val:String, _test:String) {
            var r = new EReg(_val,'gi');
            return r.match(_test);
        }

        if(has('mac', _ver))        app.os = OS.os_mac;
        if(has('win', _ver))        app.os = OS.os_windows;
            //I know it's not linux technically (should be unix)
        if(has('x11', _ver))        app.os = OS.os_linux;
        if(has('linux', _ver))      app.os = OS.os_linux;
        if(has('android', _ver))    app.os = OS.os_android;
        if(has('ipad', _agent))     app.os = OS.os_ios;
        if(has('iphone', _agent))   app.os = OS.os_ios;
        if(has('ipod', _agent))     app.os = OS.os_ios;

    } //guess_os


} //Core

#end //snow_web
