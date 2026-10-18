"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useCallback, useEffect, useRef, useState } from "react";
import { AnimatePresence, useMotionValueEvent, useScroll } from "motion/react";
import * as m from "motion/react-m";
import { GET_STARTED_URL, NAV_LINKS, SIGN_IN_URL } from "@/lib/site";
import { Logo } from "@/components/Logo";

const ease = [0.16, 1, 0.3, 1] as const;

export function Navbar() {
  const pathname = usePathname();
  const { scrollY } = useScroll();
  const [scrolled, setScrolled] = useState(false);
  const [hidden, setHidden] = useState(false);
  const [open, setOpen] = useState(false);
  const [focusWithin, setFocusWithin] = useState(false);
  const toggleRef = useRef<HTMLButtonElement>(null);

  // Shrink after the first screenful; hide while scrolling down, return on up.
  useMotionValueEvent(scrollY, "change", (y) => {
    const prev = scrollY.getPrevious() ?? 0;
    setScrolled(y > 24);
    if (y < 120) setHidden(false);
    else if (y > prev + 4) setHidden(true);
    else if (y < prev - 4) setHidden(false);
  });

  const close = useCallback(() => {
    setOpen(false);
    requestAnimationFrame(() => toggleRef.current?.focus());
  }, []);

  // Route change closes the menu.
  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect -- reacting to navigation
    setOpen(false);
  }, [pathname]);

  // Lock page scroll (native + Lenis) while the overlay is open.
  useEffect(() => {
    if (!open) return;
    const root = document.documentElement;
    const prev = root.style.overflow;
    root.style.overflow = "hidden";
    window.dispatchEvent(new Event("heymey:scroll-lock"));
    return () => {
      root.style.overflow = prev;
      window.dispatchEvent(new Event("heymey:scroll-unlock"));
    };
  }, [open]);

  const isActive = (href: string) => pathname === href || pathname.startsWith(href + "/");
  // Never hide while the menu is open or while a keyboard user is inside the nav.
  const visible = !hidden || open || focusWithin;

  return (
    <header
      className="pointer-events-none fixed inset-x-0 top-0 z-50 flex justify-center px-3 pt-3"
      onFocus={() => setFocusWithin(true)}
      onBlur={(e) => {
        if (!e.currentTarget.contains(e.relatedTarget as Node)) setFocusWithin(false);
      }}
    >
      <m.nav
        aria-label="Main"
        initial={{ y: -24, opacity: 0 }}
        animate={{ y: visible ? 0 : -110, opacity: 1 }}
        transition={{ duration: 0.5, ease }}
        className={[
          "pointer-events-auto flex w-full max-w-[860px] items-center justify-between gap-2 rounded-full border transition-[padding,background-color,backdrop-filter,border-color] duration-300",
          "supports-[backdrop-filter]:backdrop-blur-md",
          scrolled
            ? "border-white/15 bg-black/70 py-1.5 pl-4 pr-1.5 supports-[backdrop-filter]:bg-black/45 supports-[backdrop-filter]:backdrop-blur-xl"
            : "border-white/10 bg-black/80 py-2 pl-5 pr-2 supports-[backdrop-filter]:bg-white/[0.04]",
        ].join(" ")}
      >
        <Link href="/" aria-label="HeyMey home" className="flex min-h-11 items-center gap-2 rounded-full pr-2">
          <Logo size={24} />
          <span className="text-[1.05rem] font-bold tracking-tight text-white">HeyMey</span>
        </Link>

        <ul className="hidden items-center gap-1 md:flex">
          {NAV_LINKS.map(({ href, label }) => {
            const active = isActive(href);
            return (
              <li key={href} className="relative">
                <Link
                  href={href}
                  aria-current={active ? "page" : undefined}
                  className={`relative z-10 flex min-h-11 items-center rounded-full px-4 text-[0.9rem] font-medium transition-colors ${
                    active ? "text-white" : "text-white/65 hover:text-white"
                  }`}
                >
                  {label}
                </Link>
                {active && (
                  <m.span
                    layoutId="nav-active"
                    aria-hidden
                    className="absolute inset-y-1 inset-x-0 rounded-full bg-white/10 ring-1 ring-white/15"
                    transition={{ type: "spring", stiffness: 420, damping: 34 }}
                  />
                )}
              </li>
            );
          })}
        </ul>

        <div className="flex items-center gap-1">
          <a
            href={SIGN_IN_URL}
            className="hidden min-h-11 items-center rounded-full px-3 text-[0.9rem] text-white/65 transition-colors hover:text-white sm:flex"
          >
            Sign in
          </a>
          <m.a
            href={GET_STARTED_URL}
            whileHover={{ scale: 1.03 }}
            whileTap={{ scale: 0.97 }}
            className="grad-border hidden min-h-11 items-center gap-1.5 rounded-full px-5 text-[0.9rem] font-semibold text-black [--grad-fill:#fff] sm:flex"
          >
            Get Started <span aria-hidden>→</span>
          </m.a>
          <button
            ref={toggleRef}
            type="button"
            aria-label={open ? "Close menu" : "Open menu"}
            aria-expanded={open}
            aria-controls="mobile-menu"
            onClick={() => setOpen((v) => !v)}
            className="flex size-11 items-center justify-center rounded-full border border-white/15 text-white md:hidden"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" aria-hidden>
              <line x1="4" y1="8" x2="20" y2="8" />
              <line x1="4" y1="16" x2="20" y2="16" />
            </svg>
          </button>
        </div>
      </m.nav>

      <AnimatePresence>{open && <MobileMenu onClose={close} isActive={isActive} />}</AnimatePresence>
    </header>
  );
}

function MobileMenu({ onClose, isActive }: { onClose: () => void; isActive: (href: string) => boolean }) {
  const panelRef = useRef<HTMLDivElement>(null);

  // Focus trap + Esc to close.
  useEffect(() => {
    const panel = panelRef.current;
    if (!panel) return;
    const focusables = () =>
      Array.from(panel.querySelectorAll<HTMLElement>("a[href], button:not([disabled])"));
    focusables()[0]?.focus();
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        e.preventDefault();
        onClose();
        return;
      }
      if (e.key !== "Tab") return;
      const items = focusables();
      const first = items[0];
      const last = items[items.length - 1];
      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    };
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [onClose]);

  const items = [...NAV_LINKS, { href: SIGN_IN_URL, label: "Sign in" }];

  return (
    <m.div
      id="mobile-menu"
      ref={panelRef}
      role="dialog"
      aria-modal="true"
      aria-label="Menu"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.25 }}
      className="pointer-events-auto fixed inset-0 z-[60] flex h-[100dvh] flex-col bg-black/95 px-6 pb-10 pt-6 backdrop-blur-xl"
    >
      <div className="flex items-center justify-between">
        <span className="flex items-center gap-2 text-lg font-bold">
          <Logo size={24} /> HeyMey
        </span>
        <button
          type="button"
          onClick={onClose}
          aria-label="Close menu"
          className="flex size-11 items-center justify-center rounded-full border border-white/15 text-2xl leading-none"
        >
          <span aria-hidden>×</span>
        </button>
      </div>

      <m.ul
        className="mt-12 flex flex-col gap-2"
        initial="hidden"
        animate="show"
        variants={{ show: { transition: { staggerChildren: 0.06, delayChildren: 0.05 } } }}
      >
        {items.map(({ href, label }) => {
          const external = href.startsWith("http");
          const cls = `flex min-h-14 items-center font-[family-name:var(--font-display)] text-[clamp(2.25rem,9vw,3.25rem)] leading-none ${
            !external && isActive(href) ? "text-mint-300" : "text-white"
          }`;
          return (
            <m.li
              key={href}
              variants={{ hidden: { opacity: 0, y: 24 }, show: { opacity: 1, y: 0, transition: { duration: 0.5, ease } } }}
            >
              {external ? (
                <a href={href} className={cls}>
                  {label}
                </a>
              ) : (
                <Link href={href} className={cls} onClick={onClose} aria-current={isActive(href) ? "page" : undefined}>
                  {label}
                </Link>
              )}
            </m.li>
          );
        })}
      </m.ul>

      <m.a
        href={GET_STARTED_URL}
        initial={{ opacity: 0, y: 16 }}
        animate={{ opacity: 1, y: 0, transition: { delay: 0.35, duration: 0.5, ease } }}
        className="grad-border mt-auto flex min-h-14 items-center justify-center rounded-full text-lg font-semibold text-black [--grad-fill:#fff]"
      >
        Get Started →
      </m.a>
    </m.div>
  );
}
