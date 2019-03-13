package snow.core.native.window;


import snow.Snow;
import snow.types.Types;
import snow.system.window.Window;
import snow.system.window.Windowing;

import snow.api.Libs;

 //Internal class handled by Windowing, the window system gives access to window features and functions
 //allowing the abstraction to exist between platform and implementation, so the system can be swapped out and the implementation remains unchanged.

@:allow(snow.system.window.Windowing)
class Windowing implements snow.modules.interfaces.Windowing {

    var system:snow.system.window.Windowing;

    function new( _system:snow.system.window.Windowing ) system = _system;

    function init() {}
    function update() {}
    function destroy() {}
    function on_event( event:SystemEvent ) {}

    function listen( window:Window ) {}
    function unlisten( window:Window ) {}

    public inline function create( render_config:RenderConfig, config:WindowConfig, on_created: WindowHandle->Int->WindowingConfig->Void ) {
    	snow_window_create( render_config, config, on_created );
    } //window_create

    public inline function close( window:Window ) {
        snow_window_close( window.handle );
    } //close

    public inline function show( window:Window ) {
        snow_window_show( window.handle );
    }

    public inline function destroy_window( window:Window ) {
		snow_window_destroy_window( window.handle );
    }

    public inline function update_window( window:Window ) {
		snow_window_update( window.handle );
    }

    public inline function render( window:Window ) {
		snow_window_render( window.handle );
    }

    public inline function swap( window:Window ) {
		snow_window_swap( window.handle );
    }

    public inline function simple_message( window:Window, message:String, ?title:String="" ) {
		snow_window_simple_message( window.handle, message, title );
    } //window_simple_message

    public inline function set_size( window:Window, w:Int, h:Int ) {
    	snow_window_set_size( window.handle, w, h );
    } //window_set_size

    public inline function set_position( window:Window, x:Int, y:Int ) {
    	snow_window_set_position( window.handle, x, y );
    } //window_set_position

    public inline function set_title( window:Window, title:String ) {
    	snow_window_set_title( window.handle, title );
    } //window_set_title

    public inline function set_max_size( window:Window, w:Int, h:Int ) {
    	snow_window_set_max_size( window.handle, w, h );
    } //window_set_max_size

    public inline function set_min_size( window:Window, w:Int, h:Int ) {
    	snow_window_set_min_size( window.handle, w, h );
    } //window_set_min_size

    public inline function fullscreen( window:Window, fullscreen:Bool ) {
    	snow_window_fullscreen( window.handle, fullscreen, ( window.config.fullscreen_desktop ) ? 0 : 1 );
    } //window_fullscreen

    public inline function bordered( window:Window, bordered:Bool ) {
    	snow_window_bordered( window.handle, bordered );
    } //window_bordered

    public inline function grab( window:Window, grabbed:Bool ) {
        snow_window_grab( window.handle, grabbed );
    } //window_grab

    public inline function set_cursor_position( window:Window, x:Int, y:Int ) {
        snow_window_set_cursor_position( window.handle, x, y );
    } //set_cursor_position


//General

        /** Lock the OS cursor to the foreground window. This hides the cursor and prevents it from leaving, reporting relative coordinates. */
    public inline function system_lock_cursor( enable:Bool ) {
        snow_system_lock_cursor( enable );
    } //system_lock_cursor

        /** Toggle the OS cursor. This is not window specific but system wide */
    public inline function system_enable_cursor( enable:Bool ) {
        snow_system_show_cursor( enable );
    } //system_enable_cursor

        /** Toggle vertical refresh. This is not window specific but context wide */
    public inline function system_enable_vsync( enable:Bool ) : Int {
        return snow_system_enable_vsync( enable );
    } //system_enable_vsync


//Desktop only functions


    public inline function display_count() : Int {
        return snow_desktop_get_display_count();
    } //desktop_get_display_count

    public inline function display_mode_count( display:Int ) : Int {
        return snow_desktop_get_display_mode_count( display );
    } //desktop_get_display_mode_count

    public inline function display_native_mode( display:Int ) : DisplayMode {
        return snow_desktop_get_display_native_mode( display );
    } //desktop_get_display_native_mode

    public inline function display_current_mode( display:Int ) : DisplayMode {
        return snow_desktop_get_display_current_mode( display );
    } //desktop_get_display_current_mode

    public inline function display_mode( display:Int, mode_index:Int ) : DisplayMode {
        return snow_desktop_get_display_mode( display, mode_index );
    } //desktop_get_display_mode

    public inline function display_bounds( display:Int ) : { x:Int, y:Int, width:Int, height:Int } {
        return snow_desktop_get_display_bounds( display );
    } //desktop_get_display_bounds

    public inline function display_name( display:Int ) : String {
        return snow_desktop_get_display_name( display );
    } //desktop_get_display_name


//Native bindings


    static var snow_window_create                   = Libs.load( "snow", "snow_window_create", 3 );
    static var snow_window_close                    = Libs.load( "snow", "snow_window_close", 1 );
    static var snow_window_show                     = Libs.load( "snow", "snow_window_show", 1 );
    static var snow_window_destroy_window           = Libs.load( "snow", "snow_window_destroy_window", 1 );
    static var snow_window_update                   = Libs.load( "snow", "snow_window_update", 1 );
    static var snow_window_render                   = Libs.load( "snow", "snow_window_render", 1 );
    static var snow_window_swap                     = Libs.load( "snow", "snow_window_swap", 1 );
    static var snow_window_simple_message           = Libs.load( "snow", "snow_window_simple_message", 3 );
    static var snow_window_set_size                 = Libs.load( "snow", "snow_window_set_size", 3 );
    static var snow_window_set_position             = Libs.load( "snow", "snow_window_set_position", 3 );
    static var snow_window_set_title                = Libs.load( "snow", "snow_window_set_title", 2 );
    static var snow_window_set_max_size             = Libs.load( "snow", "snow_window_set_max_size", 3 );
    static var snow_window_set_min_size             = Libs.load( "snow", "snow_window_set_min_size", 3 );
    static var snow_window_fullscreen               = Libs.load( "snow", "snow_window_fullscreen", 3 );
    static var snow_window_bordered                 = Libs.load( "snow", "snow_window_bordered", 2 );
    static var snow_window_grab                     = Libs.load( "snow", "snow_window_grab", 2 );
    static var snow_window_set_cursor_position      = Libs.load( "snow", "snow_window_set_cursor_position", 3 );

//system helpers

    static var snow_system_show_cursor              = Libs.load("snow", "snow_system_show_cursor", 1);
    static var snow_system_lock_cursor              = Libs.load("snow", "snow_system_lock_cursor", 1);
    static var snow_system_enable_vsync             = Libs.load("snow", "snow_system_enable_vsync", 1);

//desktop only native bindings

    static var snow_desktop_get_display_count         = Libs.load("snow", "snow_desktop_get_display_count", 0);
    static var snow_desktop_get_display_mode_count    = Libs.load("snow", "snow_desktop_get_display_mode_count", 1);
    static var snow_desktop_get_display_native_mode   = Libs.load("snow", "snow_desktop_get_display_native_mode", 1);
    static var snow_desktop_get_display_current_mode  = Libs.load("snow", "snow_desktop_get_display_current_mode", 1);
    static var snow_desktop_get_display_mode          = Libs.load("snow", "snow_desktop_get_display_mode", 2);
    static var snow_desktop_get_display_bounds        = Libs.load("snow", "snow_desktop_get_display_bounds", 1);
    static var snow_desktop_get_display_name          = Libs.load("snow", "snow_desktop_get_display_name", 1);

} //Windowing




