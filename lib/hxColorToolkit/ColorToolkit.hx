/*
Author: Andy Li (andy@onthewings.net)
Based on colortoolkit (http://code.google.com/p/colortoolkit/)
*/

package hxColorToolkit;

import hxColorToolkit.schemes.*;
import hxColorToolkit.spaces.*;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class ColorToolkit {	
	static private var rybWheel: Array<Array<Int>> = [[0, 0], [15, 8], [30, 17], [45, 26], [60, 34], [75, 41], [90, 48], [105, 54], [120, 60], [135, 81], [150, 103], [165, 123], [180, 138], [195, 155], [210, 171], [225, 187], [240, 204], [255, 219], [270, 234], [285, 251], [300, 267], [315, 282], [330, 298], [345, 329], [360, 0]];
	
	inline public static function setColorOpaque(color:Int, ?opaqueValue:Int = 0xff):Int { return (opaqueValue << 24) | (color & 0xffffff); }
	
	inline public static function desaturate(color:Int):Int { return new Gray().setColor(color).getColor(); }

	inline public static function getComplement(color:Int):Int { return rybRotate(color, 180); }
	
	public static function shiftBrighteness(color:Int, degree:Float):Int 
	{
		var col:HSB = new HSB().setColor(color);
		
		col.brightness+=degree;
		
		return col.getColor();
	}
	
	public static function shiftSaturation(color:Int, degree:Float):Int
	{
		var col:HSB = new HSB().setColor(color);
		
		col.saturation+=degree;
		
		return col.getColor();
	}
	
	public static function shiftHue(color:Int, degree:Float):Int
	{
		var col:HSB = new HSB().setColor(color);
		
		col.hue+=degree;
		
		return col.getColor();
	}
	
	inline static public function toLab(color:Int):Lab
	{
		return new Lab().setColor(color);
	}
	
	inline static public function toGray(color:Int):Gray
	{
		return new Gray().setColor(color);
	}
	
	inline static public function toRGB(color:Int):RGB
	{
		return new RGB(color >> 16 & 0xFF, color >> 8 & 0xFF, color & 0xFF);
	}
	
	inline static public function toARGB(color:Int):RGB
	{
		return new ARGB(color >> 24 & 0xFF, color >> 16 & 0xFF, color >> 8 & 0xFF, color & 0xFF);
	}
	
	inline static public function toHSB(color:Int):HSB
	{
		return new HSB().setColor(color);
	}
	
	inline static public function toHSL(color:Int):HSL
	{
		return new HSL().setColor(color);
	}
	
	inline static public function toCMYK(color:Int):CMYK
	{
		return new CMYK().setColor(color);
	}
	
	inline static public function toXYZ(color:Int):XYZ
	{
		return new XYZ().setColor(color);
	}
	
	inline static public function toYUV(color:Int):YUV
	{
		return new YUV().setColor(color);
	}
	
	inline static public function toHex(color:Int):Hex
	{
		return new Hex(color);
	}

	inline static public function getAnalogousScheme(color:Int, ?angle:Float=10, ?contrast:Float=25):Analogous<Hex> {
		return new Analogous<Hex>(new Hex(color),angle,contrast);
	}

	inline static public function getComplementaryScheme(color:Int):Complementary<Hex> {
		return new Complementary<Hex>(new Hex(color));
	}

	inline static public function getCompoundScheme(color:Int):Compound<Hex> {
		return new Compound<Hex>(new Hex(color));
	}

	inline static public function getFlippedCompoundScheme(color:Int):FlippedCompound<Hex> {
		return new FlippedCompound<Hex>(new Hex(color));
	}

	inline static public function getMonochromeScheme(color:Int):Monochrome<Hex> {
		return new Monochrome<Hex>(new Hex(color));
	}

	inline static public function getSplitComplementaryScheme(color:Int):SplitComplementary<Hex> {
		return new SplitComplementary<Hex>(new Hex(color));
	}

	inline static public function getTetradScheme(color:Int, ?angle:Float=90, ?alt:Bool = false):Tetrad<Hex> {
		return new Tetrad<Hex>(new Hex(color),angle,alt);
	}

	inline static public function getTriadScheme(color:Int, ?angle:Float=120):Triad<Hex> {
		return new Triad<Hex>(new Hex(color),angle);
	}
	
	
	public static function rybRotate(color:Int, angle:Float):Int 
	{			
		var hsb:HSB = new HSB().setColor(color);
		
		var a: Float = 0;
		for (i in 0...rybWheel.length) {
			var x0: Int = rybWheel[i][0];
			var y0: Int = rybWheel[i][1];
       
			var x1: Int = rybWheel[i + 1][0];
			var y1: Int = rybWheel[i + 1][1];
			if(y1 < y0)  y1 += 360;
			if(y0 <= hsb.hue && hsb.hue <= y1) {
				a = 1.0 * x0 + (x1 - x0) * (hsb.hue - y0) / (y1 - y0);
				break;
			}
		}
		
		a = (a + (angle % 360));
		if (a < 0)  a = 360 + a;
		if (a > 360)  a = a - 360;
		a = a % 360;
		
		var newHue:Float = 0;
		for (k in 0...rybWheel.length) {
			var xx0: Int = rybWheel[k][0];
			var yy0: Int = rybWheel[k][1];
       
			var xx1: Int = rybWheel[k + 1][0];
			var yy1: Int = rybWheel[k + 1][1];
			if (yy1 < yy0) yy1 += 360;
			if (xx0 <= a && a <= xx1) {
				newHue = yy0 + (yy1 - yy0) * (a - xx0) / (xx1 - xx0);
				break;
			}
		}
		hsb.hue = newHue;
		
		return hsb.getColor();
	}

	static public function intArray(colors:ColorScheme<Dynamic>):Array<Int> {
		var a = [];
		for (c in colors) {
			a.push(c.getColor());
		}
		return a;
	}
}

class ColorSpaceToolkit {
	inline static public function toLab(color:Color):Lab
	{
		return new Lab().fromRGB(color.toRGB());
	}
	
	inline static public function toGray(color:Color):Gray
	{
		return new Gray().fromRGB(color.toRGB());
	}
	
	inline static public function toHSB(color:Color):HSB
	{
		return new HSB().fromRGB(color.toRGB());
	}
	
	inline static public function toHSL(color:Color):HSL
	{
		return new HSL().fromRGB(color.toRGB());
	}
	
	inline static public function toCMYK(color:Color):CMYK
	{
		return new CMYK().fromRGB(color.toRGB());
	}
	
	inline static public function toXYZ(color:Color):XYZ
	{
		return new XYZ().fromRGB(color.toRGB());
	}
	
	inline static public function toYUV(color:Color):YUV
	{
		return new YUV().fromRGB(color.toRGB());
	}
	
	inline static public function toARGB(color:Color):ARGB
	{
		return new ARGB().fromRGB(color.toRGB());
	}
	
	inline static public function toHex(color:Color):Hex
	{
		return new Hex(color.getColor());
	}
	
	macro static public function getAnalogousScheme(color:ExprOf<Color>, ?angle:ExprOf<Float>, ?contrast:ExprOf<Float>) {
		var colorType = switch (Context.typeof(color)){
			case TInst(t,_): t.get();
			default: throw color + "should be a Color class";
		}
		
		return { expr:ENew({ sub:null, name:"Analogous", pack:["hxColorToolkit","schemes"], params:[TPType(TPath({ sub:null, name:colorType.name, pack:colorType.pack, params:[] }))] },[color,angle,contrast]), pos:Context.currentPos() };
	}
	
	macro static public function getComplementaryScheme(color:ExprOf<Color>) {
		var colorType = switch (Context.typeof(color)){
			case TInst(t,_): t.get();
			default: throw color + "should be a Color class";
		}
		
		return { expr:ENew({ sub:null, name:"Complementary", pack:["hxColorToolkit","schemes"], params:[TPType(TPath({ sub:null, name:colorType.name, pack:colorType.pack, params:[] }))] },[color]), pos:Context.currentPos() };
	}
	
	macro static public function getCompoundScheme(color:ExprOf<Color>) {
		var colorType = switch (Context.typeof(color)){
			case TInst(t,_): t.get();
			default: throw color + "should be a Color class";
		}
		
		return { expr:ENew({ sub:null, name:"Compound", pack:["hxColorToolkit","schemes"], params:[TPType(TPath({ sub:null, name:colorType.name, pack:colorType.pack, params:[] }))] },[color]), pos:Context.currentPos() };
	}
	
	macro static public function getFlippedCompoundScheme(color:ExprOf<Color>) {
		var colorType = switch (Context.typeof(color)){
			case TInst(t,_): t.get();
			default: throw color + "should be a Color class";
		}
		
		return { expr:ENew({ sub:null, name:"FlippedCompound", pack:["hxColorToolkit","schemes"], params:[TPType(TPath({ sub:null, name:colorType.name, pack:colorType.pack, params:[] }))] },[color]), pos:Context.currentPos() };
	}
	
	macro static public function getMonochromeScheme(color:ExprOf<Color>) {
		var colorType = switch (Context.typeof(color)){
			case TInst(t,_): t.get();
			default: throw color + "should be a Color class";
		}
		
		return { expr:ENew({ sub:null, name:"Monochrome", pack:["hxColorToolkit","schemes"], params:[TPType(TPath({ sub:null, name:colorType.name, pack:colorType.pack, params:[] }))] },[color]), pos:Context.currentPos() };
	}
	
	macro static public function getSplitComplementaryScheme(color:ExprOf<Color>) {
		var colorType = switch (Context.typeof(color)){
			case TInst(t,_): t.get();
			default: throw color + "should be a Color class";
		}
		
		return { expr:ENew({ sub:null, name:"SplitComplementary", pack:["hxColorToolkit","schemes"], params:[TPType(TPath({ sub:null, name:colorType.name, pack:colorType.pack, params:[] }))] },[color]), pos:Context.currentPos() };
	}
	
	macro static public function getTetradScheme(color:ExprOf<Color>, ?angle:ExprOf<Float>, ?alt:ExprOf<Bool>) {
		var colorType = switch (Context.typeof(color)){
			case TInst(t,_): t.get();
			default: throw color + "should be a Color class";
		}
		
		return { expr:ENew({ sub:null, name:"Tetrad", pack:["hxColorToolkit","schemes"], params:[TPType(TPath({ sub:null, name:colorType.name, pack:colorType.pack, params:[] }))] },[color,angle,alt]), pos:Context.currentPos() };
	}
	
	macro static public function getTriadScheme(color:ExprOf<Color>, ?angle:ExprOf<Float>) {
		var colorType = switch (Context.typeof(color)){
			case TInst(t,_): t.get();
			default: throw color + "should be a Color class";
		}
		
		return { expr:ENew({ sub:null, name:"Triad", pack:["hxColorToolkit","schemes"], params:[TPType(TPath({ sub:null, name:colorType.name, pack:colorType.pack, params:[] }))] },[color,angle]), pos:Context.currentPos() };
	}
}
