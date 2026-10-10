import { Link } from 'react-router-dom';

interface AlsoExploreProps {
  links: Array<{ label: string; href: string }>;
}

export const AlsoExplore = ({ links }: AlsoExploreProps) => {
  if (!links || links.length === 0) return null;

  return (
    <div className="pt-4 border-t border-neutral-800/10 w-full flex flex-col items-center">
      <span className="text-[11px] font-sans font-medium uppercase tracking-wider text-neutral-500 mb-2">
        Also explore
      </span>
      <div className="flex flex-wrap items-center justify-center gap-2.5 sm:gap-4">
        {links.map((link) => (
          <Link
            key={link.href}
            to={link.href}
            className="px-3.5 py-1.5 rounded-full text-xs font-sans font-medium bg-white/70 hover:bg-white/95 text-neutral-800 border border-neutral-200/80 transition-all hover:scale-[1.02] shadow-xs"
          >
            {link.label} →
          </Link>
        ))}
      </div>
    </div>
  );
};
