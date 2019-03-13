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

package hxColorToolkit.schemes;

import hxColorToolkit.ColorToolkit;
import hxColorToolkit.spaces.HSB;

class Analogous<C:hxColorToolkit.spaces.Color> extends ColorWheelScheme<C> {

	override public function clone():Analogous<C> {
		return new Analogous<C>(primaryColor, angle, contrast);
	}

	public var angle(get_angle,set_angle): Float;	
	public var contrast(get_contrast,set_contrast): Float;

	private var _angle:Float;
	private function get_angle():Float {
		return _angle;
	}
	private function set_angle(val:Float):Float {
		_angle = val;
		generate();
		return angle;
	}

	private var _contrast:Float;
	private function get_contrast():Float {
		return _contrast;
	}
	private function set_contrast(val:Float):Float {
		_contrast = val;
		generate();
		return _contrast;
	}
	
	public function new(primaryColor:C, ?angle:Float=10, ?contrast:Float=25)
	{
		super(primaryColor);
		_angle=angle;
		_contrast=contrast;
		generate();
	}
	
	override function generate():Void
	{
		_colors = [primaryColor];
		var _primaryHSB:HSB;
		if (Std.is(primaryColor,HSB)){
			_primaryHSB = untyped primaryColor;
		} else {
			_primaryHSB = new HSB().fromRGB(primaryColor.toRGB());
		}
		var newHSB:HSB = new HSB();
		var array: Array<Array<Float>> = [[1.0, 2.2], [2.0, 1.0], [-1.0, -0.5], [-2.0, 1.0]];
		for (i in 0...array.length) {
			var one = array[i][0];
			var two = array[i][1];
			
			newHSB.setColor(ColorToolkit.rybRotate(_primaryHSB.getColor(), angle * one));
			var t: Float = 0.44 - two * 0.1;
			if(_primaryHSB.brightness - contrast * two < t) {
				newHSB.brightness=t * 100;
			} else {
				newHSB.brightness=_primaryHSB.brightness - contrast * two;
			}
			newHSB.saturation= newHSB.saturation - 5;
			_colors.push(mutateFromPrimary(newHSB));
		}
		numOfColors = _colors.length;
	}
}
