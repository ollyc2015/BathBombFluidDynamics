#TODO
- WebGL fail fallback
- Need for minification

#LESS IMPORTANT TODOs
- iPhone 6S WebGL has a bug when UNSIGNED_BYTE textures are used in fluid sim
	-> result is continuous negative fluid velocity
	-> solution is to use float textures (only half float supported?)
	-> alternatively, if outer particles are not visible, this bug is less important
	(Not an issue on iPad Mini or iPad 2)
- Use float texture for rgb if system supports it
	-> great GPUCapabilties class
- Replace window.width with getWidth()
	- and fix window width bug
- Improve dye fall-off
- Remove keyboard shortcuts
- Integrate into master?
- Improve particle appearance
- Remove debug code
- Force render fluid and particle as static inlines bools


#NOTES
- Particle colors,
	* fluid texture lookup?
		- gets hue from fluid, alpha from grey/level?
	-> color filter from increasing fluid saturation?

- Background transparency - possible, tricky to get the color fadeout right. Easier to do the tv glow effect with shader