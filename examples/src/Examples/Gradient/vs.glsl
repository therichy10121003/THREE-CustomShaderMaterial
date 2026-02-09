
uniform float uTime;
uniform float uAmplitude;

varying vec3 vPosition;
varying vec3 vNormal;

// Parametric deformation function
vec3 parametricDeform(vec3 pos) {
  vec3 p = pos;
  
  // Apply sinusoidal deformation along multiple axes
  float frequency = 2.0;
  float speed = uTime * 0.5;
  
  // Wave along X axis
  p.y += sin(pos.x * frequency + speed) * uAmplitude * 0.3;
  
  // Wave along Z axis
  p.y += cos(pos.z * frequency + speed * 0.8) * uAmplitude * 0.2;
  
  // Circular wave from center
  float dist = length(pos.xz);
  p.y += sin(dist * 3.0 - speed * 2.0) * uAmplitude * 0.15;
  
  return p;
}

// Calculate deformed normal
vec3 calculateNormal(vec3 pos) {
  float epsilon = 0.01;
  
  vec3 tangentX = parametricDeform(pos + vec3(epsilon, 0.0, 0.0)) - parametricDeform(pos - vec3(epsilon, 0.0, 0.0));
  vec3 tangentZ = parametricDeform(pos + vec3(0.0, 0.0, epsilon)) - parametricDeform(pos - vec3(0.0, 0.0, epsilon));
  
  return normalize(cross(tangentX, tangentZ));
}

void main() {
  vPosition = position;
  
  // Apply parametric deformation
  vec3 deformedPosition = parametricDeform(position);
  csm_Position = deformedPosition;
  
  // Calculate and apply deformed normal
  csm_Normal = calculateNormal(position);
  vNormal = csm_Normal;
}
