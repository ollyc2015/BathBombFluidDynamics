**Bath Bomb Fluid Dynamics**

This is an experimental project simulating a bath bomb in digital water. This project was only made possible due to the awesome code base from **Haxiomic**. To view the original build, please go to https://github.com/haxiomic/GPU-Fluid-Experiments/

- [haxe 3.2.1](https://haxe.org/download/version/3.2.1/) is required to build (newer versions produce errors)

Please check out the [demo](https://bathbombmania.000webhostapp.com/BathBombFluidDynamics/bin/web) to see the it in action! if you're using a Google Pixel phone, please run the demo using Firefox browser. I have recently moved the demo to a free hosting service, so apologies for slow loading times.

-------

**Building**

Install the dependencies:
'flow' build tool and 'snow' library (more info on http://snowkit.org):

	haxelib git snow https://github.com/underscorediscovery/snow.git ab0e6c084c55dc9be72807178f9dc21807e9e46e
	haxelib git flow https://github.com/underscorediscovery/flow.git

haxe libraries:

	haxelib git shaderblox https://github.com/haxiomic/shaderblox.git
	haxelib git gltoolbox https://github.com/haxiomic/GLToolbox.git dcddf6
	haxelib install hxColorToolkit

and you should be good to go

cd into the project root and to build and run execute:

	haxelib run flow run web

(it'll start a server and open a web browser)

**Also**

I have another repo found here: https://github.com/ollyc2015/LushMoods where I implement a fluid simulation in native Android - I started to get tech interns to build a workflow, but the project was abondoned, when I get time I will look to fix it. However, if you select through the screens, you will get to the fluid simulation which you can play with.
