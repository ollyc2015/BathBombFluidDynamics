 /*
Author: Andy Li (andy@onthewings.net)
Based on colortoolkit (http://code.google.com/p/colortoolkit/)
 
The MIT License

Copyright (c) 2009 P.J. Onori (pj@somerandomdude.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

//via http://www.adobe.com/cfusion/communityengine/index.cfm?event=showdetails&productId=2&postId=14227
//@see http://en.wikipedia.org/wiki/CIE_1931_color_space

package hxColorToolkit.spaces;

import hxColorToolkit.spaces.Lab;

class XYZ implements Color {

	public var numOfChannels(default,null):Int;

	public function getValue(channel:Int):Float {
		return data[channel];
	}
	public function setValue(channel:Int,val:Float):Float {
		if (channel < 0 || channel >= numOfChannels) throw "no such channel";
		data[channel] = Math.min(maxValue(channel), Math.max(val, minValue(channel)));
		return val;
	}

	inline public function minValue(channel:Int):Float {
		return 0;
	}
	public function maxValue(channel:Int):Float {
		return switch (channel) {
			case 0: 95.047;
			case 1: 100.000;
			case 2: 108.883;
			default: throw "XYZ does not have channel "+ channel;
		}
	}

	public var x(get_x, set_x) : Float;
	public var y(get_y, set_y) : Float;
	public var z(get_z, set_z) : Float;

	private function get_x():Float{
		return getValue(0);
	}

	private function set_x(value:Float):Float{
		return setValue(0,value);
	}
	
	private function get_y():Float{
		return getValue(1);
	}
	
	private function set_y(value:Float):Float{
		return setValue(1,value);
	}
	
	private function get_z():Float{
		return getValue(2);
	}
	
	private function set_z(value:Float):Float{
		return setValue(2,value);
	}
	
	public function toRGB():RGB {
		//X from 0 to  95.047      (Observer = 2°, Illuminant = D65)
		//Y from 0 to 100.000
		//Z from 0 to 108.883
		var x:Float = x * 0.01;
		var y:Float = y * 0.01;
		var z:Float = z * 0.01;
		 
		var r:Float = x * 3.2406 + y * -1.5372 + z * -0.4986;
		var g:Float = x * -0.9689 + y * 1.8758 + z * 0.0415;
		var b:Float = x * 0.0557 + y * -0.2040 + z * 1.0570;
		 
		if ( r > 0.0031308 ) { r = 1.055 * Math.pow( r , ( 1 / 2.4 ) ) - 0.055; }
		else { r = 12.92 * r; }
		if ( g > 0.0031308 ) { g = 1.055 * Math.pow( g , ( 1 / 2.4 ) ) - 0.055; }
		else { g = 12.92 * g; }
		if ( b > 0.0031308 ) { b = 1.055 * Math.pow( b , ( 1 / 2.4 ) ) - 0.055; }
		else { b = 12.92 * b; }
		
		return new RGB(Math.round(r*255), Math.round(g*255), Math.round(b*255));
	}
	
	public function getColor():Int{
		//X from 0 to  95.047      (Observer = 2°, Illuminant = D65)
		//Y from 0 to 100.000
		//Z from 0 to 108.883
		var x:Float = x * 0.01;
		var y:Float = y * 0.01;
		var z:Float = z * 0.01;
		 
		var r:Float = x * 3.2406 + y * -1.5372 + z * -0.4986;
		var g:Float = x * -0.9689 + y * 1.8758 + z * 0.0415;
		var b:Float = x * 0.0557 + y * -0.2040 + z * 1.0570;
		 
		if ( r > 0.0031308 ) { r = 1.055 * Math.pow( r , ( 1 / 2.4 ) ) - 0.055; }
		else { r = 12.92 * r; }
		if ( g > 0.0031308 ) { g = 1.055 * Math.pow( g , ( 1 / 2.4 ) ) - 0.055; }
		else { g = 12.92 * g; }
		if ( b > 0.0031308 ) { b = 1.055 * Math.pow( b , ( 1 / 2.4 ) ) - 0.055; }
		else { b = 12.92 * b; }
		
		var cR:Int = Math.round(r*255) << 16;
		var cG:Int = Math.round(g*255) << 8;
		var cB:Int = Math.round(b*255);
		
		return cR | cG | cB;
	}
	
	public function fromRGB(rgb:RGB):XYZ {
		var r = rgb.red/255;
		var g = rgb.green/255;
		var b = rgb.blue/255;
		 
		if (r > 0.04045){ r = Math.pow((r + 0.055) / 1.055, 2.4); }
		else { r = r / 12.92; }
		if ( g > 0.04045){ g = Math.pow((g + 0.055) / 1.055, 2.4); }
		else { g = g / 12.92; }
		if (b > 0.04045){ b = Math.pow((b + 0.055) / 1.055, 2.4); }
		else { b = b / 12.92; }
		r *= 100;
		g *= 100;
		b *= 100;
		 
		//Observer. = 2°, Illuminant = D65
		this.x = r * 0.4124 + g * 0.3576 + b * 0.1805;
		this.y = r * 0.2126 + g * 0.7152 + b * 0.0722;
		this.z = r * 0.0193 + g * 0.1192 + b * 0.9505;
		return this;
	}

	public function toLab():Lab {
		var x:Float = this.x / 95.047;   // Observer= 2°, Illuminant= D65
		var y:Float = this.y / 100.000;  
		var z:Float = this.z / 108.883;  
		 
		if ( x > 0.008856 ) { x = Math.pow( x , 1/3 ); }
		else { x = ( 7.787 * x ) + ( 16/116 ); }
		if ( y > 0.008856 ) { y = Math.pow( y , 1/3 ); }
		else { y = ( 7.787 * y ) + ( 16/116 ); }
		if ( z > 0.008856 ) { z = Math.pow( z , 1/3 ); }
		else { z = ( 7.787 * z ) + ( 16/116 ); }			
		
		return new Lab(( 116 * y ) - 16, 500 * ( x - y ), 200 * ( y - z ));
	}
	
	public function setColor(color:Int):XYZ{
		return fromRGB(new RGB(color >> 16 & 0xFF, color >> 8 & 0xFF, color & 0xFF));
	}
	
	public function new(?x:Float=0, ?y:Float=0, ?z:Float=0):Void {
		numOfChannels = 3;
		data = [];
		this.x=x;
		this.y=y;
		this.z=z;
	}
	
	public function clone() { return new XYZ(x, y, z); }
	
	public function interpolate(target:Color, ratio:Float = 0.5):XYZ {
		var target:XYZ = Std.is(target,XYZ) ? cast target : new XYZ().fromRGB(target.toRGB());
		return new XYZ
			(
				x+ (target.x - x) * ratio, 
				y + (target.y - y) * ratio, 
				z + (target.z - z) * ratio
			);
	}

	private var data:Array<Float>;	
}
