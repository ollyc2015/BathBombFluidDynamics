package gltoolbox;

#if snow
import snow.modules.opengl.GL;
import snow.api.buffers.Float32Array;
#elseif lime
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
#end

class GeometryTools{

    static var unitQuadCache = new Map<Int,GLBuffer>();
    static public function getCachedUnitQuad(drawMode:Int = GL.TRIANGLE_STRIP):GLBuffer{
        var unitQuad = unitQuadCache.get(drawMode);
        if(unitQuad == null || !GL.isBuffer(unitQuad)){
            unitQuad = createUnitQuad(drawMode);
            unitQuadCache.set(drawMode, unitQuad);
        }
        return unitQuad;
    }

    static var clipSpaceQuadCache = new Map<Int,GLBuffer>();
    static public function getCachedClipSpaceQuad(drawMode:Int = GL.TRIANGLE_STRIP):GLBuffer{
        var clipSpaceQuad = clipSpaceQuadCache.get(drawMode);
        if(clipSpaceQuad == null || !GL.isBuffer(clipSpaceQuad)){
            clipSpaceQuad = createClipSpaceQuad(drawMode);
            clipSpaceQuadCache.set(drawMode, clipSpaceQuad);
        }
        return clipSpaceQuad;
    }

    static public inline function createUnitQuad(drawMode:Int = GL.TRIANGLE_STRIP):GLBuffer{
        return createQuad(0, 0, 1, 1, drawMode);
    }

    static public inline function createClipSpaceQuad(drawMode:Int = GL.TRIANGLE_STRIP):GLBuffer{
        return createQuad(-1, -1, 2, 2, drawMode);
    }

    static public function createQuad(
        originX:Float = 0,
        originY:Float = 0,
        width:Float   = 1,
        height:Float  = 1,
        drawMode:Int  = GL.TRIANGLE_STRIP,
        usage:Int     = GL.STATIC_DRAW):GLBuffer{
        var quad = GL.createBuffer();
        var vertices = new Array<Float>();
        switch (drawMode) {
            case GL.TRIANGLE_STRIP, GL.TRIANGLES:
                vertices = [//anti-clockwise triangle strip
                    originX,        originY+height,     //  0---2
                    originX,        originY,            //  |  /|
                    originX+width,  originY+height,     //  | / |
                    originX+width,  originY,            //  1---3
                    //TRIANGLE_STRIP builds triangles with the pattern, v0, v1, v2 | v2, v1, v3
                    //by default, anti-clockwise triangles are front-facing 
                ];
                if(drawMode == GL.TRIANGLES){
                    vertices = vertices.concat([        //  *---4
                        originX+width,  originY+height, //  |  /|
                        originX,        originY,        //  | / |
                    ]);                                 //  5---*
                }
            case GL.TRIANGLE_FAN:
                vertices = [//anti-clockwise triangle strip
                    originX,        originY+height,     //  0---3
                    originX,        originY,            //  |\  |
                    originX+width,  originY,            //  | \ |
                    originX+width,  originY+height,     //  1---2
                    //TRIANGLE_STRIP builds triangles with the pattern, v0, v1, v2 | v2, v1, v3
                    //by default, anti-clockwise triangles are front-facing 
                ];
        }
        GL.bindBuffer(GL.ARRAY_BUFFER, quad);
        GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(vertices), usage);
        GL.bindBuffer(GL.ARRAY_BUFFER, null);
        return quad;
    }

    /*  
    *   OpenGL line drawing
    *   +--X--+-----+-----+
    *   |  '  |     |     |
    *   O---->---->---->--X
    *   |  '  |     |     |
    *   +--^--+-----+-----+
    *   |  '  |     |     |
    *   |  ^  |     |     |
    *   |  '  |     |     |
    *   +--O--+-----+-----+
    */
    static public function boundaryLinesArray(width:Int, height:Int)return new Float32Array(//OGL centers lines on the boundary between pixels
        [
            //left
            0.5       , 0,
            0.5       , height,
            //top
            0         , height-0.5,
            width     , height-0.5,
            //right
            width-0.5 , height,
            width-0.5 , 0,
            //bottom
            width     , 0.5,
            0         , 0.5
        ]
    );
    
}