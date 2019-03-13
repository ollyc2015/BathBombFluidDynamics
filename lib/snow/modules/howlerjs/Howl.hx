package snow.modules.howlerjs;

#if snow_web

//https://github.com/insweater/HaxeHowlerJS/

@:native("window.Howl") extern class Howl
{
    function new(o:Dynamic):Void;
    function load():Howl;
    function urls(urls:Array<String>):Dynamic; // returns Howl or current list or URLs (Array<String>)
    function play(?sprite:String, ?callBack:?String->Void):Howl;
    function pause(?id:String, ?timerId:String):Howl;
    function stop(?id:String, ?timerId:String):Howl;
    function mute(?id:String):Howl;
    function unmute(?id:String):Howl;
    function volume(?vol:Float, ?id:String):Dynamic; // returns Howl or current volume (Float)
    function loop(loop:Bool):Dynamic; // returns Howl or current looping value (Bool)
    function sprite(sprite:SpriteParams):Dynamic; // Returns Howl or current sprite
    function pos(?pos:Float, ?id:String):Dynamic; // returns Howl or current playback position (Float)
    function pos3d(?x:Float, ?y:Float, ?z:Float, ?id:String):Dynamic; // returns Howl or current 3D position (Array<Float>)
    function fade(from:Float, to:Float, len:Float, ?callBack:Void->Void, ?id:String):Howl;
    function fadeIn(to:Float, len:Float, callBack:Void->Void):Howl;
    function fadeOut(to:Float, len:Float, calBack:Void->Void, ?id:String):Howl;
    function on(event:String, fn:Dynamic):Howl;
    function off(event:String, fn:Dynamic):Howl;
    function unload():Void;
}

typedef SpriteParams = {
    ?offset:Int,
    ?duration:Int,
    ?loop:Bool
}

typedef AudioParams = {
    ?autoplay:Bool,
    ?buffer:Bool,
    ?duration:Float,
    ?format:Bool,
    ?loop:Bool,
    ?sprite:Dynamic,
    ?src:String,
    ?pos3d:Array<Float>,
    ?volume:Float,
    ?urls:Array<String>,
    ?rate:Float,
    ?onload:Void->Void,
    ?onloaderror:Void->Void,
    ?onend:Void->Void,
    ?onpause:Void->Void,
    ?onplay:Void->Void
}

#end //snow_web
