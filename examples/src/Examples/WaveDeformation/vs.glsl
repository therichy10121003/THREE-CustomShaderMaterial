
uniform float uTime;
uniform float uWaveHeight;
uniform float uWaveFrequency;
uniform float uWaveSpeed;

varying vec3 vPosition;
varying vec3 vNormal;
varying float vElevation;

// Advanced wave transformation with multiple wave types
vec3 advancedWaveTransform(vec3 pos) {
  vec3 p = pos;
  float time = uTime * uWaveSpeed;
  
  // Primary sine wave
  float wave1 = sin(pos.x * uWaveFrequency + time) * uWaveHeight;
  
  // Secondary cosine wave (perpendicular)
  float wave2 = cos(pos.z * uWaveFrequency * 0.8 + time * 1.2) * uWaveHeight * 0.6;
  
  // Circular ripple effect from center
  float dist = length(pos.xz);
  float ripple = sin(dist * uWaveFrequency * 1.5 - time * 2.0) * uWaveHeight * 0.4;
  
  // Gerstner wave-like effect
  float gerstnerX = cos(pos.x * uWaveFrequency * 0.5 + time) * uWaveHeight * 0.3;
  float gerstnerZ = sin(pos.z * uWaveFrequency * 0.5 + time) * uWaveHeight * 0.3;
  
  // Combine all waves
  p.y += wave1 + wave2 + ripple;
  p.x += gerstnerX;
  p.z += gerstnerZ;
  
  // Store elevation for fragment shader
  vElevation = wave1 + wave2 + ripple;
  
  return p;
}

// Calculate accurate normals for the deformed surface
vec3 calculateSurfaceNormal(vec3 pos) {
  float eps = 0.01;
  
  // Sample neighboring points
  vec3 tangentU = advancedWaveTransform(pos + vec3(eps, 0.0, 0.0)) - 
                   advancedWaveTransform(pos - vec3(eps, 0.0, 0.0));
  vec3 tangentV = advancedWaveTransform(pos + vec3(0.0, 0.0, eps)) - 
                   advancedWaveTransform(pos - vec3(0.0, 0.0, eps));
  
  return normalize(cross(tangentU, tangentV));
}

void main() {
  vPosition = position;
  
  // Apply advanced wave transformation
  vec3 transformedPosition = advancedWaveTransform(position);
  csm_Position = transformedPosition;
  
  // Calculate and apply surface normal
  vec3 surfaceNormal = calculateSurfaceNormal(position);
  csm_Normal = surfaceNormal;
  vNormal = surfaceNormal;
}
