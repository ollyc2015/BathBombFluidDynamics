package snow.core.web.window;

#if snow_web

import snow.types.Types;
import snow.system.window.Window;

@:allow(snow.system.window.Windowing)
class Windowing implements snow.modules.interfaces.Windowing {

    public var gl_contexts : Map<Int, js.html.webgl.RenderingContext>;

    var seq_window : Int = 1;
    var fs_windows : Array<Window>;
    var system : snow.system.window.Windowing;

    public function new( _system:snow.system.window.Windowing ) {

        system = _system;
        fs_windows = [];
        gl_contexts = new Map();

    } //new

    function init() {

        listen_for_visibility();
        listen_for_resize();

    } //init

    function update() {}
    function destroy() {}
    function on_event(event:SystemEvent) {}

    function _copy_config( _config:WindowConfig ) {
        return {
            borderless:_config.borderless,
            fullscreen:_config.fullscreen,
            fullscreen_desktop:_config.fullscreen_desktop,
            height:_config.height,
            no_input:_config.no_input,
            resizable:_config.resizable,
            title:_config.title,
            width:_config.width,
            x:_config.x,
            y:_config.y
        }
    }

    public function create( render_config:RenderConfig, _config:WindowConfig, on_created: WindowHandle->Int->WindowingConfig->Void ) {

        var _window_id = seq_window;
        var _handle : js.html.CanvasElement = js.Browser.document.createCanvasElement();
        var config = _copy_config(_config);

                //assign the initial sizes
            _handle.width = config.width;
            _handle.height = config.height;

                //make sure it displays nicely
            _handle.style.display = 'block';
            _handle.style.position = 'relative';
            _handle.style.background = '#000';

                //add it to the document
            js.Browser.document.body.appendChild(_handle);

            //:todo: These options need to be exposed and documented
        var _gl_context = _handle.getContextWebGL({ alpha:false, premultipliedAlpha:false, antialias: render_config.antialiasing > 0 });
            //early out on no possible context
        if(_gl_context == null) {
            var msg =  'WebGL is required to run this!<br/><br/>';
                msg += 'visit http://get.webgl.org/ for help <br/>';
                msg += 'and contact the developer of the application';
            internal_fallback(msg);
            throw Error.windowing(msg);
        }

            //make sure there is a set up context early
        if(snow.modules.opengl.GL.current_context == null) {
            snow.modules.opengl.GL.current_context = _gl_context;
        }

            //store it for activating later
        gl_contexts.set(_window_id, _gl_context);

            //get the real canvas position and give it to the config
        var _window_pos = get_real_window_position( _handle );

            config.x = _window_pos.x;
            config.y = _window_pos.y;

            //set the window title to the config title if there is one
        if(config.title != null && config.title != '') {
            js.Browser.document.title = config.title;
        }

            //tell them and give the handle for later.
        on_created(_handle, _window_id, { config:config, render_config:render_config });
        _handle.setAttribute('id', 'window${_window_id}');

        seq_window++;

    } //window_create

    public function destroy_window( _window:Window ) {

        js.Browser.document.body.removeChild( _window.handle );

    } //destroy_window

    public function close( _window:Window ) {

        _window.handle.style.display = 'none';

    } //close

    public function show( _window:Window ) {

        _window.handle.style.display = null;

    } //show

    function internal_resize( _window:Window, _w:Float, _h:Float ) {

        system.app.dispatch_system_event({
            type : SystemEventType.window,
            window : {
                type : WindowEventType.size_changed,
                timestamp : system.app.time,
                window_id : _window.id,
                event : { x:_w, y:_h }
            }
        });

        system.app.dispatch_system_event({
            type : SystemEventType.window,
            window : {
                type : WindowEventType.resized,
                timestamp : system.app.time,
                window_id : _window.id,
                event : { x:_w, y:_h }
            }
        });

    } //internal_resize

    public function update_window( _window:Window ) {

        var _rect = _window.handle.getBoundingClientRect();

            if(_rect.left != _window.x || _rect.top != _window.y) {

                system.app.dispatch_system_event({
                    type : SystemEventType.window,
                    window : {
                        type : WindowEventType.moved,
                        timestamp : system.app.time,
                        window_id : _window.id,
                        event : { x:_rect.left, y:_rect.top }
                    }
                });

            }

            if(_rect.width != _window.width || _rect.height != _window.height) {

                internal_resize(_window, _rect.width, _rect.height);

            }

        _rect = null;

    } //window_update

    public function render( _window:Window ) {

        var _window_gl_context = gl_contexts.get(_window.id);
        if(snow.modules.opengl.GL.current_context != _window_gl_context) {
            snow.modules.opengl.GL.current_context = _window_gl_context;
        }

    } //window_render

    public function swap( _window:Window ) {

        //:unsupported:
        //this concept is not possible in browser

    } //window_swap

    public function simple_message( _window:Window, message:String, ?title:String="" ) {

        js.Browser.window.alert( message );

    } //window_simple_message

    public function set_size( _window:Window, w:Int, h:Int ) {

        _window.handle.width = w;
        _window.handle.height = h;
        _window.handle.style.width = '${w}px';
        _window.handle.style.height = '${h}px';

        internal_resize(_window, w, h);

    } //window_set_size

    public function set_position( _window:Window, x:Int, y:Int ) {

        _window.handle.style.left = '${x}px';
        _window.handle.style.top = '${y}px';

    } //window_set_position

    public function get_real_window_position( handle:WindowHandle ) : { x:Int, y:Int } {

        // see the following link for this implementation
        // http://www.quirksmode.org/js/findpos.html

        var curleft = 0;
        var curtop = 0;

            //start at the canvas
        var _obj : js.html.Element = cast handle;

        var _has_parent : Bool = true;
        var _max_count = 0;

        while(_has_parent == true) {

            _max_count++;

            if(_max_count > 100) {
                _has_parent = false;
                break;
            } //prevent rogue endless loops

            if(_obj.offsetParent != null) {

                    //it still has an offset parent, add it up
                curleft += _obj.offsetLeft;
                curtop += _obj.offsetTop;

                    //then move onto the parent
                _obj = cast _obj.offsetParent;

            } else {
                    //we are done
                _has_parent = false;

            }
        } //while

        return { x:curleft, y:curtop };

    } //get_real_window_position

    public function set_title( _window:Window, title:String ) {

        js.Browser.document.title = title;

    } //window_set_title

    public function set_max_size( _window:Window, w:Int, h:Int ) {

        _window.handle.style.maxWidth = '${w}px';
        _window.handle.style.maxHeight = '${h}px';

    } //window_set_max_size

    public function set_min_size( _window:Window, w:Int, h:Int ) {

        _window.handle.style.minWidth = '${w}px';
        _window.handle.style.minHeight = '${h}px';

    } //window_set_min_size



    var _pre_fs_padding : String = '0';
    var _pre_fs_margin : String = '0';
    var _pre_fs_s_width : String = '';
    var _pre_fs_s_height : String = '';
    var _pre_fs_width : Int = 0;
    var _pre_fs_height : Int = 0;
    var _pre_fs_body_overflow : String = '0';
    var _pre_fs_body_margin : String = '0';

    function internal_fullscreen( _window:Window, fullscreen:Bool ) {

        var  _handle = _window.handle;

            //track for resizes
        if(fullscreen) {
            if(fs_windows.indexOf(_window) == -1) {
                fs_windows.push(_window);
            }
        } else {
            fs_windows.remove(_window);
        }

            //find out if the config requested true fullscreen or not
        var true_fullscreen = system.app.config.web.true_fullscreen;

            //as always browser support for newer features will be
            //sporadic. Tested fullscreen against firefox/chrome/opera/safari latest
            //all appear to work as expected, but have no cancel (user must press escape)
        if(fullscreen) {

            if(true_fullscreen) {


                    //official api's first
                if(untyped _handle.requestFullscreen == null) {
                    if(untyped _handle.requestFullScreen == null) {
                        if(untyped _handle.webkitRequestFullscreen == null) {
                            if(untyped _handle.mozRequestFullScreen == null) {

                            } else { untyped _handle.mozRequestFullScreen(); }
                        } else { untyped _handle.webkitRequestFullscreen(); }
                    } else { untyped _handle.requestFullScreen(null); }
                } else { untyped _handle.requestFullscreen(); }

            } else {

                _pre_fs_padding = _handle.style.padding;
                _pre_fs_margin = _handle.style.margin;
                _pre_fs_s_width = _handle.style.width;
                _pre_fs_s_height = _handle.style.height;
                _pre_fs_width = _handle.width;
                _pre_fs_height = _handle.height;
                _pre_fs_body_margin = js.Browser.document.body.style.margin;
                _pre_fs_body_overflow = js.Browser.document.body.style.overflow;

                _handle.style.margin = '0';
                _handle.style.padding = '0';
                _handle.style.width = js.Browser.window.innerWidth + 'px';
                _handle.style.height = js.Browser.window.innerHeight + 'px';
                _handle.width = js.Browser.window.innerWidth;
                _handle.height = js.Browser.window.innerHeight;

                    //stop the browser page from having scrollbars etc
                js.Browser.document.body.style.margin = '0';
                js.Browser.document.body.style.overflow = 'hidden';

            }

        } else {

            if(true_fullscreen) {

                //:unsupported:
                //currently no cancel full screen in fullscreen mode

            } else {

                _handle.style.padding = _pre_fs_padding;
                _handle.style.margin = _pre_fs_margin;
                _handle.style.width = _pre_fs_s_width;
                _handle.style.height = _pre_fs_s_height;
                _handle.width = _pre_fs_width;
                _handle.height = _pre_fs_height;
                js.Browser.document.body.style.margin = _pre_fs_body_margin;
                js.Browser.document.body.style.overflow = _pre_fs_body_overflow;

            }

        }

    } //set_handle_fullscreen

    public function fullscreen( _window:Window, fullscreen:Bool ) {

        internal_fullscreen( _window, fullscreen );

    } //window_fullscreen

    public function bordered( _window:Window, bordered:Bool ) {

        //:unsupported:
        //no such concept on browser

    } //window_bordered


    public function grab( _window:Window, grabbed:Bool ) {

        if(grabbed) {
                //official api's first
            if(_window.handle.requestPointerLock == null) {
                    if(untyped _window.handle.webkitRequestPointerLock == null) {
                        if(untyped _window.handle.mozRequestPointerLock == null) {

                        } else { untyped _window.handle.mozRequestPointerLock(); }
                    } else { untyped _window.handle.webkitRequestPointerLock(); }
            } else { _window.handle.requestPointerLock(); }

        } else {

            //:unsupported:
            //pointer lock cancel api not yet in browsers,
            //user must press escape

        }

    } //window_grab

    public function set_cursor_position( _window:Window, x:Int, y:Int ) {

        // :unsupported:
        // for good reason.

    } //set_cursor_position

        /** Toggle the OS cursor. This is not window specific but system wide */
    var cursor_style : js.html.Element;
    var _cursor_visible : Bool = true;
    public function system_enable_cursor( enable:Bool ) {

        if(cursor_style == null) {
            cursor_style = js.Browser.document.createStyleElement();
            cursor_style.innerHTML = '* { cursor:none; }';
        }

        if(enable && !_cursor_visible) {
            _cursor_visible = true;
            js.Browser.document.body.removeChild(cursor_style);
        } else if(!enable && _cursor_visible) {
            _cursor_visible = false;
            js.Browser.document.body.appendChild(cursor_style);
        }

    } //system_enable_cursor

        /** Lock the OS cursor to the foreground window. This hides the cursor and prevents it from leaving, reporting relative coordinates. */
    public function system_lock_cursor( enable:Bool ) {

        if(system.app.window != null) {
            grab(system.app.window, enable);
        }

    } //system_lock_cursor

        /** Toggle vertical refresh. This is not window specific but context wide */
    public function system_enable_vsync( enable:Bool ) : Int {

        // :unsupported:
        //technically RAF is vsync but it's not a toggle,
        //and without it is terrible so, not doing that

        return -1;

    } //system_enable_vsync


    public function display_count() : Int {

        //:unsupported:
        return 1;

    } //display_count

    public function display_mode_count( display:Int ) : Int {

        //:unsupported:
        return 1;

    } //display_mode_count

    public function display_native_mode( display:Int ) : DisplayMode {

        //:unsupported:

        return {
            format : 0,
            refresh_rate : 0,
            width : js.Browser.window.screen.width,
            height : js.Browser.window.screen.height
        };

    } //display_native_mode

    public function display_current_mode( display:Int ) : DisplayMode {

        //:unsupported:
        //will always return the default display mode

        return display_native_mode(display);

    } //display_current_mode

    public function display_mode( display:Int, mode_index:Int ) : DisplayMode {

        //:unsupported:
        //will always return the default display mode

        return display_native_mode(display);

    } //display_mode

        //returns the size of the main window
    public function display_bounds( display:Int ) : { x:Int, y:Int, width:Int, height:Int } {

        return {
            x : 0,
            y : 0,
            width : js.Browser.window.innerWidth,
            height : js.Browser.window.innerHeight
        };

    } //display_bounds

    public function display_name( display:Int ) : String {

        return js.Browser.navigator.vendor;

    } //display_name

        /** Called to set up any listeners on the given window  */
    public function listen( _window:Window ) {

        _window.handle.addEventListener('mouseleave', on_internal_leave);
        _window.handle.addEventListener('mouseenter', on_internal_enter);

        if(_window.config.fullscreen) {
            internal_fullscreen( _window, _window.config.fullscreen );
            _window.config.width = _window.handle.width;
            _window.config.height = _window.handle.height;
        }

    } //listen

        /** Called to remove any listeners on the given window  */
    public function unlisten( _window:Window ) {

        _window.handle.removeEventListener('mouseleave', on_internal_leave);
        _window.handle.removeEventListener('mouseenter', on_internal_enter);

        fs_windows.remove(_window);

    } //unlisten


    function on_internal_leave( _mouse_event:js.html.MouseEvent ) {

        var _window : Window = system.window_from_handle(cast _mouse_event.target);

            //tell the system
        system.app.dispatch_system_event({
            type : SystemEventType.window,
            window : {
                type : WindowEventType.leave,
                timestamp : _mouse_event.timeStamp,
                window_id : _window.id,
                event : _mouse_event
            }
        });

    } //on_internal_leave

    function on_internal_enter( _mouse_event:js.html.MouseEvent ) {

        var _window : Window = system.window_from_handle(cast _mouse_event.target);

            //tell the system
        system.app.dispatch_system_event({
            type : SystemEventType.window,
            window : {
                type : WindowEventType.enter,
                timestamp : _mouse_event.timeStamp,
                window_id : _window.id,
                event : _mouse_event
            }
        });

    } //on_internal_enter

    function listen_for_resize() {

        js.Browser.window.onresize = function(e){
            if(!system.app.config.web.true_fullscreen) {

                for(window in fs_windows) {
                    window.set_size( js.Browser.window.innerWidth, js.Browser.window.innerHeight);
                    internal_resize( window, window.width, window.height );
                }

            } //if true_fullscreen
        } //onresize

    } //listen_for_resize

    var _hidden_name = '';
    var _hidden_event_name = '';
    function listen_for_visibility() {

        if( untyped __js__('typeof document.hidden !== undefined') ) {
            _hidden_name = 'hidden';
            _hidden_event_name = 'visibilitychange';
        } else if( untyped __js__('typeof document.mozHidden !== undefined ')) {
            _hidden_name = 'mozHidden';
            _hidden_name = 'mozvisibilitychange';
        } else if( untyped __js__('typeof document.msHidden !== "undefined"')) {
            _hidden_name = "msHidden";
            _hidden_event_name = "msvisibilitychange";
        } else if( untyped __js__('typeof document.webkitHidden !== "undefined"')) {
            _hidden_name = "webkitHidden";
            _hidden_event_name = "webkitvisibilitychange";
        }

        if(_hidden_name != '' && _hidden_event_name != '') {
            js.Browser.document.addEventListener(_hidden_event_name, on_visibility_change );
        }

    }

    function on_visibility_change(jsevent) {

        var _event = {
            type : SystemEventType.window,
            window : {
                type : WindowEventType.shown,
                timestamp : system.app.time,
                window_id : 1, //page window id is 1
                event : jsevent
            }
        };

            //dispatch one for minimize/restore, one for focus lost/gain
            //and one for hidden/exposed
        if( untyped document[_hidden_name] ) {
            _event.window.type = WindowEventType.hidden;
                system.app.dispatch_system_event(_event);
            _event.window.type = WindowEventType.minimized;
                system.app.dispatch_system_event(_event);
            _event.window.type = WindowEventType.focus_lost;
                system.app.dispatch_system_event(_event);
        } else {
            _event.window.type = WindowEventType.shown;
                system.app.dispatch_system_event(_event);
            _event.window.type = WindowEventType.restored;
                system.app.dispatch_system_event(_event);
            _event.window.type = WindowEventType.focus_gained;
                system.app.dispatch_system_event(_event);
        }

    } //on_visibility_change

    function internal_fallback( message:String ) {

        var text_el : js.html.Element;
        var overlay_el : js.html.Element;

        text_el = js.Browser.document.createDivElement();
        overlay_el = js.Browser.document.createDivElement();

        text_el.style.marginLeft = 'auto';
        text_el.style.marginRight = 'auto';
        text_el.style.color = '#d3d3d3';
        text_el.style.marginTop = '5em';
        text_el.style.fontSize = '1.4em';
        text_el.style.fontFamily = 'helvetica,sans-serif';
        text_el.innerHTML = message;

        overlay_el.style.top = '0';
        overlay_el.style.left = '0';
        overlay_el.style.width = '100%';
        overlay_el.style.height = '100%';
        overlay_el.style.display = 'block';
        overlay_el.style.minWidth = '100%';
        overlay_el.style.minHeight = '100%';
        overlay_el.style.textAlign = 'center';
        overlay_el.style.position = 'absolute';
        overlay_el.style.background = 'rgba(1,1,1,0.90)';

        overlay_el.appendChild(text_el);
        js.Browser.document.body.appendChild(overlay_el);


    }

} //Windowing

#end //snow_web
