uniform sampler2D velocity;
uniform float dt;
uniform float rdx; //reciprocal of grid scale, used to scale velocity into simulation domain

varying vec2 texelCoord;
varying vec2 p;//aspect space

void main(void){
  //texelCoord refers to the center of the texel! Not a corner!
  
  vec2 tracedPos = p - dt * rdx * sampleVelocity(velocity, texelCoord).xy; //aspect space

  //Bilinear Interpolation of the target field value at tracedPos
  //convert from aspect space to texel space (0 -> 1 | x & y)
  tracedPos = aspectToTexelSpace(tracedPos);
  //convert from texel space to pixel space (0 -> w)
  tracedPos /= invresolution;
  
  vec4 st;
  st.xy = floor(tracedPos-.5)+.5; //left & bottom cell centers
  st.zw = st.xy+1.;               //right & top centers

  vec2 t = tracedPos - st.xy;

  st *= invresolution.xyxy; //to unitary coords
  
  vec2 tex11 = sampleVelocity(velocity, st.xy);
  vec2 tex21 = sampleVelocity(velocity, st.zy);
  vec2 tex12 = sampleVelocity(velocity, st.xw);
  vec2 tex22 = sampleVelocity(velocity, st.zw);
  
  //need to bilerp this result
  gl_FragColor = packFluidVelocity(mix(mix(tex11, tex21, t.x), mix(tex12, tex22, t.x), t.y));
}