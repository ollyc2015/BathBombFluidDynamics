/*
Author: Andy Li (andy@onthewings.net)
Based on colortoolkit (http://code.google.com/p/colortoolkit/)
*/
 
package hxColorToolkit.spaces;

class Hex implements Color {
	
	public var numOfChannels(default,null):Int;

	inline public function getValue(channel:Int):Float {
		return data;
	}
	inline public function setValue(channel:Int,val:Float):Float {
		data = Math.round(Math.min(maxValue(channel), Math.max(val, minValue(channel))));
		return val;
	}

	inline public function minValue(channel:Int):Float {
		return 0;
	}
	inline public function maxValue(channel:Int):Float {
		return 0xFFFFFFFF;
	}
	
	inline public function toRGB():RGB {
		return new RGB(red, green, blue);
	}
	
	inline public function toARGB():ARGB {
		return new ARGB(alpha, red, green, blue);
	}
	
	inline public function getColor():Int {
		return data;
	}
	
	public function fromRGB(rgb:RGB):Hex {
		data = rgb.getColor();
		return this;
	}

	inline public function setColor(color:Int):Hex {
		data = color;
		return this;
	}

	public var alpha(get_alpha,set_alpha):Int;
	public var red(get_red,set_red):Int;
	public var green(get_green,set_green):Int;
	public var blue(get_blue,set_blue):Int;

	inline private function get_alpha():Int {
		return data >> 24 & 0xFF;
	}

	inline private function get_red():Int {
		return data >> 16 & 0xFF;
	}

	inline private function get_green():Int {
		return data >> 8 & 0xFF;
	}

	inline private function get_blue():Int {
		return data & 0xFF;
	}

	private function set_alpha(v:Int):Int {
		data = 
			if (v <= 0) 
				data & 0x00FFFFFF;
			else if (v >= 255) 
				data | 0xFF000000;
			else 
				(data & 0x00FFFFFF) | (v << 24);
		return v;
	}

	private function set_red(v:Int):Int {
		data = 
			if (v <= 0) 
				data & 0xFF00FFFF;
			else if (v >= 255) 
				data | 0x00FF0000;
			else 
				(data & 0xFF00FFFF) | (v << 16);
		return v;
	}

	private function set_green(v:Int):Int {
		data = 
			if (v <= 0)
				data & 0xFFFF00FF;
			else if (v >= 255)
				data | 0x0000FF00;
			else
				(data & 0xFFFF00FF) | (v << 8);
		return v;
	}

	private function set_blue(v:Int):Int {
		data = 
			if (v <= 0)
				data & 0xFFFFFF00;
			else if (v >= 255)
				data | 0x000000FF;
			else
				(data & 0xFFFFFF00) | v;
		return v;
	}
	
	public function new(?color:Int = 0):Void {
		numOfChannels = 1;
		setColor(color);
	}
	
	public function clone() { return new Hex(data); }
	
	public function interpolate(target:Color, ratio:Float = 0.5):Hex {
		var target:Hex = Std.is(target,Hex) ? cast target : new Hex(target.getColor());
		return new Hex(toRGB().interpolate(target.toRGB(), ratio).getColor());
	}

	private var data:Int;
}
