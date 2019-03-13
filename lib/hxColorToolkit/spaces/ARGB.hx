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

class ARGB extends RGB {
	/**
	 * Alpha color channel
	 * @return Number (between 0 and 255)
	 */	
	public var alpha(get_alpha, set_alpha) : Float;

	private function get_alpha():Float{
		return getValue(0);
	}

	private function set_alpha(value:Float):Float{
		return setValue(0,value);
	}

	override private function get_red():Float{
		return getValue(1);
	}

	override private function set_red(value:Float):Float{
		return setValue(1,value);
	}
	
	override private function get_green():Float{
		return getValue(2);
	}
	
	override private function set_green(value:Float):Float{
		return setValue(2,value);
	}
	
	override private function get_blue():Float{
		return getValue(3);
	}
	
	override private function set_blue(value:Float):Float{
		return setValue(3,value);
	}
	
	override public function toRGB():RGB {
		return new RGB(red, green, blue);
	}
	
	inline public function toARGB():ARGB {
		return clone();
	}
	
	/**
	 * Hexidecimal RGB translation of color
	 * @return Hexidecimal color value
	 * 
	 */
	override public function getColor():Int{
		return (Math.round(alpha) << 24) | (Math.round(red) << 16) | (Math.round(green) << 8) | Math.round(blue);
	}
	
	override public function fromRGB(rgb:RGB):ARGB {
		this.alpha = 0xFF;
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
	override public function setColor(color:Int):ARGB{
		this.alpha = color >> 24 & 0xFF;
		this.red = color >> 16 & 0xFF;
		this.green = color >> 8 & 0xFF;
		this.blue = color & 0xFF;
		return this;
	}
	
	/**
	 * 
	 * @param a Number (between 0 and 255)
	 * @param r Number (between 0 and 255)
	 * @param g Number (between 0 and 255)
	 * @param b Number (between 0 and 255)
	 * 
	 */		
	public function new(?a:Float=0xFF, ?r:Float=0, ?g:Float=0, ?b:Float=0)
	{
		super(r, g, b);
		numOfChannels = 4;
		this.alpha = a;
	}
	
	override public function clone() { return new ARGB(alpha, red, green, blue); }
	
	override public function interpolate(target:Color, ratio:Float = 0.5):RGB {
		var target:ARGB = Std.is(target,ARGB) ? cast target : new ARGB().fromRGB(target.toRGB());
		return new ARGB
			(
				alpha + (target.alpha - alpha) * ratio, 
				red + (target.red - red) * ratio, 
				green + (target.green - green) * ratio, 
				blue + (target.blue - blue) * ratio
			);
	}
}
