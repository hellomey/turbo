import { Link } from 'react-router-dom';
import { getBeginJourneyTarget } from '../config/app.config';

interface CtaButtonProps {
  label?: string;
  className?: string;
  variant?: 'primary' | 'secondary';
  href?: string;
}

export const CtaButton = ({
  label = 'Begin Journey',
  className = '',
  variant = 'primary',
  href,
}: CtaButtonProps) => {
  const target = href
    ? { href, isExternal: href.startsWith('http') }
    : getBeginJourneyTarget();

  const baseStyles =
    'inline-flex items-center justify-center font-sans font-medium transition-all duration-300 ease-out cursor-pointer active:scale-[0.98]';

  const variantStyles =
    variant === 'primary'
      ? 'rounded-full px-8 sm:px-12 py-3 sm:py-3.5 text-sm sm:text-base bg-neutral-950 hover:bg-neutral-800 text-white shadow-xl hover:shadow-2xl hover:scale-[1.02]'
      : 'rounded-full px-6 sm:px-8 py-3 sm:py-3.5 text-sm sm:text-base bg-white/70 hover:bg-white/95 backdrop-blur-md border border-neutral-300/70 text-neutral-900 shadow-sm hover:shadow';

  const content = (
    <>
      <span>{label}</span>
      {variant === 'primary' && (
        <svg
          className="w-4 h-4 ml-2 transition-transform duration-300 group-hover:translate-x-1"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          strokeWidth="2"
        >
          <path strokeLinecap="round" strokeLinejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3" />
        </svg>
      )}
    </>
  );

  if (target.isExternal) {
    return (
      <a
        href={target.href}
        target="_blank"
        rel="noopener noreferrer"
        className={`group ${baseStyles} ${variantStyles} ${className}`}
      >
        {content}
      </a>
    );
  }

  return (
    <Link to={target.href} className={`group ${baseStyles} ${variantStyles} ${className}`}>
      {content}
    </Link>
  );
};
