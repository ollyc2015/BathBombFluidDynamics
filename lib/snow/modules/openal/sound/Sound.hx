package snow.modules.openal.sound;

import snow.types.Types;
import snow.api.Debug.*;

/** Not generally used directly. See the `snow.system.audio.Sound` docs for reference.

    The concrete implementation of the snow audio system sound type for OpenAL.
    This class handles the difference between streaming and normal sounds by creating
    an instance of either ALSound or ALStream and managing it. */
@:allow(snow.system.audio.Audio)
@:allow(snow.modules.openal.Audio)
@:allow(snow.modules.openal.sound.ALSound)
@:allow(snow.modules.openal.sound.ALStream)
@:noCompletion
class Sound extends snow.system.audio.Sound {

        //The sound instance, which can be ALStream or ALSound depending on is_stream
    var instance: ALSound;

    function new( _system:snow.system.audio.Audio, _name:String, ?_is_stream:Bool=false ) {

        super(_system, _name, _is_stream);

        instance = switch(_is_stream) {
            case true: new ALStream(this);
            case false: new ALSound(this);
            case _: null;
        }

        assertnull(instance);

    } //new


//

        /** Play this sound */
    override public inline function play() {

            //play is explicitly not looping
        if(looping) {
            looping = false;
        }

            //loop flag should be set before this
        instance.play();

        playing = true;
        paused = false;

    }
        /** Loop this sound */
    override public inline function loop() {

        if(!looping) {
            looping = true;
        }

            //loop flag should be set before this
        instance.loop();

        playing = true;
        paused = false;

    }
        /** Stop this sound */
    override public inline function stop() {

        instance.stop();
        onended();

    } //stop

        /** Pause this sound */
    override public inline function pause() {

        instance.pause();

        playing = false;
        paused = true;

    } //pause

        /** Destroy this sound and it's data. */
    override public function destroy() {

        stop();
        instance.destroy();
        system.kill(this);

    } //destroy

// Internal system events

    @:noCompletion override public inline function internal_update() { instance.internal_update(); }
    @:noCompletion override public inline function internal_play()  { instance.internal_play(); }
    @:noCompletion override public inline function internal_loop() { instance.internal_loop(); }
    @:noCompletion override public inline function internal_stop() { instance.internal_stop(); }
    @:noCompletion override public inline function internal_pause() { instance.internal_pause(); }

//Internal sound events

    function onended() {

        playing = false;
        paused = false;
        emit('end');

    }

//Getters/setters

    override function set_info( _info:AudioInfo ) : AudioInfo {

            //if preexisting,
        if(info != null) {
            destroy();
        }

            //flag as done for gc
        info = null;

            //now
        if(_info == null) {
            log("not creating sound, info was null!");
            return info;
        }

            //store the new info
        info = _info;
        loaded = true;

        instance.update_info(info);

        return info;

    } //set_info


    override function get_playing() : Bool       return playing;
    override function get_paused() : Bool        return paused;
    override function get_loaded() : Bool        return loaded;
    override function get_info() : AudioInfo     return info;
    override function get_pan() : Float          return pan;
    override function get_pitch() : Float        return pitch;
    override function get_volume() : Float       return volume;
    override function get_looping() : Bool       return looping;

    override function get_length_bytes() : Int   return info.data.length_pcm;
    override function get_position() : Float     return instance.get_position();
    override function get_position_bytes() : Int return instance.get_position_bytes();
    override function get_duration() : Float     return system.bytes_to_seconds(info, length_bytes);

    override function set_playing(_playing:Bool) : Bool {
        playing = instance.set_playing(_playing);
        return playing;
    }

    override function set_paused(_paused:Bool) : Bool {
        paused = instance.set_paused(_paused);
        return paused;
    }

    override function set_loaded(_loaded:Bool) : Bool {
        loaded = instance.set_loaded(_loaded);
        return loaded;
    }


    override function set_pan( _pan:Float ) : Float {
        if(info.data.channels > 1) log('OpenAL: Pan on Stereo sound sources is not supported, nothing will happen!');
        pan = instance.set_pan(_pan);
        return pan;
    }

    override function set_pitch( _pitch:Float ) : Float {
        pitch = instance.set_pitch(_pitch);
        return pitch;
    }

    override function set_volume( _volume:Float ) : Float {
        volume = instance.set_volume(_volume);
        return volume;
    }

    override function set_position( _position:Float ) : Float {
        position = instance.set_position(_position);
        return position;
    }

    override function set_looping( _looping:Bool ) : Bool {
        looping = instance.set_looping(_looping);
        return looping;
    }

    override function set_position_bytes(_position_bytes) : Int {
        position_bytes = instance.set_position_bytes(_position_bytes);
        return position_bytes;
    }

} //Sound