/* 
*   Packing Parameters
*   - the smaller the scale, the greater the upper limits of the field, but the lower the precision
*   - aim is to find the maximum scale while maintaining a decent decent appearance
*/
const float PACK_PARTICLE_VELOCITY_SCALE = 0.05; //@! this may change with cellSize!

const bool FLOAT_DATA = false;

//Position Packing
vec4 packParticlePosition(in vec2 p){
	if(FLOAT_DATA){
		return vec4(p.xy, 0.0, 0.0);
	}else{	
	    vec2 np = (p)*0.5 + 0.5;
	    return vec4(packFloat8bitRG(np.x), packFloat8bitRG(np.y));
	}
}

vec2 unpackParticlePosition(in vec4 pp){
	if(FLOAT_DATA){
		return pp.xy;
	}else{
	    vec2 np = vec2(unpackFloat8bitRG(pp.xy), unpackFloat8bitRG(pp.zw));
	    return (2.0*np.xy - 1.0);
	}
}

//Velocity Packing
vec4 packParticleVelocity(in vec2 v){
	if(FLOAT_DATA){
		return vec4(v.xy, 0.0, 0.0);
	}else{
	    vec2 nv = (v * PACK_PARTICLE_VELOCITY_SCALE)*0.5 + 0.5;
	    return vec4(packFloat8bitRG(nv.x), packFloat8bitRG(nv.y));
	}

}

vec2 unpackParticleVelocity(in vec4 pv){
	if(FLOAT_DATA){
		return pv.xy;
	}else{
	    const float INV_PACK_PARTICLE_VELOCITY_SCALE = 1./PACK_PARTICLE_VELOCITY_SCALE;
	    vec2 nv = vec2(unpackFloat8bitRG(pv.xy), unpackFloat8bitRG(pv.zw));
	    return (2.0*nv.xy - 1.0)* INV_PACK_PARTICLE_VELOCITY_SCALE;
	}
}