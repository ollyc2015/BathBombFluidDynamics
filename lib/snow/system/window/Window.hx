package snow.system.window;

import snow.types.Types;
import snow.system.window.Windowing;

import snow.modules.opengl.GL;

import snow.api.Debug.*;

    //A window has it's own event loop
    //and allows opening and closing windows
@:allow(snow.system.window.Windowing)
class Window {

        /** the window id, for tracking events to each window */
    public var id : Int;
        /** the system this window belongs to */
    public var system : Windowing;
        /** the requested window config */
    public var asked_config : WindowConfig;
        /** the actual returned window config */
    public var config : WindowConfig;
        /** the native window handle */
    public var handle : WindowHandle;

        /** the window event handler callback */
    public var onevent : WindowEvent->Void;
        /** the window render handler callback */
    public var onrender : Window->Void;

        /** The window title `(read/write)` */
    @:isVar public var title (get,set) : String = 'snow window';
        /** The window bordered state `(read/write)` */
    @:isVar public var bordered (get,set) : Bool = true;
        /** The window grab state `(read/write)` */
    @:isVar public var grab (get,set) : Bool = false;
        /** The window fullscreen state `(read/write)` */
    @:isVar public var fullscreen (get,set) : Bool = false;

        /** The window position `(read/write)` */
    @:isVar public var x (default,set) : Int = 0;
    @:isVar public var y (default,set) : Int = 0;
    @:isVar public var width (default,set) : Int = 0;
    @:isVar public var height (default,set) : Int = 0;

        /** The window maximum size `(read/write)` */
    @:isVar public var max_size (get,set) : { x:Int, y:Int };
        /** The window minimum size `(read/write)` */
    @:isVar public var min_size (get,set) : { x:Int, y:Int };

        /** set this if you want to control when a window calls swap() */
    public var auto_swap : Bool = true;
        /** set this if you want to control when a window calls render() */
    public var auto_render : Bool = true;
        /** A flag for whether this window is open or closed */
    public var closed : Bool = true;

        //internal minimized flag to avoid rendering when minimized.
        //use on_event for this yourself
    var minimized : Bool = false;
    var internal_position : Bool = false;
    var internal_resize : Bool = false;

    public function new( _system:Windowing, _config:WindowConfig ) {

        max_size    = { x:0, y:0 };
        min_size    = { x:0, y:0 };

        system = _system;
        asked_config = _config;
        config = _config;

            //default to OS defined window position
        if(config.x == null) {
            config.x = 0x1FFF0000;
        }

        if(config.y == null) {
            config.y = 0x1FFF0000;
        }

        system.module.create( system.app.config.render, _config, on_window_created );

    } //new

    function on_window_created( _handle:WindowHandle, _id:Int, _configs:{ config:WindowConfig, render_config:RenderConfig } ) : Void {

        id = _id;
        handle = _handle;

        if(handle == null) {
            log("failed to create window");
            return;
        }

        closed = false;
            //store the real config
        config = _configs.config;
            //update the render config in the core
        system.app.config.render = _configs.render_config;

            //update the position and size
            //because it updates in the config
            internal_position = true;
        x = config.x;
        y = config.y;
            internal_position = false;

            internal_resize = true;
        width = config.width;
        height = config.height;
            internal_resize = false;

        #if mobile
        set_fullscreen(fullscreen);
        #end

        on_event({
            type:WindowEventType.created,
            window_id : _id,
            timestamp : system.app.time,
            event : {}
        });

        _debug("created window with id: " + id);
        _debug('updating real window config for $id is ' + _configs);

    } //on_window_created

    function on_event( _event:WindowEvent ) {

        _verbose("window event " + id + " / " + _event.type + " / " + _event.event );

        switch(_event.type) {

            case WindowEventType.moved : {

                    internal_position = true;
                set_position(_event.event.x, _event.event.y);
                    internal_position = false;

            } //moved

            case WindowEventType.resized : {

                    internal_resize = true;
                set_size(_event.event.x, _event.event.y);
                    internal_resize = false;

            } //resized

            case WindowEventType.size_changed : {

                    internal_resize = true;
                set_size(_event.event.x, _event.event.y);
                    internal_resize = false;

            } //size_changed

            case WindowEventType.minimized : {

                minimized = true;

            } //minimized

            case WindowEventType.restored : {

                minimized = false;

            } //restored

            default: {}

        } //switch

        if(onevent != null) {
            onevent( _event );
        }

    } //on_event

    function update() {

        if(handle != null && !closed) {
            system.module.update_window( this );
        }

    } //update


        /** Called for you automatically, unless auto_render is disabled. */
    public function render() {

        if(minimized || closed) {
            return;
        }

        if(handle == null) {
            return;
        }

        system.module.render( this );

        if(onrender != null) {

            onrender( this );

            if(auto_swap) {
                swap();
            }

            return;

        } //has render handler

        GL.clearColor( 0, 0, 0, 1.0 );
        GL.clear(GL.COLOR_BUFFER_BIT);

        if(auto_swap) {
            swap();
        }

    } //render

        /** Swap the back buffer of the window, call after rendering to update the window view */
    public function swap() {

        if(handle == null || closed || minimized) {
            return;
        }

        system.module.swap( this );

    } //swap

        /** Destroy the window. To recreate it create must be used, show will not work. */
    public function destroy() {

        closed = true;

        if(handle == null) {
            return;
        }
            //remove from the internal list
        system.remove(this);
            //destroy system window
        system.module.destroy_window( this );
            //clear handle as it's invalid
        handle = null;

    } //destroy

        /** Close the window, hiding it (not destroying it). Calling show() will unhide it. */
    public function close() {

        closed = true;

        if(handle == null) {
            return;
        }

        system.module.close( this );

    } //close

        /** Show the window, unhiding it. If destroyed, nothing happens. */
    public function show() {

        if(handle == null) {
            return;
        }

        closed = false;

        system.module.show( this );

    } //show

        /** Display a cross platform message on this window */
    public function simple_message( message:String, title:String="" ) {

        if(handle == null) {
            return;
        }

        system.module.simple_message( this, message, title );

    } //simple_message

    function get_fullscreen() : Bool {

        return fullscreen;

    } //get_fullscreen


    function set_fullscreen( _enable:Bool ) {

        if(handle != null) {
            system.module.fullscreen( this, _enable );
        }

        return fullscreen = _enable;

    } //set_fullscreen

    function get_bordered() : Bool {

        return bordered;

    } //get_bordered

    function get_grab() : Bool {

        return grab;

    } //get_grab

    function get_max_size() : { x:Int, y:Int } {

        return max_size;

    } //get_max_size

    function get_min_size() : { x:Int, y:Int } {

        return min_size;

    } //get_min_size

    function get_title() : String {

        return title;

    } //get_title

    function set_title( _title:String ) {

        if(handle != null) {
            system.module.set_title( this, _title );
        }

        return title = _title;

    } //set_title

    function set_x( _x:Int ) : Int {

        x = _x;

        if(handle != null && !internal_position) {
            system.module.set_position( this, x, y );
        }

        return x;

    } //set_x

    function set_y( _y:Int ) : Int {

        y = _y;

        if(handle != null && !internal_position) {
            system.module.set_position( this, x, y );
        }

        return y;

    } //set_y

    function set_width( _width:Int ) : Int {

        width = _width;

        if(handle != null && !internal_resize) {
            system.module.set_size( this, width, height );
        }

        return width;

    } //set_width

    function set_height( _height:Int ) : Int {

        height = _height;

        if(handle != null && !internal_resize) {
            system.module.set_size( this, width, height );
        }

        return height;

    } //set_height

    public function set_cursor_position( _x:Int, _y:Int ) {

        if(handle != null && !closed) {
            system.module.set_cursor_position( this, _x, _y );
        }

    } //set_cursor_position

    public function set_position( _x:Int, _y:Int ) {

            //keep the flag
        var last_internal_position_flag = internal_position;

            //force true
        internal_position = true;
            x = _x;
            y = _y;
        internal_position = last_internal_position_flag;

            //this is never called
        if(handle != null && !internal_position) {
            system.module.set_position( this, x, y );
        }

    } //set_position

    public function set_size( _width:Int, _height:Int ) {

            //keep the flag
        var last_internal_resize_flag = internal_resize;

            //force true
        internal_resize = true;
            width = _width;
            height = _height;
        internal_resize = last_internal_resize_flag;

        if(handle != null && !internal_resize) {
            system.module.set_size( this, _width, _height );
        }

    } //set_size

    function set_max_size( _size:{ x:Int, y:Int } ) : { x:Int, y:Int } {

        if(max_size != null && handle != null) {
            system.module.set_max_size( this, _size.x, _size.y );
        }

        return max_size = _size;

    } //set_max_size

    function set_min_size( _size: { x:Int, y:Int } ) : { x:Int, y:Int } {

        if(min_size != null && handle != null) {
            system.module.set_min_size( this, _size.x, _size.y );
        }

        return min_size = _size;

    } //set_min_size

    function set_bordered( _bordered:Bool ) : Bool {

        if(handle != null) {
            system.module.bordered( this, _bordered );
        }

        return bordered = _bordered;

    } //set_bordered

    function set_grab( _grab:Bool ) : Bool {

        if(handle != null) {
            system.module.grab( this, _grab );
        }

        return grab = _grab;

    } //set_grab

} //Window
