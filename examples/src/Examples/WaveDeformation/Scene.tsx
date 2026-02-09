import {
  ContactShadows,
  Environment,
  OrbitControls,
  PerspectiveCamera,
} from "@react-three/drei";
import { useFrame } from "@react-three/fiber";
import { useControls } from "leva";
import { Suspense, useMemo, useRef } from "react";
import * as THREE from "three";
import CSMType from "../../../../package/src";
import CSM from "../../../../package/src/React";
import { useShader } from "../../pages/Root";

const BASE_MATERIALS = {
  MeshStandardMaterial: THREE.MeshStandardMaterial,
  MeshPhysicalMaterial: THREE.MeshPhysicalMaterial,
  MeshBasicMaterial: THREE.MeshBasicMaterial,
};

function FrameUpdate({ materialRef }) {
  useFrame(({ clock }) => {
    if (materialRef.current) {
      materialRef.current.uniforms.uTime.value = clock.elapsedTime;
    }
  });

  return null!;
}

export function Scene() {
  const { vs, fs } = useShader();
  const materialRef = useRef<CSMType>(null!);

  const {
    Base: baseKey,
    visible,
    waveHeight,
    waveFrequency,
    waveSpeed,
    shininess,
  } = useControls(
    "Wave Controls",
    {
      Base: {
        options: Object.keys(BASE_MATERIALS),
        value: "MeshPhysicalMaterial",
        label: "Base Material",
      },
      visible: {
        value: true,
      },
      waveHeight: {
        value: 0.3,
        min: 0,
        max: 1,
        step: 0.01,
        label: "Wave Height",
      },
      waveFrequency: {
        value: 2.5,
        min: 0.5,
        max: 5,
        step: 0.1,
        label: "Wave Frequency",
      },
      waveSpeed: {
        value: 1.0,
        min: 0.1,
        max: 3,
        step: 0.1,
        label: "Wave Speed",
      },
      shininess: {
        value: 32.0,
        min: 1,
        max: 128,
        step: 1,
        label: "Shininess",
      },
    },
    []
  );

  const baseMaterial = BASE_MATERIALS[baseKey];

  const uniforms = useMemo(
    () => ({
      uTime: { value: 0 },
      uWaveHeight: { value: waveHeight },
      uWaveFrequency: { value: waveFrequency },
      uWaveSpeed: { value: waveSpeed },
      uDeepColor: {
        value: new THREE.Color("#003d5c").convertLinearToSRGB(),
      },
      uSurfaceColor: {
        value: new THREE.Color("#00a8cc").convertLinearToSRGB(),
      },
      uFoamColor: {
        value: new THREE.Color("#e8f4f8").convertLinearToSRGB(),
      },
      uShininess: { value: shininess },
    }),
    []
  );

  // Update uniforms when controls change
  if (materialRef.current) {
    materialRef.current.uniforms.uWaveHeight.value = waveHeight;
    materialRef.current.uniforms.uWaveFrequency.value = waveFrequency;
    materialRef.current.uniforms.uWaveSpeed.value = waveSpeed;
    materialRef.current.uniforms.uShininess.value = shininess;
  }

  return (
    <>
      <color attach="background" args={["#0a1929"]} />
      <Suspense fallback={null}>
        {baseKey === "MeshPhysicalMaterial" && (
          <Environment files="https://dl.polyhaven.org/file/ph-assets/HDRIs/hdr/1k/venice_sunset_1k.hdr" />
        )}
      </Suspense>

      <mesh visible={visible} castShadow receiveShadow rotation-x={-Math.PI / 2}>
        <planeGeometry args={[8, 8, 256, 256]} />
        <CSM
          ref={materialRef}
          baseMaterial={baseMaterial}
          vertexShader={vs}
          fragmentShader={fs}
          side={THREE.DoubleSide}
          roughness={0.1}
          metalness={0.8}
          uniforms={uniforms}
        />
      </mesh>
      <FrameUpdate materialRef={materialRef} />

      <ContactShadows
        position={[0, -0.2, 0]}
        width={12}
        height={12}
        far={20}
        opacity={0.3}
        rotation={[Math.PI / 2, 0, 0]}
      />

      <PerspectiveCamera makeDefault position={[6, 4, 6]} />
      <OrbitControls makeDefault />
    </>
  );
}
