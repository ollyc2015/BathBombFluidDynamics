package snow.system.audio;

import snow.system.audio.Audio;
import snow.types.Types;
import snow.api.Debug.*;


@:allow(snow.system.audio.Audio)
class Sound {

        /** The `Audio` system handling this sound */
    public var system : Audio;
        /** The name of this sound */
    public var name : String = '';

        /** If the sound is playing */
    @:isVar public var playing  (get, set): Bool = false;
        /** If the sound is paused */
    @:isVar public var paused   (get, set): Bool = false;
        /** If the sound is loaded or ready to use */
    @:isVar public var loaded   (get, set): Bool = false;
        /** The `AudioInfo` this sound is created from. When assigning this it will clean up and set itself to this info instead. */
    @:isVar public var info     (get,set) : AudioInfo;
        /** The pitch of this sound */
    @:isVar public var pitch    (get,set) : Float = 1.0;
        /** The volume of this sound */
    @:isVar public var volume   (get,set) : Float = 1.0;
        /** The pan of this sound. Pan only logically works on mono sounds, and is by default 2D sounds  */
    @:isVar public var pan      (get,set) : Float = 0.0;
        /** If the sound is looping or not. Use `loop()` to change this. */
    @:isVar public var looping  (get,set) : Bool = false;
        /** The current playback position of this sound in `seconds` */
    @:isVar public var position  (get,set) : Float = 0.0;
        /** The duration of this sound, in `seconds` */
    @:isVar public var duration (get,never) : Float = 0.0;
        /** The length of this sound in `bytes` */
    @:isVar public var length_bytes   (get, never) : Int = 0;
        /** The current playback position of this sound in `bytes` */
    @:isVar public var position_bytes (get, set) : Int = 0;

//Stream specific

        /** Stream: If the sound is a streamed source */
    @:isVar public var is_stream (default, null): Bool = false;

#if snow_native //:todo:
        /** `Stream only`: The length of bytes for a single buffer to queue up to stream. default: `176400`, about 1 second in 16 bit mono.*/
    public var stream_buffer_length : Int;
        /** `Stream only`: The number of buffers to use in the queue for streaming. default: `4` */
    public var stream_buffer_count : Int;
        /** `Stream only`: The get function, assign a function here only if you want to stream data to the source manually, like generative sound. */
    public var stream_data_get : Int->Int->AudioDataBlob;
        /** `Stream only`: The seek function, assign a function here only if you want to stream data to the source manually, like generative sound. */
    public var stream_data_seek : Int->Bool;
#end //snow_native

//

        /** Create a new Sound instance. Usually not called directly, handled internally by `audio.create` */
    public function new( _system:Audio, _name:String, _is_stream:Bool=false ) {

        name = _name;
        system = _system;
        is_stream = _is_stream;

        #if snow_native //:todo:
            stream_buffer_length = system.app.config.native.audio_buffer_length;
            stream_buffer_count = system.app.config.native.audio_buffer_count;
            stream_data_get = default_stream_data_get;
            stream_data_seek = default_stream_data_seek;
        #end //snow_native

    } //new

//

    @:noCompletion public function emit(_event:String) {

        @:privateAccess system.sound_event(this, _event);

    } //emit

        /** Connect a handler to a named event.
            Current events include `load` and `end`, and will soon be strict typed. */
    public function on(_event:String, _handler:Sound->Void) {

        system.on(name, _event, _handler);

    } //emit

        /** Disconnect a handler from a named event type, previously connected with `on`. */
    public function off(_event:String, _handler:Sound->Void) {

        system.off(name, _event, _handler);

    } //off


//Functions implemented in subclasses

        /** Play this sound */
    public function play() { log('Sound:play called in root Sound module. Nothing will happen.'); }
        /** Loop this sound */
    public function loop() { log('Sound:loop called in root Sound module. Nothing will happen.'); }
        /** Stop this sound */
    public function stop() { log('Sound:stop called in root Sound module. Nothing will happen.'); }
        /** Pause this sound */
    public function pause() { log('Sound:pause called in root Sound module. Nothing will happen.'); }
        /** Destroy this sound and it's data. */
    public function destroy() { log('Sound:destroy called in root Sound module. Nothing will happen.'); }

// Internal system events

    @:noCompletion public function internal_update() {}
    @:noCompletion public function internal_play()  {}
    @:noCompletion public function internal_loop() {}
    @:noCompletion public function internal_stop() {}
    @:noCompletion public function internal_pause() {}

//Shared implementations

        /** Toggle this sound */
    public function toggle() {

        playing = !playing;

        if(playing) {
            if(looping) {
                loop();
            } else {
                play();
            }
        } else {
            pause();
        }

    } //toggle

//Streaming API

//:todo:
#if snow_native

        /** Default data seek implementation for `SoundStream` uses `assets.system.audio_seek_source` */
    function default_stream_data_seek( _to:Int ) : Bool {

        return system.app.assets.module.audio_seek_source( info, _to );

    } //default_data_seek

        /** Default data get implementation for `SoundStream` uses `assets.system.audio_load_portion` */
    function default_stream_data_get( _start:Int, _length:Int ) : AudioDataBlob {

        return system.app.assets.module.audio_load_portion( info, _start, _length );

    } //default_data_get

#end //snow_native

//Getters/setters

    function get_playing() : Bool return playing;
    function get_paused() : Bool return paused;
    function get_loaded() : Bool return loaded;
    function get_info() : AudioInfo return info;
    function set_info( _info:AudioInfo ) : AudioInfo return info = _info;
    function get_pan() : Float return pan;
    function get_pitch() : Float return pitch;
    function get_volume() : Float return volume;
    function get_looping() : Bool return looping;
    function get_position() : Float return position;
    function get_position_bytes() : Int return position_bytes;
    function get_length_bytes() : Int return length_bytes;
        //overridden in platform concrete
    function get_duration() : Float return 0;
    function set_playing(_playing:Bool) : Bool return playing = _playing;
    function set_paused(_paused:Bool) : Bool return paused = _paused;
    function set_loaded(_loaded:Bool) : Bool return loaded = _loaded;
    function set_pan( _pan:Float ) : Float return pan = _pan;
    function set_pitch( _pitch:Float ) : Float return pitch = _pitch;
    function set_volume( _volume:Float ) : Float return volume = _volume;
    function set_position( _position:Float ) : Float return position = _position;
    function set_looping( _looping:Bool ) : Bool return looping = _looping;
    function set_position_bytes(_position_bytes) : Int return position_bytes = _position_bytes;

} //Sound
