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
import hxColorToolkit.spaces.Color;

class Complementary<C:Color> extends ColorWheelScheme<C> {

	override public function clone():Complementary<C> {
		return new Complementary<C>(primaryColor);
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
		
		var contrasting: HSB = _primaryHSB.clone();
		
		if(_primaryHSB.brightness > 40) {
			contrasting.brightness=10 + _primaryHSB.brightness * 0.25;
		} else {
			contrasting.brightness=100 - _primaryHSB.brightness * 0.25;
		}
		_colors.push(mutateFromPrimary(contrasting));
		
		var supporting: HSB = _primaryHSB.clone();
		
		supporting.brightness=30 + _primaryHSB.brightness;
		supporting.saturation=10 + _primaryHSB.saturation * 0.3;
		_colors.push(mutateFromPrimary(supporting));
		
		//complement
		var complement:HSB = new HSB().setColor(ColorToolkit.rybRotate(_primaryColor.getColor(), 180));
		_colors.push(mutateFromPrimary(complement));
		
		var contrastingComplement:HSB = complement.clone();
				
		if(complement.brightness > 30) {
			contrastingComplement.brightness=10 + complement.brightness * 0.25;
		} else {
			contrastingComplement.brightness=100 - complement.brightness * 0.25;
		}
		_colors.push(mutateFromPrimary(contrastingComplement));
		
		var supportingComplement:HSB = complement.clone();
		
		supportingComplement.brightness=30 + complement.brightness;
		supportingComplement.saturation=10 + complement.saturation * 0.3;
		_colors.push(mutateFromPrimary(supportingComplement));
		
		numOfColors = _colors.length;
	}

}
