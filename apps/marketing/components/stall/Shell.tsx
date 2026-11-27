import Link from "next/link";
import "./stall.css";

export function StallShell({ children }: { children: React.ReactNode }) {
  return (
    <main className="st">
      <div className="st-wrap">
        <Link href="/" className="st-brand" aria-label="HeyMey home">
          <svg width="34" height="34" viewBox="0 0 34 34" aria-hidden="true">
            <circle cx="17" cy="13" r="10" fill="#f5c518" stroke="#111" strokeWidth="3" />
            <rect x="11" y="23" width="12" height="9" fill="#d7261e" stroke="#111" strokeWidth="3" />
          </svg>
          HeyMey
        </Link>
        <div className="st-shapes" aria-hidden="true">
          <span className="c" />
          <span className="s" />
          <span className="t" />
        </div>
        {children}
      </div>
    </main>
  );
}

export function DraftNotice() {
  return (
    <div className="st-draft" role="note">
      <p>
        <b>Draft, pending legal review.</b> This page is not final. The reviewed
        text will replace it before HeyMey takes any payment.
      </p>
    </div>
  );
}
