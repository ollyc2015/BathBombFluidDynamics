package snow.api.buffers;

@:enum
abstract TypedArrayType(Int) from Int to Int {
    var None            = 0;
    var Int8            = 1;
    var Int16           = 2;
    var Int32           = 3;
    var Uint8           = 4;
    var Uint8Clamped    = 5;
    var Uint16          = 6;
    var Uint32          = 7;
    var Float32         = 8;
    var Float64         = 9;
}

