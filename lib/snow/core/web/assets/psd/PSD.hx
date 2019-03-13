package snow.core.web.assets.psd;

import snow.api.buffers.Uint8Array;

/*
Bindings for https://github.com/meltingice/psd.js
Copyright Sven Bergström
Created for http://snowkit.org/snow
MIT License
*/

@:native('window.PSD')
extern class PSD {

    public function new( _bytes:Uint8Array );
    public function parse():Void;

} //PSD