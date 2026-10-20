// Single source of truth for links and copy shared across pages.

/** The product app. Dev: http://localhost:4567 (.env.development). */
export const APP_URL = (process.env.NEXT_PUBLIC_APP_URL ?? "https://app.heymey.in").replace(/\/$/, "");
export const SIGN_IN_URL = `${APP_URL}/login`;
export const GET_STARTED_URL = `${APP_URL}/login`;

export const NAV_LINKS = [
  { href: "/product", label: "Product" },
  { href: "/exams", label: "Exams" },
  { href: "/about", label: "About" },
  { href: "/pricing", label: "Pricing" },
] as const;

export const FOOTER_GROUPS = [
  {
    title: "Product",
    links: [
      { href: "/product", label: "Overview" },
      { href: "/product#daily-flash", label: "Daily Flash" },
      { href: "/creators", label: "For Creators" },
      { href: "/pricing", label: "Pricing" },
    ],
  },
  {
    title: "Company",
    links: [
      { href: "/about", label: "About" },
      { href: "/exams", label: "Exams" },
      { href: "/contact", label: "Contact" },
    ],
  },
  {
    title: "Legal",
    links: [
      { href: "/legal/privacy", label: "Privacy" },
      { href: "/legal/terms", label: "Terms" },
      { href: "/legal/refunds", label: "Refunds" },
    ],
  },
] as const;

export const INDEPENDENCE_LINE =
  "HeyMey Technologies Pvt Ltd is independent and is not affiliated with TNPSC, TRB (TET), SET, or the Government of Tamil Nadu.";

/**
 * Verified figures only. Each one is taken from a TNPSC press release
 * (primary source). Figures that could not be verified from TNPSC were
 * dropped: "about 20 lakh applied" and "13,89,738 appeared".
 */
export const TNPSC_SOURCES = {
  pr44: {
    label: "TNPSC Press Release No. 44/2025 (25.04.2025)",
    url: "https://tnpsc.gov.in/Document/PressEnglish/Press%20Release_25.04.2025.pdf",
  },
  pr132: {
    label: "TNPSC Press Release No. 132/2025 (26.09.2025)",
    url: "https://www.tnpsc.gov.in/Document/PressEnglish/Press%20Release%2026.09.2025.pdf",
  },
} as const;
