package snow.modules.interfaces;

import snow.types.Types;
import snow.system.window.Window;

@:noCompletion
@:allow(snow.system.window.Windowing)
interface Windowing {

    private function init():Void;
    private function update():Void;
    private function destroy():Void;
    private function on_event( event:SystemEvent ):Void;

    private function listen( window:snow.system.window.Window ):Void;
    private function unlisten( window:snow.system.window.Window ):Void;


        /** Create a window with config, calls on_created when complete passing the handle, the ID,
            and the actual config that was used since the requested config could fail */
    function create( render_config:RenderConfig, config:WindowConfig, on_created: WindowHandle->Int->WindowingConfig->Void ) : Void;
        /** Close a given window */
    function close( window:Window ) : Void;
        /** reopen this window once closed. Destroyed windows cannot be reopened, it must use create again */
    function show( window:Window ) : Void;
        /** Close a given window */
    function destroy_window( window:Window ) : Void;
        /** Update a given window */
    function update_window( window:Window ) : Void;
        /** Render a given window */
    function render( window:Window ) : Void;
        /** Swap a given window */
    function swap( window:Window ) : Void;
        /** Display a message on a window */
    function simple_message( window:Window, message:String, ?title:String="" ) : Void;
        /** Set the size of a window */
    function set_size( window:Window, w:Int, h:Int ) : Void;
        /** Set the position of a window */
    function set_position( window:Window, x:Int, y:Int ) : Void;
        /** Set the title of a window */
    function set_title( window:Window, title:String ) : Void;
        /** Set the max size of a window */
    function set_max_size( window:Window, w:Int, h:Int ) : Void;
        /** Set the min size of a window */
    function set_min_size( window:Window, w:Int, h:Int ) : Void;
        /** Set the fullscreen state of a window */
    function fullscreen( window:Window, fullscreen:Bool ) : Void;
        /** Set the bordered state of a window */
    function bordered( window:Window, bordered:Bool ) : Void;

//cursor
        /** Set the grab state of a window */
    function grab( window:Window, grabbed:Bool ) : Void;
        /** Set the cursor position inside of a given window */
    function set_cursor_position( window:Window, x:Int, y:Int ) : Void;

//General

        /** Toggle the OS cursor. This is not window specific but system wide */
    function system_enable_cursor( enable:Bool ) : Void;
        /** Lock the OS cursor to the foreground window. This hides the cursor and prevents it from leaving, reporting relative coordinates. */
    function system_lock_cursor( enable:Bool ) : Void;
        /** Toggle vertical refresh. This is not window specific but context wide, returns 0 on success or -1 if not supported */
    function system_enable_vsync( enable:Bool ) : Int;

//Desktop

        /** Get the number of displays present */
    function display_count() : Int;
        /** Get the number of display modes present */
    function display_mode_count( display:Int ) : Int;
        /** Get the native mode information of the display by index */
    function display_native_mode( display:Int ) : DisplayMode;
        /** Get the current mode information of the display by index */
    function display_current_mode( display:Int ) : DisplayMode;
        /** Get the information from a specific mode index, the index obtrained from iterating with `display_mode_count` value */
    function display_mode( display:Int, mode_index:Int ) : DisplayMode;
        /** Get the bounds of the display by index */
    function display_bounds( display:Int ) : { x:Int, y:Int, width:Int, height:Int };
        /** Get the name of the display by index, where available */
    function display_name( display:Int ) : String;

} //Windowing