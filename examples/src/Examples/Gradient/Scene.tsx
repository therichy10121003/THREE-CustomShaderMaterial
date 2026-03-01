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
    amplitude,
    lightIntensity,
  } = useControls(
    "Material",
    {
      Base: {
        options: Object.keys(BASE_MATERIALS),
        value: "MeshPhysicalMaterial",
        label: "Base Material",
      },
      visible: {
        value: true,
      },
      amplitude: {
        value: 0.2,
        min: 0,
        max: 1,
        step: 0.01,
        label: "Wave Amplitude",
      },
      lightIntensity: {
        value: 0.7,
        min: 0,
        max: 2,
        step: 0.1,
        label: "Light Intensity",
      },
    },
    []
  );

  const baseMaterial = BASE_MATERIALS[baseKey];

  const uniforms = useMemo(
    () => ({
      uTime: { value: 0 },
      uAmplitude: { value: amplitude },
      uColorA: {
        value: new THREE.Color("#ff6b6b").convertSRGBToLinear(),
      },
      uColorB: {
        value: new THREE.Color("#4ecdc4").convertSRGBToLinear(),
      },
      uColorC: {
        value: new THREE.Color("#ffe66d").convertSRGBToLinear(),
      },
      uLightIntensity: { value: lightIntensity },
    }),
    []
  );

  // Update uniforms when controls change
  if (materialRef.current) {
    materialRef.current.uniforms.uAmplitude.value = amplitude;
    materialRef.current.uniforms.uLightIntensity.value = lightIntensity;
  }

  return (
    <>
      <color attach="background" args={["#1a1a1a"]} />
      <Suspense fallback={null}>
        {baseKey === "MeshPhysicalMaterial" && (
          <Environment files="https://dl.polyhaven.org/file/ph-assets/HDRIs/hdr/1k/venice_sunset_1k.hdr" />
        )}
      </Suspense>

      <mesh visible={visible} castShadow receiveShadow>
        <planeGeometry args={[6, 6, 128, 128]} />
        <CSM
          ref={materialRef}
          baseMaterial={baseMaterial}
          vertexShader={vs}
          fragmentShader={fs}
          side={THREE.DoubleSide}
          roughness={0.3}
          metalness={0.2}
          uniforms={uniforms}
        />
      </mesh>
      <FrameUpdate materialRef={materialRef} />

      <ContactShadows
        position={[0, -0.5, 0]}
        width={10}
        height={10}
        far={20}
        opacity={0.4}
        rotation={[Math.PI / 2, 0, 0]}
      />

      <PerspectiveCamera makeDefault position={[4, 3, 4]} />
      <OrbitControls makeDefault />
    </>
  );
}
