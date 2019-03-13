package snow.core.native;

import snow.types.Types;
import snow.api.Debug.*;

#if (hxcpp_static_std && cpp && !scriptable)

    //These use hxcpp magic to
    //import the std/zlib/regex modules

    import hxcpp.StaticRegexp;
    import hxcpp.StaticStd;
    import hxcpp.StaticZlib;

#end //hxcpp_static_std

/** The native snow core implementation details.
    See snow.Core class code for doc details */
@:allow(snow.Snow)
@:noCompletion
class Core {

    var app:snow.Snow;
    var start_timestamp : Float = 0.0;

        function new( _app:Snow ) {

            app = _app;

            set_os();

        }

        function init( _event_handler : SystemEvent->Void ) : Void {

            start_timestamp = timestamp();

            snow_init( _event_handler, {
                has_loop:app.snow_config.has_loop,
                log_level:snow.api.Debug.get_level()
            });

        } //init

        function shutdown() : Void {

            snow_shutdown();

        } //shutdown

        function timestamp() : Float {

            var now : Float = snow_timestamp();
            return now - start_timestamp;

        } //timestamp

        function set_os() {

            #if ios      app.os = OS.os_ios;       #end
            #if mac      app.os = OS.os_mac;       #end
            #if linux    app.os = OS.os_linux;     #end
            #if android  app.os = OS.os_android;   #end
            #if windows  app.os = OS.os_windows;   #end

        } //set_os

    //lib functions

        static var snow_init       = snow.api.Libs.load( "snow", "snow_init", 2 );
        static var snow_shutdown   = snow.api.Libs.load( "snow", "snow_shutdown", 0 );
        static var snow_timestamp  = snow.api.Libs.load( "snow", "snow_timestamp", 0 );

} //Core



#if !snow_dynamic_link

//This is temporarily placed here, an include xml or similar will replace this soon


@:cppFileCode( 'extern "C" void snow_register_prims();')
@:buildXml("

<set name='MSVC_LIB_VERSION' value='-${MSVC_VER}' if='windows'/>
<set name='DEBUG_SNOW' value='${DBG}' if='debug_snow'/>
<target id='haxe'>
  <lib name='${haxelib:snow}/ndll/${BINDIR}/libsnow${DEBUG_SNOW}${LIBEXTRA}${LIBEXT}'/>

    <section if='mac'>
        <vflag name='-l' value='iconv'/>
        <vflag name='-framework' value='IOKit' />
        <vflag name='-framework' value='Foundation' />
        <vflag name='-framework' value='CoreAudio' />
        <vflag name='-framework' value='CoreVideo' />
        <vflag name='-framework' value='Cocoa' />
        <vflag name='-framework' value='OpenGL' />
        <vflag name='-framework' value='AudioToolbox' />
        <vflag name='-framework' value='AudioUnit' />
        <vflag name='-framework' value='ForceFeedback' />
        <vflag name='-framework' value='Carbon' />
        <vflag name='-framework' value='AppKit' />
        <vflag name='-framework' value='OpenAL'/>
    </section>

    <section if='windows'>

        <lib name='gdi32.lib' />
        <lib name='opengl32.lib' />
        <lib name='user32.lib' />
        <lib name='kernel32.lib' />
        <lib name='advapi32.lib' />
        <lib name='winmm.lib' />
        <lib name='imm32.lib'  />
        <lib name='ole32.lib' />
        <lib name='oleaut32.lib' />
        <lib name='version.lib' />
        <lib name='ws2_32.lib'  />
        <lib name='wldap32.lib' />
        <lib name='shell32.lib' />
        <lib name='comdlg32.lib' />

     </section>

    <section if='linux'>

        <lib name='${HXCPP}/lib/${BINDIR}/liblinuxcompat.a' />
        <lib name='-lpthread' />
        <lib name='-lrt' />
        <lib name='-lGL' />

            <!-- These are from `pkg-config --libs gtk+-3.0` -->
        <lib name='-lgtk-3'  unless='SNOW_NO_GTK'/>
        <lib name='-lgdk-3' unless='SNOW_NO_GTK'/>
        <lib name='-latk-1.0' unless='SNOW_NO_GTK'/>
        <lib name='-lgio-2.0' unless='SNOW_NO_GTK'/>
        <lib name='-lpangocairo-1.0' unless='SNOW_NO_GTK'/>
        <lib name='-lgdk_pixbuf-2.0' unless='SNOW_NO_GTK'/>
        <lib name='-lcairo-gobject' unless='SNOW_NO_GTK'/>
        <lib name='-lpango-1.0' unless='SNOW_NO_GTK'/>
        <lib name='-lcairo' unless='SNOW_NO_GTK'/>
        <lib name='-lgobject-2.0' unless='SNOW_NO_GTK'/>
        <lib name='-lglib-2.0'  unless='SNOW_NO_GTK'/>

     </section>

</target>
")

@:noCompletion
@:keep private class StaticSnow {
    static function __init__() {
        #if cpp untyped __cpp__("snow_register_prims();"); #end
    } //__init__
} //StaticSnow

#end //!snow_dynamic_link

