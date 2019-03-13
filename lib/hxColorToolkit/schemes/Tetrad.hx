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

class Tetrad<C:Color> extends ColorWheelScheme<C> {

	override public function clone():Tetrad<C> {
		return new Tetrad<C>(primaryColor,angle,alt);
	}
	
	public var angle(get_angle, set_angle) : Float;
	private var _angle:Float;
	private function get_angle():Float{
		return _angle;
	}
	private function set_angle(value:Float):Float{
		_angle=value;
		generate();	
		return value;
	}
	
	public var alt(get_alt,set_alt):Bool;
	private var _alt:Bool;
	private function get_alt():Bool {
		return _alt;
	}
	private function set_alt(val:Bool):Bool {
		_alt = val;
		generate();
		return alt;
	}
	
	public function new(primaryColor:C, ?angle:Float = 90, ?alt:Bool = false)
	{
		super(primaryColor);
		_angle = angle;
		_alt = alt;
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
		var _primary = _primaryColor.getColor();
		
		var c1:HSB = new HSB().setColor(ColorToolkit.rybRotate(_primary, _angle));
		var multiplier;
		if(!alt)
		{
			if(_primaryHSB.brightness < 50) {
			c1.brightness+=20;
			} else {
				c1.brightness-=20;
			}
		} else {
			multiplier = (50-_primaryHSB.brightness)/50;
			c1.brightness=c1.brightness+Math.min(20, Math.max(-20,20*multiplier));
		}
						   
		_colors.push(mutateFromPrimary(c1));
		
		var c2:HSB = new HSB().setColor(ColorToolkit.rybRotate(_primary, _angle * 2));
		if(!alt)
		{
			if(_primaryHSB.brightness > 50) {
			c2.brightness+=10;
			} else {
				c2.brightness-=10;
			}
		} else {
			multiplier = (50-_primaryHSB.brightness)/50;
			c2.brightness=c2.brightness+Math.min(10, Math.max(-10,10*multiplier));
		}
		
		_colors.push(mutateFromPrimary(c2));
		
		var c3:HSB = new HSB().setColor(ColorToolkit.rybRotate(_primary, _angle * 3));
		c3.brightness+=10;
		_colors.push(mutateFromPrimary(c3));

		numOfColors = _colors.length;
	}

}
