import Image from "next/image";

export function Logo({ size = 28, className = "" }: { size?: number; className?: string }) {
  return (
    <Image
      src="/logo.png"
      alt="HeyMey Logo"
      width={size}
      height={size}
      priority
      className={`rounded-full object-contain ${className}`}
    />
  );
}

