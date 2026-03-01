
uniform float uTime;
uniform vec3 uDeepColor;
uniform vec3 uSurfaceColor;
uniform vec3 uFoamColor;
uniform float uShininess;

varying vec3 vPosition;
varying vec3 vNormal;
varying float vElevation;

// Dynamic lighting with multiple light sources
vec3 calculateDynamicLighting(vec3 baseColor, vec3 normal, vec3 worldPos) {
  vec3 finalColor = vec3(0.0);
  
  // Main animated directional light
  vec3 lightDir1 = normalize(vec3(
    sin(uTime * 0.3) * 0.7,
    0.8,
    cos(uTime * 0.3) * 0.7
  ));
  
  // Secondary fixed light
  vec3 lightDir2 = normalize(vec3(-0.5, 0.6, 0.5));
  
  // View direction for specular
  vec3 viewDir = normalize(cameraPosition - worldPos);
  
  // Diffuse lighting from main light
  float diffuse1 = max(dot(normal, lightDir1), 0.0);
  vec3 diffuseColor1 = baseColor * diffuse1 * 0.8;
  
  // Diffuse lighting from secondary light
  float diffuse2 = max(dot(normal, lightDir2), 0.0);
  vec3 diffuseColor2 = baseColor * diffuse2 * 0.4;
  
  // Specular highlights (main light)
  vec3 halfDir1 = normalize(lightDir1 + viewDir);
  float specular1 = pow(max(dot(normal, halfDir1), 0.0), uShininess);
  vec3 specularColor1 = vec3(1.0) * specular1 * 0.6;
  
  // Fresnel effect for water-like appearance
  float fresnel = pow(1.0 - max(dot(viewDir, normal), 0.0), 3.0);
  vec3 fresnelColor = vec3(0.3, 0.5, 0.7) * fresnel * 0.4;
  
  // Ambient lighting
  vec3 ambient = baseColor * 0.2;
  
  // Combine all lighting
  finalColor = ambient + diffuseColor1 + diffuseColor2 + specularColor1 + fresnelColor;
  
  return finalColor;
}

// Color gradient based on elevation
vec3 elevationGradient(float elevation) {
  // Normalize elevation
  float t = (elevation / 1.0 + 1.0) * 0.5;
  
  // Create gradient from deep to surface to foam
  vec3 color;
  if (t < 0.4) {
    color = mix(uDeepColor, uSurfaceColor, t / 0.4);
  } else if (t < 0.7) {
    color = uSurfaceColor;
  } else {
    color = mix(uSurfaceColor, uFoamColor, (t - 0.7) / 0.3);
  }
  
  return color;
}

// Animated foam effect on wave peaks
float foamEffect(float elevation, vec3 pos) {
  float foam = 0.0;
  
  // Foam appears on high elevations
  if (elevation > 0.3) {
    float foamPattern = sin(pos.x * 20.0 + uTime * 2.0) * 
                        cos(pos.z * 20.0 + uTime * 2.0);
    foamPattern = smoothstep(0.3, 0.7, foamPattern);
    foam = foamPattern * (elevation - 0.3) * 2.0;
  }
  
  return foam;
}

void main() {
  // Calculate base color from elevation
  vec3 baseColor = elevationGradient(vElevation);
  
  // Add foam effect
  float foam = foamEffect(vElevation, vPosition);
  baseColor = mix(baseColor, uFoamColor, foam);
  
  // Apply dynamic lighting
  vec3 litColor = calculateDynamicLighting(baseColor, normalize(vNormal), vPosition);
  
  csm_DiffuseColor = vec4(litColor, 1.0);
}
