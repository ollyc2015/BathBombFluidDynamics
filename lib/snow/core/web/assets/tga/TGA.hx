package snow.core.web.assets.tga;

/*
Externs for https://github.com/vthibault/jsTGALoader
Copyright Sven Bergström
Created for http://snowkit.org/snow
MIT License
*/

#if js

typedef TGAHeader = {
    idLength : Int,
    colorMapType : Int,
    imageType : Int,
    colorMapIndex : Int,
    colorMapLength : Int,
    colorMapDepth : Int,
    offsetX : Int,
    offsetY : Int,
    width : Int,
    height : Int,
    pixelDepth : Int,
    flags : Int,
    hasEncoding : Bool,
    hasColorMap : Bool,
    isGreyColor : Bool
}

@:native("window.TGA")
extern class TGA {

    public var header : TGAHeader;

    public function new();
    public function open( _url:String, onload:Dynamic->Void ):Void;
    public function load( data:js.html.Uint8Array ) : Void;
    public function getCanvas() : js.html.CanvasElement;
    public function getDataURL( ?_mime:String='image/png' ) : String;
    public function getImageData() : js.html.ImageData;

} //TGA

#end //js