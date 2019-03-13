package snow.api.buffers;

#if !js

class ArrayBufferIO {

    //8

        #if !snow_no_inline_buffers @:extern inline #end
        public static function getInt8( buffer:ArrayBuffer, byteOffset:Int ) : Int {

            #if cpp
                return untyped __global__.__hxcpp_memory_get_byte(buffer.getData(), byteOffset);
            #else
                var val:Int = buffer.get(byteOffset);
                return ((val & 0x80) != 0) ?(val - 0x100) : val;
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function setInt8( buffer:ArrayBuffer, byteOffset:Int, value:Int ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_byte(buffer.getData(), byteOffset, value);
            #elseif neko
                untyped __dollar__sset(buffer.b, byteOffset, value & 0xff);
            #else
                buffer.set(byteOffset, value);
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function getUint8( buffer:ArrayBuffer, byteOffset:Int ) : Null<UInt> {

            #if cpp
                return untyped __global__.__hxcpp_memory_get_byte(buffer.getData(), byteOffset) & 0xff;
            #else
                return buffer.get( byteOffset );
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function setUint8Clamped( buffer:ArrayBuffer, byteOffset:Int, value:UInt ) {

            setUint8( buffer, byteOffset, _clamp(value) );

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function setUint8( buffer:ArrayBuffer, byteOffset:Int, value:UInt ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_byte(buffer.getData(), byteOffset, value);
            #else
                buffer.set( byteOffset, value );
            #end

        }

    //16

        public static  function getInt16( buffer:ArrayBuffer, byteOffset:Int ) : Int {

            #if cpp
                untyped return __global__.__hxcpp_memory_get_i16(buffer.getData(), byteOffset);
            #else
                var ch1 = buffer.get(byteOffset    );
                var ch2 = buffer.get(byteOffset + 1);

                var val = ((ch2 << 8) | ch1);

                return
                    ((val & 0x8000) != 0) ?
                        ( val - 0x10000 ) : ( val );
            #end

        }

        public static  function getInt16_BE( buffer:ArrayBuffer, byteOffset:Int ) : Int {

            #if cpp
                untyped return __global__.__hxcpp_memory_get_i16(buffer.getData(), byteOffset);
            #else
                
                var ch1 = buffer.get(byteOffset    );
                var ch2 = buffer.get(byteOffset + 1);

                var val = ((ch1 << 8) | ch2);

                return
                    ((val & 0x8000) != 0) ?
                        ( val - 0x10000 ) : ( val );
            #end

        }

        public static function setInt16( buffer:ArrayBuffer, byteOffset:Int, value:Int ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_i16(buffer.getData(), byteOffset, value);
            #elseif neko
                untyped var b = buffer.b;
                untyped __dollar__sset(b, byteOffset  , (value     ) & 0xff);
                untyped __dollar__sset(b, byteOffset+1, (value >> 8) & 0xff);
            #else
                buffer.set(byteOffset  , (value     ) & 0xff);
                buffer.set(byteOffset+1, (value >> 8) & 0xff);
            #end

        }

        public static function setInt16_BE( buffer:ArrayBuffer, byteOffset:Int, value:Int ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_i16(buffer.getData(), byteOffset, value);
            #elseif neko
                untyped var b = buffer.b;
                untyped __dollar__sset(b, byteOffset  , (value >> 8) & 0xff);
                untyped __dollar__sset(b, byteOffset+1, (value     ) & 0xff);
            #else
                buffer.set(byteOffset  , (value >> 8) & 0xff);
                buffer.set(byteOffset+1, (value     ) & 0xff);
            #end

        } //setInt16_BE

        #if !snow_no_inline_buffers @:extern inline #end
        public static function getUint16( buffer:ArrayBuffer, byteOffset:Int ) : Null<UInt> {

            #if cpp
                untyped return __global__.__hxcpp_memory_get_ui16(buffer.getData(), byteOffset) & 0xffff;
            #else

                var ch1 = buffer.get(byteOffset    );
                var ch2 = buffer.get(byteOffset + 1);

                return ((ch2 << 8) | ch1);

            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function getUint16_BE( buffer:ArrayBuffer, byteOffset:Int ) : Null<UInt> {

            #if cpp
                untyped return __global__.__hxcpp_memory_get_ui16(buffer.getData(), byteOffset) & 0xffff;
            #else

                var ch1 = buffer.get(byteOffset    );
                var ch2 = buffer.get(byteOffset + 1);

                return ((ch1 << 8) | ch2);

            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function setUint16( buffer:ArrayBuffer, byteOffset:Int, value:UInt ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_ui16(buffer.getData(), byteOffset, value);
            #else
                setInt16(buffer, byteOffset, value);
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function setUint16_BE( buffer:ArrayBuffer, byteOffset:Int, value:UInt ) {

            #if cpp
                    //:todo: Big endian ui16
                untyped __global__.__hxcpp_memory_set_ui16(buffer.getData(), byteOffset, value);
            #else
                setInt16_BE(buffer, byteOffset, value);
            #end

        }

    //32

        #if !snow_no_inline_buffers @:extern inline #end
        public static function getInt32( buffer:ArrayBuffer, byteOffset:Int ) : Int {

            #if cpp
                untyped return __global__.__hxcpp_memory_get_i32(buffer.getData(), byteOffset);
            #else

                #if (haxe_ver >= 3.2)
                    return buffer.getInt32(byteOffset);
                #else

                    var ch1 = getInt8(buffer, byteOffset  );
                    var ch2 = getInt8(buffer, byteOffset+1);
                    var ch3 = getInt8(buffer, byteOffset+2);
                    var ch4 = getInt8(buffer, byteOffset+3);

                    return (ch4 << 24) |(ch3 << 16) |(ch2 << 8) | ch1;

                #end //3.1.3
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function getInt32_BE( buffer:ArrayBuffer, byteOffset:Int ) : Int {

            #if cpp
                untyped return __global__.__hxcpp_memory_get_i32(buffer.getData(), byteOffset);
            #else

                #if (haxe_ver >= 3.2)
                    return buffer.getInt32(byteOffset);
                #else

                    var ch1 = getInt8(buffer, byteOffset  );
                    var ch2 = getInt8(buffer, byteOffset+1);
                    var ch3 = getInt8(buffer, byteOffset+2);
                    var ch4 = getInt8(buffer, byteOffset+3);

                    return (ch1 << 24) |(ch2 << 16) |(ch3 << 8) | ch4;

                #end //3.1.3
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function setInt32( buffer:ArrayBuffer, byteOffset:Int, value:Int ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_i32(buffer.getData(), byteOffset, value);
            #else
                #if (haxe_ver >= 3.2)
                    buffer.setInt32(byteOffset,value);
                #else
                    setInt8(buffer, byteOffset  , value      );
                    setInt8(buffer, byteOffset+1, value >>  8);
                    setInt8(buffer, byteOffset+2, value >> 16);
                    setInt8(buffer, byteOffset+3, value >> 24);
                #end //3.1.3.
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function setInt32_BE( buffer:ArrayBuffer, byteOffset:Int, value:Int ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_i32(buffer.getData(), byteOffset, value);
            #else
                #if (haxe_ver >= 3.2)
                    buffer.setInt32(byteOffset,value);
                #else
                    setInt8(buffer, byteOffset  , value >> 24);
                    setInt8(buffer, byteOffset+1, value >> 16);
                    setInt8(buffer, byteOffset+2, value >>  8);
                    setInt8(buffer, byteOffset+3, value      );
                #end //3.1.3.
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function getUint32( buffer:ArrayBuffer, byteOffset:Int ) : Null<UInt> {

            #if cpp
                untyped return __global__.__hxcpp_memory_get_ui32(buffer.getData(), byteOffset);
            #else
                return getInt32( buffer, byteOffset );
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function getUint32_BE( buffer:ArrayBuffer, byteOffset:Int ) : Null<UInt> {

            #if cpp
                untyped return __global__.__hxcpp_memory_get_ui32(buffer.getData(), byteOffset);
            #else
                return getInt32_BE( buffer, byteOffset );
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function setUint32( buffer:ArrayBuffer, byteOffset:Int, value:UInt ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_ui32(buffer.getData(), byteOffset, value);
            #else
                setInt32( buffer, byteOffset, value );
            #end

        }
        #if !snow_no_inline_buffers @:extern inline #end
        public static function setUint32_BE( buffer:ArrayBuffer, byteOffset:Int, value:UInt ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_ui32(buffer.getData(), byteOffset, value);
            #else
                setInt32_BE( buffer, byteOffset, value );
            #end

        }

    //Float

        #if !snow_no_inline_buffers @:extern inline #end
        public static function getFloat32( buffer:ArrayBuffer, byteOffset:Int ) : Float {

            #if cpp
                untyped return __global__.__hxcpp_memory_get_float(buffer.getData(), byteOffset);
            #else
                return buffer.getFloat( byteOffset );
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function getFloat32_BE( buffer:ArrayBuffer, byteOffset:Int ) : Float {

            #if cpp
                untyped return __global__.__hxcpp_memory_get_float(buffer.getData(), byteOffset);
            #else
                return buffer.getFloat( byteOffset );
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function setFloat32( buffer:ArrayBuffer, byteOffset:Int, value:Float ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_float(buffer.getData(), byteOffset, value);
            #else
                buffer.setFloat( byteOffset, value );
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function setFloat32_BE( buffer:ArrayBuffer, byteOffset:Int, value:Float ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_float(buffer.getData(), byteOffset, value);
            #else
                buffer.setFloat( byteOffset, value );
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function getFloat64( buffer:ArrayBuffer, byteOffset:Int ) : Float {

            #if cpp
                untyped return __global__.__hxcpp_memory_get_double(buffer.getData(), byteOffset);
            #else
                return buffer.getDouble( byteOffset );
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function getFloat64_BE( buffer:ArrayBuffer, byteOffset:Int ) : Float {

            #if cpp
                untyped return __global__.__hxcpp_memory_get_double(buffer.getData(), byteOffset);
            #else
                return buffer.getDouble( byteOffset );
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function setFloat64( buffer:ArrayBuffer, byteOffset:Int, value:Float ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_double(buffer.getData(), byteOffset, value);
            #else
                buffer.setDouble( byteOffset, value );
            #end

        }

        #if !snow_no_inline_buffers @:extern inline #end
        public static function setFloat64_BE( buffer:ArrayBuffer, byteOffset:Int, value:Float ) {

            #if cpp
                untyped __global__.__hxcpp_memory_set_double(buffer.getData(), byteOffset, value);
            #else
                buffer.setDouble( byteOffset, value );
            #end

        }

//Internal

    #if !snow_no_inline_buffers @:extern inline #end
    //clamp a Int to a 0-255 Uint8 (for Uint8Clamped array)
    static function _clamp(_in:Float) : Int {

        var _out = Std.int(_in);
        _out = _out > 255 ? 255 : _out;
        return _out < 0 ? 0 : _out;

    } //_clamp

}

#else

    #error "ArrayBufferIO is not used on js target, use DataView instead"

#end //!js