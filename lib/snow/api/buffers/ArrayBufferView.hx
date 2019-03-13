package snow.api.buffers;

#if js

    typedef ArrayBufferView = js.html.ArrayBufferView;

#else

    import snow.api.buffers.TypedArrayType;

    class ArrayBufferView {

        public var type = TypedArrayType.None;
        public var buffer:ArrayBuffer;
        public var byteOffset:Int;
        public var byteLength:Int;
        public var length:Int;

            //internal for avoiding switching on types
        var bytesPerElement (default,null) : Int = 0;

        @:allow(snow.api.buffers)
        #if !snow_no_inline_buffers inline #end
        function new( ?elements:Null<Int> = null, in_type:TypedArrayType) {

            type = in_type;
            bytesPerElement = bytesForType(type);

                //other constructor types use
                //the init calls below
            if(elements != null && elements != 0) {

                if(elements < 0) elements = 0;
                //:note:spec: also has, platform specific max int?
                //elements = min(elements,maxint);

                byteOffset = 0;
                byteLength = toByteLength(elements);
                buffer = new ArrayBuffer( byteLength );
                length = elements;

            }

        } //new

    //Constructor helpers

        @:allow(snow.api.buffers)
        #if !snow_no_inline_buffers inline #end
        function initTypedArray( view:ArrayBufferView ) {

            var srcData = view.buffer;
            var srcLength = view.length;
            var srcByteOffset = view.byteOffset;
            var srcElementSize = view.bytesPerElement;
            var elementSize = bytesPerElement;

                    //same species, so just blit the data
                    //in other words, it shares the same bytes per element etc
                if(view.type == type) {
                    cloneBuffer(srcData, srcByteOffset);
                } else {
                    //see :note:1: below use FPHelper!
                    throw ("unimplemented");
                }

            byteLength = bytesPerElement * srcLength;
            byteOffset = 0;
            length = srcLength;

            return this;

        } //(typedArray)

        @:allow(snow.api.buffers)
        #if !snow_no_inline_buffers inline #end
        function initBuffer( in_buffer:ArrayBuffer, ?in_byteOffset:Int = 0, len:Null<Int> = null ) {

            if(in_byteOffset < 0) throw TAError.RangeError;
            if(in_byteOffset % bytesPerElement != 0) throw TAError.RangeError;

            var bufferByteLength = in_buffer.length;
            var elementSize = bytesPerElement;
            var newByteLength = bufferByteLength;

            if( len == null ) {

                newByteLength = bufferByteLength - in_byteOffset;

                if(bufferByteLength % bytesPerElement != 0) throw TAError.RangeError;
                if(newByteLength < 0) throw TAError.RangeError;

            } else {

                newByteLength = len * bytesPerElement;

                var newRange = in_byteOffset + newByteLength;
                if( newRange > bufferByteLength ) throw TAError.RangeError;

            }

            buffer = in_buffer;
            byteOffset = in_byteOffset;
            byteLength = newByteLength;
            length = Std.int(newByteLength / bytesPerElement);

            return this;

        } //(buffer [, byteOffset [, length]])


        @:allow(snow.api.buffers)
        #if !snow_no_inline_buffers inline #end
        function initArray<T>( array:Array<T> ) {

            byteOffset = 0;
            length = array.length;
            byteLength = toByteLength(length);

            buffer = new ArrayBuffer( byteLength );
            copyFromArray(cast array);

            return this;

        }


    //Public shared APIs

    //T is required because it can translate [0,0] as Int array
        #if !snow_no_inline_buffers inline #end
    public function set<T>( ?view:ArrayBufferView, ?array:Array<T>, offset:Int = 0 ) : Void {

        if(view != null && array == null) {
            buffer.blit( toByteLength(offset), view.buffer, view.byteOffset, view.byteLength );
        } else if(array != null && view == null) {
            copyFromArray(cast array, offset);
        } else {
            throw "Invalid .set call. either view, or array must be not-null.";
        }

    }


    //Internal TypedArray api

        #if !snow_no_inline_buffers inline #end
        function cloneBuffer(src:ArrayBuffer, srcByteOffset:Int = 0) {

            var srcLength = src.length;
            var cloneLength = srcLength - srcByteOffset;

            buffer = new ArrayBuffer( cloneLength );
            buffer.blit( 0, src, srcByteOffset, cloneLength );

        }


        @:generic
        @:allow(snow.api.buffers)
        #if !snow_no_inline_buffers inline #end
        function subarray<T_subarray>( begin:Int, end:Null<Int> = null ) : T_subarray {

            if (end == null) end == length;
            var len = end - begin;
            var byte_offset = toByteLength(begin) + byteOffset;

            var view : ArrayBufferView =
                switch(type) {

                    case Int8:
                         new Int8Array(buffer, byte_offset, len);

                    case Int16:
                         new Int16Array(buffer, byte_offset, len);

                    case Int32:
                         new Int32Array(buffer, byte_offset, len);

                    case Uint8:
                         new Uint8Array(buffer, byte_offset, len);

                    case Uint8Clamped:
                         new Uint8ClampedArray(buffer, byte_offset, len);

                    case Uint16:
                         new Uint16Array(buffer, byte_offset, len);

                    case Uint32:
                         new Uint32Array(buffer, byte_offset, len);

                    case Float32:
                         new Float32Array(buffer, byte_offset, len);

                    case Float64:
                         new Float64Array(buffer, byte_offset, len);

                    case None:
                        throw "subarray on a blank ArrayBufferView";
                }

            return cast view;

        }

        #if !snow_no_inline_buffers inline #end
        function bytesForType( type:TypedArrayType ) : Int {

            return
                switch(type) {

                    case Int8:
                         Int8Array.BYTES_PER_ELEMENT;

                    case Uint8:
                         Uint8Array.BYTES_PER_ELEMENT;

                    case Uint8Clamped:
                         Uint8ClampedArray.BYTES_PER_ELEMENT;

                    case Int16:
                         Int16Array.BYTES_PER_ELEMENT;

                    case Uint16:
                         Uint16Array.BYTES_PER_ELEMENT;

                    case Int32:
                         Int32Array.BYTES_PER_ELEMENT;

                    case Uint32:
                         Uint32Array.BYTES_PER_ELEMENT;

                    case Float32:
                         Float32Array.BYTES_PER_ELEMENT;

                    case Float64:
                         Float64Array.BYTES_PER_ELEMENT;

                    case _: 1;
                }

        }

        #if !snow_no_inline_buffers inline #end
        function toString() {

            var name =
                switch(type) {
                    case Int8: 'Int8Array';
                    case Uint8: 'Uint8Array';
                    case Uint8Clamped: 'Uint8ClampedArray';
                    case Int16: 'Int16Array';
                    case Uint16: 'Uint16Array';
                    case Int32: 'Int32Array';
                    case Uint32: 'Uint32Array';
                    case Float32: 'Float32Array';
                    case Float64: 'Float64Array';
                    case _: 'ArrayBufferView';
                }

            return name + ' [byteLength:${this.byteLength}, length:${this.length}]';

        } //toString

        #if !snow_no_inline_buffers inline #end
        function toByteLength( elemCount:Int ) : Int {

            return elemCount * bytesPerElement;

        }

    //Non-spec

        #if !snow_no_inline_buffers #end
        function copyFromArray(array:Array<Float>, ?offset : Int = 0 ) {

            //Ideally, native semantics could be used, like cpp.NativeArray.blit
            var i = 0, len = array.length;

            switch(type) {
                case Int8:
                    while(i<len) {
                        var pos = (offset+i)*bytesPerElement;
                        ArrayBufferIO.setInt8(buffer,
                            pos, Std.int(array[i]));
                        ++i;
                    }
                case Int16:
                    while(i<len) {
                        var pos = (offset+i)*bytesPerElement;
                        ArrayBufferIO.setInt16(buffer,
                            pos, Std.int(array[i]));
                        ++i;
                    }
                case Int32:
                    while(i<len) {
                        var pos = (offset+i)*bytesPerElement;
                        ArrayBufferIO.setInt32(buffer,
                            pos, Std.int(array[i]));
                        ++i;
                    }
                case Uint8:
                    while(i<len) {
                        var pos = (offset+i)*bytesPerElement;
                        ArrayBufferIO.setUint8(buffer,
                            pos, Std.int(array[i]));
                        ++i;
                    }
                case Uint16:
                    while(i<len) {
                        var pos = (offset+i)*bytesPerElement;
                        ArrayBufferIO.setUint16(buffer,
                            pos, Std.int(array[i]));
                        ++i;
                    }
                case Uint32:
                    while(i<len) {
                        var pos = (offset+i)*bytesPerElement;
                        ArrayBufferIO.setUint32(buffer,
                            pos, Std.int(array[i]));
                        ++i;
                    }
                case Uint8Clamped:
                    while(i<len) {
                        var pos = (offset+i)*bytesPerElement;
                        ArrayBufferIO.setUint8Clamped(buffer,
                            pos, Std.int(array[i]));
                        ++i;
                    }
                case Float32:
                    while(i<len) {
                        var pos = (offset+i)*bytesPerElement;
                        ArrayBufferIO.setFloat32(buffer,
                            pos, array[i]);
                        ++i;
                    }
                case Float64:
                    while(i<len) {
                        var pos = (offset+i)*bytesPerElement;
                        ArrayBufferIO.setFloat64(buffer,
                            pos, array[i]);
                        ++i;
                    }

                case None:
                    throw "copyFromArray on a base type ArrayBuffer";

            }

        }

    } //ArrayBufferView

#end //!js
