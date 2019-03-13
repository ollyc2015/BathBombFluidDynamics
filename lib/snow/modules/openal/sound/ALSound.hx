package snow.modules.openal.sound;

import snow.system.audio.Audio;
import snow.types.Types;
import snow.api.buffers.Float32Array;

import snow.modules.openal.AL;
import snow.modules.openal.ALHelper;

import snow.api.Debug.*;


@:allow(snow.modules.openal.sound.Sound)
@:noCompletion
class ALSound {

        /** the sound source name */
    public var source : Int;
        /** the sound buffer name */
    public var buffer : Int = -1;
        /** mono8? stereo16? */
    public var format : Int;

        /** The openal system Sound controlling this instance */
    var owner : Sound;

    function new( _owner:Sound ) owner = _owner;

    function play() {

        AL.sourcePlay(source);

        _debug('${owner.name} playing sound / ${AL.getErrorMeaning(AL.getError())} ');

    } //play

//API

     function loop() {

        AL.sourcePlay(source);

        _debug('${owner.name} looping sound / ${AL.getErrorMeaning(AL.getError())} ');

    } //loop

    function pause() {

        AL.sourcePause(source);

        _debug('${owner.name} pausing sound / ${AL.getErrorMeaning(AL.getError())} ');

    } //pause

    function stop() {

        AL.sourceStop(source);

        _debug('${owner.name} stopping sound / ${AL.getErrorMeaning(AL.getError())} ');

    } //stop

    function destroy() {

        AL.deleteSource(source);
        if(buffer != -1) AL.deleteBuffer(buffer);

    } //destroy

//internal

    function internal_update() {

        if(!owner.playing) {
            return;
        }

        if(AL.getSourcei(source, AL.SOURCE_STATE) == AL.STOPPED) {
            owner.onended();
        }

    } //internal_update

    function internal_play()  {  }
    function internal_loop() { }
    function internal_stop() { }
    function internal_pause() { }

//getters / setters

    function update_info( info:AudioInfo ) {

        _debug('creating sound / ${owner.name} / ${info.id} / ${info.format}');

        _debug('\t > rate : ${info.data.rate}');
        _debug('\t > channels : ${info.data.channels}');
        _debug('\t > bitrate : ${info.data.bitrate}');
        _debug('\t > bits_per_sample : ${info.data.bits_per_sample}');
        _debug('\t > file length : ${info.data.length}');
        _debug('\t > byte length: ${info.data.length_pcm}');
        _debug('\t > duration : ${owner.duration}');

        source = AL.genSource();

            _debug('${owner.name} generating source for sound / ${AL.getErrorMeaning(AL.getError())} ');

            //ask the shared openal helper function
        ALHelper.default_source_setup( source );

            //generate a buffer for this sound
        buffer = AL.genBuffer();

            _debug('${owner.name} generating buffer for sound / ${AL.getErrorMeaning(AL.getError())} ');

            //ask the helper to determine the format
        format = ALHelper.determine_format( info );

            //check that we have valid data info
        if(info.data.samples == null || info.data.samples.length == 0) {
            _debug('${owner.name} cannot create sound, empty/null data provided!');
            return;
        }

            //give the data from the sound info to the buffer
        AL.bufferData(buffer, format, new Float32Array(info.data.samples.buffer), info.data.rate );

            _debug('${owner.name} buffered data / ${AL.getErrorMeaning(AL.getError())} ');

            //give the buffer to the source
        AL.sourcei(source, AL.BUFFER, buffer);

            _debug('${owner.name} assigning buffer to source / ${AL.getErrorMeaning(AL.getError())} ');

    } //update_info

    function set_playing(_playing:Bool) { return _playing; }
    function set_paused(_paused:Bool) { return _paused; }
    function set_loaded(_loaded:Bool) { return _loaded; }

    static var half_pi : Float = 1.5707;

    function get_position_bytes() : Int {

        return Std.int(AL.getSourcef(source, AL.SAMPLE_OFFSET));

    } //get_position_bytes

    function get_position() : Float {

        return AL.getSourcef(source, AL.SEC_OFFSET);

    } //get_position

    function set_pan( _pan:Float ) {

        AL.source3f(source, AL.POSITION, Math.cos((_pan - 1) * (half_pi)), 0, Math.sin((_pan + 1) * (half_pi)));

        return _pan;

    } //set_pan

    function set_pitch( _pitch:Float ) {

        AL.sourcef( source, AL.PITCH, _pitch );

        return _pitch;

    } //set_pitch

    function set_volume( _volume:Float ) {

        AL.sourcef( source, AL.GAIN, _volume );

        return _volume;

    } //set_volume

    function set_looping( _looping:Bool ) {

        log('${owner.name} pre looping / ${AL.getErrorMeaning(AL.getError())} ');

        AL.sourcei( source, AL.LOOPING, _looping ? AL.TRUE : AL.FALSE );

        log('${owner.name} set looping on sound source / ${AL.getErrorMeaning(AL.getError())} ');

        return _looping;

    } //set_looping

    function set_position_bytes( _position_bytes:Int ) {

        AL.sourcef(source, AL.SAMPLE_OFFSET, _position_bytes);

        return _position_bytes;

    } //set_position_bytes

    function set_position( _position:Float ) {

        AL.sourcef(source, AL.SEC_OFFSET, _position);

        return _position;

    } //set_position


}