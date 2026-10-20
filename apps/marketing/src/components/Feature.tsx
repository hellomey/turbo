/** Two-column feature row used by content pages. */
export function Feature({
  id,
  eyebrow,
  title,
  children,
}: {
  id?: string;
  eyebrow: string;
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section id={id} aria-labelledby={id ? `${id}-title` : undefined} className="scroll-mt-28 border-t border-line">
      <div className="mx-auto grid max-w-6xl gap-6 px-5 py-[clamp(3rem,8svh,5.5rem)] sm:px-8 md:grid-cols-[0.9fr_1.1fr] md:gap-16">
        <div>
          <p className="t-eyebrow">{eyebrow}</p>
          <h2 id={id ? `${id}-title` : undefined} className="t-h2 mt-3 text-balance">
            {title}
          </h2>
        </div>
        <div className="space-y-4 text-[1.08rem] leading-relaxed text-ink-2 md:pt-8">{children}</div>
      </div>
    </section>
  );
}
