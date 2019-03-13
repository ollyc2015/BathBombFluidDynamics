/* 
*   Packing Parameters
*   - the smaller the scale, the greater the upper limits of the field, but the lower the precision
*   - aim is to find the maximum scale while maintaining a decent decent appearance
*/
const float PACK_FLUID_VELOCITY_SCALE = 0.0025; //@! this may change with cellSize!
const float PACK_FLUID_PRESSURE_SCALE = 0.00025;
const float PACK_FLUID_DIVERGENCE_SCALE = 0.25;

const bool FLOAT_VELOCITY = true;
const bool FLOAT_PRESSURE = true;
const bool FLOAT_DIVERGENCE = true;

//Velocity Packing
vec4 packFluidVelocity(in vec2 v){
    if(FLOAT_VELOCITY){
        return vec4(v, 0.0, 0.0);
    }else{
        vec2 nv = (v * PACK_FLUID_VELOCITY_SCALE)*0.5 + 0.5;
        return vec4(packFloat8bitRG(nv.x), packFloat8bitRG(nv.y));
    }
}

vec2 unpackFluidVelocity(in vec4 pv){
    if(FLOAT_VELOCITY){
        return pv.xy;
    }else{    
        const float INV_PACK_FLUID_VELOCITY_SCALE = 1./PACK_FLUID_VELOCITY_SCALE;
        vec2 nv = vec2(unpackFloat8bitRG(pv.xy), unpackFloat8bitRG(pv.zw));
        return (2.0*nv.xy - 1.0)* INV_PACK_FLUID_VELOCITY_SCALE;
    }
}

//Pressure Packing
vec4 packFluidPressure(in float p){
    if(FLOAT_PRESSURE){
        return vec4(p, 0.0, 0.0, 0.0);
    }else{
        float np = (p * PACK_FLUID_PRESSURE_SCALE)*0.5 + 0.5;
        return vec4(packFloat8bitRGB(np), 0.0);
    }
}

float unpackFluidPressure(in vec4 pp){
    if(FLOAT_PRESSURE){
        return pp.x;
    }else{    
        const float INV_PACK_FLUID_PRESSURE_SCALE = 1./PACK_FLUID_PRESSURE_SCALE;
        float np = unpackFloat8bitRGB(pp.rgb);
        return (2.0*np - 1.0) * INV_PACK_FLUID_PRESSURE_SCALE;
    }
}

//Divergence Packing
vec4 packFluidDivergence(in float d){
    if(FLOAT_DIVERGENCE){
        return vec4(d, 0.0, 0.0, 0.0);
    }else{
        float nd = (d * PACK_FLUID_DIVERGENCE_SCALE)*0.5 + 0.5;
        return vec4(packFloat8bitRGB(nd), 0.0);
    }
}

float unpackFluidDivergence(in vec4 pd){
    if(FLOAT_DIVERGENCE){
        return pd.x;
    }else{
        const float INV_PACK_FLUID_DIVERGENCE_SCALE = 1./PACK_FLUID_DIVERGENCE_SCALE;
        float nd = unpackFloat8bitRGB(pd.rgb);
        return (2.0*nd - 1.0) * INV_PACK_FLUID_DIVERGENCE_SCALE;
    }
}