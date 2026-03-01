
uniform float uTime;
uniform vec3 uColorA;
uniform vec3 uColorB;
uniform vec3 uColorC;
uniform float uLightIntensity;

varying vec3 vPosition;
varying vec3 vNormal;

// Dynamic gradient function
vec3 dynamicGradient(vec3 pos, vec3 normal) {
  // Create multi-color gradient based on position and time
  float gradientFactor1 = (pos.y + 1.0) * 0.5;
  float gradientFactor2 = (sin(pos.x * 2.0 + uTime) + 1.0) * 0.5;
  float gradientFactor3 = (cos(pos.z * 2.0 + uTime * 0.7) + 1.0) * 0.5;
  
  // Mix three colors
  vec3 color1 = mix(uColorA, uColorB, gradientFactor1);
  vec3 color2 = mix(uColorB, uColorC, gradientFactor2);
  vec3 finalColor = mix(color1, color2, gradientFactor3);
  
  return finalColor;
}

// Dynamic lighting calculation
vec3 dynamicLighting(vec3 baseColor, vec3 normal) {
  // Animated light direction
  vec3 lightDir = normalize(vec3(
    sin(uTime * 0.5),
    cos(uTime * 0.3) * 0.5 + 0.5,
    cos(uTime * 0.5)
  ));
  
  // Calculate diffuse lighting
  float diffuse = max(dot(normal, lightDir), 0.0);
  
  // Add ambient light
  float ambient = 0.3;
  
  // Rim lighting effect
  vec3 viewDir = normalize(cameraPosition - vPosition);
  float rim = 1.0 - max(dot(viewDir, normal), 0.0);
  rim = pow(rim, 3.0) * 0.5;
  
  // Combine lighting
  float lighting = ambient + diffuse * uLightIntensity + rim;
  
  return baseColor * lighting;
}

void main() {
  // Generate dynamic gradient
  vec3 gradientColor = dynamicGradient(vPosition, vNormal);
  
  // Apply dynamic lighting
  vec3 litColor = dynamicLighting(gradientColor, normalize(vNormal));
  
  csm_DiffuseColor = vec4(litColor, 1.0);
}
