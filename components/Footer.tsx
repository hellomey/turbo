"use client";

import React from "react";

export default function Footer() {
  return (
    <footer className="c-footer" data-footer="">
      <div className="c-footer__top">
        <canvas
          data-footer-canvas=""
          data-artboard="Main - Desktop"
          data-state-machines="SM - Footer"
          className="show-desktop"
          width="1905"
          height="800"
        ></canvas>
        <canvas
          data-footer-canvas=""
          data-artboard="Main - Mobile"
          data-state-machines="SM - Footer"
          className="show-mobile"
          width="0"
          height="0"
        ></canvas>

        <div className="c-footer__top__content">
          <h3 className="c-styles__title">Let’s Light Your Gold Lamp</h3>
          <p className="c-styles__desc">
            Bring the commitment. We’ll bring the gamified mastery.
          </p>
          <a
            href="#pricing"
            className="c-button"
          >
            <span className="c-button__text">Start Free Today</span>
          </a>
        </div>
      </div>

      <div className="c-footer__bottom">
        <div className="c-footer__bottom__inner">
          <div className="c-footer__bottom__top">
            <div className="c-footer__bottom__top__left">
              <div className="c-footer__bottom__top__logo">
                <img loading="lazy" src="/logomark.svg" alt="HeyMey Logo" height={40} />
              </div>
              <div className="c-footer__bottom__top__word">
                Prepare like a game • HeyMey Technologies
              </div>
            </div>
          </div>

          <div className="c-footer__bottom__bottom">
            <div className="c-footer__credits">© HeyMey 2026. All rights reserved.</div>

            <div className="c-footer__legal">
              <a href="#how" className="c-footer__link">
                How It Works
              </a>
              <a href="#styles" className="c-footer__link">
                Study Map
              </a>
              <a href="#pricing" className="c-footer__link">
                Pricing
              </a>
              <a href="#faq" className="c-footer__link">
                Privacy Policy
              </a>
            </div>

            <div className="c-footer__socials">
              <a
                href="https://instagram.com"
                target="_blank"
                rel="noopener noreferrer"
                className="c-footer__social"
                aria-label="Instagram"
              >
                <img loading="lazy" src="/images/instagram.svg" alt="Instagram" />
              </a>
              <a
                href="mailto:contact@heymey.app"
                target="_blank"
                rel="noopener noreferrer"
                className="c-footer__social"
                aria-label="Email"
              >
                <img loading="lazy" src="/images/mail.svg" alt="Mail" />
              </a>
              <a
                href="https://x.com"
                target="_blank"
                rel="noopener noreferrer"
                className="c-footer__social"
                aria-label="X (Twitter)"
              >
                <img loading="lazy" src="/images/x.svg" alt="X" />
              </a>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}
