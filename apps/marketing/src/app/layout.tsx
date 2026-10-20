import type { Metadata, Viewport } from "next";
import { Inter, Instrument_Serif, Noto_Sans_Tamil } from "next/font/google";
import "./globals.css";
import { Providers } from "@/components/providers/Providers";
import { Navbar } from "@/components/nav/Navbar";
import { Footer } from "@/components/Footer";

// Same faces the hero used before (Inter with optical sizing, Noto Sans Tamil),
// now self-hosted by next/font instead of a render-blocking Google CSS request.
const inter = Inter({ subsets: ["latin"], axes: ["opsz"], variable: "--font-inter", display: "swap" });
// Static instances like the original Google Fonts request, so the hero badge keeps
// identical metrics. Only the weights the site uses (400 text, 700 badge/Kural).
const tamil = Noto_Sans_Tamil({
  subsets: ["tamil"],
  weight: ["400", "700"],
  variable: "--font-noto-tamil",
  display: "swap",
});
// Editorial display face for the new sections.
// Below the fold only: not preloaded, so it never competes with the hero.
const serif = Instrument_Serif({ subsets: ["latin"], weight: "400", style: ["normal", "italic"], variable: "--font-serif", display: "swap", preload: false });

export const metadata: Metadata = {
  metadataBase: new URL("https://heymey.app"),
  title: { default: "HeyMey™ — Truth beneath the noise", template: "%s · HeyMey™" },
  description:
    "An honest daily companion for TNPSC, TET, SET, and all Tamil Nadu government exam aspirants: where you truly stand, what to do today, in Tamil and English.",
  openGraph: { siteName: "HeyMey Technologies Pvt Ltd", type: "website", locale: "en_IN" },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
  themeColor: "#000000",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${inter.variable} ${tamil.variable} ${serif.variable}`}>
      <body>
        <a href="#main" className="skip-link">
          Skip to content
        </a>
        <Providers>
          <Navbar />
          <main id="main" tabIndex={-1} className="outline-none">
            {children}
          </main>
          <Footer />
        </Providers>
      </body>
    </html>
  );
}
