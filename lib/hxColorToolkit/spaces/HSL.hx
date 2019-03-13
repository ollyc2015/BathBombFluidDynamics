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

class HSL implements Color {

	public var numOfChannels(default,null):Int;

	public function getValue(channel:Int):Float {
		return data[channel];
	}
	public function setValue(channel:Int, val:Float):Float {
		data[channel] = 
			if (channel == 0) {
				loop(val, 360);
			} else {
				Math.min(maxValue(channel), Math.max(val, minValue(channel)));
			}
		
		return val;
	}

	inline public function minValue(channel:Int):Float {
		return 0;
	}
	inline public function maxValue(channel:Int):Float {
		return channel == 0 ? 360 : 100;
	}
	
	/**
	 * Hue color value
	 * @return Number (between 0 and 360)
	 */	
	public var hue(get_hue, set_hue) : Float;
	
	/**
	 * Saturation color value
	 * @return Number (between 0 and 100)
	 */		
	public var saturation(get_saturation, set_saturation) : Float;

	/**
	 * Black color value
	 * @return Number (between 0 and 100)
	 */	
	public var lightness(get_lightness, set_lightness) : Float;
	
	
	private function get_hue():Float{
		return getValue(0);
	}

	private function set_hue(val:Float):Float{
		data[0] = loop(val, 360);
		return val;
	}
	
	private function get_saturation():Float{
		return getValue(1);
	}
	
	private function set_saturation(val:Float):Float{
		data[1] = Math.min(100, Math.max(val, 0));
		return val;
	}
	
	private function get_lightness():Float{
		return getValue(2);
	}
	
	private function set_lightness(val:Float):Float{
		data[2] = Math.min(100, Math.max(val, 0));
		return val;
	}
	
	public function toRGB():RGB {
		var hue = hue/360; 
		var saturation = saturation*0.01;
		var lightness = lightness*0.01;
		
		var r:Float, g:Float, b:Float;

	    if(saturation == 0){
	        r = g = b = lightness; // achromatic
	    }else{
	        var q = lightness < 0.5 ? lightness * (1 + saturation) : lightness + saturation - lightness * saturation;
	        var p = 2 * lightness - q;
	        r = hue2rgb(p, q, hue + 1/3);
	        g = hue2rgb(p, q, hue);
	        b = hue2rgb(p, q, hue - 1/3);
	    }
		
		return new RGB(r * 255, g * 255, b * 255);
	}
	
	/**
	 * Hexidecimal RGB translation of HSB color
	 * @return Hexidecimal color value
	 * 
	 */	
	public function getColor():Int{
		return toRGB().getColor();
	}
	
	public function fromRGB(rgb:RGB):HSL {
		var r = rgb.red;
		var g = rgb.green;
		var b = rgb.blue;
		
		r /= 255;
		g /= 255;
		b /= 255;
		var max:Float = Math.max(r, Math.max(g, b));
		var min:Float = Math.min(r, Math.min(g, b));
		var h:Float, s:Float, l:Float;
		
		h=s=l=(max+min)/2;

	    if(max == min){
	        h = s = 0; 
	    }else{
	        var d:Float = max - min;
	        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
	        h = if (max == r)
				(g - b) / d + (g < b ? 6 : 0);
			else if (max == g)
				(b - r) / d + 2;
			else //if (maxe == b)
				(r - g) / d + 4;
	        h /= 6;
	    }			
		
		this.hue = Math.round(h*360);
		this.saturation = Math.round(s*100);
		this.lightness = Math.round(l*100);
		return this;
	}
	
	/**
	 * Hexidecimal RGB translation of HSB color
	 * @param value Hexidecimal color value
	 * 
	 */		
	public function setColor(color:Int):HSL{
		return fromRGB(new RGB(color >> 16 & 0xFF, color >> 8 & 0xFF, color & 0xFF));
	}
	
	/**
	 * 
	 * @param hue (between 0 and 360)
	 * @param saturation (between 0 and 100)
	 * @param black (between 0 and 100)
	 * 
	 */		
	public function new(?hue:Float=0, ?saturation:Float=0, ?lightness:Float=0)
	{
		numOfChannels = 3;
		data = [];
		this.hue = hue;
		this.saturation = saturation;
		this.lightness = lightness;
	}
	
	public function clone() { return new HSL(hue, saturation, lightness); }
	
	public function interpolate(target:Color, ratio:Float = 0.5):HSL {
		var target:HSL = Std.is(target,HSL) ? cast target : new HSL().fromRGB(target.toRGB());
		return new HSL
			(
				hue + (target.hue - hue) * ratio, 
				saturation + (target.saturation - saturation) * ratio, 
				lightness + (target.lightness - lightness) * ratio
			);
	}

	private var data:Array<Float>;

	private function hue2rgb(p:Float, q:Float, t:Float):Float {
        if(t < 0) t += 1;
        if(t > 1) t -= 1;
        if(t < 1/6) return p + (q - p) * 6 * t;
        if(t < 1/2) return q;
        if(t < 2/3) return p + (q - p) * (2/3 - t) * 6;
       
        return p;
    }
	
	static function loop(index:Float, length:Float):Float {
		if (index < 0)
			index = length + index % length;
		
		if (index >= length)
			index %= length;
		
		return index;
	}
}
