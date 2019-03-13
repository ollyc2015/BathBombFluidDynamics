package snow.system.assets;

import snow.types.Types;
import snow.api.Promise;
import snow.api.buffers.Uint8Array;
import snow.api.Debug.*;

import snow.system.assets.Asset;

#if (!macro && !display && !scribe)
    private typedef AssetsModule = haxe.macro.MacroType<[snow.system.module.Module.assign('Assets')]>;
#end

/** The asset system class gives you access to fetching and manipulating assets,
    handling loading files and data in a consistent cross platform way */
class Assets {


        /** If the assets are not relative to the runtime root path, this value can adjust all asset paths. This is automatically handled and exists to allow control. */
    public var root : String = '';

        /** access to module implementation */
    public var module : snow.system.module.Assets;
        /** access to snow from subsystems */
    public var app : Snow;


        /** constructed internally, use `app.assets` */
    @:allow(snow.Snow)
    function new( _app:Snow ) {

        #if ios
                //This is because of how the files are put into the xcode project
                //for the iOS builds, it stores them inside of /assets to avoid
                //including the root in the project in the Resources/ folder
            root = 'assets/';
        #end

        app = _app;
        module = new snow.system.module.Assets(this);

    } //new

//Public API

        /** Get the asset path for an asset, adjusted by platform, root etc. */
    public inline function path( _id:String ) : String return haxe.io.Path.join([root,_id]);

        /** Get an asset as an `AssetBytes`, data stored as `Uint8Array`, using the default processor and provider */
    public inline function bytes( _id:String ) : Promise return AssetBytes.load(this, _id);

        /** Get an asset as an `AssetText`, data stored as `String`, using the default processor and provider */
    public inline function text( _id:String ) : Promise  return AssetText.load(this, _id);

        /** Get an asset as an `AssetJSON`, data stored as `Dynamic`, using the default processor and provider */
    public inline function json( _id:String ) : Promise  return AssetJSON.load(this, _id);

        /** Get an asset as an `AssetImage`, data stored as `ImageInfo`, using the default processor and provider */
    public inline function image( _id:String ) : Promise  return AssetImage.load(this, _id);

        /** Get an asset as an `AssetImage`, data stored as `ImageInfo`, created from image file bytes (not pixels). */
    public inline function image_from_bytes( _id:String, _bytes:Uint8Array ) : Promise
        return AssetImage.load_from_bytes(this, _id, _bytes);

        /** Get an asset as an `AssetImage`, data stored as `ImageInfo`, created from image file pixels */
    public inline function image_from_pixels( _id:String, _width:Int, _height:Int, _pixels:Uint8Array ) : AssetImage
        return AssetImage.load_from_pixels(this, _id, _width, _height, _pixels);

} //Assets
