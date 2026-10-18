import Link from "next/link";
import { FOOTER_GROUPS, INDEPENDENCE_LINE } from "@/lib/site";
import { Logo } from "@/components/Logo";

export function Footer() {
  return (
    <footer className="relative border-t border-line bg-black px-5 pb-10 pt-16 sm:px-8">
      <div className="mx-auto grid max-w-6xl gap-12 md:grid-cols-[1.4fr_repeat(3,1fr)]">
        <div>
          <Link href="/" className="inline-flex min-h-11 items-center gap-2 text-lg font-bold">
            <Logo size={24} /> HeyMey<span className="align-super text-xs">™</span>
          </Link>
          <p className="mt-3 max-w-xs text-sm leading-relaxed text-ink-2">
            Truth beneath the noise. An honest daily companion for TNPSC, TET, SET, and all Tamil Nadu government exam aspirants, in Tamil and English.
          </p>
        </div>
        {FOOTER_GROUPS.map((group) => (
          <nav key={group.title} aria-label={group.title}>
            <h2 className="text-xs font-semibold uppercase tracking-[0.18em] text-ink-3">{group.title}</h2>
            <ul className="mt-3 space-y-1">
              {group.links.map((l) => (
                <li key={l.href}>
                  <Link href={l.href} className="inline-flex min-h-11 min-w-11 items-center text-[0.95rem] text-ink-2 transition-colors hover:text-white">
                    {l.label}
                  </Link>
                </li>
              ))}
            </ul>
          </nav>
        ))}
      </div>
      <div className="mx-auto mt-14 flex max-w-6xl flex-col gap-3 border-t border-line pt-6 text-sm text-ink-3 sm:flex-row sm:items-center sm:justify-between">
        <p>{INDEPENDENCE_LINE}</p>
        <p>© {new Date().getFullYear()} HeyMey Technologies Pvt Ltd. All rights reserved.</p>
      </div>
    </footer>
  );
}
