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
//@see http://en.wikipedia.org/wiki/Lab_color_space

package hxColorToolkit.spaces;

class Lab implements Color {

public var numOfChannels(default,null):Int;

	public function getValue(channel:Int):Float {
		return data[channel];
	}
	public function setValue(channel:Int,val:Float):Float {
		data[channel] = Math.min(maxValue(channel), Math.max(val, minValue(channel)));
		return val;
	}

	inline public function minValue(channel:Int):Float {
		return channel == 0 ? 0 : -128;
	}
	inline public function maxValue(channel:Int):Float {
		return channel == 0 ? 100 : 127;
	}

	public var lightness(get_lightness, set_lightness) : Float;
	public var a(get_a, set_a) : Float;
	public var b(get_b, set_b) : Float;
	
	public function toRGB():RGB {
		return toXYZ().toRGB();
	}

	public function toXYZ():XYZ {
		var y:Float = (lightness + 16) / 116;
		var x:Float = a * 0.002 + y;
		var z:Float = y - b * 0.005;
		 
		if ( Math.pow( y , 3 ) > 0.008856 ) { y = Math.pow( y , 3 ); }
		else { y = ( y - 16 / 116 ) / 7.787; }
		if ( Math.pow( x , 3 ) > 0.008856 ) { x = Math.pow( x , 3 ); }
		else { x = ( x - 16 / 116 ) / 7.787; }
		if ( Math.pow( z , 3 ) > 0.008856 ) { z = Math.pow( z , 3 ); }
		else { z = ( z - 16 / 116 ) / 7.787; }

		return new XYZ(95.047 * x, 100.000 * y, 108.883 * z); // Observer= 2°, Illuminant= D65
	}
	
	public function getColor():Int{
		return toXYZ().getColor();
	}
	
	public function fromRGB(rgb:RGB):Lab {
		data = new XYZ().fromRGB(rgb).toLab().data;
		return this;
	}
	
	public function setColor(value:Int):Lab{
		data = new XYZ().setColor(value).toLab().data;
		return this;
	}
	
	private function get_lightness():Float{
		return getValue(0);
	}
	
	private function set_lightness(value:Float):Float{
		return setValue(0,value);
	}

	private function get_a():Float{
		return getValue(1);
	}

	private function set_a(value:Float):Float{
		return setValue(1,value);
	}
	
	private function get_b():Float{
		return getValue(2);
	}
	
	private function set_b(value:Float):Float{
		return setValue(2,value);
	}

	public function new(?lightness:Float=0, ?a:Float=0, ?b:Float=0)
	{
		numOfChannels = 3;
		data = [];
		this.lightness=lightness;
		this.a=a;
		this.b=b;
	}
	
	public function clone() { return new Lab(lightness, a, b); }
	
	public function interpolate(target:Color, ratio:Float = 0.5):Lab {
		var target:Lab = Std.is(target,Lab) ? cast target : new Lab().fromRGB(target.toRGB());
		return new Lab
			(
				lightness + (target.lightness - lightness) * ratio, 
				a + (target.a - a) * ratio, 
				b + (target.b - b) * ratio
			);
	}

	private var data:Array<Float>;

}
