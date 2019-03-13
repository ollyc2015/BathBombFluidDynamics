package snow.modules.howlerjs.sound;

#if snow_web

import snow.types.Types;

import snow.api.Debug.*;

class Sound extends snow.system.audio.Sound {

    public function new( _system:snow.system.audio.Audio, _name:String, _is_stream:Bool=false ) {

        super(_system, _name, _is_stream);

    } //new

    override function set_info( _info:AudioInfo ) {

            //if preexisting,
        if(info != null) {
            destroy();
        }

            //flag as done for gc
        info = null;

                //now
            if(_info == null) {
                log("not creating sound, info was null");
                return info;
            }

            //store the new sound
        info = _info;
        loaded = true;

            _debug('creating sound / ${name} / ${info.id} / ${info.format}');

        return info;

    } //set_info


    override function set_pan(_pan:Float) : Float {

        if(info != null && info.handle != null) {
            info.handle.pos3d(pan);
        }

        return pan = _pan;

    } //set_pan

    override function set_volume(_volume:Float) : Float {

        if(info != null && info.handle != null) {
            info.handle.volume(_volume);
        }

        return volume = _volume;

    } //set_volume


    override function set_pitch( _pitch:Float ) : Float {

        // untyped this.info.handle._rate = _pitch;
        if(info != null && info.handle != null) {
            info.handle.rate(_pitch);
        }

        return pitch = _pitch;

    } //set_pitch

    override function set_position( _position:Float ) : Float {

        if(info != null && info.handle != null) {
            info.handle.pos(_position);
        }

        return position = _position;

    } //set_position

    override function get_position() : Float {

        if(info != null && info.handle != null) {
            return info.handle.pos();
        } //has info

        return position;
    } //get_position

        //will return 0 if the info is not set yet i.e loading
    override function get_duration() : Float {

        if(info != null && info.handle != null) {
            return untyped this.info.handle._duration;
        } //has info

        return 0;

    } //get_duration

        /** Play this sound */
    override public function play() {

        if(info != null && info.handle != null) {

            playing = true;
            looping = false;

            info.handle.loop(false);
            info.handle.play();
            ensure_parameters();

        }  //has info

    } //play

        /** Loop this sound */
    override public function loop() {

        if(info != null && info.handle != null) {

            playing = true;
            looping = true;

            info.handle.loop(true);
            info.handle.play();
            ensure_parameters();

        } //has info

    } //loop

        /** Stop this sound */
    override public function stop() {

        playing = false;

        if(info != null && info.handle != null) {
            info.handle.stop();
        } //

    } //stop

        /** Pause this sound */
    override public function pause() {

        if(info != null && info.handle != null) {
            info.handle.pause();
        } //

    } //pause

        /** Destroy this sound and it's data */
    override public function destroy() {

        if(info != null && info.handle != null) {
            info.handle.unload();
        } //

        system.kill(this);

    } //destroy

//Internal

        /** Ensures the values are up to date when playing a new instance */
    inline function ensure_parameters() {
        if(info != null && info.handle != null) {
            info.handle.rate(pitch);
            info.handle.volume(volume);
            info.handle.pos3d(pan);
        }
    }

} //Sound

#end //snow_web
