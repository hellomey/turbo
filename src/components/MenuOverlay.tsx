import { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { APP_CONFIG } from '../config/app.config';

interface MenuOverlayProps {
  isOpen: boolean;
  onClose: () => void;
}

export const MenuOverlay = ({ isOpen, onClose }: MenuOverlayProps) => {
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const sections = [
    {
      title: 'Product',
      links: [
        { label: 'Home', href: '/' },
        { label: 'Studio (Tour)', href: '/studio' },
        { label: 'Choose Your Exam', href: '/exams' },
        { label: 'TNPSC Group 4 & VAO', href: '/exams/tnpsc-group-4' },
        { label: 'Result Day Toolkit', href: '/result-day' },
        { label: 'Pricing & Plans', href: '/pricing' },
      ],
    },
    {
      title: 'Learn & Stories',
      links: [
        { label: 'Journal Index', href: '/journal' },
        { label: 'Group 4 By The Numbers', href: '/journal/group-4-numbers' },
        { label: 'What Readiness Means', href: '/journal/what-readiness-means' },
        { label: 'Why We Named It மெய்', href: '/journal/why-we-named-it-mey' },
      ],
    },
    {
      title: 'Company & Access',
      links: [
        { label: 'About & Principles', href: '/about' },
        { label: 'Our Trust Promise', href: '/trust' },
        { label: 'Frequently Asked Questions', href: '/faq' },
        { label: 'Reach Us (Contact)', href: '/contact' },
        { label: 'For Institutions & Colleges', href: '/institutions' },
        { label: 'Begin Journey (Waitlist)', href: '/begin' },
      ],
    },
    {
      title: 'Legal & Privacy',
      links: [
        { label: 'Privacy Policy', href: '/legal/privacy' },
        { label: 'Terms of Use', href: '/legal/terms' },
        { label: 'Refund & Cancellation', href: '/legal/refunds' },
        { label: 'Grievance Officer', href: '/legal/grievance' },
      ],
    },
  ];

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label="All Pages Site Navigation"
      className="fixed inset-0 z-50 bg-[#FAF7F2]/98 backdrop-blur-xl flex flex-col justify-between p-6 sm:p-12 overflow-y-auto animate-fade-rise"
    >
      {/* Top Header */}
      <div className="flex items-center justify-between max-w-6xl mx-auto w-full pb-6 border-b border-neutral-200">
        <Link
          to="/"
          onClick={onClose}
          className="font-serif text-3xl text-neutral-900 tracking-tight"
        >
          {APP_CONFIG.BRAND_NAME}
          <sup className="text-sm font-normal ml-0.5" style={{ top: '-0.6em' }}>
            {APP_CONFIG.BRAND_SYMBOL}
          </sup>
        </Link>

        <button
          type="button"
          onClick={onClose}
          aria-label="Close navigation overlay"
          className="min-h-[44px] min-w-[44px] flex items-center justify-center p-2 rounded-full bg-white hover:bg-neutral-100 text-neutral-900 border border-neutral-300 cursor-pointer shadow-xs transition-transform active:scale-95"
        >
          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.8" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      {/* Grid of Sections */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-8 max-w-6xl mx-auto w-full my-8">
        {sections.map((section) => (
          <div key={section.title} className="flex flex-col space-y-3">
            <h3 className="text-[11px] font-sans font-medium uppercase tracking-widest text-neutral-400 border-b border-neutral-200/80 pb-2">
              {section.title}
            </h3>
            <ul className="space-y-1">
              {section.links.map((link) => (
                <li key={link.href}>
                  <Link
                    to={link.href}
                    onClick={onClose}
                    className="min-h-[38px] flex items-center text-sm font-sans text-neutral-700 hover:text-neutral-950 transition-colors py-1"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>

      {/* Disclaimer Bottom Banner */}
      <div className="max-w-6xl mx-auto w-full pt-6 border-t border-neutral-200 text-center">
        <p className="text-xs font-sans text-neutral-500">
          {APP_CONFIG.DISCLAIMER}
        </p>
      </div>
    </div>
  );
};
