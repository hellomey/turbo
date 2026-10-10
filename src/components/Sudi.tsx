export type SudiState = 'resting' | 'bright' | 'sleepy' | 'thinking';

interface SudiProps {
  state?: SudiState;
  className?: string;
  size?: number;
}

export const Sudi = ({ state = 'resting', className = '', size = 56 }: SudiProps) => {
  return (
    <div
      className={`inline-flex items-center justify-center transition-transform duration-300 ${className}`}
      aria-label={`Sudi companion flame (${state} state)`}
      role="img"
    >
      <svg
        width={size}
        height={size}
        viewBox="0 0 64 64"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="drop-shadow-sm select-none"
      >
        {/* Ambient Outer Aura */}
        <circle
          cx="32"
          cy="34"
          r="26"
          fill={state === 'bright' ? 'url(#sudi-bright-aura)' : 'url(#sudi-aura)'}
          opacity={state === 'sleepy' ? 0.35 : 0.65}
        />

        {/* Outer Flame Silhouette */}
        <path
          d="M32 4C32 4 48 20 48 36C48 44.8366 40.8366 52 32 52C23.1634 52 16 44.8366 16 36C16 20 32 4 32 4Z"
          fill="url(#sudi-outer-gradient)"
        />

        {/* Inner Flame Core */}
        <path
          d="M32 18C32 18 42 28 42 38C42 43.5228 37.5228 48 32 48C26.4772 48 22 43.5228 22 38C22 28 32 18 32 18Z"
          fill="url(#sudi-inner-gradient)"
        />

        {/* Character Eyes based on State */}
        {state === 'resting' && (
          <g fill="#1F2937">
            <ellipse cx="28" cy="36" rx="2.2" ry="2.2" />
            <ellipse cx="36" cy="36" rx="2.2" ry="2.2" />
            <path d="M30 41C31 42 33 42 34 41" stroke="#1F2937" strokeWidth="1.5" strokeLinecap="round" />
          </g>
        )}

        {state === 'bright' && (
          <g fill="#1F2937">
            <path d="M26 35C27 33 29 33 30 35" stroke="#1F2937" strokeWidth="2" strokeLinecap="round" fill="none" />
            <path d="M34 35C35 33 37 33 38 35" stroke="#1F2937" strokeWidth="2" strokeLinecap="round" fill="none" />
            <ellipse cx="32" cy="41" rx="2.5" ry="1.8" fill="#1F2937" />
            {/* Sparkles */}
            <circle cx="16" cy="18" r="1.8" fill="#F59E0B" className="animate-ping" />
            <circle cx="48" cy="16" r="1.5" fill="#F59E0B" className="animate-ping" />
          </g>
        )}

        {state === 'sleepy' && (
          <g fill="#4B5563">
            <path d="M26 37C27.5 38.5 29.5 38.5 30 37" stroke="#4B5563" strokeWidth="1.8" strokeLinecap="round" fill="none" />
            <path d="M34 37C35.5 38.5 37.5 38.5 38 37" stroke="#4B5563" strokeWidth="1.8" strokeLinecap="round" fill="none" />
            <circle cx="45" cy="24" r="2" fill="#9CA3AF" opacity="0.8" />
            <circle cx="50" cy="18" r="2.8" fill="#9CA3AF" opacity="0.6" />
          </g>
        )}

        {state === 'thinking' && (
          <g fill="#1F2937">
            <ellipse cx="28" cy="34" rx="2" ry="2.5" />
            <ellipse cx="36" cy="34" rx="2" ry="2.5" />
            <path d="M29 41C30.5 40 33.5 40 35 41" stroke="#1F2937" strokeWidth="1.8" strokeLinecap="round" fill="none" />
            {/* Soft question dot bubble */}
            <circle cx="43" cy="20" r="2" fill="#D97706" />
            <circle cx="47" cy="15" r="2.8" fill="#D97706" />
          </g>
        )}

        <defs>
          <radialGradient id="sudi-aura" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#F59E0B" stopOpacity="0.3" />
            <stop offset="100%" stopColor="#F59E0B" stopOpacity="0" />
          </radialGradient>
          <radialGradient id="sudi-bright-aura" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#FBBF24" stopOpacity="0.5" />
            <stop offset="100%" stopColor="#F59E0B" stopOpacity="0" />
          </radialGradient>
          <linearGradient id="sudi-outer-gradient" x1="32" y1="4" x2="32" y2="52" gradientUnits="userSpaceOnUse">
            <stop stopColor="#FBBF24" />
            <stop offset="60%" stopColor="#F59E0B" />
            <stop offset="100%" stopColor="#D97706" />
          </linearGradient>
          <linearGradient id="sudi-inner-gradient" x1="32" y1="18" x2="32" y2="48" gradientUnits="userSpaceOnUse">
            <stop stopColor="#FEF08A" />
            <stop offset="70%" stopColor="#FDE047" />
            <stop offset="100%" stopColor="#F59E0B" />
          </linearGradient>
        </defs>
      </svg>
    </div>
  );
};
