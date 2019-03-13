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

class Gray implements Color {
	
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
	 * Single gray channel value (not the hexidecimal color)
	 * @return Number (between 0 and 255)
	 * 
	 */	
	public var gray(get_gray, set_gray) : Float;
	
	private function get_gray():Float{ 
		return getValue(0);
	}
	
	private function set_gray(value:Float):Float{
		return setValue(0,value);
	}
	
	public function toRGB():RGB {
		return new RGB(gray, gray, gray);
	}
	
	/**
	 * Grayscale color value
	 * @return Hexidecimal grayscale color
	 * 
	 */	
	public function getColor():Int {
		return toRGB().getColor();
	}
	
	public function fromRGB(rgb:RGB):Gray {
		this.gray = 0.3 * rgb.red + 0.59 * rgb.green + 0.11 * rgb.blue;
		return this;
	}

	public function setColor(color:Int):Gray {
		return fromRGB(new RGB(color >> 16 & 0xFF, color >> 8 & 0xFF, color & 0xFF));
	}
	
	/**
	 * Single gray channel value (not the hexidecimal color)
	 * @param value Number between 0 and 255);
	 * 
	 */	
	public function new(?gray:Float=0):Void {
		numOfChannels = 1;
		data = [];
		this.gray=gray;
	}
	
	public function clone() { return new Gray(gray); }
	
	public function interpolate(target:Color, ratio:Float = 0.5):Gray {
		var target:Gray = Std.is(target,Gray) ? cast target : new Gray().fromRGB(target.toRGB());
		return new Gray
			(
				gray + (target.gray - gray) * ratio
			);
	}

	private var data:Array<Float>;
}
