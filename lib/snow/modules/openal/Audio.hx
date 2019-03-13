package snow.modules.openal;

import snow.types.Types;
import snow.api.Promise;

import snow.modules.openal.AL;
import snow.modules.openal.AL.Context;
import snow.modules.openal.AL.Device;

import snow.system.audio.Sound;
import snow.api.buffers.Uint8Array;

import snow.api.Debug.*;

@:noCompletion
typedef Sound = snow.modules.openal.sound.Sound;

    /** Internal audio system implementation for OpenAL, interact with this system through `snow.Audio`, not directly */
@:noCompletion
class Audio extends snow.core.native.audio.Audio {

    var device : Device;
    var context : Context;

    override public function init() {

            _debug('init');

        device = ALC.openDevice();

        if(device == null) {
            log('failed / didn\'t create device!');
            return;
        }

            _debug('created device / ${device} / ${ ALC.getErrorMeaning(ALC.getError(device)) }');

        context = ALC.createContext(device, null);

            _debug('created context / ${context} / ${ ALC.getErrorMeaning(ALC.getError(device)) }');

        ALC.makeContextCurrent( context );

            _debug('set current / ${ ALC.getErrorMeaning(ALC.getError(device)) }');

    } //init

    override public function destroy() {

        ALC.makeContextCurrent( null );
        ALC.destroyContext( context );
        ALC.closeDevice( device );

            _debug('destroying device / ${ AL.getErrorMeaning(AL.getError()) }');

    } //destroy

    override public function suspend() {

            _debug('suspending context ');

        ALC.suspendContext( context );
        ALC.makeContextCurrent( null );

    } //suspend

    override public function resume() {

            _debug('resuming context ');

        ALC.processContext( context );
        ALC.makeContextCurrent( context );

    } //resume

    override public function create_sound( _id:String, _name:String, _streaming:Bool=false, ?_format:AudioFormatType ) : Promise {

        var sound = new Sound(system, _name, _streaming);
        var assets = system.app.assets;

            //:todo:this triggers the creation/init of the sound, but was
            //a by product of earlier code, will refactor.
        sound.info = assets.module.audio_load_info(assets.path(_id), !_streaming, _format);

        return Promise.resolve(sound);

    } //create_sound

    override public function create_sound_from_bytes( _name:String, _bytes:Uint8Array, _format:AudioFormatType ) : Sound {

        var sound = new Sound(system, _name, false);
        var assets = system.app.assets;

        sound.info = assets.module.audio_info_from_bytes(_bytes, _format);

        return sound;

    } //create_sound_from_bytes

} //Audio
