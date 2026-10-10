import { useState } from 'react';

export const Navbar = () => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const menuItems = [
    { label: 'Home', href: '#home', active: true },
    { label: 'Studio', href: '#studio', active: false },
    { label: 'About', href: '#about', active: false },
    { label: 'Journal', href: '#journal', active: false },
    { label: 'Reach Us', href: '#reach-us', active: false },
  ];

  return (
    <header className="relative z-10 w-full">
      <nav
        aria-label="Main Navigation"
        className="flex items-center justify-between px-8 py-6 max-w-7xl mx-auto"
      >
        {/* Logo: "HeyMey®" (with registered trademark symbol as superscript) */}
        <a
          href="#"
          id="nav-logo"
          className="font-serif text-3xl tracking-tight text-[#000000] inline-flex items-baseline select-none transition-opacity hover:opacity-80"
        >
          <span>HeyMey</span>
          <sup className="text-sm font-normal ml-0.5" style={{ top: '-0.6em' }}>
            ®
          </sup>
        </a>

        {/* Desktop Menu Items */}
        <div className="hidden md:flex items-center space-x-10">
          {menuItems.map((item) => (
            <a
              key={item.label}
              href={item.href}
              id={`nav-link-${item.label.toLowerCase().replace(/\s+/g, '-')}`}
              className={`text-sm font-sans transition-colors duration-200 ${
                item.active
                  ? 'text-[#000000] font-medium'
                  : 'text-[#6F6F6F] hover:text-[#000000]'
              }`}
            >
              {item.label}
            </a>
          ))}
        </div>

        {/* Desktop CTA Button */}
        <div className="hidden md:block">
          <button
            type="button"
            id="nav-cta-button"
            className="rounded-full px-6 py-2.5 text-sm font-sans font-medium bg-[#000000] text-white transition-all duration-200 hover:scale-[1.03] active:scale-[0.98] cursor-pointer shadow-sm"
          >
            Begin Journey
          </button>
        </div>

        {/* Mobile Hamburger Toggle */}
        <div className="md:hidden flex items-center">
          <button
            type="button"
            id="mobile-menu-toggle"
            aria-label="Toggle Navigation Menu"
            aria-expanded={mobileMenuOpen}
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="p-2 text-[#000000] hover:text-[#6F6F6F] transition-colors focus:outline-none"
          >
            <svg
              className="w-6 h-6"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
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

      {/* Mobile Dropdown Menu with Glassmorphic styling */}
      {mobileMenuOpen && (
        <div
          id="mobile-menu-drawer"
          className="md:hidden px-8 py-6 mx-4 rounded-2xl bg-white/90 backdrop-blur-md border border-neutral-200/60 shadow-lg flex flex-col space-y-4 animate-fade-rise"
        >
          {menuItems.map((item) => (
            <a
              key={item.label}
              href={item.href}
              onClick={() => setMobileMenuOpen(false)}
              className={`text-base font-sans py-1 transition-colors ${
                item.active
                  ? 'text-[#000000] font-medium'
                  : 'text-[#6F6F6F] hover:text-[#000000]'
              }`}
            >
              {item.label}
            </a>
          ))}
          <div className="pt-2">
            <button
              type="button"
              id="mobile-nav-cta-button"
              onClick={() => setMobileMenuOpen(false)}
              className="w-full rounded-full px-6 py-2.5 text-sm font-sans font-medium bg-[#000000] text-white transition-all duration-200 hover:scale-[1.03] cursor-pointer"
            >
              Begin Journey
            </button>
          </div>
        </div>
      )}
    </header>
  );
};
