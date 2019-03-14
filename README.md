##Bath Bomb Fluid Dynamics

This is an experimnental project displaying a bath bomb in water. This project was only made possible due to the awesome code base from ##**Haxiomic**. To view the original build, please go to https://github.com/haxiomic/GPU-Fluid-Experiments/tree/snow

- [haxe 3.2.1](https://haxe.org/download/version/3.2.1/) is required to build (never versions produce errors)

Please check out the [demo](http://oliverbcurtis.co.uk/FluidDynamics2/bin/web) to see the it in action!

-------

##Building
Install the latest version of haxe from [haxe.org](http://haxe.org/)

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
