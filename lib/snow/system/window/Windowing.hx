package snow.system.window;

import snow.types.Types;
import snow.system.window.Window;

#if (!macro && !display && !scribe)
    private typedef WindowingModule = haxe.macro.MacroType<[snow.system.module.Module.assign('Windowing')]>;
#end

/** The window manager, accessed via `app.window` */
@:allow(snow.Snow)
@:allow(snow.system.window.Window)
class Windowing {

        /** The list of windows in this manager */
    public var window_list : Map<Int, Window>;
        /** The list of window handles, pointing to id's in the `window_list` */
    public var window_handles : WindowHandleMap;
        /** The number of windows in this manager */
    public var window_count : Int = 0;

        /** access to snow for subsystems/windows */
    @:noCompletion public var app : Snow;
        /** The concrete implementation of the window system */
    @:noCompletion public var module : snow.system.module.Windowing;


        /** constructed internally, use `app.windowing` */
    function new( _app:Snow ) {

        app = _app;
        window_list = new Map();
        window_handles = new WindowHandleMap();

        module = new snow.system.module.Windowing(this);

        module.init();

    } //new

//Public facing API

        /** Create a window with the given config. */
    public function create( _config:WindowConfig ) : Window {

        var _window = new Window( this, _config );

            window_list.set( _window.id, _window );
            window_handles.set( _window.handle, _window.id );
            window_count++;

            //handle any window system specifics that have to happen
            //to this window when creating it, like enter/leave events
        module.listen( _window );

            //unless requested not to, give this window to the input
            //system to listen for events and dispatch them as needed
        if(_config.no_input == null || _config.no_input == false) {
            app.input.listen( _window );
        }

        return _window;

    } //create

        /** Remove a window from the system, stopping events, etc.
            Called from window.destroy()! Don't use manually unless manually controlling the list. */
    function remove( _window:Window ) {

        window_list.remove( _window.id );
        window_handles.remove( _window.handle );
        window_count--;

        module.unlisten( _window );

        if(_window.config.no_input == null || _window.config.no_input == false) {
            app.input.unlisten( _window );
        }

    } //remove

        /** Get a window instance from an window handle. */
    @:noCompletion public function window_from_handle( _handle:WindowHandle ) : Window {

        if(window_handles.exists(_handle)) {
            var _id = window_handles.get(_handle);
            return window_list.get(_id);
        }

        return null;

    } //window_from_handle

        /** Get a window instance from an ID. */
    @:noCompletion public function window_from_id( _id:Int ) : Window {

        return window_list.get(_id);

    } //window_from_id

//System helpers

        /** Toggle vertical refresh. This is not window specific but context wide */
    public function enable_vsync( _enable:Bool ) : Int {

        return module.system_enable_vsync(_enable);

    } //enable_vsync

        /** Toggle the OS cursor. This is not window specific but application wide, when inside a window, the OS cursor is hidden. */
    public function enable_cursor( _enable:Bool ) : Void {

        module.system_enable_cursor(_enable);

    } //enable_cursor

        /** Lock the OS cursor to the foreground window. This hides the cursor and prevents it from leaving, reporting relative coordinates. */
    public function enable_cursor_lock( _enable:Bool ) : Void {

        module.system_lock_cursor(_enable);

    } //enable_cursor

//Desktop API
    //note that these only make sense on some platforms but will
    //try and return valid values either way. Use the window itself for info

        /** Get the number of displays present */
    public function display_count() : Int {
        return module.display_count();
    } //display_count

        /** Get the number of display modes present */
    public function display_mode_count( display:Int ) : Int {
        return module.display_mode_count(display);
    } //display_mode_count

        /** Get the native mode information of the display by index */
    public function display_native_mode( display:Int ) : DisplayMode {
        return module.display_native_mode(display);
    } //display_native_mode

        /** Get the current mode information of the display by index */
    public function display_current_mode( display:Int ) : DisplayMode {
        return module.display_current_mode(display);
    } //display_current_mode

        /** Get the information from a specific mode index, the index is obtained by iterating with a `display_mode_count` as the loop value */
    public function display_mode( display:Int, mode_index:Int ) : DisplayMode {
        return module.display_mode(display, mode_index);
    } //display_mode

        /** Get the bounds of the display by index */
    public function display_bounds( display:Int ) : { x:Int, y:Int, width:Int, height:Int } {
        return module.display_bounds(display);
    } //display_bounds

        /** Get the name of the display by index, where available */
    public function display_name( display:Int ) : String {
        return module.display_name(display);
    } //display_name


//Internal core API

        /** Called by Snow when a system event is dispatched */
    function on_event( _event:SystemEvent ) {

        if(_event.type == SystemEventType.window) {

            var _window_event = _event.window;

            var _window = window_list.get( _window_event.window_id );

            if(_window != null) {
                _window.on_event( _window_event );
            }

        } //only window events

    } //on_event

        /** Called by Snow, process any window handling */
    function update() {

        module.update();

        for(window in window_list) {
            window.update();
        }

        for(window in window_list) {
            if(window.auto_render) {
                window.render();
            }
        }

    } //update

        /** Called by Snow, destroy everything. */
    function destroy() {

        module.destroy();

    } //destroy


} //Windowing


#if snow_web

    private typedef WindowHandleMap = Map<WindowHandle, Int>;

#else

    private class WindowHandleMap extends haxe.ds.BalancedTree<WindowHandle,Int> {

        override function compare(k1:WindowHandle, k2:WindowHandle) {
            if(k1 == null) return 1;
            if(k2 == null) return 1;
            if(k1 == k2) return 0;
            if(k1 < k2) return -1;
            return 1;
        }

    } //WindowHandleMap

#end
