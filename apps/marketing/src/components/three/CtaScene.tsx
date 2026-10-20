"use client";
// Light WebGL layer for the final CTA: a star field and a slowly turning
// ringed planet in the hero palette. DPR capped at 1.5; the render loop stops
// entirely when the section is off-screen; the camera eases with scroll.
import { useEffect, useMemo, useRef, type RefObject } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import { Stars } from "@react-three/drei";
import * as THREE from "three";

// Off to the side and small, so it frames the headline instead of sitting behind it.
function Planet({ progress, offset }: { progress: RefObject<number>; offset: [number, number, number] }) {
  const group = useRef<THREE.Group>(null);
  const ringGeometry = useMemo(() => new THREE.RingGeometry(1.25, 1.6, 128, 1), []);
  useEffect(() => () => ringGeometry.dispose(), [ringGeometry]);

  useFrame(({ camera }, delta) => {
    if (group.current) group.current.rotation.y += delta * 0.12;
    // Scroll nudges the camera: closer and slightly higher as the CTA centres.
    const p = progress.current ?? 0;
    camera.position.z += (7.2 - p * 1.4 - camera.position.z) * 0.06;
    camera.position.y += (0.4 + p * 0.5 - camera.position.y) * 0.06;
    camera.lookAt(0, 0, 0);
  });

  return (
    <group ref={group} position={offset} rotation={[0.42, 0, 0.22]} scale={0.62}>
      <mesh>
        <sphereGeometry args={[1.1, 64, 64]} />
        <meshStandardMaterial color="#1b1338" roughness={0.9} metalness={0.05} emissive="#381c86" emissiveIntensity={0.25} />
      </mesh>
      <mesh geometry={ringGeometry} rotation={[-Math.PI / 2.3, 0, 0]}>
        <meshBasicMaterial color="#b1f0cf" transparent opacity={0.18} side={THREE.DoubleSide} depthWrite={false} />
      </mesh>
      <mesh rotation={[-Math.PI / 2.3, 0, 0]}>
        <ringGeometry args={[1.7, 1.74, 128]} />
        <meshBasicMaterial color="#a855f7" transparent opacity={0.45} side={THREE.DoubleSide} depthWrite={false} />
      </mesh>
    </group>
  );
}

export default function CtaScene({ active, sectionRef }: { active: boolean; sectionRef: RefObject<HTMLElement | null> }) {
  const progress = useRef(0);
  const wide = typeof window !== "undefined" && window.innerWidth >= 768;

  useEffect(() => {
    const onScroll = () => {
      const el = sectionRef.current;
      if (!el) return;
      const r = el.getBoundingClientRect();
      const vh = window.innerHeight;
      progress.current = Math.min(1, Math.max(0, (vh - r.top) / (vh + r.height)));
    };
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, [sectionRef]);

  return (
    <Canvas
      dpr={[1, 1.5]}
      frameloop={active ? "always" : "never"}
      camera={{ position: [0, 0.4, 7.2], fov: 40 }}
      gl={{ antialias: true, alpha: true, powerPreference: "low-power" }}
    >
      <ambientLight intensity={0.35} />
      <pointLight position={[-4, 3, 4]} intensity={14} color="#bd6cfb" />
      <pointLight position={[4, -2, 3]} intensity={9} color="#5df3be" />
      <Stars radius={60} depth={30} count={1400} factor={3} saturation={0} fade speed={0.4} />
      <Planet progress={progress} offset={wide ? [2.6, -1.1, 0] : [0.9, -2.2, 0]} />
    </Canvas>
  );
}
