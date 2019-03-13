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

import hxColorToolkit.spaces.Color;

class ColorWheelScheme<C:Color> implements ColorScheme<C> {
	public function clone():ColorWheelScheme<C> {
		return throw "need to be overrided";
	}

	public var numOfColors(default,null):Int;
	
	public function getColor(index:Int):C {
		return _colors[index];
	}
	
	public function iterator():Iterator<C> {
		return _colors.iterator();
	}

	public var primaryColor(get_primaryColor,set_primaryColor):C;

	private var _primaryColor:C;
	private function get_primaryColor():C {
		return _primaryColor;
	}
	private function set_primaryColor(val:C):C {
		_primaryColor = val;
		generate();
		return primaryColor;
	}
	
	private function new(primaryColor:C) {
		_colors = [];
		_primaryColor = primaryColor;
		numOfColors = 1;
	}

	private var _colors:Array<C>;
	private var _class:Class<C>;
	
	private function generate():Void {
		throw 'Method must be called by child class';
	}
	
	inline private function wrap(x : Float, min : Float,threshold : Float, plus : Float) : Float {
		return ( x - min < threshold) ? x + plus : x - min;
	}

	private function mutateFromPrimary(newColor:Color):C {
		if (Std.is(newColor,_class)) {
			return cast newColor.clone();
		} else {
			return cast primaryColor.clone().fromRGB(newColor.toRGB());
		}
	}

}
