package snow;

import snow.App;
import snow.types.Types;

import snow.api.Debug.*;
import snow.api.Timer;
import snow.api.Promise;
import snow.api.buffers.Uint8Array;

import snow.system.audio.Audio;
import snow.system.assets.Assets;
import snow.system.io.IO;
import snow.system.input.Input;
import snow.system.window.Window;
import snow.system.window.Windowing;


class Snow {

//Property accessors

        /** The current timestamp */
    public var time (get,never) : Float;
        /** Generate a unique ID to use */
    public var uniqueid (get,never) : String;

//Static convenience

    public static var timestamp (get, never) : Float;

//State management

        /** The host application */
    public var host : App;
        /** The application configuration specifics (like window, runtime, and asset lists) */
    public var config : snow.types.Types.AppConfig;
        /** The configuration for snow itself, set via build project flags */
    public var snow_config : SnowConfig;
        /** Whether or not we are frozen, ignoring events i.e backgrounded/paused */
    public var freeze (default,set) : Bool = false;

//Sub systems

        /** The io system */
    public var io : IO;
        /** The input system */
    public var input : Input;
        /** The asset system */
    public var assets : Assets;
        /** The audio system */
    public var audio : Audio;
        /** The window manager */
    public var windowing : Windowing;
        /** The platform identifier, a string,
            but uses `snow.types.Types.Platform` abstract enum internally */
    public var platform : String = 'unknown';
        /** The os identifier, a string,
            but uses `snow.types.Types.OS` abstract enum internally */
    public var os : String = 'unknown';
        /** A debug flag for convenience, true if the app was built with the haxe -debug flag or define */
    public var debug : Bool = #if debug true #else false #end;

        /** Set if shut down has commenced */
    public var shutting_down : Bool = false;
        /** Set if shut dow has completed  */
    public var has_shutdown : Bool = false;
        /** If the config specifies a default window, this is it */
    public var window : Window;

//Internal values

        //if already passed the ready state
    var was_ready : Bool = false;
        //if ready has completed, so systems can begin safely
    var is_ready : Bool = false;
        //the core platform instance to bind us
    @:noCompletion public static var core : Core;
        //the list of functions to run next loop
    static var next_queue : Array<Void->Void>;
        //the list of functions to run at the end of the current loop
    static var defer_queue : Array<Void->Void>;

    @:noCompletion
    public function new() {

        if(snow.api.Debug.get_level() > 1) {
            log('log / level to ${snow.api.Debug.get_level()}' );
            log('log / filter : ${snow.api.Debug.get_filter()}');
            log('log / exclude : ${snow.api.Debug.get_exclude()}');
        }

        #if ios      platform = Platform.platform_ios;       #end
        #if mac      platform = Platform.platform_mac;       #end
        #if web      platform = Platform.platform_web;       #end
        #if linux    platform = Platform.platform_linux;     #end
        #if android  platform = Platform.platform_android;   #end
        #if windows  platform = Platform.platform_windows;   #end

            //We create the core as a concrete platform version of the core
        core = new Core( this );
        next_queue = [];
        defer_queue = [];

    } //new

//Public API

        /** Shutdown the engine and quit */
    public function shutdown() {

        shutting_down = true;

        host.ondestroy();
        io.destroy();
        audio.destroy();
        input.destroy();
        windowing.destroy();

        core.shutdown();

        has_shutdown = true;

    } //shutdown

        /** Called for you by snow, unless configured otherwise.
            Only call this manually if your render_rate is 0! */
    public inline function render() {

        windowing.update();

    } //render

    public inline function dispatch_system_event( _event:SystemEvent ) {

        on_event(_event);

    } //dispatch_system_event

//Public static API

        /** Call a function at the start of the next frame,
            useful for async calls in a sync context, allowing the sync function to return safely before the onload is fired. */
    inline
    public static function next( func: Void->Void ) {

        if(func != null) next_queue.push(func);

    } //next

        /** Call a function at the end of the current frame */
    inline
    public static function defer( func: Void->Void ) {

        if(func != null) defer_queue.push(func);

    } //defer

//Internal API

    @:noCompletion
    public function init( _snow_config:SnowConfig, _host : App ) {

        snow_config = _snow_config;

        if(snow_config.app_package == null) {
            snow_config.app_package = 'org.snowkit.snow';
        }

        if(snow_config.config_path == null) {
            snow_config.config_path = '';
        }

        config = default_config();
        host = _host;
        host.app = this;

        core.init( on_event );

    } //init

    function on_snow_init() {

        _debug('init / initializing');
        _debug('init / pre ready, init host');

            //any app pre ready init can be handled in here
        host.on_internal_init();

    } //on_snow_init

    function on_snow_ready() {

        if(was_ready) {
            throw Error.error('firing ready event more than once is invalid usage');
        }

        _debug('init / setting up additional systems...');

                //create the sub systems
            io = new IO( this );
            input = new Input( this );
            audio = new Audio( this );
            assets = new Assets( this );
            windowing = new Windowing( this );

        _debug('modules /');
        _debug('  Assets - '    + typename(assets.module));
        _debug('  Audio - '     + typename(audio.module));
        _debug('  Input - '     + typename(input.module));
        _debug('  IO - '        + typename(io.module));
        _debug('  Windowing - ' + typename(windowing.module));

            //disllow re-entry
        was_ready = true;

        setup_app_path();

        _debug('init / setup default assets : ok');

        setup_configs().then(function(_){

            _debug('init / setup default configs : ok');

            setup_default_window();

            next(on_ready);

        }).error(function(e) {

            throw Error.init('snow / cannot recover from error: $e');

        });

            //make sure the initial promises happen
        snow.api.Promise.Promises.step();

            //make sure all events pushed into
            //the queues are flushed
        while(next_queue.length > 0) {
            cycle_next_queue();
        }

        while(defer_queue.length > 0) {
            cycle_defer_queue();
        }

    } //on_snow_ready

    @:allow(snow.App)
    function do_internal_update( dt:Float ) {

        io.update();
        input.update();
        audio.update();
        host.update( dt );

    } //do_internal_update

        //once start up is done, this is called
    function on_ready() {

        _debug('init / calling host ready');
        is_ready = true;
        host.ready();

    } //on_ready

    function on_snow_update() {

        if(freeze) return;

            //first update timers
        Timer.update();

            //handle promise executions
        snow.api.Promise.Promises.step();

            //handle the events
        cycle_next_queue();

            //game updates aren't allowed till we are flagged
        if(!is_ready) return;

            //handle any internal pre updates
        host.ontickstart();

            //handle any internal updates
        host.on_internal_update();

            //handle any internal render updates
        host.on_internal_render();

            //let the system have some time
        #if snow_native
            Sys.sleep(0);
        #end

            //handle any internal post updates
        host.ontickend();

        cycle_defer_queue();

    } //on_snow_update

    function on_event( _event:SystemEvent ) {

        if( _event.type != SystemEventType.update &&
            _event.type != SystemEventType.unknown &&
            _event.type != SystemEventType.window &&
            _event.type != SystemEventType.input

        ) {
            _debug( 'event / system event / ${_event.type} / $_event');
        }

        if( _event.type != SystemEventType.update ) {
            _verboser( 'event / system event / $_event');
        }

            //all systems should get these basically...
            //cos of app lifecycles etc being here.
        if(is_ready) {
            io.on_event( _event );
            audio.on_event( _event );
            windowing.on_event( _event );
            input.on_event( _event );
        }

        host.onevent( _event );

        switch(_event.type) {

            case SystemEventType.init: {
                on_snow_init();
            } //init

            case SystemEventType.ready: {
                on_snow_ready();
            } //ready

            case SystemEventType.update: {
                on_snow_update();
            } //update

            case SystemEventType.quit, SystemEventType.app_terminating: {
                shutdown();
            } //quit

            case SystemEventType.shutdown: {
                log('Goodbye.');
            } //shutdown

            default: {

            } //default

        } //switch _event.type

    } //on_event

    inline function cycle_next_queue() {

        var count = next_queue.length;
        var i = 0;
        while(i < count) {
            (next_queue.shift())();
            ++i;
        }

    } //cycle_next_queue

    inline function cycle_defer_queue() {

        var count = defer_queue.length;
        var i = 0;
        while(i < count) {
            (defer_queue.shift())();
            ++i;
        }

    } //cycle_next_queue

//Setup specifics

        //ensure that we are in the correct location for asset loading
    function setup_app_path() {

        #if snow_native

            var app_path = io.module.app_path();
            var pref_path = io.module.app_path_prefs();

            Sys.setCwd( app_path );

            _debug('init / setting up app path $app_path');
            _debug('init / setting up pref path: $pref_path');

        #end //snow_native

    } //setup_app_path

    function setup_configs() {

            //blank config path means don't try to load config.json
        if(snow_config.config_path == '') {
            setup_host_config();
            return Promise.resolve();
        }

        return new Promise(function(resolve, reject) {

            _debug('config / fetching runtime config');

            default_runtime_config().then(function(_runtime_conf:Dynamic) {

                config.runtime = _runtime_conf;

            }).error(function(error){

                throw Error.init('config / failed / default runtime config failed to parse as JSON. cannot recover. $error');

            }).then(function(){

                setup_host_config();
                resolve();

            });

        }); //promise

    } //setup_configs

    function setup_host_config() {

        _debug('config / fetching user config');

        config = host.config( config );

    } //setup_host_config

    function setup_default_window() {

        _debug('windowing / creating default window');

            //force fullscreen on mobile to get better
            //behavior from the window for now.
            //borderless will control the status bar
        #if mobile
            config.window.fullscreen = true;
        #end //mobile

            //now if they requested a window, let's open one
        if(config.has_window == true) {

            _debug('windowing / has window, so creating with ${config.window}');

            window = windowing.create( config.window );

                //failed to create?
            if(window.handle == null) {
                throw Error.windowing('requested default window cannot be created. cannot continue');
            }

        } else { //has_window

            _debug('windowing / not! creating default window, has_window was ${config.has_window}');

        }

    } //create_default_window

//Default handlers

    function default_config() : AppConfig {
        return {
            has_window : true,
            runtime : {},
            window : default_window_config(),
            render : default_render_config(),
            web : {
                no_context_menu : true,
                prevent_default_keys : [
                    Key.left, Key.right, Key.up, Key.down,
                    Key.backspace, Key.tab, Key.delete
                ],
                prevent_default_mouse_wheel : true,
                true_fullscreen : false
            },
            native : {
                audio_buffer_length : 176400,
                audio_buffer_count : 4
            }
        }
    }

        /** handles the default method of parsing a runtime config json,
            To change this behavior override `get_runtime_config`. This is called by default in get_runtime_config. */
    function default_runtime_config() : Promise {

        _debug('config / setting up default runtime config');

            //for the default config, we only reject if there is a json parse error
        return new Promise(function(resolve, reject) {

            var load = io.data_flow( assets.path(snow_config.config_path), AssetJSON.processor);

                load.then(resolve).error(function(error:Error) {
                    switch(error) {
                        case Error.parse(val):
                            reject(error);
                        case _:
                            _debug('config / default config rejected / $error');
                            resolve();
                    }
                });

        }); //promise

    } //default_runtime_config

        /** Returns a default configured render config */
    function default_render_config() : RenderConfig {

        _debug('config / fetching default render config');

        return {
            depth : false,
            stencil : false,
            antialiasing : 0,
            red_bits : 8,
            green_bits : 8,
            blue_bits : 8,
            alpha_bits : 8,
            depth_bits : 0,
            stencil_bits : 0,
            opengl : {
                minor:0, major:0,
                profile:OpenGLProfile.compatibility
            }
        };

    } //default_render_config

        /** Returns a default configured window config */
    function default_window_config() : WindowConfig {

        _debug('config / fetching default window config');

        var conf =  {
            fullscreen_desktop  : true,
            fullscreen          : false,
            borderless          : false,
            resizable           : true,
            x                   : 0x1FFF0000,
            y                   : 0x1FFF0000,
            width               : 960,
            height              : 640,
            title               : 'snow app'
        };

            #if mobile
                conf.fullscreen = true;
                conf.borderless = true;
            #end //mobile

        return conf;

    } //default_window_config

//Properties

    function set_freeze( _freeze:Bool ) {

        freeze = _freeze;

        if(_freeze) {
            audio.suspend();
        } else {
            audio.resume();
        }

        return freeze;

    } //set_freeze

    inline function get_time() : Float return core.timestamp();
    inline function get_uniqueid() : String return make_uniqueid();
    static inline function get_timestamp() return core.timestamp();

//Helpers


        // http://www.anotherchris.net/csharp/friendly-unique-id-generation-part-2/#base62
    function make_uniqueid(?val:Int) : String {

        if(val == null) {
            #if neko val = Std.random(0x3FFFFFFF);
            #else val = Std.random(0x7fffffff);
            #end
        }

        inline function to_char(value:Int) {
            if (value > 9) {
                var ascii = (65 + (value - 10));
                if (ascii > 90) ascii += 6;
                return String.fromCharCode(ascii);
            } else return Std.string(value).charAt(0);
        } //to_char

        var r = Std.int(val % 62);
        var q = Std.int(val / 62);

        if (q > 0) return make_uniqueid(q) + to_char(r);

        return Std.string(to_char(r));

    } //make_uniqueid

    inline function typename(t:Dynamic) {
        return Type.getClassName(Type.getClass(t));
    }

} //Snow



#if snow_web
    private typedef Core = snow.core.web.Core;
#else
    private typedef Core = snow.core.native.Core;
#end