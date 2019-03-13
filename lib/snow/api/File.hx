package snow.api;

import snow.api.buffers.ArrayBufferView;
import snow.api.Libs;

#if snow_native

    @:enum abstract FileSeek(Int) from Int to Int {
        var set = 0;
        var cur = 1;
        var end = 2;
    }

    abstract FileHandle(Null<Float>) from Null<Float> to Null<Float> { }

    /** This class is a low level cross platform file access helper, that handles in bundle assets etc.
        If you want a file, use `Assets` instead, unless really required. */
    class File {

            /** The internal native file handle */
        public var handle : FileHandle;

        function new( _handle:FileHandle ) {
            handle = _handle;
        } //new

            /** Read a `maxnum` of items of `size` in bytes, into `dest`. Same signature/returns as `fread` */
        public function read( dest:ArrayBufferView, size:Int, maxnum:Int ) {
            return snow_iosrc_file_read(handle, dest.buffer.getData(), size, maxnum);
        } //read

            /** Write `num` of items of `size` in bytes, from `src` into this file. Same signature/returns as `fwrite` */
        public function write( src:ArrayBufferView, size:Int, num:Int ) {
            return snow_iosrc_file_write(handle, src.buffer.getData(), size, num);
        } //write

            /** Seek `offset` from `whence`, where whence is FileSeek.set, FileSeek.cur, or FileSeek.end. Same signature/returns as `fseek` */
        public function seek( offset:Int, whence:FileSeek ) {
            return snow_iosrc_file_seek(handle, offset, whence);
        } //seek

            /** Tell the current position in the file, in bytes */
        public function tell() {
            return snow_iosrc_file_tell(handle);
        } //tell

            /** Close the file handle and releases the internal handle. 
                After calling this the file is no longer usable. */
        public function close() {
            var res : Int = snow_iosrc_file_close(handle);
                handle = null;
            return res;
        } //close


            /** Create a `File` from a file path `_id`, this bypasses the `Asset` system path helpers, so use wisely */
        public static function from_file( _id:String, ?_mode:String="rb" ) : File {

            var handle : FileHandle = snow_iosrc_from_file(_id, _mode);

            if(handle != null) {
                return new File(handle);
            }

            return null;

        } //from_file

        static var snow_iosrc_from_file    = Libs.load( "snow", "snow_iosrc_from_file", 2 );
        static var snow_iosrc_file_read    = Libs.load( "snow", "snow_iosrc_file_read", 4 );
        static var snow_iosrc_file_write   = Libs.load( "snow", "snow_iosrc_file_write", 4 );
        static var snow_iosrc_file_seek    = Libs.load( "snow", "snow_iosrc_file_seek", 3 );
        static var snow_iosrc_file_tell    = Libs.load( "snow", "snow_iosrc_file_tell", 1 );
        static var snow_iosrc_file_close   = Libs.load( "snow", "snow_iosrc_file_close", 1 );

    } //File

#else

#error "File is only available on snow native platforms."

#end //snow_native
