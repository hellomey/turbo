import type { Metadata, Viewport } from "next";
import "./globals.css";

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#ffffff",
};

export const metadata: Metadata = {
  metadataBase: new URL("https://heymey.app"),
  title: "HeyMey — Gamified Government Exam Preparation",
  description:
    "HeyMey turns a 1–3 year government-exam preparation into a game you want to come back to. Progress your syllabus lamps, climb the Career Ladder, and win Squad Battles.",
  icons: {
    icon: "/favicon.svg",
  },
  openGraph: {
    title: "HeyMey — Gamified Government Exam Preparation",
    description:
      "HeyMey turns a 1–3 year government-exam preparation into a game you want to come back to. Syllabus lamps, Career Ladder, and Squad Battles for TNPSC aspirants.",
    url: "https://heymey.app/",
    siteName: "HeyMey",
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "HeyMey — Gamified Government Exam Preparation",
    description:
      "HeyMey turns a 1–3 year government-exam preparation into a game you want to come back to. Syllabus lamps, Career Ladder, and Squad Battles for TNPSC aspirants.",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="lenis">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin="anonymous"
        />
        <link
          href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Inter+Tight:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500&display=swap"
          rel="stylesheet"
        />
      </head>
      <body>{children}</body>
    </html>
  );
}
