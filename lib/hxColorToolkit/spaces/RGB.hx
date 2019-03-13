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

package hxColorToolkit.spaces;

class RGB implements Color {

	public var numOfChannels(default,null):Int;

	public function getValue(channel:Int):Float {
		return data[channel];
	}
	public function setValue(channel:Int,val:Float):Float {
		data[channel] = Math.min(maxValue(channel), Math.max(val, minValue(channel)));
		return val;
	}

	inline public function minValue(channel:Int):Float {
		return 0;
	}
	inline public function maxValue(channel:Int):Float {
		return 255;
	}

	/**
	 * Red color channel
	 * @return Number (between 0 and 255)
	 */	
	public var red(get_red, set_red) : Float;
	
	/**
	 * Green color channel
	 * @return Number (between 0 and 255)
	 */	
	public var green(get_green, set_green) : Float;

	/**
	 * Blue color channel
	 * @return Number (between 0 and 255)
	 */	
	public var blue(get_blue, set_blue) : Float;

	private function get_red():Float{
		return getValue(0);
	}

	private function set_red(value:Float):Float{
		return setValue(0,value);
	}
	
	private function get_green():Float{
		return getValue(1);
	}
	
	private function set_green(value:Float):Float{
		return setValue(1,value);
	}
	
	private function get_blue():Float{
		return getValue(2);
	}
	
	private function set_blue(value:Float):Float{
		return setValue(2,value);
	}
	
	public function toRGB():RGB {
		return clone();
	}
	
	/**
	 * Hexidecimal RGB translation of color
	 * @return Hexidecimal color value
	 * 
	 */
	public function getColor():Int{
		return (Math.round(red) << 16) | (Math.round(green) << 8) | Math.round(blue);
	}
	
	public function fromRGB(rgb:RGB):RGB {
		this.red = rgb.red;
		this.green = rgb.green;
		this.blue = rgb.blue;
		return this;
	}
	
	/**
	 * Hexidecimal RGB translation of color
	 * @param value Hexidecimal color value
	 * 
	 */	
	public function setColor(color:Int):RGB{
		this.red = color >> 16 & 0xFF;
		this.green = color >> 8 & 0xFF;
		this.blue = color & 0xFF;
		return this;
	}
	
	/**
	 * 
	 * @param r Number (between 0 and 255)
	 * @param g Number (between 0 and 255)
	 * @param b Number (between 0 and 255)
	 * 
	 */		
	public function new(?r:Float=0, ?g:Float=0, ?b:Float=0)
	{
		numOfChannels = 3;
		data = [];
		this.red = r;
		this.green = g;
		this.blue = b;
	}
	
	public function clone() { return new RGB(red, green, blue); }
	
	public function interpolate(target:Color, ratio:Float = 0.5):RGB {
		var target:RGB = Std.is(target,RGB) ? cast target : new RGB().fromRGB(target.toRGB());
		return new RGB
			(
				red + (target.red - red) * ratio, 
				green + (target.green - green) * ratio, 
				blue + (target.blue - blue) * ratio
			);
	}

	private var data:Array<Float>;
}
