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

import hxColorToolkit.spaces.HSB;
import hxColorToolkit.spaces.Color;

class Monochrome<C:Color> extends ColorWheelScheme<C> {

	override public function clone():Monochrome<C> {
		return new Monochrome<C>(primaryColor);
	}
	
	public function new(primaryColor:C)
	{
		super(primaryColor);
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
		
		var c1:HSB = _primaryHSB.clone();
		c1.brightness=wrap(_primaryHSB.brightness, 50, 20, 30);
		c1.saturation=wrap(_primaryHSB.saturation, 30, 10, 20);
		_colors.push(mutateFromPrimary(c1));
		
		var c2:HSB = _primaryHSB.clone();
		c2.brightness=wrap(_primaryHSB.brightness, 20, 20, 60);
		_colors.push(mutateFromPrimary(c2));

		var c3:HSB = _primaryHSB.clone();
		c3.brightness=Math.max(20, _primaryHSB.brightness + (100 - _primaryHSB.brightness ) * 0.2);
		c3.saturation=wrap(_primaryHSB.saturation, 30, 10, 30);
		_colors.push(mutateFromPrimary(c3));

		var c4:HSB = _primaryHSB.clone();
		c4.brightness=wrap(_primaryHSB.brightness, 50, 20, 30);
		_colors.push(mutateFromPrimary(c4));

		numOfColors = _colors.length;
	}

}
