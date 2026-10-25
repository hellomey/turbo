"use client";

import React from "react";

export default function Navbar() {
  return (
    <div className="c-nav" data-nav-container="">
      <div className="d-nav show-desktop-tab">
        <div className="d-nav__left">
          <a href="#" className="d-nav__logo" aria-label="HeyMey Home">
            <img src="/wordmark.svg" alt="HeyMey Logo" height={32} style={{ height: "32px", width: "auto", display: "block" }} />
          </a>
        </div>

        <div className="d-nav__center">
          <div className="d-nav__links">
            <a href="#how" className="d-nav__link">
              How it works
            </a>
            <a href="#styles" className="d-nav__link">
              Study Map
            </a>
            <a href="#faq" className="d-nav__link">
              FAQs
            </a>
          </div>
        </div>

        <div className="d-nav__right">
          <a
            href="#cta"
            className="c-button--semi"
          >
            <span className="c-button__text">Get App</span>
          </a>
        </div>
      </div>

      <div className="m-nav show-tablet" data-nav="">
        <div className="m-nav__top">
          <div className="m-nav__logo">
            <a href="#" aria-label="HeyMey Home">
              <img src="/wordmark.svg" alt="HeyMey Logo" height={26} style={{ height: "26px", width: "auto", display: "block" }} />
            </a>
          </div>
          <div className="m-nav__right">
            <a href="#cta" className="m-nav__right__button">
              <span className="c-button--semi">Get App</span>
            </a>
            <button
              className="m-nav__right__ham hamburger-nav__toggle"
              data-nav-toggle=""
              aria-label="Toggle Navigation Menu"
            >
              <div className="hamburger-nav__toggle-bar"></div>
              <div className="hamburger-nav__toggle-bar"></div>
            </button>
          </div>
        </div>
        <div className="m-nav__bottom">
          <a href="#how" className="m-nav__link">
            <span>How it works</span>
          </a>
          <a href="#styles" className="m-nav__link">
            <span>Study Map</span>
          </a>
          <a href="#faq" className="m-nav__link">
            <span>FAQs</span>
          </a>
        </div>
      </div>
    </div>
  );
}
