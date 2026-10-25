"use client";

import React from "react";

const NIGHT =
  "https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20261021_093217_cc690198-ad8c-4127-8734-8485bd878351.png";

export default function Footer() {
  return (
    <section className="cta" id="cta">
      <div className="sq-field" data-count="16" />

      <div className="cta-img">
        <img
          id="ctaImg"
          alt="Moonlit cherry blossom valley"
          src={NIGHT}
        />
      </div>

      <div className="petals" id="petals" />

      <div className="cta-card" id="ctaCard">
        <h2
          className="cta-title split"
          style={{ fontSize: "clamp(24px, 2.9vw, 38px)" }}
        >
          Every hour of preparation is <em>gold.</em>
        </h2>
        <p className="cta-desc reveal">
          Light your first Study Map lamp in minutes and see your readiness soar on day one.
        </p>
        <a className="btn-petal reveal" href="#cta">
          <span>Start Free Today</span>
          <svg width="15" height="15" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M6 3.5L10.5 8L6 12.5" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </a>
      </div>

      {/* 4e. Transparent Glassmorphism Footer directly on the background */}
      <footer id="footer" className="cta-glass-footer">
        {/* Authentic HeyMey Brand Mark */}
        <div className="f-logo-wrap">
          <a href="#" aria-label="HeyMey Home" style={{ display: "inline-block" }}>
            <img
              src="/logo-mark-light.svg"
              alt="HeyMey Brand Mark"
              className="f-logo"
              style={{ width: "80px", height: "auto", display: "block" }}
            />
          </a>
        </div>

        {/* Center Group: Navigation Links & Copyright */}
        <div className="f-center">
          <nav className="f-links" aria-label="Footer Navigation">
            <a href="#how">How It Works</a>
            <a href="#styles">Study Map</a>
            <a href="#faq">Privacy Policy</a>
            <a href="#faq">Terms</a>
          </nav>
          <div className="f-copy">
            © 2026 HeyMey Technologies Pvt Ltd. All rights reserved.
          </div>
        </div>

        {/* Socials */}
        <div className="f-social">
          <a
            href="https://x.com"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="X (Twitter)"
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
              <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
            </svg>
          </a>
          <a
            href="https://instagram.com"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="Instagram"
          >
            <svg
              width="18"
              height="18"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <rect x="2" y="2" width="20" height="20" rx="5" ry="5" />
              <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" />
              <line x1="17.5" y1="6.5" x2="17.51" y2="6.5" />
            </svg>
          </a>
          <a
            href="mailto:contact@heymey.app"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="Email"
          >
            <svg
              width="18"
              height="18"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
              <polyline points="22,6 12,13 2,6" />
            </svg>
          </a>
        </div>
      </footer>
    </section>
  );
}
