/*
aspectRatio = w/h

#Coordinate Spaces

    Clip Space,     -1 -> 1 | x & y

    Aspect Space,   -aspectRatio -> aspectRatio | x
                                        -1 -> 1 | y
        * Same as clip space but maintains aspect ratio by fixing height

    Sim Space,      (Aspect Space) * cellSize
        * Used for the flow velocity, this is the space the physics takes place in

    Texel Space,    0 -> 1 | x & y
        * Texture coordinates for use in texture2D

    Pixel Space,    0 -> w | x
                    0 -> h | y
*/

#define PRESSURE_BOUNDARY
#define VELOCITY_BOUNDARY

uniform vec2 invresolution;
uniform float aspectRatio;

vec2 clipToAspectSpace(in vec2 p){
    return vec2(p.x * aspectRatio, p.y);
}

vec2 aspectToTexelSpace(in vec2 p){
    return vec2(p.x / aspectRatio + 1.0 , p.y + 1.0)*.5;
}

//packing functions
#pragma include("src/shaders/glsl/float-packing.glsl")
#pragma include("src/shaders/glsl/fluid/field-packing.glsl")

//sampling pressure texture factoring in boundary conditions
float samplePressue(in sampler2D pressure, in vec2 coord){
    vec2 cellOffset = vec2(0.0, 0.0);

    #ifdef PRESSURE_BOUNDARY
    //pure Neumann boundary conditions: 0 pressure gradient across the boundary
    //dP/dx = 0
    //walls
    //celloffset = f(coord){
    //  x < 0  =>  1.0
    //  x > 1  => -1.0
    //  else   =>  0.0
    //}
    cellOffset = -floor(coord);
    #endif

    return unpackFluidPressure(texture2D(pressure, coord + cellOffset * invresolution));
}


//sampling velocity texture factoring in boundary conditions
vec2 sampleVelocity(in sampler2D velocity, in vec2 coord){
    vec2 cellOffset = vec2(0.0, 0.0);
    vec2 multiplier = vec2(1.0, 1.0);

    #ifdef VELOCITY_BOUNDARY
    //free-slip boundary: the average flow across the boundary is restricted to 0
    //avg(uA.xy, uB.xy) dot (boundary normal).xy = 0
    //container walls:
    //x < 0, o =  1.0, m = -1.0
    //x > 0, o = -1.0, m = -1.0
    //else   o =  0.0, m =  1.0
    cellOffset = -floor(coord);
    multiplier -= 2.0*abs(cellOffset);
    #endif

    vec2 v = unpackFluidVelocity(texture2D(velocity, coord + cellOffset * invresolution));
    return multiplier * v;
}

#define sampleDivergence(divergence, coord) unpackFluidDivergence(texture2D(divergence, coord))

