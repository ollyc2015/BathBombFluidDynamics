package snow.system.audio;

import snow.types.Types;
import snow.system.audio.Sound;
import snow.system.assets.Asset;
import snow.api.Promise;
import snow.api.Debug.*;

#if (!macro && !display && !scribe)
    typedef AudioModule = haxe.macro.MacroType<[snow.system.module.Module.assign('Audio')]>;
#end

class Audio {

        /** access to module specific implementation */
    public var module : snow.system.module.Audio;
        /** Set to false to stop any and all processing in the audio system */
    public var active : Bool = false;

        /** for external access to the library by the systems */
    @:noCompletion public var app : Snow;
        /** for mapping named sounds to Sound instances. Use the `app.audio` to manipulate preferably. */
    @:noCompletion public var sound_list : Map<String, Sound>;
        /** for mapping named streams to SoundStream instances. Use the `app.audio` to manipulate preferably. */
    @:noCompletion public var stream_list : Map<String, Sound>;

        /** constructed internally, use `app.audio` */
    @:allow(snow.Snow)
    function new( _app:Snow ) {

        app = _app;

        module = new snow.system.module.Audio(this);

        module.init();

        sound_list = new Map();
        stream_list = new Map();

        active = true;

    } //new


//Public API


        /** Create a sound for playing. If no name is given, a unique id is assigned. Use the sound instance or the public api by name. */
    public function create( _id:String, ?_name:String = '', ?_streaming:Bool = false ) : Promise {

        if(_name == '') _name = app.uniqueid;

        log('creating sound named $_name (stream: $_streaming)');

        return new Promise(function(resolve, reject) {

            var _create = module.create_sound(_id, _name, _streaming);

            _create.then(function(_sound:Sound) {

                sound_list.set(_name, _sound);

                if(_streaming) stream_list.set(_name, _sound);

                resolve(_sound);

                _sound.emit('load');

            }).error(reject);

        }); //promise

    } //create

        /** Create a sound for playing from bytes. If no name is given, a unique id is assigned.
            Use the sound instance or the public api by name.
            Currently only non-stream sounds. */
    @:noCompletion
    public function create_from_bytes( ?_name:String = '', _bytes:snow.api.buffers.Uint8Array, _format:AudioFormatType ) : Sound {

        if(_name == '') _name = app.uniqueid;

        var sound = module.create_sound_from_bytes(_name, _bytes, _format);

        assertnull(sound);

        sound_list.set(_name, sound);

        return sound;

    } //create_from_bytes

        /** Destroy a sound instance by name. Use sound_instance.destroy() if you have an instance already. */
    public function uncreate( _name:String ) {

        var _sound = sound_list.get(_name);

        if(_sound == null) {
            log('can\'t find sound, unable to uncreate, use create first: ${_name}');
        } //_sound

            //kill the sound
        _sound.destroy();

    } //uncreate

        /** Add a manually created sound instance to the audio system.
            Once added the regular named api should apply.
            Do not add sounds returned from `create` calls. */
    @:noCompletion public function add( sound:Sound ) {
        sound_list.set(sound.name, sound);
        if(sound.is_stream) stream_list.set(sound.name, sound);
    }


        //:todo: temp fixes for audio issues created by modules
    var handlers : Map<String, Array<Sound->Void> >;
    static var splitter = ' • ';

        /** Listen for a event on a named sound. `load` and `end` are valid events. */
    public function on( _name:String, _event:String, _handler:Sound->Void ) {

            //first check if the event has already happened
        if(_event == 'load') {
            var sound = get(_name);
            if(sound != null) {
                if(sound.loaded) {
                    _debug('already loaded $_name, calling $_event handler immediately');
                    _handler(sound);
                    return;
                }
            }
        }

        var _event_id = '${_event}${splitter}${_name}';

        _debug('adding listener for $_event_id');

            //make sure the lists exist
        if(handlers == null) handlers = new Map();
            //make sure the array exists for this event
        if(!handlers.exists(_event_id)) handlers.set(_event_id, []);

            //get the list
        var _list = handlers.get(_event_id);

        if(_list.indexOf(_handler) != -1) throw "Audio on event adding the same handler twice";

        _list.push(_handler);

        handlers.set(_event_id, _list);

    } //on

        /** Remove a listener for a event on a named sound. see `on` */
    public function off( _name:String, _event:String, _handler:Sound->Void ) {

        if(handlers == null) return;

        var _event_id = '${_event}${splitter}${_name}';

        var _list = handlers.get(_event_id);
        if(_list != null) {
            _list.remove(_handler);
            handlers.set(_event_id, _list);
        }

    } //off

        /** Get a sound instance by name */
    public function get( _name:String ) : Sound {

        var _sound = sound_list.get(_name);

        return _sound;

    } //get

        /** Get/Set the volume of a sound instance by name.
            Leave the second argument blank to return the current value. */
    public function volume( _name:String, ?_volume:Float ) : Float {
        var sound = get(_name);
        if(sound != null) {
            if(_volume != null) {
                return sound.volume = _volume;
            } else {
                return sound.volume;
            }
        }
        return 0;
    } //volume

        /** Get/Set the pan of a sound instance by name
            Leave the second argument blank to return the current value.  */
    public function pan( _name:String, ?_pan:Float ) {
        var sound = get(_name);
        if(sound != null) {
            if(_pan != null) {
                return sound.pan = _pan;
            } else {
                return sound.pan;
            }
        }
        return 0;
    } //pan

        /** Get/Set the pitch of a sound instance by name
            Leave the second argument blank to return the current value.  */
    public function pitch( _name:String, ?_pitch:Float ) {
        var sound = get(_name);
        if(sound != null) {
            if(_pitch != null) {
                return sound.pitch = _pitch;
            } else {
                return sound.pitch;
            }
        }
        return 0;
    } //pitch

        /** Get/Set the position **in seconds** of a sound instance by name.
            Leave the second argument blank to return the current value.  */
    public function position( _name:String, ?_position:Float ) {
        var sound = get(_name);
        if(sound != null) {
            if(_position != null) {
                return sound.position = _position;
            } else {
                return sound.position;
            }
        }
        return 0;
    } //position

        /** Get the duration of a sound instance by name.
            Duration is set from the sound instance, so it is read only. */
    public function duration( _name:String ) {
        var sound = get(_name);
        if(sound != null) {
            return sound.duration;
        }
        return 0;
    } //duration

        /** Play a sound instance by name */
    public function play(_name:String) {

        if(!active) {
            return;
        }

        var sound = get(_name);
        if(sound != null) {
            sound.play();
        }
    } //play

        /** Loop a sound instance by name, indefinitely. Use stop to end it */
    public function loop(_name:String) {

        if(!active) {
            return;
        }

        var sound = get(_name);
        if(sound != null) {
            sound.loop();
        }

    } //loop

        /** Pause a sound instance by name */
    public function pause(_name:String) {

        if(!active) {
            return;
        }

        var sound = get(_name);
        if(sound != null) {
            sound.pause();
        }
    } //pause

        /** Stop a sound instance by name */
    public function stop(_name:String) {

        if(!active) {
            return;
        }

        var sound = get(_name);
        if(sound != null) {
            sound.stop();
        }
    } //stop

        /** Toggle a sound instance by name, pausing the sound */
    public function toggle(_name:String) {

        if(!active) {
            return;
        }

        var sound = get(_name);
        if(sound != null) {
            sound.toggle();
        }
    } //toggle


//Internal API

#if snow_native //:todo:

        /** A helper for converting bytes to seconds for a sound source, using the format from the sound.info */
    public function bytes_to_seconds( info:AudioInfo, _bytes:Int ) : Float {

        var word = info.data.bits_per_sample == 16 ? 2 : 1;
        var sample_frames = (info.data.rate * info.data.channels * word);

        return _bytes / sample_frames;

    } //bytes_to_seconds

        /** A helper for converting seconds to bytes for this sound source, using the format settings specific to this sound */
    public function seconds_to_bytes( info:AudioInfo, _seconds:Float ) : Int {

        var word = info.data.bits_per_sample == 16 ? 2 : 1;
        var sample_frames = (info.data.rate * info.data.channels * word);

        return Std.int(_seconds * sample_frames);

    } //seconds_to_bytes

#end //snow_native

        /** Stop managing a sound instance */
    @:noCompletion public function kill( _sound:Sound ) {

        if(_sound == null) return;

        sound_list.remove(_sound.name);
        stream_list.remove(_sound.name);

    } //kill

    @:noCompletion public function suspend() {

        if(!active) {
            return;
        }

        log("suspending sound context");

        active = false;

        for(sound in stream_list) {
            sound.internal_pause();
        }

        module.suspend();

    } //suspend

    @:noCompletion public function resume() {

        if(active) {
            return;
        }

        log("resuming sound context");

        active = true;

        module.resume();

        for(sound in stream_list) {
            sound.internal_play();
        }

    } //resume

        /** Called by Snow when a system event is dispatched */
    @:allow(snow.Snow)
    function on_event( _event:SystemEvent ) {

        module.on_event(_event);

        if(_event.type == SystemEventType.app_willenterbackground) {
            suspend();
        } else if(_event.type == SystemEventType.app_willenterforeground) {
            resume();
        }

        #if mobile

            if(_event.type == SystemEventType.window) {
                switch(_event.window.type) {
                    case WindowEventType.focus_lost:
                        suspend();
                    case WindowEventType.focus_gained:
                        resume();
                    default:
                }
            } //_event.type == window

        #end //mobile

    } //on_event

        /** Called by Snow, cleans up sounds/system */
    @:allow(snow.Snow)
    function destroy() {

        active = false;

        for(sound in sound_list) {
            sound.destroy();
        }

        module.destroy();

    } //destroy

        /** Called by Snow, update any sounds / streams */
    @:allow(snow.Snow)
    function update() {

        if(!active) {
            return;
        }

        for(_sound in sound_list) {
            if(_sound.playing) {
                _sound.internal_update();
            }
        }

        module.update();

    } //update

//Internal

    function sound_event(_sound:Sound, _event:String) {

        var _event_id = '${_event}${splitter}${_sound.name}';

        _debug('sound event: $_event_id');

        if(handlers == null) return;

        var _list = handlers.get(_event_id);
        if(_list != null) {
            for(fn in _list) {
                fn(_sound);
            }
        }

    } //sound_event

} //Audio
