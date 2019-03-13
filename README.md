# Update in 2019
Back when I made this I didn't properly version my dependencies so to keep things simple I've recently bundled the correct dependencies into the `lib` folder. However to build with the git libs you need to checkout the following commits in haxelib:
- snow ab0e6c084c55dc9be72807178f9dc21807e9e46e
- gltoolbox dcddf60c6ff8bae6f9b8b577a02fb44175f32d5b

(The other libraries can be installed as normal)

- [haxe 3.2.1](https://haxe.org/download/version/3.2.1/) is required to build (never versions produce errors)



-------

##Building
Install the latest version of haxe from [haxe.org](http://haxe.org/)

Install the dependencies:
'flow' build tool and 'snow' library (more info on http://snowkit.org):

	haxelib git snow https://github.com/underscorediscovery/snow.git#ab0e6c084c55dc9be72807178f9dc21807e9e46e
	haxelib git flow https://github.com/underscorediscovery/flow.git

haxe libraries:

	haxelib git shaderblox https://github.com/haxiomic/shaderblox.git
	haxelib git gltoolbox https://github.com/haxiomic/GLToolbox.git#dcddf6
	haxelib install hxColorToolkit

and you should be good to go

cd into the project root and to build and run execute:

	haxelib run flow run web

(it'll start a server and open a web browser)

That is a bit much to type out frequently so it’s worth making an alias, on OS X I use

	alias fweb=“haxelib run flow run web --timeout 0”

Then you can build and run with 'fweb'.

If you're on windows, there's some instructions on how to make an alias to flow here [underscorediscovery.github.io/flow/#install-the-flow-shortcut](http://underscorediscovery.github.io/flow/#install-the-flow-shortcut).


------------------------------

You can build it as a native desktop application which will run a little faster:

install hxcpp:

	haxelib install hxcpp

from the project root run

	haxelib run flow run
