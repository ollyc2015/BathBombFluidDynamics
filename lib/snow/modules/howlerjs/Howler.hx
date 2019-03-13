package snow.modules.howlerjs;

#if snow_web

//https://github.com/insweater/HaxeHowlerJS/

@:native("window.Howler") extern class Howler
{
	static function volume(vol:Float):Dynamic; // returns Howler or current volume (Float)
	static function mute():Howler;
	static function unmute():Howler;
}

#end //snow_web