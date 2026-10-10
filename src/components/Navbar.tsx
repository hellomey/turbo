import { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { CtaButton } from './CtaButton';
import { MenuOverlay } from './MenuOverlay';
import { APP_CONFIG } from '../config/app.config';

export const Navbar = () => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const location = useLocation();

  const menuItems = [
    { label: 'Home', href: '/' },
    { label: 'Studio', href: '/studio' },
    { label: 'About', href: '/about' },
    { label: 'Journal', href: '/journal' },
    { label: 'Reach Us', href: '/contact' },
  ];

  const isItemActive = (href: string) => {
    if (href === '/') return location.pathname === '/';
    return location.pathname.startsWith(href);
  };

  return (
    <>
      <header className="relative z-20 w-full select-none">
        <nav
          aria-label="Main Navigation"
          className="flex items-center justify-between px-6 sm:px-8 py-5 sm:py-6 max-w-7xl mx-auto"
        >
          {/* Logo: "HeyMey™" */}
          <Link
            to="/"
            id="nav-logo"
            className="font-serif text-3xl tracking-tight text-[#000000] inline-flex items-baseline select-none transition-opacity hover:opacity-80"
          >
            <span>{APP_CONFIG.BRAND_NAME}</span>
            <sup className="text-sm font-normal ml-0.5" style={{ top: '-0.6em' }}>
              {APP_CONFIG.BRAND_SYMBOL}
            </sup>
          </Link>

          {/* Desktop Menu Items */}
          <div className="hidden md:flex items-center space-x-10">
            {menuItems.map((item) => {
              const active = isItemActive(item.href);
              return (
                <Link
                  key={item.label}
                  to={item.href}
                  id={`nav-link-${item.label.toLowerCase().replace(/\s+/g, '-')}`}
                  className={`text-sm font-sans transition-colors duration-200 ${
                    active
                      ? 'text-[#000000] font-medium'
                      : 'text-[#6F6F6F] hover:text-[#000000]'
                  }`}
                >
                  {item.label}
                </Link>
              );
            })}
          </div>

          {/* Desktop CTA Button */}
          <div className="hidden md:block">
            <CtaButton
              label="Begin Journey"
              className="px-6 py-2.5 text-sm font-sans font-medium"
            />
          </div>

          {/* Mobile Hamburger Toggle */}
          <div className="md:hidden flex items-center">
            <button
              type="button"
              id="mobile-menu-toggle"
              aria-label="Toggle Navigation Menu"
              aria-expanded={mobileMenuOpen}
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 text-[#000000] hover:text-[#6F6F6F] transition-colors focus:outline-none cursor-pointer"
            >
              <svg
                className="w-6 h-6"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                {mobileMenuOpen ? (
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={1.8}
                    d="M6 18L18 6M6 6l12 12"
                  />
                ) : (
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={1.8}
                    d="M4 7h16M4 12h16M4 17h16"
                  />
                )}
              </svg>
            </button>
          </div>
        </nav>
      </header>

      {/* Mobile Drawer Overlay */}
      <MenuOverlay isOpen={mobileMenuOpen} onClose={() => setMobileMenuOpen(false)} />
    </>
  );
};
