package;

import haxe.Timer;
import js.Browser.*;

//import haxe.ui.toolkit.core.PopupManager;
import js.html.webgl.RenderingContext;

import shaderblox.uniforms.UTexture;
import snow.modules.opengl.GL;
import snow.Snow;
import snow.types.Types;
import snow.system.window.Window;

import gltoolbox.render.RenderTarget;
import shaderblox.ShaderBase;
import shaderblox.uniforms.UVec2.Vector2;
import shaderblox.uniforms.UVec3.Vector3;
import shaderblox.uniforms.UVec4.Vector4;

import hxColorToolkit.spaces.HSB;
import snow.types.Types.WindowEvent;
import snow.types.Types.WindowEventType;
using hxColorToolkit.ColorToolkit;

typedef TShader = {	
	function activate(_:Bool, _:Bool):Void;
	function deactivate():Void;
}


class Main extends snow.App {
	var gl = GL;
	//Simulations
	var fluid:GPUFluid;
	var particles:GPUParticles;
	//Geometry
	var textureQuad:GLBuffer = null; 
	//Framebuffers
	var screenBuffer:GLFramebuffer = null;	//null for all platforms excluding ios, where it references the defaultFramebuffer (UIStageView.mm)
	//Shaders
	var blitTextureShader:BlitTexture;
	var debugBlitTextureShader:DebugBlitTexture;
	var renderFluidShader:FluidRender;
	var renderParticlesShader:ColorParticleMotion;
	var updateDyeShader:MouseDye;
	var mouseForceShader:MouseForce;
	//Window
	static inline var MOUSE_ALWAYS_DOWN:Bool = false;
	
	var HAS_RUN = false;
	var TWILIGHT = false; 
	var SEX_BOMB = false; 
	var BIG_BLUE = false; 
	var THINK_PINK = false; 
	var AVOBATH = false; 
	var CHEER_UP_BUTTERCUP = false; 
	var SECRET_ARTS = false; 
	var BIG_SLEEP = false; 
	var THE_EXPERIMENTOR = false; 
	var INTERGALACTIC = false;
	
	var isMouseDown:Bool = MOUSE_ALWAYS_DOWN;
	//var isMouseDown:Bool = false;
	var mousePointKnown:Bool = false;
	var lastMousePointKnown:Bool = false;
	var mouse = new Vector2();
	var mouseFluid = new Vector2();
	var lastMouse = new Vector2();
	var lastMouseFluid = new Vector2();
	var initTime:Float;
	var time:Float;
	var lastTime:Float;
	//Drawing Settings
	var renderParticlesEnabled:Bool = true;
	var renderFluidEnabled:Bool = true;
	var hueCycleEnabled:Bool = MOUSE_ALWAYS_DOWN;
	var dyeColorHSB = new HSB(180, 100, 100);
	var dyeColor = new Vector3();
	var pointSize = 1;
	//
	var performanceMonitor:PerformanceMonitor;
	//Parameters
	var particleCount:Int;
	var fluidScale:Float;
	var fluidIterations(default, set):Int;
	var offScreenScale:Float;
	var offScreenFilter:Int;
	var simulationQuality(default, set):SimulationQuality;
	//My vars
	var timer = new haxe.Timer(19000); // 12000ms (12 second) delay before bath bomb shape disappears
	

	var window:Window;
	
	public function new () {
		super();

		performanceMonitor = new PerformanceMonitor(35, null, 800);

		simulationQuality = Medium;

		#if desktop
		simulationQuality = High;
		#elseif ios
		simulationQuality = Low;
		#end

		#if js
		performanceMonitor.fpsTooLowCallback = lowerQualityRequired; //auto adjust quality

		//extract quality parameter, ?q= and set simulation quality
		var urlParams = js.Web.getParams();
		if(urlParams.exists('q')){
			var q = StringTools.trim(urlParams.get('q').toLowerCase());
			//match enum
			for(e in Type.allEnums(SimulationQuality)){
				var name = Type.enumConstructor(e).toLowerCase();
				if(q == name){
					simulationQuality = e;
					performanceMonitor.fpsTooLowCallback = null; //disable auto quality adjusting
					break;
				}
			}
		}
		//extract iterations
		if(urlParams.exists('iterations')){
			var iterationsParam = Std.parseInt(urlParams.get('iterations'));
			if(Std.is(iterationsParam, Int))
				fluidIterations = iterationsParam;
		}
		#end
		
		
	
	}

	override function config( config:AppConfig ) : AppConfig {
		config.web.no_context_menu = false;
		config.web.prevent_default_mouse_wheel = false;
		config.window.borderless = true;
		config.window.fullscreen = true;
		config.window.title = "Bath Bomb Mania!";

		//for some reason, window width and height are set initially from config and ignores true size
		//(in the case of web)
		#if js
		config.window.width = js.Browser.window.innerWidth;
		config.window.height = js.Browser.window.innerHeight;
		#end

		config.render.antialiasing = 0;

	    return config;
	}

	override function ready(){
		this.window = app.window;

		init();
		//Handle clicks made when selecting a bath bomb/ render different colours depending on bath bomb chosen
		bathBombSelection();
		this.window.onevent = onWindowEvent;
		this.window.onrender = render;
	}

	function init():Void {
		#if debug
		GPUCapabilities.report();
		#end

		gl.disable(gl.DEPTH_TEST);
		gl.disable(gl.CULL_FACE);
		gl.disable(gl.DITHER);

        #if ios
        screenBuffer = GL.getParameter(GL.FRAMEBUFFER_BINDING);
        #end

		textureQuad = gltoolbox.GeometryTools.createQuad(0, 0, 1, 1);

		//create shaders
		blitTextureShader = new BlitTexture();
		debugBlitTextureShader = new DebugBlitTexture();
		renderFluidShader = new FluidRender();
		renderParticlesShader = new ColorParticleMotion();
		updateDyeShader = new MouseDye();
		mouseForceShader = new MouseForce();

		//set uniform objects
		updateDyeShader.mouse.data = mouseFluid;
		updateDyeShader.lastMouse.data = lastMouseFluid;
		updateDyeShader.dyeColor.data = dyeColor;
		mouseForceShader.mouse.data = mouseFluid;
		mouseForceShader.lastMouse.data = lastMouseFluid;

		updatePointSize();

		var cellScale = 32;
		fluid = new GPUFluid(Math.round(window.width*fluidScale), Math.round(window.height*fluidScale), cellScale, fluidIterations);
		fluid.updateDyeShader = updateDyeShader;
		fluid.applyForcesShader = mouseForceShader;

		particles = new GPUParticles(particleCount);
		//scale from fluid's velocity field to clipSpace, which the particle velocity uses
		particles.flowScaleX = 1/(fluid.cellSize * fluid.aspectRatio);
		particles.flowScaleY = 1/fluid.cellSize;
		particles.flowIsFloat = fluid.floatVelocity;
		particles.dragCoefficient = 1;
		renderParticlesShader.FLOAT_DATA = particles.floatData ? "true" : "false";

		//setup internal data
		dyeColor.set(51, 78, 255);

		initTime = haxe.Timer.stamp();
		lastTime = initTime;
		
		//dat.GUI
		//create controls
		haxe.macro.Compiler.includeFile("dat.gui.min.js");
		
		var gui = new dat.GUI({autoPlace: true});
		//particle count
		var particleCountGUI = gui.add(particles, 'count').name('Particle Count').listen();
		particleCountGUI.__li.className = particleCountGUI.__li.className+' disabled';
		untyped particleCountGUI.__input.disabled = true;//	disable editing
		//quality
		gui.add(this, 'simulationQuality', Type.allEnums(SimulationQuality)).onChange(function(v){
			js.Browser.window.location.href = StringTools.replace(js.Browser.window.location.href, js.Browser.window.location.search, '') + '?q=' + v;//remove query string
		}).name('Quality');//.listen();
		//fluid iterations
		gui.add(this, 'fluidIterations', 1, 50).name('Solver Iterations').onChange(function(v) fluidIterations = v);
		//rest particles
		gui.add({f:particles.reset}, 'f').name('Reset Particles');
		//stop fluid
		gui.add({f:fluid.clear}, 'f').name('Stop Fluid');
					
			
	}

	override function update( dt:Float ){
		time = haxe.Timer.stamp() - initTime;
		performanceMonitor.recordFrameTime(dt);
		//Smaller number creates a bigger ripple, was 0.016
		dt = 0.090;//@!
		//Physics
		//interaction
		updateDyeShader.isMouseDown.set(isMouseDown && lastMousePointKnown);
		mouseForceShader.isMouseDown.set(isMouseDown && lastMousePointKnown);

		//step physics
		fluid.step(dt);


		particles.flowVelocityField = fluid.velocityRenderTarget.readFromTexture;

		if(renderParticlesEnabled){
			particles.step(dt);
		}

		//update dye color
		//cycle hue
		if(hueCycleEnabled) 
			dyeColorHSB.hue += 1.2;
		if(isMouseDown && !TWILIGHT && !SEX_BOMB && !BIG_BLUE && !THINK_PINK && !AVOBATH && !CHEER_UP_BUTTERCUP && !SECRET_ARTS && !BIG_SLEEP && !THE_EXPERIMENTOR && !INTERGALACTIC){
			//cycle further by mouse velocity
			if (hueCycleEnabled){
				
				var vx = (mouse.x - lastMouse.x)/(dt*window.width);
				var vy = (mouse.y - lastMouse.y)/(dt*window.height);
				dyeColorHSB.hue += Math.sqrt(vx * vx + vy * vy) * 0.5;
				 
			}
			var rgb = dyeColorHSB.toRGB();
			dyeColor.set(rgb.red / 255, rgb.green / 255, rgb.blue / 255 );
			
		}else if (isMouseDown && TWILIGHT == true){
			 
			if (!HAS_RUN){
			
			var x_location = windowToClipSpaceX(mouse.x);
			var y_location = windowToClipSpaceY(mouse.y);
			
			var mouse_x = (x_location + 1) / 2 * fluid.width - 25;
			var mouse_y = (y_location + 1) / 2 * fluid.height - 25;
				
			var image:js.html.ImageElement = cast document.querySelector('img[src="images/twilight_dye.png"]');
			if(image !=null){
			gl.bindTexture(gl.TEXTURE_2D, fluid.dyeRenderTarget.readFromTexture);
			gl.current_context.texSubImage2D(gl.TEXTURE_2D, 0,  Math.round(mouse_x), Math.round(mouse_y), RenderingContext.RGB, RenderingContext.UNSIGNED_BYTE, image);
			
			}
			
			HAS_RUN = true;
			}
			
			var vx = (mouse.x - lastMouse.x)/(dt*window.width);
			var vy = (mouse.y - lastMouse.y)/(dt*window.height);
			dyeColorHSB.hue += Math.sqrt(vx*vx + vy*vy)*0.5;

			var rgb = dyeColorHSB.toRGB();
			dyeColor.set(232 / 255, 165 / 255, 207 / 255);
			
		}else if (isMouseDown && SEX_BOMB == true){
			
			if (!HAS_RUN){
			
			var x_location = windowToClipSpaceX(mouse.x);
			var y_location = windowToClipSpaceY(mouse.y);
			
			var mouse_x = (x_location + 1) / 2 * fluid.width - 25;
			var mouse_y = (y_location + 1) / 2 * fluid.height - 25;
				
			var image:js.html.ImageElement = cast document.querySelector('img[src="images/sex_bomb_dye.png"]');
			if(image !=null){
			gl.bindTexture(gl.TEXTURE_2D, fluid.dyeRenderTarget.readFromTexture);
			gl.current_context.texSubImage2D(gl.TEXTURE_2D, 0,  Math.round(mouse_x), Math.round(mouse_y), RenderingContext.RGB, RenderingContext.UNSIGNED_BYTE, image);
			
			}
			
			HAS_RUN = true;
			}
			
			var vx = (mouse.x - lastMouse.x)/(dt*window.width);
				var vy = (mouse.y - lastMouse.y)/(dt*window.height);
				dyeColorHSB.hue += Math.sqrt(vx*vx + vy*vy)*0.5;

			var rgb = dyeColorHSB.toRGB();
			dyeColor.set(251/255, 141/255, 155/255); 
			
			
		}else if (isMouseDown && BIG_BLUE == true){
			
			if (!HAS_RUN){
			
			var x_location = windowToClipSpaceX(mouse.x);
			var y_location = windowToClipSpaceY(mouse.y);
			
			var mouse_x = (x_location + 1) / 2 * fluid.width - 25;
			var mouse_y = (y_location + 1) / 2 * fluid.height - 25;
				
			var image:js.html.ImageElement = cast document.querySelector('img[src="images/big_blue_dye.png"]');
			if(image !=null){
			gl.bindTexture(gl.TEXTURE_2D, fluid.dyeRenderTarget.readFromTexture);
			gl.current_context.texSubImage2D(gl.TEXTURE_2D, 0,  Math.round(mouse_x), Math.round(mouse_y), RenderingContext.RGB, RenderingContext.UNSIGNED_BYTE, image);
			
			}
			
			HAS_RUN = true;
			}
			
			var vx = (mouse.x - lastMouse.x)/(dt*window.width);
				var vy = (mouse.y - lastMouse.y)/(dt*window.height);
				dyeColorHSB.hue += Math.sqrt(vx*vx + vy*vy)*0.5;

			var rgb = dyeColorHSB.toRGB();
			dyeColor.set(36/255, 175/255, 190/255); 
			
			
			
		}else if (isMouseDown && THINK_PINK == true){
			
			if (!HAS_RUN){
			
			var x_location = windowToClipSpaceX(mouse.x);
			var y_location = windowToClipSpaceY(mouse.y);
			
			var mouse_x = (x_location + 1) / 2 * fluid.width - 25;
			var mouse_y = (y_location + 1) / 2 * fluid.height - 25;
				
			var image:js.html.ImageElement = cast document.querySelector('img[src="images/think_pink_dye.png"]');
			if(image !=null){
			gl.bindTexture(gl.TEXTURE_2D, fluid.dyeRenderTarget.readFromTexture);
			gl.current_context.texSubImage2D(gl.TEXTURE_2D, 0,  Math.round(mouse_x), Math.round(mouse_y), RenderingContext.RGB, RenderingContext.UNSIGNED_BYTE, image);
			
			}
			
			HAS_RUN = true;
			}
			
			var vx = (mouse.x - lastMouse.x)/(dt*window.width);
				var vy = (mouse.y - lastMouse.y)/(dt*window.height);
				dyeColorHSB.hue += Math.sqrt(vx*vx + vy*vy)*0.5;

			var rgb = dyeColorHSB.toRGB();
			dyeColor.set(216/255, 71/255, 120/255); 
			
			
			
		}else if (isMouseDown && AVOBATH == true){
			
			if (!HAS_RUN){
			
			var x_location = windowToClipSpaceX(mouse.x);
			var y_location = windowToClipSpaceY(mouse.y);
			
			var mouse_x = (x_location + 1) / 2 * fluid.width - 25;
			var mouse_y = (y_location + 1) / 2 * fluid.height - 25;
				
			var image:js.html.ImageElement = cast document.querySelector('img[src="images/avobath_dye.png"]');
			if(image !=null){
			gl.bindTexture(gl.TEXTURE_2D, fluid.dyeRenderTarget.readFromTexture);
			gl.current_context.texSubImage2D(gl.TEXTURE_2D, 0,  Math.round(mouse_x), Math.round(mouse_y), RenderingContext.RGB, RenderingContext.UNSIGNED_BYTE, image);
			
			}
			
			HAS_RUN = true;
			}
			
			var vx = (mouse.x - lastMouse.x)/(dt*window.width);
				var vy = (mouse.y - lastMouse.y)/(dt*window.height);
				dyeColorHSB.hue += Math.sqrt(vx*vx + vy*vy)*0.5;

			var rgb = dyeColorHSB.toRGB();
			dyeColor.set(140/255, 183/255, 102/255); 
		
			
		}else if (isMouseDown && CHEER_UP_BUTTERCUP == true){
			
			if (!HAS_RUN){
			
			var x_location = windowToClipSpaceX(mouse.x);
			var y_location = windowToClipSpaceY(mouse.y);
			
			var mouse_x = (x_location + 1) / 2 * fluid.width - 25;
			var mouse_y = (y_location + 1) / 2 * fluid.height - 25;
				
			var image:js.html.ImageElement = cast document.querySelector('img[src="images/cheer_up_buttercup_dye.png"]');
			if(image !=null){
			gl.bindTexture(gl.TEXTURE_2D, fluid.dyeRenderTarget.readFromTexture);
			gl.current_context.texSubImage2D(gl.TEXTURE_2D, 0,  Math.round(mouse_x), Math.round(mouse_y), RenderingContext.RGB, RenderingContext.UNSIGNED_BYTE, image);
			
			}
			
			HAS_RUN = true;
			}
			
			var vx = (mouse.x - lastMouse.x)/(dt*window.width);
				var vy = (mouse.y - lastMouse.y)/(dt*window.height);
				dyeColorHSB.hue += Math.sqrt(vx*vx + vy*vy)*0.5;

			var rgb = dyeColorHSB.toRGB();
			dyeColor.set(253/255, 217/255, 103/255); 
			
			
			
		}else if (isMouseDown && SECRET_ARTS == true){
			
			
			if (!HAS_RUN){
			
			var x_location = windowToClipSpaceX(mouse.x);
			var y_location = windowToClipSpaceY(mouse.y);
			
			var mouse_x = (x_location + 1) / 2 * fluid.width - 25;
			var mouse_y = (y_location + 1) / 2 * fluid.height - 25;
				
			var image:js.html.ImageElement = cast document.querySelector('img[src="images/secret_arts_dye.png"]');
			if(image !=null){
			gl.bindTexture(gl.TEXTURE_2D, fluid.dyeRenderTarget.readFromTexture);
			gl.current_context.texSubImage2D(gl.TEXTURE_2D, 0,  Math.round(mouse_x), Math.round(mouse_y), RenderingContext.RGB, RenderingContext.UNSIGNED_BYTE, image);
			
			}
			
			HAS_RUN = true;
			}
			
			var vx = (mouse.x - lastMouse.x)/(dt*window.width);
				var vy = (mouse.y - lastMouse.y)/(dt*window.height);
				dyeColorHSB.hue += Math.sqrt(vx*vx + vy*vy)*0.5;

			var rgb = dyeColorHSB.toRGB();
			dyeColor.set(141/255, 140/255, 145/255); 
			
			
			
		}else if (isMouseDown && BIG_SLEEP == true){	
			
			if (!HAS_RUN){
			
			var x_location = windowToClipSpaceX(mouse.x);
			var y_location = windowToClipSpaceY(mouse.y);
			
			var mouse_x = (x_location + 1) / 2 * fluid.width - 25;
			var mouse_y = (y_location + 1) / 2 * fluid.height - 25;
				
			var image:js.html.ImageElement = cast document.querySelector('img[src="images/big_sleep_dye.png"]');
			if(image !=null){
			gl.bindTexture(gl.TEXTURE_2D, fluid.dyeRenderTarget.readFromTexture);
			gl.current_context.texSubImage2D(gl.TEXTURE_2D, 0,  Math.round(mouse_x), Math.round(mouse_y), RenderingContext.RGB, RenderingContext.UNSIGNED_BYTE, image);
			
			}
			
			HAS_RUN = true;
			}
			
			var vx = (mouse.x - lastMouse.x)/(dt*window.width);
				var vy = (mouse.y - lastMouse.y)/(dt*window.height);
				dyeColorHSB.hue += Math.sqrt(vx*vx + vy*vy)*0.5;

			var rgb = dyeColorHSB.toRGB();
			dyeColor.set(105/255, 212/255, 234/255); 
					
			
		}else if (isMouseDown && THE_EXPERIMENTOR == true){		
			
			if (!HAS_RUN){
			
			var x_location = windowToClipSpaceX(mouse.x);
			var y_location = windowToClipSpaceY(mouse.y);
			
			var mouse_x = (x_location + 1) / 2 * fluid.width - 25;
			var mouse_y = (y_location + 1) / 2 * fluid.height - 25;
				
			var image:js.html.ImageElement = cast document.querySelector('img[src="images/experimenter_dye.png"]');
			if(image !=null){
			gl.bindTexture(gl.TEXTURE_2D, fluid.dyeRenderTarget.readFromTexture);
			gl.current_context.texSubImage2D(gl.TEXTURE_2D, 0,  Math.round(mouse_x), Math.round(mouse_y), RenderingContext.RGB, RenderingContext.UNSIGNED_BYTE, image);
			
			}
			
			HAS_RUN = true;
			}
			
			if(hueCycleEnabled) 
			dyeColorHSB.hue += 1.2;
			//cycle further by mouse velocity
			if(hueCycleEnabled){
				var vx = (mouse.x - lastMouse.x)/(dt*window.width);
				var vy = (mouse.y - lastMouse.y)/(dt*window.height);
				dyeColorHSB.hue += Math.sqrt(vx*vx + vy*vy)*0.5;
			}
			var rgb = dyeColorHSB.toRGB();
			dyeColor.set(rgb.red/255, rgb.green/255, rgb.blue/255 );
					
			
		}else if (isMouseDown && INTERGALACTIC == true){
			
			if (!HAS_RUN){
			
			var x_location = windowToClipSpaceX(mouse.x);
			var y_location = windowToClipSpaceY(mouse.y);
			
			var mouse_x = (x_location + 1) / 2 * fluid.width - 25;
			var mouse_y = (y_location + 1) / 2 * fluid.height - 25;
				
			var image:js.html.ImageElement = cast document.querySelector('img[src="images/intergalactic_dye.png"]');
			if(image !=null){
			gl.bindTexture(gl.TEXTURE_2D, fluid.dyeRenderTarget.readFromTexture);
			gl.current_context.texSubImage2D(gl.TEXTURE_2D, 0,  Math.round(mouse_x), Math.round(mouse_y), RenderingContext.RGB, RenderingContext.UNSIGNED_BYTE, image);
			
			}
			
			HAS_RUN = true;
			}
			
			if(hueCycleEnabled) 
			dyeColorHSB.hue += 1.2;
			//cycle further by mouse velocity
			if(hueCycleEnabled){
				var vx = (mouse.x - lastMouse.x)/(dt*window.width);
				var vy = (mouse.y - lastMouse.y)/(dt*window.height);
				dyeColorHSB.hue += Math.sqrt(vx*vx + vy*vy)*0.5;
			}
			var rgb = dyeColorHSB.toRGB();
			dyeColor.set(rgb.red/255, rgb.green/255, rgb.blue/255 );
			
		}

		updateLastMouse();
	}

	function render(?w:Window):Void {
		//copy fluid dye texture to screen
		gl.viewport (0, 0, window.width, window.height);
		gl.bindFramebuffer(gl.FRAMEBUFFER, screenBuffer);

		renderTexture(blitTextureShader, fluid.dyeRenderTarget.readFromTexture);
		
		if(renderParticlesEnabled){
			// gl.enable(gl.BLEND);
			// gl.blendEquation(gl.FUNC_ADD);
			// gl.blendFunc( gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA ); //alpha blending
			// gl.blendFunc( gl.SRC_ALPHA, gl.ONE );//additive

			renderParticles(renderParticlesShader);

			// gl.disable(gl.BLEND);
		}
	}

	inline function renderTexture(shader:{>TShader, texture:UTexture}, texture:GLTexture){
		gl.bindBuffer (gl.ARRAY_BUFFER, textureQuad);

		shader.texture.data = texture;
		
		shader.activate(true, true);
		gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
		shader.deactivate();
	}

	inline function renderParticles(shader:{>TShader, positionData:UTexture, velocityData:UTexture}):Void{
		//set vertices
		gl.bindBuffer(gl.ARRAY_BUFFER, particles.particleUVs);

		//set uniforms
		shader.positionData.data = particles.positionData.readFromTexture;
		shader.velocityData.data = particles.velocityData.readFromTexture;

		//draw points
		shader.activate(true, true);
		gl.drawArrays(gl.POINTS, 0, particles.count);
		shader.deactivate();
	}

	function updateSimulationTextures(){
		//only resize if there is a change
		var w:Int, h:Int;
		w = Math.round(window.width*fluidScale); h = Math.round(window.height*fluidScale);
		if(w != fluid.width || h != fluid.height) fluid.resize(w, h);

		if(particleCount != particles.count) particles.setCount(particleCount);

		particles.flowScaleX = 1/(fluid.cellSize * fluid.aspectRatio);
		particles.flowScaleY = 1/fluid.cellSize;
		particles.dragCoefficient = 1;
	}

	function updatePointSize(){
		renderParticlesShader.POINT_SIZE = Std.int(pointSize) + ".0";
	}

	function set_simulationQuality(quality:SimulationQuality):SimulationQuality{
		switch (quality) {
			case UltraHigh:
				particleCount = 1 << 20;
				fluidScale = 1/2;
				fluidIterations = 30;
				offScreenScale = 1/1;
				offScreenFilter = GL.NEAREST;
			case High:
				particleCount = 1 << 20;
				fluidScale = 1/4;
				fluidIterations = 20;
				offScreenScale = 1/1;
				offScreenFilter = GL.NEAREST;
			case Medium:
				particleCount = 1 << 18;
				fluidScale = 1/4;
				fluidIterations = 18;
				offScreenScale = 1/2;
				offScreenFilter = GL.LINEAR;
			case Low:
				particleCount = 1 << 16;
				fluidScale = 1/5;
				fluidIterations = 14;
				offScreenScale = 1/4;
				offScreenFilter = GL.LINEAR;
				pointSize = 2;
			case UltraLow:
				particleCount = 1 << 14;
				fluidScale = 1/6;
				fluidIterations = 12;
				offScreenScale = 1/4;
				offScreenFilter = GL.LINEAR;
				pointSize = 2;
			case iOS:
				particleCount = 1 << 14;
				fluidScale = 1/10;
				fluidIterations = 6;
				offScreenScale = 1/4;
				offScreenFilter = GL.LINEAR;
				pointSize = 2;
			case UltraUltraLow:
				particleCount = 1 << 12;
				fluidScale = 1/16;
				fluidIterations = 5;
				offScreenScale = 1/4;
				offScreenFilter = GL.LINEAR;
				pointSize = 2;
		}

		renderParticlesEnabled = particleCount > 1;

		return simulationQuality = quality;
	}

	function set_fluidIterations(v:Int):Int{
		fluidIterations = v;
		if(fluid != null) fluid.solverIterations = v;
		return v;
	}

	var qualityDirection:Int = 0;
	function lowerQualityRequired(magnitude:Float){
		if(qualityDirection>0)return;
		qualityDirection = -1;
		var qualityIndex = Type.enumIndex(this.simulationQuality);
		var maxIndex = Type.allEnums(SimulationQuality).length - 1;
		if(qualityIndex >= maxIndex)return;

		if(magnitude < 0.5) qualityIndex +=1;
		else                qualityIndex +=2;

		if(qualityIndex > maxIndex)qualityIndex = maxIndex;

		var newQuality = Type.createEnumIndex(SimulationQuality, qualityIndex);
		trace('Average FPS: '+performanceMonitor.fpsAverage+', lowering quality to: '+newQuality);
		this.simulationQuality = newQuality;
		updateSimulationTextures();
		updatePointSize();
	}

	//@! Requires better upsampling before use!
	function higherQualityRequired(magnitude:Float){
		if(qualityDirection<0)return;
		qualityDirection = 1;

		var qualityIndex = Type.enumIndex(this.simulationQuality);
		var minIndex = 0;
		if(qualityIndex <= minIndex)return;

		if(magnitude < 0.5) qualityIndex -=1;
		else                qualityIndex -=2;

		if(qualityIndex < minIndex)qualityIndex = minIndex;

		var newQuality = Type.createEnumIndex(SimulationQuality, qualityIndex);
		trace('Raising quality to: '+newQuality);
		this.simulationQuality = newQuality;
		updateSimulationTextures();
		updatePointSize();
	}

	inline function updateLastMouse(){
		lastMouse.set(mouse.x, mouse.y);
		lastMouseFluid.set(
			fluid.clipToAspectSpaceX(windowToClipSpaceX(mouse.x)),
			fluid.clipToAspectSpaceY(windowToClipSpaceY(mouse.y))
		);
		lastMousePointKnown = true && mousePointKnown;
	}

	//---- Interface & Events----//
	function reset():Void{
		particles.reset();	
		fluid.clear();
		this.HAS_RUN = false;
		
	}
	
	function bathBombSelection(): Void{
		
		document.querySelector('.myscrollbar1').addEventListener('click', function() {
			// twilight clicked
			HAS_RUN = false;
			closeNav(); 
			reset();
			TWILIGHT = true;  SEX_BOMB = false; BIG_BLUE = false; THINK_PINK = false; AVOBATH = false; CHEER_UP_BUTTERCUP = false; 
			SECRET_ARTS = false; BIG_SLEEP = false; THE_EXPERIMENTOR = false; INTERGALACTIC = false;
			
		});
		
		document.querySelector('.myscrollbar2').addEventListener('click', function() {
			// Sex Bomb clicked
			HAS_RUN = false;
			closeNav();
			reset();
			TWILIGHT = false;  SEX_BOMB = true; BIG_BLUE = false; THINK_PINK = false; AVOBATH = false; CHEER_UP_BUTTERCUP = false; 
			SECRET_ARTS = false; BIG_SLEEP = false; THE_EXPERIMENTOR = false; INTERGALACTIC = false;
			
		});
		
		document.querySelector('.myscrollbar3').addEventListener('click', function() {
			// Big Blue clicked
			HAS_RUN = false;
			closeNav();
			reset();
			TWILIGHT = false;  SEX_BOMB = false; BIG_BLUE = true; THINK_PINK = false; AVOBATH = false; CHEER_UP_BUTTERCUP = false; 
			SECRET_ARTS = false; BIG_SLEEP = false; THE_EXPERIMENTOR = false; INTERGALACTIC = false;
		});
		
		document.querySelector('.myscrollbar4').addEventListener('click', function() {
			// Think Pink clicked
			HAS_RUN = false;
			closeNav();
			reset();
			TWILIGHT = false;  SEX_BOMB = false; BIG_BLUE = false; THINK_PINK = true; AVOBATH = false; CHEER_UP_BUTTERCUP = false; 
			SECRET_ARTS = false; BIG_SLEEP = false; THE_EXPERIMENTOR = false; INTERGALACTIC = false;
		});
		
		document.querySelector('.myscrollbar5').addEventListener('click', function() {
			// Avobath clicked
			HAS_RUN = false;
			closeNav();
			reset();
			TWILIGHT = false;  SEX_BOMB = false; BIG_BLUE = false; THINK_PINK = false; AVOBATH = true; CHEER_UP_BUTTERCUP = false; 
			SECRET_ARTS = false; BIG_SLEEP = false; THE_EXPERIMENTOR = false; INTERGALACTIC = false;
		});
		
		document.querySelector('.myscrollbar6').addEventListener('click', function() {
			// Cheer Up Buttercup clicked
			HAS_RUN = false;
			closeNav();
			reset();
			TWILIGHT = false;  SEX_BOMB = false; BIG_BLUE = false; THINK_PINK = false; AVOBATH = false; CHEER_UP_BUTTERCUP = true; 
			SECRET_ARTS = false; BIG_SLEEP = false; THE_EXPERIMENTOR = false; INTERGALACTIC = false;
		});
		
		document.querySelector('.myscrollbar7').addEventListener('click', function() {
			// Secret Arts clicked
			HAS_RUN = false;
			closeNav();
			reset();
			TWILIGHT = false;  SEX_BOMB = false; BIG_BLUE = false; THINK_PINK = false; AVOBATH = false; CHEER_UP_BUTTERCUP = false; 
			SECRET_ARTS = true; BIG_SLEEP = false; THE_EXPERIMENTOR = false; INTERGALACTIC = false;
		});
		
		document.querySelector('.myscrollbar8').addEventListener('click', function() {
			// Big Sleep clicked
			HAS_RUN = false;
			closeNav();
			reset();
			TWILIGHT = false;  SEX_BOMB = false; BIG_BLUE = false; THINK_PINK = false; AVOBATH = false; CHEER_UP_BUTTERCUP = false; 
			SECRET_ARTS = false; BIG_SLEEP = true; THE_EXPERIMENTOR = false; INTERGALACTIC = false;
		});
		
		document.querySelector('.myscrollbar9').addEventListener('click', function() {
			// The Experimenter clicked
			HAS_RUN = false;
			closeNav();
			reset();
			TWILIGHT = false;  SEX_BOMB = false; BIG_BLUE = false; THINK_PINK = false; AVOBATH = false; CHEER_UP_BUTTERCUP = false; 
			SECRET_ARTS = false; BIG_SLEEP = false; THE_EXPERIMENTOR = true; INTERGALACTIC = false;
		});
		
		document.querySelector('.myscrollbar10').addEventListener('click', function() {
			// Intergalactic clicked
			HAS_RUN = false;
			closeNav();
			reset();
			TWILIGHT = false;  SEX_BOMB = false; BIG_BLUE = false; THINK_PINK = false; AVOBATH = false; CHEER_UP_BUTTERCUP = false; 
			SECRET_ARTS = false; BIG_SLEEP = false; THE_EXPERIMENTOR = false; INTERGALACTIC = true;
		});
		
	} 
	
	function closeNav() {
	document.getElementById("style-5").style.width = "0";
	document.getElementById("close-button").style.display = "inline-block";
	}
	

	//coordinate conversion
	inline function windowToClipSpaceX(x:Float) return (x/window.width)*2 - 1;
	inline function windowToClipSpaceY(y:Float) return ((window.height-y)/window.height)*2 - 1;

	override function onmousedown( x : Float , y : Float , button : Int, _, _){
		this.isMouseDown = true;
		this.hueCycleEnabled = true;
	}
	override function onmouseup( x : Float , y : Float , button : Int, _, _){
		timer;
		timer.run = function() { this.isMouseDown = false; this.HAS_RUN = false;}
		
		//this.isMouseDown = false;
	}

	override function onmousemove( x : Float , y : Float , xrel:Int, yrel:Int, _, _) {
		mouse.set(x, y);
		mouseFluid.set(
			fluid.clipToAspectSpaceX(windowToClipSpaceX(x)),
			fluid.clipToAspectSpaceY(windowToClipSpaceY(y))
		);
		mousePointKnown = true;
	}

	override function ontouchdown(x:Float,y:Float,touch_id:Int,_){
		#if desktop return; #end
		// return;//@! touch disabled
		updateTouchCoordinate(x,y);
		updateLastMouse();
		this.isMouseDown = true;
		this.hueCycleEnabled = true;
	}

	override function ontouchup(x:Float,y:Float,touch_id:Int,_){
		#if desktop return; #end
		// return;//@! touch disabled
		updateTouchCoordinate(x, y);
		
		timer;
		timer.run = function() { this.isMouseDown = false; this.HAS_RUN = false;}
		
		//this.isMouseDown = false;
	}

	override function ontouchmove(x:Float,y:Float,dx:Float,dy:Float,touch_id:Int,_){
		#if desktop return; #end
		// return;//@! touch disabled
		updateTouchCoordinate(x,y);
	}

	inline function updateTouchCoordinate(x:Float, y:Float){
		x = x*window.width;
		y = y*window.height;
		mouse.set(x, y);
		mouseFluid.set(
			fluid.clipToAspectSpaceX(windowToClipSpaceX(x)),
			fluid.clipToAspectSpaceY(windowToClipSpaceY(y))
		);
		mousePointKnown = true;
	}


	var lshiftDown = false;
	var rshiftDown = false;
	override function onkeydown( keyCode : Int, _, _, _, _, _){
		switch (keyCode) {
			case Key.lshift: 
				lshiftDown = true;
			case Key.rshift: 
				rshiftDown = true;
		}
	}
	
	override function onkeyup( keyCode : Int , _, _, _, _, _){
		switch (keyCode) {
			case Key.key_r:
				if(lshiftDown || rshiftDown) particles.reset();
				else reset();
			case Key.key_p:
				renderParticlesEnabled = !renderParticlesEnabled;
			case Key.key_d:
				renderFluidEnabled = !renderFluidEnabled;
			case Key.key_s:
				fluid.clear();
			case Key.lshift: 
				lshiftDown = false;
			case Key.rshift: 
				rshiftDown = false;
		}
	}

	function onWindowEvent(e:WindowEvent){
		switch(e.type){
			case WindowEventType.resized:
				updateSimulationTextures();//triggers resize of fluid
				lastMousePointKnown = false;
				mousePointKnown = false;
				if(!MOUSE_ALWAYS_DOWN){
					isMouseDown = false;
				}
			case WindowEventType.leave:
				isMouseDown = false;
			case WindowEventType.enter:
				mousePointKnown = false;
				lastMousePointKnown = false;
				if(MOUSE_ALWAYS_DOWN){
					isMouseDown = true;
				}
			default:
		}
	}
}

enum SimulationQuality{
	UltraHigh;
	High;
	Medium;
	Low;
	UltraLow;
	iOS;
	UltraUltraLow;
}


@:vert('#pragma include("src/shaders/glsl/no-transform.vert")')
@:frag('
	uniform sampler2D texture;
	varying vec2 texelCoord;

	void main(void){
		gl_FragColor = texture2D(texture, texelCoord);
	}
')
class BlitTexture extends ShaderBase {}

@:vert('#pragma include("src/shaders/glsl/no-transform.vert")')
@:frag('
	uniform sampler2D texture;
	varying vec2 texelCoord;

	void main(void){
		gl_FragColor = texture2D(texture, texelCoord);
	}
')
class FluidRender extends ShaderBase {}

@:vert('
	vec3 saturation(in vec3 rgb, in float amount){
		const vec3 CW = vec3(0.299, 0.587, 0.114);
		vec3 bw = vec3(dot(rgb, CW));//uses NTSC conversion weights
		return mix(bw, rgb, amount);
	}

	const float POINT_SIZE = 1.0;

	void main(){
		vec2 p = unpackParticlePosition(texture2D(positionData, particleUV));
		vec2 v = unpackParticleVelocity(texture2D(velocityData, particleUV));
		gl_PointSize = 1.0;
		gl_Position = vec4(p, 0.0, 1.0);
		float speed = length(v);
		float x = clamp(speed * 4.0, 0., 1.);
		color.rgb = (
				mix(vec3(40.4, 0.0, 35.0) / 300.0, vec3(0.2, 47.8, 100) / 100.0, x)
				+ (vec3(63.1, 92.5, 100) / 100.) * x*x*x * .1
		);
		color.a = 1.0;
	}
')
class ColorParticleMotion extends GPUParticles.RenderParticles{}

@:frag('
	#pragma include("src/shaders/glsl/geom.glsl")
	uniform bool isMouseDown;
	uniform vec2 mouse; //aspect space coordinates
	uniform vec2 lastMouse;
	uniform vec3 dyeColor;

	vec3 saturation(in vec3 rgb, in float amount){
		const vec3 CW = vec3(0.299, 0.587, 0.114);
		vec3 bw = vec3(dot(rgb, CW));//uses NTSC conversion weights
		return mix(bw, rgb, amount);
	}

	void main(){
		vec4 color = texture2D(dye, texelCoord);
		//darken
		color -= sign(color)*(0.006 - (1.0 - color)*0.004);
		// color *= 0.99;

		//saturate, needs to be carefully balanced with darken
		// color.rgb = saturation(color.rgb, 0.99);

		if(isMouseDown){			
			vec2 mouseVelocity = (mouse - lastMouse)/dt;
			
			//compute tapered distance to mouse line segment
			float projection;
			float l = distanceToSegment(mouse, lastMouse, p, projection);
			float taperFactor = 0.6;
			float projectedFraction = 1.0 - clamp(projection, 0.0, 1.0)*taperFactor;

			float speed = 0.016*length(mouseVelocity)/dt;
			float x = speed;
									
			float R = 0.3;
			float m = 1.0*exp(-l/R);
			float m2 = m*m;
			float m3 = m2*m;
			float m4 = m3*m;
			float m6 = m4*m*m;

			color.rgb +=
				0.004*dyeColor*(16.0*m3*(0.5*x+1.0)+m2) //color
			  + 0.03*m6*m*m*vec3(1.0)*(0.5*m3*x + 1.0);     //white
		}

		gl_FragColor = color;
	}
')
class MouseDye extends GPUFluid.UpdateDye{}

@:frag('
	#pragma include("src/shaders/glsl/geom.glsl")
	// #pragma include("src/shaders/glsl/math.glsl")
	uniform bool isMouseDown;
	uniform vec2 mouse; //aspect space coordinates
	uniform vec2 lastMouse;

	void main(){
		vec2 v = sampleVelocity(velocity, texelCoord);
		// v -= abs(sign(v))*0.2*dt;
		// v -= sign(v)*(0.005 - (1.0 - v)*0.001);
		v *= 0.999;
		if(isMouseDown){
			vec2 mouseVelocity = -(lastMouse - mouse)/dt;
			// mouse = mouse - (lastMouse - mouse) * 2.0;//predict mouse position
				
			//compute tapered distance to mouse line segment
			float projection;
			float l = distanceToSegment(mouse, lastMouse, p, projection);
			float taperFactor = 0.6;//1 => 0 at lastMouse, 0 => no tapering
			
			//Messing around with below changes the impact radius from drag point (was 1.0)
			float projectedFraction = 2.3 - clamp(projection, 0.0, 1.0) * taperFactor;
			//was 0.02
			float R = 0.010;
			float m = exp(-l/R); //drag coefficient
			m *= projectedFraction * projectedFraction;
			//vec2 targetVelocity = mouseVelocity * dx * 1.4; | removed the dx as this reduces the fractured distance which is needed when moving the bath bomb fast 
			vec2 targetVelocity = mouseVelocity * 1.4;

			v += (targetVelocity - v)*(m + m*m*m*8.0)*(0.2);
		}

		//add a wee bit of random noise
		// v += (rand((texelCoord + v))*2.0 - 1.0)*0.5;

		gl_FragColor = packFluidVelocity(v);
	}
')
class MouseForce extends GPUFluid.ApplyForces{}

@:vert('#pragma include("src/shaders/glsl/no-transform.vert")')
@:frag('
	#pragma include("src/shaders/glsl/fluid/fluid-base.frag")
	uniform sampler2D texture;
	varying vec2 texelCoord;

	void main(void){
		float d = sampleDivergence(texture, texelCoord);
		gl_FragColor = vec4(d, -d, 0.0, 1.0);
	}
')
class DebugBlitTexture extends ShaderBase {}