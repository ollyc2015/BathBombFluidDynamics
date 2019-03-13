package snow.modules.openal.sound;

import snow.system.audio.Audio;
import snow.types.Types;
import snow.api.buffers.Float32Array;

import snow.modules.openal.AL;
import snow.modules.openal.ALHelper;

import snow.api.Debug.*;

/** The openal specifics for a streamed sound */
@:noCompletion
class ALStream extends snow.modules.openal.sound.ALSound {

        /** the sound buffer names */
    public var buffers : Array<Int>;
        /** remaining buffers to play */
    public var buffers_left : Int = 0;

//Internal API

    override function update_info( info : AudioInfo ) {

        _debug('creating sound / ${owner.name} / ${info.id} / ${info.format}');

        _debug('\t > rate : ${info.data.rate}');
        _debug('\t > channels : ${info.data.channels}');
        _debug('\t > bitrate : ${info.data.bitrate}');
        _debug('\t > bits_per_sample : ${info.data.bits_per_sample}');
        _debug('\t > file length : ${info.data.length}');
        _debug('\t > byte length: ${info.data.length_pcm}');
        _debug('\t > duration : ${owner.duration}');

            //generate a source
        source = AL.genSource();

            //default source properties
        ALHelper.default_source_setup( source );

            _debug('${owner.name} generating source for sound / ${AL.getErrorMeaning(AL.getError())} ');

            //four streaming buffers to cycle.
        buffers = AL.genBuffers(owner.stream_buffer_count);

            _debug('${owner.name} generating ${owner.stream_buffer_count} buffers for sound / ${AL.getErrorMeaning(AL.getError())} ');

        for(b in buffers) {
            _debug('/ snow /    > buffer id ${b}');
        }

        format = ALHelper.determine_format( info );

            //fill the first set of buffers up
        init_queue();

        _debug('${owner.name} buffered data / ${AL.getErrorMeaning(AL.getError())} ');

    } //update_info

        //will try and fill the buffer, will return false if there
        //was no data to get (i.e end of file )
    function fill_buffer(_buffer:Int) : AudioDataBlob {

            //try to read the data into the buffer, the -1 means "from current"
        var _blob : AudioDataBlob = owner.stream_data_get( -1, owner.stream_buffer_length );

        if(_blob != null && _blob.bytes != null && _blob.bytes.length != 0) {
            AL.bufferData( _buffer, format, new Float32Array(_blob.bytes.buffer), owner.info.data.rate ); AL.getError();
        }

        return _blob;

    } //fill_buffer

        //this function takes the start of a buffer to allow streaming a section of a buffer
        //but it has to submit the first buffer separately, which handles the seeking to the first slot
        //and subsequent fill_buffers continue from that point onward.
    function init_queue( ?_buffer_start:Int=-1 ) {

        if(_buffer_start != -1) {
            owner.stream_data_seek(_buffer_start);
        }

        for(i in 0...owner.stream_buffer_count) {
            fill_buffer(buffers[i]);
            _debug('${owner.name} queue buffer ' + buffers[i]);
            AL.sourceQueueBuffer(source, buffers[i]);
        }

        buffers_left = owner.stream_buffer_count;

    } //init_queue


        //when pausing or stopping the sound you want to flush
        //the buffers sometimes because otherwise the remaining queue will
        //continue to play until it consumes them up.
    function flush_queue() {

        var queued = AL.getSourcei(source, AL.BUFFERS_QUEUED);

        _debug('${owner.name} flushing queued buffers ' + queued);

        for(i in 0 ... queued) {
            AL.sourceUnqueueBuffer( source );
        }

    } //flush_queue

        //this is to check the stream state and flag any changes
    function update_stream() : Bool {

        var still_busy = true;

        _verbose(' ${owner.position}/${owner.duration} | ${owner.position_bytes}/${owner.length_bytes} | ${buffers_left} ');

        var processed_buffers : Int = AL.getSourcei(source, AL.BUFFERS_PROCESSED );

            //disallow large or invalid values since we are using a while loop
        if(processed_buffers > owner.stream_buffer_count) {
            processed_buffers = owner.stream_buffer_count;
        }

            //for each buffer that was already processed, unqueue it
            //which returns the buffer id, so it can be refilled
        while(processed_buffers > 0) {

            var err = AL.getError();
            if(err != AL.NO_ERROR) {
                throw "failed failed with " + AL.getErrorMeaning(err);
            }

            var _buffer:Int = AL.sourceUnqueueBuffer( source );

            var err = AL.getError();
            if(err != AL.NO_ERROR) {
                throw "sourceUnqueueBuffer failed with " + AL.getErrorMeaning(err);
            }

            var _buffer_size = AL.getBufferi(_buffer, AL.SIZE);

            current_time += owner.system.bytes_to_seconds( owner.info, _buffer_size );

            _verbose('    > buffer was done / ${_buffer} / size / ${_buffer_size} / current_time / ${current_time} / position / ${owner.position}');

                //repopulate this empty buffer,
                //if it succeeds, then throw it back at the end of
                //the queue list to keep playing.
            var blob = fill_buffer(_buffer);
                //we shouldn't queue if complete and not looping, or if the data length was 0
            var skip_queue = (!owner.looping && blob.complete);

                //make sure the time resets correctly when looping
            var at_end = owner.position >= owner.duration;
            if(at_end && owner.looping) {
                current_time = 0;
                owner.emit('end');
            }

            if(blob.complete) {

                if(owner.looping) {
                        //if we are looping, we must seek to the beginning again
                    owner.stream_data_seek(0);

                } else {
                    buffers_left--;
                    _verbose('another buffer down ${buffers_left}');
                    if(buffers_left < 0) {
                        still_busy = false;
                    } else {
                        skip_queue = false;
                    }
                }

            } //complete

            if(!skip_queue && blob.bytes.length != 0) {
                AL.sourceQueueBuffer(source, _buffer);
                _verbose("requeue buffer " + _buffer);
            }

            processed_buffers--;

        } //while

        var _al_play_state = AL.getSourcei(source, AL.SOURCE_STATE);
        if(_al_play_state != AL.PLAYING) {
            _debug('${owner.name} update stream not needed, sound is not playing');
            still_busy = false;
        }

        return still_busy;

    } //update_stream

    override function internal_update() {

        if(!owner.playing) {
            return;
        }

        if(!update_stream()) {
            _debug('${owner.name} streaming sound complete');
            owner.stop();
        }

    } //internal_update

    override function internal_pause() {

        AL.sourcePause(source);

        flush_queue();

    } //internal_pause

    override function internal_play() {

        if(owner.playing) {
                //make sure the queue is clear and ready
            flush_queue();
            init_queue();
            AL.sourcePlay(source);
        }

    } //internal_play

    override public function pause() {

        super.pause();
        flush_queue();

    } //pause

    override public function stop() {

        super.stop();

        flush_queue();
        owner.position = 0;

    } //stop

    override function destroy() {

        super.destroy();

        AL.deleteBuffers(buffers);

    } //destroy

//getters / setters

    static var half_pi : Float = 1.5707;

    var current_time : Float = 0;

    override function get_position_bytes() : Int {

        return owner.system.seconds_to_bytes(owner.info, owner.position);

    } //get_position_bytes

    override function get_position() : Float {

        // return bytes_to_seconds(position_bytes);
        var _pos_sec : Float = AL.getSourcef(source, AL.SEC_OFFSET);

        return current_time + _pos_sec;

    } //get_position

    override function set_position_bytes( _position_bytes:Int ) : Int {

        owner.position = owner.system.bytes_to_seconds(owner.info, _position_bytes);

        return _position_bytes;

    } //set_position_bytes

    override function set_position( _position:Float ) : Float {

            //stop source so it lets go of buffers
        AL.sourceStop(source);
            //clear queue
        flush_queue();

            //sanity checks
        if(_position < 0) { _position = 0; }
        if(_position > owner.duration) { _position = owner.duration; }

        current_time = _position;

            //fill up the first buffers again, seeking there first
        init_queue( owner.system.seconds_to_bytes(owner.info, _position) );

            //and, if it was playing, play it
        if(owner.playing) {
            AL.sourcePlay(source);
        }

        return _position;

    } //set_position

        //Don't set AL source to looping in streamed
        //sounds, it will break with unqueuing a buffer.
    override function set_looping(_looping:Bool) {
        return _looping;
    }


} //ALStream
