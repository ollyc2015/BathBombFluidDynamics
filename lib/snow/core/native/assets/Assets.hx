package snow.core.native.assets;

import snow.types.Types;
import snow.api.Libs;
import snow.api.buffers.Uint8Array;
import snow.api.Promise;
import snow.api.Debug.*;


@:allow(snow.system.assets.Assets)
class Assets implements snow.modules.interfaces.Assets {

    var system: snow.system.assets.Assets;
    function new( _system:snow.system.assets.Assets ) system = _system;

//images

    public function image_load_info( _path:String, ?_components:Int = 4 ) : Promise {

        return new Promise(function(resolve, reject) {

            var _native_info = snow_assets_image_load_info( _path, _components );
            if(_native_info == null) return reject(Error.error('failed to load $_path : does the file exist?'));
            if(_native_info.data == null) return reject(Error.error('failed to load $_path : data was null.'));

            var _bytes = haxe.io.Bytes.ofData( _native_info.data );

            var info : ImageInfo = {
                id : _native_info.id,
                bpp : _native_info.bpp,
                width : _native_info.width,
                height : _native_info.height,
                width_actual : _native_info.width,
                height_actual : _native_info.height,
                bpp_source : _native_info.bpp_source,
                pixels : new Uint8Array( _bytes )
            };

            _native_info = null;

            return resolve(info);

        });

    } //image_load_info

    public function image_info_from_bytes( _id:String, _bytes:Uint8Array, ?_components:Int = 4 ) : Promise {

        assertnull(_id);
        assertnull(_bytes);

        return new Promise(function(resolve, reject) {

            var _native_info = snow_assets_image_info_from_bytes( _id, _bytes.buffer.getData(), _bytes.byteOffset, _bytes.byteLength, _components );

            if(_native_info == null)
                return reject(Error.error('failed to load image from bytes, native code returned null.'));
            if(_native_info.data == null)
                return reject(Error.error('failed to load image from bytes, native code returned null data.'));

            var _out_bytes : haxe.io.Bytes = haxe.io.Bytes.ofData(_native_info.data);

            var info : ImageInfo = {
                id : _native_info.id,
                bpp : _native_info.bpp,
                width : _native_info.width,
                height : _native_info.height,
                width_actual : _native_info.width,
                height_actual : _native_info.height,
                bpp_source : _native_info.bpp_source,
                pixels : new Uint8Array( _out_bytes )
            }

            _native_info = null;

            return resolve(info);

        }); //promise

    } //image_info_from_bytes

            /** Create an image info from raw (already decoded) image pixels. */
    public function image_info_from_pixels( _id:String, _width:Int, _height:Int, _pixels:Uint8Array ) : ImageInfo {

        assertnull( _id );
        assertnull( _pixels );

        var info : ImageInfo = {
            id : _id,
            bpp : 4,
            width : _width,
            height : _height,
            width_actual : _width,
            height_actual : _height,
            bpp_source : 4,
            pixels : _pixels
        };

        return info;

    } //image_info_from_pixels

//audio

    public function audio_load_info( _path:String, ?_load:Bool = true, ?_format:AudioFormatType ) : AudioInfo {

        if(_format == null) {
            var _ext = haxe.io.Path.extension(_path);
            _format = switch(_ext) {
                case 'wav': AudioFormatType.wav;
                case 'ogg': AudioFormatType.ogg;
                case 'pcm': AudioFormatType.pcm;
                case _: AudioFormatType.unknown;
            }
        }

        var _native_info : NativeAudioInfo = switch(_format) {
            case AudioFormatType.wav: audio_load_wav( _path, _load );
            case AudioFormatType.ogg: audio_load_ogg( _path, _load );
            case AudioFormatType.pcm: audio_load_pcm( _path, _load );
            case _: null;
        } //switch _format

            //:todo:
        if(_native_info == null) throw Error.error('failed to load $_path : does the file exist?');
        if(_native_info.data == null) throw Error.error('failed to load $_path : data was null.');

        var _result_bytes = haxe.io.Bytes.ofData(_native_info.data.bytes);
        var _result_info : AudioInfo = {

            id:     _native_info.id,
            format: _native_info.format,
            handle: _native_info.handle,

            data: {
                samples         : new Uint8Array( _result_bytes ),
                length          : _native_info.data.length,
                length_pcm      : _native_info.data.length_pcm,
                channels        : _native_info.data.channels,
                rate            : _native_info.data.rate,
                bitrate         : _native_info.data.bitrate,
                bits_per_sample : _native_info.data.bits_per_sample
            }

        } //result_info

        _native_info = null;

        return _result_info;

    } //audio_load_info


    public function audio_info_from_bytes( _bytes:Uint8Array, _format:AudioFormatType ) : AudioInfo {

        assertnull(_bytes);

        var _id = 'audio_info_from_bytes/$_format';

        var _native_info : NativeAudioInfo = switch(_format) {
                case AudioFormatType.wav: audio_load_wav_from_bytes( _id, _bytes );
                case AudioFormatType.ogg: audio_load_ogg_from_bytes( _id, _bytes );
                case AudioFormatType.pcm: audio_load_pcm_from_bytes( _id, _bytes );
                case _ : null;
            } //switch _format

                //:todo:
            if(_native_info == null) throw Error.error('failed to process bytes for $_id');
            if(_native_info.data == null) throw Error.error('failed to process bytes for $_id, data was null.');

            var _result_bytes = haxe.io.Bytes.ofData(_native_info.data.bytes);
            var _result_info : AudioInfo = {

                id:     _native_info.id,
                format: _native_info.format,
                handle: _native_info.handle,

                data: {
                    samples         : new Uint8Array( _result_bytes ),
                    length          : _native_info.data.length,
                    length_pcm      : _native_info.data.length_pcm,
                    channels        : _native_info.data.channels,
                    rate            : _native_info.data.rate,
                    bitrate         : _native_info.data.bitrate,
                    bits_per_sample : _native_info.data.bits_per_sample
                }

            } //result_info

            _native_info = null;

        return _result_info;

    } //audio_info_from_bytes


    public function audio_seek_source( _info:AudioInfo, _to:Int ) : Bool {

        switch(_info.format) {
            case AudioFormatType.ogg: return audio_seek_source_ogg(_info, _to);
            case AudioFormatType.wav: return audio_seek_source_wav(_info, _to);
            case AudioFormatType.pcm: return audio_seek_source_pcm(_info, _to);
            case _: return false;
        }

        return false;

    } //audio_seek_source

    public function audio_load_portion( _info:AudioInfo, _start:Int, _len:Int ) : AudioDataBlob {

        var native_blob : NativeAudioDataBlob = null;
        var result_blob : AudioDataBlob = null;

        native_blob = switch(_info.format) {
            case AudioFormatType.ogg: audio_load_portion_ogg(_info, _start, _len);
            case AudioFormatType.wav: audio_load_portion_wav(_info, _start, _len);
            case AudioFormatType.pcm: audio_load_portion_pcm(_info, _start, _len);
            case _: null;
        }

        if(native_blob != null) {
            var _result_bytes = haxe.io.Bytes.ofData(native_blob.bytes);
            result_blob = {
                bytes: new Uint8Array( _result_bytes ),
                complete: native_blob.complete
            }
        }

        return result_blob;

    } //audio_load_portion

//ogg

    function audio_load_ogg( _path:String, ?load:Bool=true ) : NativeAudioInfo {
        return snow_assets_audio_load_info_ogg( _path, load, null, 0, 0 );
    } //audio_load_ogg

    function audio_load_ogg_from_bytes( _path:String, _bytes:Uint8Array ) : NativeAudioInfo {
        return snow_assets_audio_load_info_ogg( _path, true, _bytes.toBytes().getData(), _bytes.byteOffset, _bytes.byteLength );
    } //audio_load_ogg

    function audio_load_portion_ogg( _info:AudioInfo, _start:Int, _len:Int ) : NativeAudioDataBlob {
        return snow_assets_audio_read_bytes_ogg( _info, _start, _len );
    } //load_audio_portion_ogg

    function audio_seek_source_ogg( _info:AudioInfo, _to:Int ) : Bool {
        return snow_assets_audio_seek_bytes_ogg( _info, _to );
    } //audio_seek_source_ogg

//wav

    function audio_load_wav( _path:String, ?load:Bool=true ) : NativeAudioInfo {
        return snow_assets_audio_load_info_wav( _path, load, null, 0, 0 );
    } //audio_load_wav

    function audio_load_wav_from_bytes( _path:String, _bytes:Uint8Array ) : NativeAudioInfo {
        return snow_assets_audio_load_info_wav( _path, true, _bytes.toBytes().getData(), _bytes.byteOffset, _bytes.byteLength );
    } //audio_load_wav_from_bytes

    function audio_load_portion_wav( _info:AudioInfo, _start:Int, _len:Int ) : NativeAudioDataBlob {
        return snow_assets_audio_read_bytes_wav( _info, _start, _len );
    } //load_audio_portion_wav

    function audio_seek_source_wav( _info:AudioInfo, _to:Int ) : Bool {
        return snow_assets_audio_seek_bytes_wav( _info, _to );
    } //audio_seek_source_ogg

//pcm

    function audio_load_pcm( _path:String, ?load:Bool=true ) : NativeAudioInfo {
        return snow_assets_audio_load_info_pcm( _path, load, null, 0, 0 );
    } //audio_load_pcm

    function audio_load_pcm_from_bytes( _path:String, _bytes:Uint8Array ) : NativeAudioInfo {
        return snow_assets_audio_load_info_pcm( _path, true, _bytes.toBytes().getData(), _bytes.byteOffset, _bytes.byteLength );
    } //audio_load_pcm

    function audio_load_portion_pcm( _info:AudioInfo, _start:Int, _len:Int ) : NativeAudioDataBlob {
        return snow_assets_audio_read_bytes_pcm( _info, _start, _len );
    } //load_audio_portion_pcm

    function audio_seek_source_pcm( _info:AudioInfo, _to:Int ) : Bool {
        return snow_assets_audio_seek_bytes_pcm( _info, _to );
    } //audio_seek_source_pcm



//Native bindings


    static var snow_assets_image_load_info       = Libs.load( "snow", "snow_assets_image_load_info", 2 );
    static var snow_assets_image_info_from_bytes = Libs.load( "snow", "snow_assets_image_info_from_bytes", 5 );

    static var snow_assets_audio_load_info_ogg   = Libs.load( "snow", "snow_assets_audio_load_info_ogg", 5 );
    static var snow_assets_audio_read_bytes_ogg  = Libs.load( "snow", "snow_assets_audio_read_bytes_ogg", 3 );
    static var snow_assets_audio_seek_bytes_ogg  = Libs.load( "snow", "snow_assets_audio_seek_bytes_ogg", 2 );

    static var snow_assets_audio_load_info_wav   = Libs.load( "snow", "snow_assets_audio_load_info_wav", 5 );
    static var snow_assets_audio_read_bytes_wav  = Libs.load( "snow", "snow_assets_audio_read_bytes_wav", 3 );
    static var snow_assets_audio_seek_bytes_wav  = Libs.load( "snow", "snow_assets_audio_seek_bytes_wav", 2 );

    static var snow_assets_audio_load_info_pcm   = Libs.load( "snow", "snow_assets_audio_load_info_pcm", 5 );
    static var snow_assets_audio_read_bytes_pcm  = Libs.load( "snow", "snow_assets_audio_read_bytes_pcm", 3 );
    static var snow_assets_audio_seek_bytes_pcm  = Libs.load( "snow", "snow_assets_audio_seek_bytes_pcm", 2 );

//Required by module interface

    function init():Void {}
    function update():Void {}
    function destroy():Void {}
    function on_event( event:SystemEvent ):Void {}


} //AssetSystem


    //These interact with the C++ side, where
    // haxe.io.ByteData is passed in directly

private typedef NativeAudioInfo = {
    id : String,
    format : Int,
    data : NativeAudioDataInfo,
    handle : AudioHandle
}

private typedef NativeAudioDataInfo = {
    length : Int,
    length_pcm : Int,
    channels : Int,
    rate : Int,
    bitrate : Int,
    bits_per_sample : Int,
    bytes : haxe.io.BytesData
}

private typedef NativeAudioDataBlob = {
    bytes : haxe.io.BytesData,
    complete : Bool
}
